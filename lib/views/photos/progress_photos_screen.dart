import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../models/progress_photo.dart';
import '../../viewmodels/photo_viewmodel.dart';

class ProgressPhotosScreen extends StatefulWidget {
  const ProgressPhotosScreen({super.key});

  @override
  State<ProgressPhotosScreen> createState() => _ProgressPhotosScreenState();
}

class _ProgressPhotosScreenState extends State<ProgressPhotosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PhotoViewModel>().loadPhotos();
    });
  }

  bool get _cameraSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> _addPhoto(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final picker = ImagePicker();

    ImageSource? source;
    if (_cameraSupported) {
      source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (sheetContext) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(l10n.takePhoto),
                onTap: () =>
                    Navigator.of(sheetContext).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(l10n.chooseFromGallery),
                onTap: () =>
                    Navigator.of(sheetContext).pop(ImageSource.gallery),
              ),
            ],
          ),
        ),
      );
      if (source == null) return;
    } else {
      // Desktop: no camera, the gallery source opens a file dialog.
      source = ImageSource.gallery;
    }

    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null || !context.mounted) return;

    final note = await _askNote(context);
    if (!context.mounted) return;

    await context.read<PhotoViewModel>().addPhoto(picked.path, note: note);
  }

  Future<String?> _askNote(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.photoNoteHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(''),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, ProgressPhoto photo) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deletePhoto),
        content: Text(l10n.deletePhotoConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<PhotoViewModel>().deletePhoto(photo);
    }
  }

  void _openViewer(BuildContext context, ProgressPhoto photo) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _PhotoViewer(
        photo: photo,
        onDelete: () async {
          Navigator.of(context).pop();
          await _confirmDelete(context, photo);
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final photoVM = context.watch<PhotoViewModel>();
    final monthFormat = DateFormat.yMMMM(locale);

    // Group photos by month for section headers.
    final groups = <String, List<ProgressPhoto>>{};
    for (final photo in photoVM.photos) {
      final key = monthFormat.format(DateTime.parse(photo.date));
      groups.putIfAbsent(key, () => []).add(photo);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.progressPhotos)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addPhoto(context),
        child: const Icon(Icons.add_a_photo),
      ),
      body: photoVM.photos.isEmpty
          ? Center(child: Text(l10n.noPhotosYet))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final entry in groups.entries) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(entry.key,
                        style: Theme.of(context).textTheme.titleLarge),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: entry.value.length,
                    itemBuilder: (context, index) {
                      final photo = entry.value[index];
                      return GestureDetector(
                        onTap: () => _openViewer(context, photo),
                        onLongPress: () => _confirmDelete(context, photo),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(photo.filePath),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color:
                                  Theme.of(context).colorScheme.surface,
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
    );
  }
}

class _PhotoViewer extends StatelessWidget {
  final ProgressPhoto photo;
  final Future<void> Function() onDelete;

  const _PhotoViewer({required this.photo, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat.yMMMMd(locale);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          dateFormat.format(DateTime.parse(photo.date)),
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: onDelete,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: InteractiveViewer(
                child: Image.file(File(photo.filePath)),
              ),
            ),
          ),
          if (photo.note != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                photo.note!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
