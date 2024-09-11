import 'package:equatable/equatable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:piecyfer_test/features/Image/domain/entities/image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:piecyfer_test/features/Image/domain/usecases/get_all_images.dart';

import '../../../../core/error/failures.dart';

part 'image_event.dart';
part 'image_state.dart';



/// A Bloc that manages fetching and loading more images from the API.
/// It uses an internet connection checker to ensure the device is connected
/// to the internet before making API requests.
class ImageBloc extends Bloc<ImageEvent, ImageState> {
  /// Use case for fetching images.
  final GetAllImages _getAllImages;

  /// Internet connection checker to verify if the device is online.
  final InternetConnection _internetConnection;

  /// Creates an instance of [ImageBloc] that handles fetching and loading images.
  ///
  /// Takes [getAllImages] and [internetConnection] as required parameters.
  ImageBloc({
    required GetAllImages getAllImages,
    required InternetConnection internetConnection,
  })  : _getAllImages = getAllImages,
        _internetConnection = internetConnection,
        super(ImageInitial()) {
    on<FetchImages>(_onFetchImages);
    on<LoadMoreImages>(_onLoadMoreImages);
    on<DebouncedSearch>(_onDebounceSearch);
  }

  /// Handles the event of fetching images based on the search query.
  ///
  /// This method checks if the device is connected to the internet. If not,
  /// it emits an [ImageError] state with a "No internet connection available." message.
  /// Otherwise, it fetches the images from the API.
  Future<void> _onFetchImages(FetchImages event, Emitter<ImageState> emit) async {
    // Check for internet connection before making an API request
    if (!await _internetConnection.hasInternetAccess) {
      emit(ImageError('No internet connection available.', query: event.query));
      return;
    }

    emit(ImageLoading(query: event.query)); // Emit loading state

    // Fetch images from the API
    final Either<Failure, List<ImageEntity>> result = await _getAllImages(
      ImageParams(query: event.query, limit: event.limit, page: event.page),
    );

    // Handle the result from the API call
    result.fold(
          (failure) => emit(ImageError(failure.message, query: event.query)),
          (images) {
        if (images.isEmpty) {
          emit(ImageError('No images found.', query: event.query));
        } else {
          emit(ImageLoaded(
            images: images,
            hasReachedMax: images.length < event.limit,
            query: event.query, // Store the query in the state
          ));
        }
      },
    );
  }

  /// Handles the event of loading more images for infinite scroll pagination.
  ///
  /// This method also checks for internet availability before making the request. If
  /// there is no internet connection, it emits an [ImageError] state.
  /// If there are more images to load, they are appended to the existing list.
  Future<void> _onLoadMoreImages(LoadMoreImages event, Emitter<ImageState> emit) async {
    final currentState = state;

    // Check for internet connection before making an API request
    if (!await _internetConnection.hasInternetAccess) {
      emit(ImageError('No internet connection available.', query: currentState.query));
      return;
    }

    if (currentState is ImageLoaded && !currentState.hasReachedMax) {
      // Fetch more images from the API
      final Either<Failure, List<ImageEntity>> result = await _getAllImages(
        ImageParams(query: currentState.query, limit: event.limit, page: event.page),
      );

      // Handle the result of the API call
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
                query: currentState.query, // Maintain the query in the state
              ),
            );
          }
        },
      );
    }
  }

  /// Handles the debounced search event.
  ///
  /// This event is triggered when the user is typing in the search bar.
  /// It emits a loading state with the search query.
  void _onDebounceSearch(DebouncedSearch event, Emitter<ImageState> emit) {
    emit(ImageLoading(query: event.query)); // Emit loading state while waiting for debounced search
  }
}


