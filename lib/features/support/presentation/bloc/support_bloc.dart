import 'package:bai_01/features/support/data/repositories/support_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:bai_01/features/support/domain/models/support_ticket_model.dart';
import 'package:bai_01/features/support/presentation/bloc/support_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bai_01/features/support/presentation/bloc/support_event.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart'; 

class SupportBloc extends Bloc<SupportEvent, SupportState> {
  final SupportRepository repository;

  SupportBloc(this.repository) : super(SupportInitial()) {
    
    // nếu lỗi thì giữ dl cũ
    on<LoadTicketsEvent>((event, emit) async {
      //chỉ load khi chưa có data
      if (state is! SupportLoaded) {
        emit(SupportLoading()); 
      }
      try {
        final tickets = await repository.getTicketsByUserId(event.userId);
        
        // lấy ds trạng thái đã lưu dưới local lên
        final localStatuses = repository.getAllSavedStatuses();
        
        if (state is SupportLoaded) {
          // nếu có data trc đó, cập nhật đè ds ticket VÀ trạng thái lên
          emit((state as SupportLoaded).copyWith(
            tickets: tickets,
            ticketStatuses: localStatuses, 
          ));
        } else {
          // load lần đầu thành công
          emit(SupportLoaded(
            tickets, 
            ticketStatuses: localStatuses, 
          ));
        }
      } catch (e) {
        if (state is SupportLoaded) {
          final currentState = state as SupportLoaded;
          emit(currentState.copyWith(errorMessage: 'Mất kết nối! Vui lòng thử lại.'));
          emit(currentState.copyWith(errorMessage: null));
        } else {
          emit(SupportError('Không thể tải dữ liệu. Bấm để thử lại.')); 
        }
      }
    });

    //tạo ticket ms
    on<AddTicketEvent>(
      (event, emit) async {
        if (state is SupportLoaded) {
          final currentState = state as SupportLoaded;
          final currentTickets = currentState.tickets;
          final currentStatuses = currentState.ticketStatuses;

          final localTicket = SupportTicket( 
            id: DateTime.now().millisecondsSinceEpoch,
            title: event.title,
            body: event.body,
            userId: event.userId,
          );

          final updatedTickets = [localTicket, ...currentTickets];
          final updatedStatuses = Map<int, String>.from(currentStatuses);
          updatedStatuses[localTicket.id] = 'Open';

          emit(currentState.copyWith(
            tickets: updatedTickets,
            ticketStatuses: updatedStatuses,
          ));

          try {
            await repository.addTicket(event.title, event.body, event.userId);
          } catch (e) {
            debugPrint('[SupportBloc] addTicket API fallback triggered: $e');
            repository.saveTicketToLocalCache(localTicket);
            // Báo cho người dùng biết là đã lưu offline
            emit(currentState.copyWith(errorMessage: 'Đã lưu ticket ngoại tuyến (Offline)'));
            emit(currentState.copyWith(errorMessage: null));
          }
        }
      },
      transformer: droppable(), 
    );

    // xử lý load cmt
    on<LoadTicketCommentsEvent>((event, emit) async {
      final currentState = state;
      if (currentState is SupportLoaded) {
        try {
          final comments = await repository.getCommentsByPostId(event.ticketId);
          final updatedCommentsMap = Map<int, List<dynamic>>.from(currentState.commentsMap);
          updatedCommentsMap[event.ticketId] = comments;
          emit(currentState.copyWith(commentsMap: updatedCommentsMap));
        } catch (e) {
          emit(currentState.copyWith(errorMessage: 'Lỗi tải bình luận.'));
          emit(currentState.copyWith(errorMessage: null));
        }
      }
    });

    on<ChangeTicketStatusEvent>((event, emit) async {
      final currentState = state;
      if (currentState is SupportLoaded) {
        // khai báo lại biến newStatuses
        final newStatuses = Map<int, String>.from(currentState.ticketStatuses);
        newStatuses[event.ticketId] = event.newStatus;
        
        // khai báo lại biến currentTicket để lấy userId
        final currentTicket = currentState.tickets.firstWhere((t) => t.id == event.ticketId);

        // lưu xuống
        await repository.saveTicketLocalData(
          event.ticketId, 
          currentTicket.userId, 
          event.newStatus
        );

        //update ui
        emit(currentState.copyWith(ticketStatuses: newStatuses));
      }
    });

    // thêm cmt
    on<AddCommentEvent>(
      (event, emit) async {
        if (state is SupportLoaded) {
          final currentState = state as SupportLoaded;
          
          final updatedCommentsMap = Map<int, List<dynamic>>.from(currentState.commentsMap);
          final currentComments = List<dynamic>.from(updatedCommentsMap[event.ticketId] ?? []);

          try {
            final newComment = await repository.addComment(
              event.body,
              event.ticketId,
              event.userId,
            );
            currentComments.add(newComment);
          } catch (e) {
            final fakeComment = {
              'id': DateTime.now().millisecondsSinceEpoch,
              'body': event.body,
              'postId': event.ticketId,
              'user': {
                'id': event.userId,
                'username': 'Khách hàng',
              }
            };
            currentComments.add(fakeComment);
            emit(currentState.copyWith(errorMessage: 'Đã lưu bình luận ảo (Offline)'));
            emit(currentState.copyWith(errorMessage: null));
          }

          updatedCommentsMap[event.ticketId] = currentComments;
          emit(currentState.copyWith(commentsMap: updatedCommentsMap));
        }
      },
      transformer: droppable(), 
    );

    // update cmt
    on<UpdateCommentEvent>(
      (event, emit) async {
        final currentState = state;
        if (currentState is SupportLoaded) {
          final newCommentsMap = Map<int, List<dynamic>>.from(currentState.commentsMap);
          final currentComments = List<dynamic>.from(newCommentsMap[event.ticketId] ?? []);
          
          final index = currentComments.indexWhere((comment) => comment['id'] == event.commentId);
          
          if (index != -1) {
            final updatedComment = Map<String, dynamic>.from(currentComments[index]);
            updatedComment['body'] = event.newBody; 
            currentComments[index] = updatedComment;
            newCommentsMap[event.ticketId] = currentComments;

            emit(currentState.copyWith(commentsMap: newCommentsMap));           
          }
        }
      },
      transformer: droppable(),
    );

    // xóa cmt
    on<DeleteCommentEvent>(
      (event, emit) async {
        final currentState = state;
        if (currentState is SupportLoaded) {
          final newCommentsMap = Map<int, List<dynamic>>.from(currentState.commentsMap);
          final currentComments = List<dynamic>.from(newCommentsMap[event.ticketId] ?? []);
          
          currentComments.removeWhere((comment) => comment['id'] == event.commentId);
          newCommentsMap[event.ticketId] = currentComments;

          emit(currentState.copyWith(commentsMap: newCommentsMap));
        }
      },
      transformer: droppable(),
    );

    // sửa ticket
    on<UpdateTicketEvent>(
      (event, emit) async {
        final currentState = state;
        if (currentState is SupportLoaded) {
          try {
            await Future.delayed(const Duration(milliseconds: 500));
            final updatedTickets = currentState.tickets.map((ticket) {
              if (ticket.id == event.ticketId) {
                return SupportTicket(
                  id: ticket.id,
                  title: event.newTitle,
                  body: event.newBody,
                  userId: ticket.userId,
                );
              }
              return ticket;
            }).toList();
            emit(currentState.copyWith(tickets: updatedTickets));
          } catch (e) {
            emit(currentState.copyWith(errorMessage: 'Lỗi sửa vé hỗ trợ.'));
            emit(currentState.copyWith(errorMessage: null));
          }
        }
      },
      transformer: droppable(),
    );

    // xóa
    on<DeleteTicketEvent>(
      (event, emit) async {
        final currentState = state;
        if (currentState is SupportLoaded) {
          try {
            await Future.delayed(const Duration(milliseconds: 500));
            final updatedTickets = currentState.tickets
                .where((ticket) => ticket.id != event.ticketId)
                .toList();
            emit(currentState.copyWith(tickets: updatedTickets));
          } catch (e) {
            emit(currentState.copyWith(errorMessage: 'Lỗi xóa vé hỗ trợ.'));
            emit(currentState.copyWith(errorMessage: null));
          }
        }
      },
      transformer: droppable(),
    );
  }
}