import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? get _user => supabase.auth.currentUser;

  String _meta(String key) {
    final v = _user?.userMetadata?[key];
    return v == null ? '' : v.toString();
  }

  Future<void> _editField({
    required String title,
    required String current,
    required String hint,
    bool isEmail = false,
    required Future<void> Function(String value) onSave,
  }) async {
    final ctrl = TextEditingController(text: current);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          keyboardType:
              isEmail ? TextInputType.emailAddress : TextInputType.text,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final value = ctrl.text.trim();
    if (value.isEmpty) return;
    if (isEmail && !value.contains('@')) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('بريد إلكتروني غير صالح')),
      );
      return;
    }

    try {
      await onSave(value);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم الحفظ بنجاح ✓')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل الحفظ: $e')),
      );
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريدين الخروج من حسابك؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('خروج'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('الملف الشخصي')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('غير مسجل الدخول'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                child: const Text('تسجيل الدخول'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('الملف الشخصي')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 44),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _meta('name').isEmpty ? 'بدون اسم' : _meta('name'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('الاسم'),
                  subtitle: Text(_meta('name').isEmpty ? '—' : _meta('name')),
                  trailing: const Icon(Icons.edit, size: 20),
                  onTap: () => _editField(
                    title: 'تغيير الاسم',
                    current: _meta('name'),
                    hint: 'اسمك الجديد',
                    onSave: (v) => supabase.auth
                        .updateUser(UserAttributes(data: {'name': v})),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text('رقم الجوال'),
                  subtitle: Text(_meta('phone').isEmpty ? '—' : _meta('phone')),
                  trailing: const Icon(Icons.edit, size: 20),
                  onTap: () => _editField(
                    title: 'تغيير رقم الجوال',
                    current: _meta('phone'),
                    hint: '+967 ...',
                    onSave: (v) => supabase.auth
                        .updateUser(UserAttributes(data: {'phone': v})),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('البريد الإلكتروني'),
                  subtitle: Text(_user?.email ?? '—'),
                  trailing: const Icon(Icons.edit, size: 20),
                  onTap: () => _editField(
                    title: 'تغيير البريد الإلكتروني',
                    current: _user?.email ?? '',
                    hint: 'البريد الجديد',
                    isEmail: true,
                    onSave: (v) =>
                        supabase.auth.updateUser(UserAttributes(email: v)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
