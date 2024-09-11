import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/image.dart';
import '../repositories/image_repository.dart';


class GetAllImages implements UseCase<List<ImageEntity>, ImageParams> {
  final ImageRepository repository;

  GetAllImages(this.repository);

  @override
  Future<Either<Failure, List<ImageEntity>>> call(ImageParams params) async {
    return await repository.fetchImages(
      query: params.query,
      limit: params.limit,
      page: params.page,
    );
  }
}

class ImageParams {
  final String query;
  final int limit;
  final int page;

  ImageParams({
    required this.query,
    required this.limit,
    required this.page,
  });
}
