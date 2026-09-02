import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';

class AppState extends ChangeNotifier {
  final SharedPreferences prefs;
  late AppLocalizations l10n;
  static AppState? instance;
  AppState(this.prefs) {
    instance = this;
  }

  // ===== إعدادات عامة =====
  Locale _locale = const Locale('ar');
  ThemeMode _themeMode = ThemeMode.system;
  String _currency = 'YER';

  // ===== المستخدم =====
  AppUser? user;

  // ===== البيانات =====
  List<Booking> bookings = [];
  List<WalletTx> txs = [];
  double walletBalanceYer = 100000; // رصيد تجريبي ترحيبي (Demo)
  Set<String> favoriteIds = {};
  List<String> notifications = [];

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  String get currency => _currency;
  bool get isRTL => _locale.languageCode == 'ar';
  bool get isDark => _themeMode == ThemeMode.dark;
  Membership get membership => user?.membership ?? Membership.basic;

  // ============ التحميل والحفظ ============
  void load() {
    final l = prefs.getString('locale');
    if (l == 'en') _locale = const Locale('en');
    final t = prefs.getString('theme');
    if (t == 'light') _themeMode = ThemeMode.light;
    if (t == 'dark') _themeMode = ThemeMode.dark;
    _currency = prefs.getString('currency') ?? 'YER';
    final u = prefs.getString('user');
    if (u != null) {
      try { user = AppUser.fromJson(jsonDecode(u)); } catch (_) {}
    }
    final b = prefs.getString('bookings');
    if (b != null) {
      try { bookings = (jsonDecode(b) as List).map((e) => Booking.fromJson(e)).toList(); } catch (_) {}
    }
    final tx = prefs.getString('txs');
    if (tx != null) {
      try { txs = (jsonDecode(tx) as List).map((e) => WalletTx.fromJson(e)).toList(); } catch (_) {}
    }
    walletBalanceYer = prefs.getDouble('wallet') ?? 100000;
    favoriteIds = (prefs.getStringList('favorites') ?? []).toSet();
    notifyListeners();
  }

  // ============ اللغة والثيم والعملة ============
  void setLocale(Locale loc) {
    _locale = loc;
    prefs.setString('locale', loc.languageCode);
    notifyListeners();
  }

  void toggleLanguage() => setLocale(
      _locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar'));

  void setThemeMode(ThemeMode m) {
    _themeMode = m;
    prefs.setString('theme', m.name);
    notifyListeners();
  }

  void toggleTheme() => setThemeMode(
      _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);

  void setCurrency(String c) {
    _currency = c;
    prefs.setString('currency', c);
    notifyListeners();
  }

  // ============ المصادقة ============
  void login(AppUser u) {
    user = u;
    prefs.setString('user', jsonEncode(u.toJson()));
    notifyListeners();
  }

  // تعديل الملف الشخصي — يدعم الاسم والإيميل والرقم والصورة
  void updateProfile({
    String? firstName,
    String? secondName,
    int? age,
    String? phone,
    String? email,
    String? photoUrl,
  }) {
    if (user == null) return;
    user = AppUser(
      id: user!.id,
      firstName: firstName ?? user!.firstName,
      secondName: secondName ?? user!.secondName,
      age: age ?? user!.age,
      phone: phone ?? user!.phone,
      email: email ?? user!.email,
      photoUrl: photoUrl ?? user!.photoUrl,
      role: user!.role,
      membership: user!.membership,
    );
    prefs.setString('user', jsonEncode(user!.toJson()));
    notifyListeners();
  }

  void logout() {
    user = null;
    prefs.remove('user');
    notifyListeners();
  }

  // ============ المفضلة ============
  bool isFavorite(String id) => favoriteIds.contains(id);

  void toggleFavorite(String id) {
    if (favoriteIds.contains(id)) {
      favoriteIds.remove(id);
    } else {
      favoriteIds.add(id);
    }
    prefs.setStringList('favorites', favoriteIds.toList());
    notifyListeners();
  }

  // ============ المحفظة ============
  void addMoney(double yer) {
    walletBalanceYer += yer;
    prefs.setDouble('wallet', walletBalanceYer);
    txs.insert(0, WalletTx(
      id: _txId(), reason: 'Wallet top-up', amountYer: yer,
      status: TxStatus.completed, createdAt: _now(),
    ));
    _saveTxs();
    notifyListeners();
  }

  void _chargeWallet(double yer, String reason) {
    walletBalanceYer -= yer;
    prefs.setDouble('wallet', walletBalanceYer);
    txs.insert(0, WalletTx(
      id: _txId(), reason: reason, amountYer: -yer,
      status: TxStatus.completed, createdAt: _now(),
    ));
    _saveTxs();
  }

  void _saveTxs() {
    prefs.setString('txs', jsonEncode(txs.map((e) => e.toJson()).toList()));
  }

  // ============ الحجوزات ============
  /// يحاول الدفع من المحفظة؛ يرجع false إذا الرصيد غير كافٍ
  bool createBooking({
    required ServiceType service,
    required String title,
    required String provinceId,
    required String cityId,
    required String dateText,
    required double totalYer,
    required PaymentMethod payment,
    Map<String, dynamic> details = const {},
  }) {
    if (payment == PaymentMethod.wallet) {
      if (walletBalanceYer < totalYer) return false;
      _chargeWallet(totalYer, 'Booking: $title');
    } else {
      txs.insert(0, WalletTx(
        id: _txId(), reason: 'Booking: $title', amountYer: totalYer,
        status: TxStatus.pending, createdAt: _now(),
      ));
      _saveTxs();
    }
    final b = Booking(
      id: 'TI-${10000 + Random().nextInt(90000)}',
      service: service, title: title,
      provinceId: provinceId, cityId: cityId,
      dateText: dateText, totalYer: totalYer, payment: payment,
      status: BookingStatus.confirmed, createdAt: _now(),
      details: details,
    );
    bookings.insert(0, b);
    prefs.setString('bookings', jsonEncode(bookings.map((e) => e.toJson()).toList()));
    notifications.insert(0, '✅ $title (${b.id})');
    notifyListeners();
    return true;
  }

  void cancelBooking(String id) {
    final i = bookings.indexWhere((b) => b.id == id);
    if (i == -1) return;
    final b = bookings[i];
    // استرداد إذا كان الدفع بالمحفظة (سياسة مبسطة للعرض)
    if (b.payment == PaymentMethod.wallet) {
      walletBalanceYer += b.totalYer;
      prefs.setDouble('wallet', walletBalanceYer);
      txs.insert(0, WalletTx(
        id: _txId(), reason: 'Refund: ${b.title}', amountYer: b.totalYer,
        status: TxStatus.refunded, createdAt: _now(),
      ));
      _saveTxs();
    }
    bookings[i] = Booking(
      id: b.id, service: b.service, title: b.title,
      provinceId: b.provinceId, cityId: b.cityId, dateText: b.dateText,
      totalYer: b.totalYer, payment: b.payment,
      status: BookingStatus.cancelled, createdAt: b.createdAt,
      details: b.details,
    );
    prefs.setString('bookings', jsonEncode(bookings.map((e) => e.toJson()).toList()));
    notifyListeners();
  }

  // ============ أدوات مساعدة ============
  String _txId() => 'TX-${Random().nextInt(900000) + 100000}';
  String _now() {
    final d = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }
}
