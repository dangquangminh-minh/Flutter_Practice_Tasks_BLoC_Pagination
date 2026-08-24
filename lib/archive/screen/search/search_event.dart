abstract class SearchEvent {}

//khi ng dùng đang gõ phím
class SearchKeywordChanged extends SearchEvent {
  final String keyword;
  SearchKeywordChanged(this.keyword);
}

// khi cuộn xuống cuối ds
class LoadMoreSearchResults extends SearchEvent {}