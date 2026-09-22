import 'package:bai_01/features/support/data/repositories/support_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bai_01/features/support/presentation/bloc/support_bloc.dart';
import 'package:bai_01/features/support/presentation/bloc/support_event.dart';
import 'package:bai_01/features/support/presentation/bloc/support_state.dart';

import 'package:bai_01/features/support/domain/models/support_ticket_model.dart';

// tạo mock cho repo
class MockSupportRepository extends Mock implements SupportRepository {}

void main() {
  late SupportBloc supportBloc;
  late MockSupportRepository mockRepository;

  // dl mồi để tét
  final dummyTicket = SupportTicket(
    id: 1,
    title: 'Lỗi nạp thẻ',
    body: 'Tôi không nạp được tiền',
    userId: 123,
  );

  setUp(() {
    mockRepository = MockSupportRepository();
    supportBloc = SupportBloc(mockRepository);
  });

  tearDown(() {
    supportBloc.close();
  });

  group('SupportBloc - Đổi Ticket Status Test', () {
    // Trạng thái ban đầu: Đã load thành công 1 vé có trạng thái là 'Open'
    final initialState = SupportLoaded(
      [dummyTicket],
      ticketStatuses: {1: 'Open'},
      commentsMap: const {},
    );

    blocTest<SupportBloc, SupportState>(
      'Cập nhật thành công trạng thái vé thành closed và lưu xuống Local',
      build: () {

        when(() => mockRepository.saveTicketLocalData(1, 123, 'closed'))
            .thenAnswer((_) async => Future.value());
            
        return supportBloc;
      },
      seed: () => initialState, 
      act: (bloc) => bloc.add(ChangeTicketStatusEvent(1, 'closed')),
      
      expect: () => [
        isA<SupportLoaded>().having(
          (state) => state.ticketStatuses[1],
          'trạng thái của vé số 1',
          'closed', 
        ),
      ],     
      verify: (_) {
        verify(() => mockRepository.saveTicketLocalData(1, 123, 'closed')).called(1);
      },
    );
  });
}