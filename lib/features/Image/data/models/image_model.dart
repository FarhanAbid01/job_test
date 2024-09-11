
import 'package:piecyfer_test/features/Image/domain/entities/image.dart';

class ImageModel extends ImageEntity {
  ImageModel({
    required int id,
    required String pageURL,
    required String previewURL,
    required String largeImageURL,
    required int likes,
    required int views,
  }) : super(
    id: id,
    pageURL: pageURL,
    previewURL: previewURL,
    largeImageURL: largeImageURL,
    likes: likes,
    views: views,
  );

  // Factory method to create an ImageModel from JSON
  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'] ?? 0, // Default to 0 if null
      pageURL: json['pageURL'] ?? '', // Default to empty string if null
      previewURL: json['previewURL'] ?? '', // Default to empty string if null
      largeImageURL: json['largeImageURL'] ?? '', // Default to empty string if null
      likes: json['likes'] ?? 0, // Default to 0 if null
      views: json['views'] ?? 0, // Default to 0 if null
    );
  }

  // Convert ImageModel to JSON (if needed for any future API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pageURL': pageURL,
      'previewURL': previewURL,
      'largeImageURL': largeImageURL,
      'likes': likes,
      'views': views,
    };
  }
}
