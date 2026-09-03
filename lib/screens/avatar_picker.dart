import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../device_session.dart';
import '../supabase.dart';

/// صورة شخصية قابلة للتغيير والحذف من معرض الصور
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

      // حذف أي صورة سابقة ثم رفع الجديدة
      try {
        await supabase.storage.from('avatars').remove([path]);
      } catch (_) {}

      await supabase.storage.from('avatars').uploadBinary(path, bytes);

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

  /// حذف الصورة الشخصية نهائياً من التخزين ومن الجهاز
  Future<void> _deleteAvatar() async {
    // تأكيد قبل الحذف
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الصورة'),
        content: const Text('هل تريد حذف صورتك الشخصية؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _uploading = true);
    try {
      final deviceId = await DeviceSession.deviceId();
      final path = '$deviceId.jpg';

      // حذفها من التخزين السحابي
      try {
        await supabase.storage.from('avatars').remove([path]);
      } catch (_) {}

      // حذف الرابط المحفوظ محلياً
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('avatar_url');

      if (!mounted) return;
      setState(() => _url = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الصورة الشخصية ✓')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل حذف الصورة: $e')),
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
            // زر الكاميرا — تغيير الصورة
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
            // زر الحذف — يظهر فقط إذا كانت هناك صورة
            if (_url != null)
              Positioned(
                left: 0,
                bottom: 0,
                child: InkWell(
                  onTap: _uploading ? null : _deleteAvatar,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor:
                        Theme.of(context).colorScheme.errorContainer,
                    child: const Icon(Icons.delete_outline, size: 16),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _url == null
              ? 'اضغط على الكاميرا لاختيار صورة'
              : 'اضغط الكاميرا للتغيير أو سلة الحذف',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
