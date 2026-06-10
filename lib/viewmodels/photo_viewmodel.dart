import 'package:flutter/foundation.dart';
import '../models/progress_photo.dart';
import '../repositories/photo_repository.dart';
import '../services/photo_storage_service.dart';

class PhotoViewModel extends ChangeNotifier {
  final PhotoRepository _repository;
  final PhotoStorageService _storage;

  PhotoViewModel({
    PhotoRepository? repository,
    PhotoStorageService? storage,
  })  : _repository = repository ?? PhotoRepository(),
        _storage = storage ?? PhotoStorageService();

  List<ProgressPhoto> _photos = [];
  List<ProgressPhoto> get photos => _photos;

  Future<void> loadPhotos() async {
    _photos = await _repository.getPhotos();
    notifyListeners();
  }

  /// Copies the picked file into managed storage, then records it.
  Future<void> addPhoto(String sourcePath, {String? note}) async {
    final storedPath = await _storage.persistPhoto(sourcePath);
    await _repository.insertPhoto(ProgressPhoto(
      date: DateTime.now().toIso8601String(),
      filePath: storedPath,
      note: (note == null || note.trim().isEmpty) ? null : note.trim(),
    ));
    await loadPhotos();
  }

  Future<void> deletePhoto(ProgressPhoto photo) async {
    if (photo.id != null) {
      await _repository.deletePhoto(photo.id!);
    }
    await _storage.deletePhotoFile(photo.filePath);
    await loadPhotos();
  }
}
