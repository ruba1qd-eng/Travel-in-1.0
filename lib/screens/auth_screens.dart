import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../data/models.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';
import 'developer_dashboard.dart';

/// ===== شاشة اختيار نوع المستخدم =====
class UserTypeScreen extends StatelessWidget {
  const UserTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(l.t('whoUses'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(l.t('whoHint'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).hintColor)),
              const SizedBox(height: 36),
              _UserTypeCard(
                icon: Icons.person,
                title: l.t('customer'),
                desc: l.t('customerDesc'),
                gold: false,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const PhoneLoginScreen())),
              ),
              const SizedBox(height: 16),
              _UserTypeCard(
                icon: Icons.admin_panel_settings,
                title: l.t('developer'),
                desc: l.t('developerDesc'),
                gold: true,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const DeveloperLoginScreen())),
              ),
              const Spacer(),
              Text(l.t('demoNote'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11, color: Theme.of(context).hintColor)),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserTypeCard extends StatelessWidget {
  final IconData icon;
  final String title, desc;
  final bool gold;
  final VoidCallback onTap;

  const _UserTypeCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.gold,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: gold ? TIColors.gold : Theme.of(context).dividerColor,
              width: gold ? 1.5 : 1),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(isDark ? .3 : .06),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(children: [
          CircleAvatar(
            radius: 28,
            backgroundColor:
                (gold ? TIColors.gold : TIColors.teal).withOpacity(.15),
            child: Icon(icon,
                color: gold ? TIColors.gold : TIColors.teal, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(desc,
                      style: TextStyle(
                          fontSize: 13, color: Theme.of(context).hintColor)),
                ]),
          ),
          const Icon(Icons.chevron_right),
        ]),
      ),
    );
  }
}

/// ===== دخول العميل: هاتف (OTP تجريبي) أو بريد أو Apple =====
class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});
  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phone = TextEditingController();
  final _otp = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _otpSent = false;
  bool _emailMode = false;

  void _sendOtp() {
    final l = context.l;
    if (_phone.text.trim().length < 9) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.t('errPhone'))));
      return;
    }
    setState(() => _otpSent = true);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${l.t('otp')}: 1234 (Demo)')));
  }

  void _verify() {
    final l = context.l;
    if (_otp.text.trim() != '1234') {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.t('errPhone'))));
      return;
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => ProfileSetupScreen(
              phone: _phone.text.trim(),
            )));
  }

  void _emailLogin() {
    final l = context.l;
    if (!_email.text.contains('@') || _pass.text.length < 4) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.t('errEmail'))));
      return;
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => ProfileSetupScreen(email: _email.text.trim())));
  }

  @override
  void dispose() {
    _phone.dispose();
    _otp.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _logo(),
            const SizedBox(height: 32),
            if (!_emailMode) ...[
              if (!_otpSent) ...[
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                      labelText: l.t('phone'),
                      prefixIcon: const Icon(Icons.phone),
                      hintText: '77x xxx xxx'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                    onPressed: _sendOtp, child: Text(l.t('sendOtp'))),
              ] else ...[
                TextField(
                  controller: _otp,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 24, letterSpacing: 10),
                  decoration: InputDecoration(
                      labelText: l.t('otp'), prefixIcon: const Icon(Icons.lock)),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                    onPressed: _verify, child: Text(l.t('verify'))),
              ],
              const SizedBox(height: 20),
              Row(children: [
                const Expanded(child: Divider()),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(l.t('or'))),
                const Expanded(child: Divider()),
              ]),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => setState(() => _emailMode = true),
                icon: const Icon(Icons.mail_outline),
                label: Text(l.t('emailLogin')),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.apple, size: 26),
                label: Text(l.t('appleLogin')),
              ),
            ] else ...[
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    labelText: l.t('email'),
                    prefixIcon: const Icon(Icons.mail_outline)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _pass,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: l.t('password'),
                    prefixIcon: const Icon(Icons.lock_outline)),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                    onPressed: () {},
                    child: Text(l.t('forgotPass'),
                        style: const TextStyle(fontSize: 13))),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                  onPressed: _emailLogin, child: Text(l.t('login'))),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => setState(() => _emailMode = false),
                icon: const Icon(Icons.phone),
                label: Text(l.t('phoneLogin')),
              ),
            ],
            const SizedBox(height: 24),
            Text(l.t('demoNote'),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11, color: Theme.of(context).hintColor)),
          ],
        ),
      ),
    );
  }

  Widget _logo() => Column(children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF12305E), TIColors.navy]),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: TIColors.gold, width: 1.5),
          ),
          child: const Icon(Icons.flight_takeoff,
              color: TIColors.gold, size: 42),
        ),
        const SizedBox(height: 12),
        const Text('Travel In',
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
      ]);
}

