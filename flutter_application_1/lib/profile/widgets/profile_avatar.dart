import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';

class ProfileAvatar extends StatefulWidget {
  final String? imageUrl;
  final double size;
  final VoidCallback? onEdit;
  final ValueChanged<String>? onUploaded;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.size = 100,
    this.onEdit,
    this.onUploaded,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  static final _client = Supabase.instance.client;

  bool _isUploading = false;
  String? _localUrl;

  String get _displayUrl => _localUrl ?? widget.imageUrl ?? '';

  Future<void> _pickAndUpload() async {
    final input = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..click();

    await input.onChange.first;

    final file = input.files?.first;
    if (file == null) return;

    setState(() => _isUploading = true);

    try {
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoad.first;

      final bytes = Uint8List.fromList((reader.result as List<int>));

      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      // ✅ Путь: userId/avatar.jpg — папка совпадает с auth.uid()
      final path = '$userId/avatar.jpg';

      await _client.storage
          .from('avatars')
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      final url = _client.storage.from('avatars').getPublicUrl(path);

      final urlWithCache = '$url?t=${DateTime.now().millisecondsSinceEpoch}';

      await _client
          .from('users')
          .update({'avatar_url': urlWithCache})
          .eq('id', userId);

      if (!mounted) return;
      setState(() {
        _localUrl = urlWithCache;
        _isUploading = false;
      });

      widget.onUploaded?.call(urlWithCache);
    } catch (e) {
      debugPrint('Ошибка загрузки аватара: $e');
      if (!mounted) return;
      setState(() => _isUploading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка загрузки: $e'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: widget.size / 2,
          backgroundColor: Colors.white.withOpacity(0.3),
          backgroundImage: _displayUrl.isNotEmpty
              ? NetworkImage(_displayUrl)
              : null,
          child: _displayUrl.isEmpty
              ? Icon(
                  Icons.person,
                  size: widget.size * 0.55,
                  color: Colors.white,
                )
              : null,
        ),
        Positioned(
          bottom: 2,
          right: 2,
          child: GestureDetector(
            onTap: _isUploading ? null : _pickAndUpload,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: _isUploading
                  ? const Padding(
                      padding: EdgeInsets.all(6),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.camera_alt, size: 15, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
