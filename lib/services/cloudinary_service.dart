import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  // TODO: Replace with your actual Cloud Name and Upload Preset
  final CloudinaryPublic _cloudinary = CloudinaryPublic('drjhh3u4q', 'ml_default', cache: false);

  Future<String?> uploadImage(XFile image) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(image.path, resourceType: CloudinaryResourceType.Image),
      );
      return response.secureUrl;
    } catch (e) {
      print("Cloudinary Upload Error: $e");
      return null;
    }
  }
}
