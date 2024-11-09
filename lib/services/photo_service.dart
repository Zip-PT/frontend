import 'package:image_picker/image_picker.dart';

class PhotoService {
  static final PhotoService _instance = PhotoService._internal();
  final ImagePicker _picker = ImagePicker();

  factory PhotoService() {
    return _instance;
  }

  PhotoService._internal();

  Future<String?> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80, // 이미지 품질 (0-100)
      );

      if (photo != null) {
        return photo.path; // 임시 파일 경로 반환
      }
      return null;
    } catch (e) {
      throw Exception('사진 촬영 중 오류 발생: $e');
    }
  }
}
