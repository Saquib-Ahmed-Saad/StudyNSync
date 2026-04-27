import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService({FirebaseStorage? storage}) : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> uploadUserAttachmentBytes({
    required String uid,
    required Uint8List bytes,
    required String fileName,
    String folder = 'study_materials',
    String contentType = 'application/octet-stream',
  }) async {
    if (bytes.isEmpty) {
      throw ArgumentError('The selected file is empty.');
    }

    final safeFileName = fileName.replaceAll(
      RegExp(r'[^A-Za-z0-9._-]'),
      '_',
    );

    final path =
        'user_uploads/$uid/$folder/${DateTime.now().millisecondsSinceEpoch}_$safeFileName';

    final ref = _storage.ref(path);

    await ref.putData(
      bytes,
      SettableMetadata(contentType: contentType),
    );

    return ref.getDownloadURL();
  }

  Future<void> deleteByDownloadUrl(String downloadUrl) async {
    final ref = _storage.refFromURL(downloadUrl);
    await ref.delete();
  }
}