import 'package:fpdart/fpdart.dart';
import 'package:piecyfer_test/core/error/failures.dart';
import 'package:piecyfer_test/features/Image/domain/entities/image.dart';


abstract class ImageRepository {

  /// Fetches a paginated list of images based on the search query and page number.
  /// Returns [Either<Failure, List<ImageEntity>>] where [Failure] represents
  /// any error during fetching and [List<ImageEntity>] contains the list of images.
  Future<Either<Failure, List<ImageEntity>>> fetchImages({
    required String query,
    required int limit,
    required int page,
  });
}
