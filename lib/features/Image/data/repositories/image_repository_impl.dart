import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/image.dart';
import '../../domain/repositories/image_repository.dart';
import '../datasources/image_remote_data_source.dart';


class ImageRepositoryImpl implements ImageRepository {
  final ImageRemoteDataSource remoteDataSource;

  ImageRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<ImageEntity>>> fetchImages({
    required String query,
    required int limit,
    required int page,
  }) async {
    try {
      // Fetch images from the remote data source
      final remoteImages = await remoteDataSource.fetchImages(limit, page, query);
      return Right(remoteImages);
    } on ServerException {
      return Left(Failure('Failed to fetch images from the server'));
    } catch (e) {
      return Left(Failure('An unexpected error occurred: $e'));
    }
  }
}
