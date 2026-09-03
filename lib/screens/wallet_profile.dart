import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'auth_screens.dart';
import 'avatar_picker.dart';
import 'support_screen.dart';
import 'edit_profile_screen.dart';

/// ============ تبويب المحفظة ============
class WalletTab extends StatelessWidget {
  const WalletTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: Text(l.t('wallet'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // بطاقة الرصيد
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [TIColors.navy, Color(0xFF14335F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: TIColors.gold.withOpacity(.5)),
              boxShadow: [
                BoxShadow(
                    color: TIColors.navy.withOpacity(.35),
                    blurRadius: 16,
                    offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.t('balance'),
                      style: TextStyle(
                          color: Colors.white.withOpacity(.75),
                          fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(l.money(state.walletBalanceYer),
                      style: const TextStyle(
                          color: TIColors.gold,
                          fontSize: 32,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(state.user?.fullName ?? '',
                      style: TextStyle(
                          color: Colors.white.withOpacity(.8),
                          fontSize: 12.5)),
                ]),
          ),
          const SizedBox(height: 16),
          // إضافة رصيد (Demo)
          FilledButton.icon(
            onPressed: () => _addMoney(context),
            icon: const Icon(Icons.add_card),
            label: Text(l.t('addMoney')),
          ),
          const SizedBox(height: 22),
          Text(l.t('transactions'),
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          if (state.txs.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Text(l.t('noBookings'),
                    style: TextStyle(color: Theme.of(context).hintColor)),
              ),
            )
          else
            ...state.txs.take(15).map((tx) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color:
                            Theme.of(context).dividerColor.withOpacity(.4)),
                  ),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: (tx.amountYer >= 0
                              ? TIColors.success
                              : TIColors.teal)
                          .withOpacity(.15),
                      child: Icon(
                        tx.amountYer >= 0
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        size: 17,
                        color: tx.amountYer >= 0
                            ? TIColors.success
                            : TIColors.teal,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx.reason,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            Text('${tx.id} • ${tx.createdAt}',
                                style: TextStyle(
                                    fontSize: 10.5,
                                    color: Theme.of(context).hintColor)),
                          ]),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(l.money(tx.amountYer.abs()),
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                color: tx.amountYer >= 0
                                    ? TIColors.success
                                    : TIColors.teal)),
                        Text(
                            switch (tx.status) {
                              TxStatus.pending => l.t('pending'),
                              TxStatus.completed => l.t('completedTx'),
                              TxStatus.failed => l.t('failed'),
                              TxStatus.refunded => l.t('refunded'),
                            },
                            style: TextStyle(
                                fontSize: 10,
                                color: tx.status == TxStatus.pending
                                    ? TIColors.warning
                                    : Theme.of(context).hintColor)),
                      ],
                    ),
                  ]),
                )),
        ],
      ),
    );
  }

  void _addMoney(BuildContext context) {
    final l = context.l;
    final c = TextEditingController(text: '50000');
    showDialog(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l.t('addMoney')),
        content: TextField(
          controller: c,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(suffixText: 'YER'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(d), child: Text(l.t('cancel'))),
          FilledButton(
              onPressed: () {
                final v = double.tryParse(c.text.trim());
                if (v != null && v > 0) {
                  context.read<AppState>().addMoney(v);
                }
                Navigator.pop(d);
              },
              child: Text(l.t('yes'))),
        ],
      ),
    );
  }
}

