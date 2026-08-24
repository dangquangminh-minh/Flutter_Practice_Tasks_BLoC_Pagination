import 'package:equatable/equatable.dart';

abstract class PaginationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchInitialData extends PaginationEvent {}// giống F5 , tải lại trang

class LoadMoreData extends PaginationEvent {}// event khi ng dùng kéo cuộn xuống cuối màn hình