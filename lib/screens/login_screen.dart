import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase.dart';
import 'profile_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _isRegister = false;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    if (!email.contains('@') || pass.length < 6) {
      setState(() => _error =
          'تأكدي من البريد الإلكتروني وكلمة مرور لا تقل عن 6 أحرف');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_isRegister) {
        await supabase.auth.signUp(
          email: email,
          password: pass,
          data: {'name': _nameCtrl.text.trim()},
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'تم إنشاء الحساب! افتحي بريدك واضغطي رابط التأكيد، ثم سجلي دخولك'),
            duration: Duration(seconds: 6),
          ),
        );
        setState(() => _isRegister = false);
      } else {
        await supabase.auth.signInWithPassword(
          email: email,
          password: pass,
        );
        if (!mounted) return;
        if (Navigator.of(context).canPop()) {
          Navigator.pop(context);
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        }
      }
    } on AuthException catch (e) {
      String msg = e.message;
      if (msg.contains('Invalid login')) {
        msg = 'البريد أو كلمة المرور غير صحيحة';
      } else if (msg.contains('already registered')) {
        msg = 'هذا البريد مسجل مسبقاً';
      } else if (msg.contains('not confirmed')) {
        msg = 'لم يتم تأكيد البريد بعد — افتحي إيميلك واضغطي رابط التأكيد';
      }
      setState(() => _error = msg);
    } catch (_) {
      setState(() => _error = 'تعذر الاتصال، حاولي مرة أخرى');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isRegister ? 'حساب جديد' : 'تسجيل الدخول')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.travel_explore,
                  size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 24),
              if (_isRegister) ...[
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'الاسم',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 16),
              if (_error != null)
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isRegister ? 'إنشاء الحساب' : 'دخول'),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _isRegister = !_isRegister),
                child: Text(_isRegister
                    ? 'لدي حساب بالفعل — تسجيل الدخول'
                    : 'ليس لدي حساب — إنشاء حساب جديد'),
              ),
            ],
          ),
          ),
        ),
      );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }
}
