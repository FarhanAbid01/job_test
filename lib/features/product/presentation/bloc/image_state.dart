part of 'image_bloc.dart';


// image_state.dart


abstract class ImageState extends Equatable {
  final List<ImageEntity> images;
  final bool hasReachedMax;
  final String query;

  const ImageState({
    required this.images,
    required this.hasReachedMax,
    required this.query,
  });

  @override
  List<Object?> get props => [images, hasReachedMax, query];
}

class ImageInitial extends ImageState {
  ImageInitial() : super(images: [], hasReachedMax: false, query: '');
}

class ImageLoading extends ImageState {
  ImageLoading({required String query})
      : super(images: [], hasReachedMax: false, query: query);
}

class ImageLoaded extends ImageState {
  const ImageLoaded({
    required List<ImageEntity> images,
    required bool hasReachedMax,
    required String query,
  }) : super(images: images, hasReachedMax: hasReachedMax, query: query);

  ImageLoaded copyWith({
    List<ImageEntity>? images,
    bool? hasReachedMax,
    String? query,
  }) {
    return ImageLoaded(
      images: images ?? this.images,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [images, hasReachedMax, query];
}

class ImageError extends ImageState {
  final String message;

  ImageError(this.message, {required String query})
      : super(images: [], hasReachedMax: true, query: query);

  @override
  List<Object?> get props => [message, query];
}