/// ============ تبويب الملف الشخصي ============
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final state = context.watch<AppState>();
    final user = state.user;

    return Scaffold(
      appBar: AppBar(title: Text(l.t('profile'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // بطاقة الملف
          Center(
            child: Column(children: [
              // الصورة الشخصية — قابلة للتغيير والحذف
              const AvatarPicker(radius: 44),
              const SizedBox(height: 12),
              Text(user?.fullName ?? '',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w900)),
              if (user != null)
                Text('${user.age} ${l.t('years')}',
                    style: TextStyle(color: Theme.of(context).hintColor)),
              const SizedBox(height: 8),
              // شارة العضوية
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: TIColors.gold.withOpacity(.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: TIColors.gold),
                ),
                child: Text(
                  '${l.t('membership')}: ${switch (state.membership) {
                    Membership.basic => l.t('basic'),
                    Membership.priority => l.t('priority'),
                    Membership.vip => l.t('vip'),
                  }}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: TIColors.gold),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 24),

          // الإعدادات
          _item(context, Icons.mail_outline,
              '${l.t('email')}: ${user?.email ?? user?.phone ?? '—'}', null),
          // تعديل البيانات الشخصية — الاسم والبريد والرقم
          _item(context, Icons.edit_outlined, 'تعديل البيانات', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            );
          }),
          _item(context, Icons.currency_exchange, l.t('currency'), () {
            _pickCurrency(context);
          }, trailing: state.currency),
          _item(context, Icons.translate, l.t('language'), () {
            state.toggleLanguage();
          }, trailing: state.isRTL ? 'العربية' : 'English'),
          SwitchListTile(
            secondary: Icon(
                state.isDark ? Icons.dark_mode : Icons.light_mode,
                color: TIColors.teal),
            title: Text(state.isDark ? l.t('darkMode') : l.t('lightMode')),
            value: state.isDark,
            activeColor: TIColors.teal,
            onChanged: (_) => state.toggleTheme(),
          ),
          _item(context, Icons.favorite_outline, l.t('favorites'), () {
            _showFavorites(context);
          }),
          // مركز المساعدة — يفتح محادثات الدعم الحقيقية
          _item(context, Icons.help_outline, l.t('helpCenter'), () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SupportScreen()),
            );
          }),
          _item(context, Icons.logout, l.t('logout'), () {
            _logout(context);
          },
              danger: true),
          const SizedBox(height: 16),
          Text(l.t('demoNote'),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10.5, color: Theme.of(context).hintColor)),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String title,
      VoidCallback? onTap,
      {String? trailing, bool danger = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: Theme.of(context).dividerColor.withOpacity(.4)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: danger ? TIColors.danger : TIColors.teal),
        title: Text(title,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: danger ? TIColors.danger : null)),
        trailing: trailing != null
            ? Text(trailing,
                style: const TextStyle(
                    fontWeight: FontWeight.w900, color: TIColors.gold))
            : const Icon(Icons.chevron_right, size: 20),
      ),
    );
  }

  void _pickCurrency(BuildContext context) {
    final state = context.read<AppState>();
    showDialog(
      context: context,
      builder: (d) => SimpleDialog(
        title: Text(context.l.t('currency')),
        children: ['YER', 'USD', 'SAR']
            .map((c) => SimpleDialogOption(
                  onPressed: () {
                    state.setCurrency(c);
                    Navigator.pop(d);
                  },
                  child: Text(c,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                ))
            .toList(),
      ),
    );
  }

  void _showFavorites(BuildContext context) {
    final l = context.l;
    final state = context.watch<AppState>();
    showDialog(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l.t('favorites')),
        content: state.favoriteIds.isEmpty
            ? Text(l.t('noFavorites'))
            : Text(state.favoriteIds.join(' • ')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(d),
              child: Text(l.t('cancel'))),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    final l = context.l;
    showDialog(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l.t('logout')),
        content: Text(l.t('logoutQ')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(d),
              child: Text(l.t('no'))),
          TextButton(
              onPressed: () {
                Navigator.pop(d);
                context.read<AppState>().logout();
                Navigator.of(context, rootNavigator: true)
                    .pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (_) => const UserTypeScreen()),
                        (r) => false);
              },
              child: Text(l.t('yes'),
                  style: const TextStyle(color: TIColors.danger))),
        ],
      ),
    );
  }
}
