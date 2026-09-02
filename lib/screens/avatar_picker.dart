import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../device_session.dart';
import '../supabase.dart';

/// صورة شخصية قابلة للتغيير من معرض الصور
/// تُرفع إلى Supabase Storage وتُحفظ رابطها على الجهاز
class AvatarPicker extends StatefulWidget {
  final double radius;
  const AvatarPicker({super.key, this.radius = 44});

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  String? _url;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _url = prefs.getString('avatar_url'));
  }

  Future<void> _pickAndUpload() async {
    setState(() => _uploading = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 512,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      final deviceId = await DeviceSession.deviceId();
      final path = '$deviceId.jpg';

      await supabase.storage.from('avatars').uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(
          upsert: true,
          contentType: 'image/jpeg',
        ),
      );

      var url = supabase.storage.from('avatars').getPublicUrl(path);
      // كسر الكاش حتى تظهر الصورة الجديدة فوراً
      url = '$url?v=${DateTime.now().millisecondsSinceEpoch}';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('avatar_url', url);

      if (!mounted) return;
      setState(() => _url = url);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل رفع الصورة: $e')),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: widget.radius,
              backgroundImage: _url != null ? NetworkImage(_url!) : null,
              child: _url == null
                  ? Icon(Icons.person,
                      size: widget.radius, color: Colors.grey)
                  : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: InkWell(
                onTap: _uploading ? null : _pickAndUpload,
                child: CircleAvatar(
                  radius: 16,
                  child: _uploading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.camera_alt, size: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'اضغط على الكاميرا لاختيار صورة',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
