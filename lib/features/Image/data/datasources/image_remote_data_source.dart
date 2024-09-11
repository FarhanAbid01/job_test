import 'dart:convert';
import "package:http/http.dart" as http;
import 'package:piecyfer_test/core/error/exceptions.dart';
import 'package:piecyfer_test/features/Image/data/models/image_model.dart';
import 'package:piecyfer_test/features/Image/domain/entities/image.dart';


abstract class ImageRemoteDataSource {
  /// Fetches a paginated list of images from the Pixabay API.
  /// [limit] is the number of images to fetch per page.
  /// [page] is the page number for pagination.
  /// [query] is the search keyword for the image.
  ///
  /// Returns a list of [ImageEntity].
  Future<List<ImageEntity>> fetchImages(int limit, int page, String query);
}

class ImageRemoteDataSourceImpl implements ImageRemoteDataSource {
  final http.Client client;
  final String apiKey;

  ImageRemoteDataSourceImpl({
    required this.client,
    required this.apiKey,
  });

  @override
  Future<List<ImageEntity>> fetchImages(int limit, int page, String query) async {
    final url =
        'https://pixabay.com/api/?key=$apiKey&q=$query&image_type=photo&per_page=$limit&page=$page';

    try {
      final response = await client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Extract the 'hits' from the API response
        final List<dynamic> hits = jsonData['hits'];

        // Map the JSON 'hits' to a list of ImageModels and then to ImageEntities
        final List<ImageEntity> images = hits.map((hit) {
          return ImageModel.fromJson(hit);
        }).toList();

        return images;
      } else {
        throw const ServerException('Failed to fetch images from Pixabay');
      }
    } catch (e) {
      throw ServerException('An error occurred while fetching images: $e');
    }
  }
}
