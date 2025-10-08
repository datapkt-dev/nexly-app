import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

class UploadImageWidget extends StatelessWidget {
  final void Function(String) onImagePicked;
  final Widget child;

  const UploadImageWidget({
    super.key,
    required this.child,
    required this.onImagePicked
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final path = await _pickFromGallery();
        if (path != null) {
          onImagePicked(path);
        }
      },
      child: child,
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 115,
          child: Column(
            children: <Widget>[
              ListTile(
                onTap: () async {
                  Navigator.pop(context); // 先關閉底部選單
                  final path = await _pickFromGallery();
                  if (path != null) {
                    onImagePicked(path);
                  }
                  // 取消或錯誤時就不做事
                },
                leading: const Icon(Icons.photo_library),
                title: const Text("選擇照片"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      return image?.path; // 取消時為 null
    } on PlatformException catch (e) {
      // 依需要可在這裡做錯誤提示（SnackBar / dialog）
      debugPrint('pickImage error: $e');
      return null;
    }
  }

  Future<String> _showPhotoLibrary() async {
    ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);

    return image!.path;
  }
}