/// ===== دخول المطور (آمن — OTP تجريبي ثابت) =====
class DeveloperLoginScreen extends StatefulWidget {
  const DeveloperLoginScreen({super.key});
  @override
  State<DeveloperLoginScreen> createState() => _DeveloperLoginScreenState();
}

class _DeveloperLoginScreenState extends State<DeveloperLoginScreen> {
  final _user = TextEditingController();
  final _pass = TextEditingController();
  final _twoFa = TextEditingController();
  int _step = 0;

  void _next() {
    final l = context.l;
    // في الإنتاج: تحقق حقيقي من Backend + 2FA
    if (_step == 0) {
      if (_user.text.trim().isEmpty || _pass.text.trim().isEmpty) return;
      setState(() => _step = 1);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l.t('twoFa')}: 0000 (Demo)')));
    } else {
      if (_twoFa.text.trim() != '0000') return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => ProfileSetupScreen(
                isDeveloper: true,
                email: _user.text.trim(),
              )));
    }
  }

  @override
  void dispose() {
    _user.dispose();
    _pass.dispose();
    _twoFa.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(Icons.admin_panel_settings,
              size: 72, color: TIColors.gold),
          const SizedBox(height: 16),
          Text(l.t('devLoginTitle'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(l.t('devLoginHint'),
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13)),
          const SizedBox(height: 28),
          if (_step == 0) ...[
            TextField(
              controller: _user,
              decoration: InputDecoration(
                  labelText: l.t('email'),
                  prefixIcon: const Icon(Icons.admin_panel_settings_outlined)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pass,
              obscureText: true,
              decoration: InputDecoration(
                  labelText: l.t('password'),
                  prefixIcon: const Icon(Icons.lock)),
            ),
          ] else ...[
            TextField(
              controller: _twoFa,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 10),
              decoration: InputDecoration(
                  labelText: l.t('twoFa'),
                  prefixIcon: const Icon(Icons.security)),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: TIColors.gold),
              onPressed: _next,
              child: Text(_step == 0 ? l.t('login') : l.t('verify'))),
        ],
      ),
    );
  }
}

/// ===== إكمال الملف الشخصي: الاسم الأول والثاني والعمر =====
class ProfileSetupScreen extends StatefulWidget {
  final String? phone, email;
  final bool isDeveloper;
  const ProfileSetupScreen(
      {super.key, this.phone, this.email, this.isDeveloper = false});
  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _form = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _second = TextEditingController();
  final _age = TextEditingController();
  String _currency = 'YER';

  void _save() {
    final l = context.l;
    if (!(_form.currentState?.validate() ?? false)) return;
    final state = context.read<AppState>();
    state.setCurrency(_currency);
    state.login(AppUser(
      id: 'U${DateTime.now().millisecondsSinceEpoch}',
      firstName: _first.text.trim(),
      secondName: _second.text.trim(),
      age: int.parse(_age.text.trim()),
      phone: widget.phone,
      email: widget.email,
      role: widget.isDeveloper ? 'developer' : 'customer',
    ));
    if (widget.isDeveloper) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const DeveloperDashboard()),
          (r) => false);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainShell()), (r) => false);
    }
  }

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    _age.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(l.t('completeProfile'),
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(l.t('profileHint'),
              style: TextStyle(color: Theme.of(context).hintColor)),
          const SizedBox(height: 28),
          Form(
            key: _form,
            child: Column(children: [
              TextFormField(
                controller: _first,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                    labelText: l.t('firstName'),
                    prefixIcon: const Icon(Icons.person_outline)),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l.t('errRequired') : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _second,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                    labelText: l.t('secondName'),
                    prefixIcon: const Icon(Icons.person_outline)),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l.t('errRequired') : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _age,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: l.t('age'),
                    prefixIcon: const Icon(Icons.cake_outlined)),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  return (n == null || n < 10 || n > 100)
                      ? l.t('errAge')
                      : null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _currency,
                decoration: InputDecoration(
                    labelText: l.t('prefCurrency'),
                    prefixIcon: const Icon(Icons.currency_exchange)),
                items: const [
                  DropdownMenuItem(value: 'YER', child: Text('YER — ريال يمني')),
                  DropdownMenuItem(value: 'USD', child: Text('USD — Dollar')),
                  DropdownMenuItem(value: 'SAR', child: Text('SAR — ريال سعودي')),
                ],
                onChanged: (v) => setState(() => _currency = v ?? 'YER'),
              ),
            ]),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
              onPressed: _save, child: Text(l.t('saveContinue'))),
        ],
      ),
    );
  }
}
