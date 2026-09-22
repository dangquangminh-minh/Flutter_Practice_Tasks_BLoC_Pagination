import 'package:bai_01/features/support/domain/models/support_ticket_model.dart';


abstract class SupportState {}

class SupportInitial extends SupportState {}

class SupportLoading extends SupportState {}

class SupportLoaded extends SupportState {
  final List<SupportTicket> tickets;
  final Map<int, List<dynamic>> commentsMap; // map chứa cmt theo id của ticket
  final Map<int, String> ticketStatuses;     // lưu trạng thái local
  final String? errorMessage; 

  SupportLoaded(
    this.tickets, {
    this.commentsMap = const {},
    this.ticketStatuses = const {},
    this.errorMessage,
  });


  SupportLoaded copyWith({
    List<SupportTicket>? tickets,
    Map<int, List<dynamic>>? commentsMap,
    Map<int, String>? ticketStatuses,
    String? errorMessage,
  }) {
    return SupportLoaded(
      tickets ?? this.tickets, 
      commentsMap: commentsMap ?? this.commentsMap,
      ticketStatuses: ticketStatuses ?? this.ticketStatuses,
      errorMessage: errorMessage,
    );
  }

  
}

class SupportError extends SupportState {
  final String message;

  SupportError(this.message);
}



