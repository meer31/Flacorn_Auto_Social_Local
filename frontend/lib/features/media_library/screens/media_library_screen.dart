import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Media Library screen (PDF Section 24) — user-uploaded images/videos used
/// across post templates, campaigns, and AR source media.
class MediaLibraryScreen extends ConsumerStatefulWidget {
  const MediaLibraryScreen({super.key});

  @override
  ConsumerState<MediaLibraryScreen> createState() => _MediaLibraryScreenState();
}

class _MediaLibraryScreenState extends ConsumerState<MediaLibraryScreen> {
  bool _uploading = false;

  Future<void> _upload() async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;

    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    setState(() => _uploading = true);
    try {
      final bytes = await file.readAsBytes();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final ref0 = FirebaseService.instance.storage.ref('users/$uid/media/$fileName');
      await ref0.putData(bytes);
      final url = await ref0.getDownloadURL();

      await FirebaseService.instance.userSubcollection(uid, 'media').add({
        'url': url,
        'fileName': fileName,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    if (uid == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Media Library', style: AppTextStyles.headlineLarge(AppColors.textPrimary)),
              ElevatedButton.icon(
                onPressed: _uploading ? null : _upload,
                icon: _uploading
                    ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.upload_outlined),
                label: const Text('Upload'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseService.instance
                  .userSubcollection(uid, 'media')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const EmptyState(
                    icon: Icons.perm_media_outlined,
                    title: 'No media uploaded yet',
                    message: 'Upload images to use in posts, campaigns, and AR previews.',
                  );
                }
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final url = docs[index].data()['url'] as String?;
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: url != null
                          ? Image.network(url, fit: BoxFit.cover)
                          : Container(color: AppColors.surface),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
