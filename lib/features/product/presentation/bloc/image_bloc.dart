import 'package:equatable/equatable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:piecyfer_test/features/product/domain/entities/image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:piecyfer_test/features/product/domain/usecases/get_all_images.dart';

import '../../../../core/error/failures.dart';

part 'image_event.dart';
part 'image_state.dart';



class ImageBloc extends Bloc<ImageEvent, ImageState> {
  final GetAllImages _getAllImages;
  final InternetConnection _internetConnection; // Dependency for checking internet connection

  ImageBloc({
    required GetAllImages getAllImages,
    required InternetConnection internetConnection, // Pass the internet connection checker as a dependency
  })  : _getAllImages = getAllImages,
        _internetConnection = internetConnection,
        super(ImageInitial()) {
    on<FetchImages>(_onFetchImages);
    on<LoadMoreImages>(_onLoadMoreImages);
    on<DebouncedSearch>(_onDebounceSearch);
  }

  // Fetch initial images or new search results
  Future<void> _onFetchImages(FetchImages event, Emitter<ImageState> emit) async {
    // Check internet connection before fetching images
    if (!await _internetConnection.hasInternetAccess) {
      print('here');
      emit(ImageError('No internet connection available.', query: event.query));
      return;
    }

    emit(ImageLoading(query: event.query)); // Store query in loading state

    // Reset pagination and search
    final Either<Failure, List<ImageEntity>> result = await _getAllImages(
      ImageParams(query: event.query, limit: event.limit, page: event.page),
    );

    result.fold(
          (failure) => emit(ImageError(failure.message, query: event.query)),
          (images) {
        if (images.isEmpty) {
          emit(ImageError('No images found.', query: event.query));
        } else {
          emit(ImageLoaded(
            images: images,
            hasReachedMax: images.length < event.limit,
            query: event.query, // Include query in the state
          ));
        }
      },
    );
  }

  // Load more images for infinite scroll pagination
  Future<void> _onLoadMoreImages(LoadMoreImages event, Emitter<ImageState> emit) async {
    final currentState = state;

    // Check internet connection before loading more images
    if (!await _internetConnection.hasInternetAccess) {
      emit(ImageError('No internet connection available.', query: currentState.query));
      return;
    }

    if (currentState is ImageLoaded && !currentState.hasReachedMax) {
      final Either<Failure, List<ImageEntity>> result = await _getAllImages(
        ImageParams(query: currentState.query, limit: event.limit, page: event.page),
      );

      result.fold(
            (failure) => emit(ImageError(failure.message, query: currentState.query)),
            (newImages) {
          if (newImages.isEmpty) {
            emit(currentState.copyWith(hasReachedMax: true));
          } else {
            emit(
              ImageLoaded(
                images: currentState.images + newImages,
                hasReachedMax: newImages.length < event.limit,
                query: currentState.query, // Maintain the same query
              ),
            );
          }
        },
      );
    }
  }

  void _onDebounceSearch(DebouncedSearch event, Emitter<ImageState> emit) {
    emit(ImageLoading(query: event.query));
  }
}

