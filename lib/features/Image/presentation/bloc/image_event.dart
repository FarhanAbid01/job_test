part of 'image_bloc.dart';





abstract class ImageEvent extends Equatable {
  const ImageEvent();

  @override
  List<Object?> get props => [];
}

class FetchImages extends ImageEvent {
  final String query;
  final int limit;
  final int page;

  const FetchImages({
    required this.query,
    required this.limit,
    required this.page,
  });

  @override
  List<Object?> get props => [query, limit, page];
}

class LoadMoreImages extends ImageEvent {
  final int limit;
  final int page;

  const LoadMoreImages({
    required this.limit,
    required this.page,
  });

  @override
  List<Object?> get props => [limit, page];
}
class DebouncedSearch extends ImageEvent {
  final String query;

  const DebouncedSearch({
    required this.query,
  });

  @override
  List<Object?> get props => [query];
}
