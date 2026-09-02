import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/demo_data.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Travel In — Admin/Developer Portal (Phase 1 Demo)
class DeveloperDashboard extends StatelessWidget {
  const DeveloperDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final ar = l.isArabic;
    final state = context.watch<AppState>();
    String bi(String a, String e) => ar ? a : e;

    final availableCars =
        kCars.where((c) => c.status == Availability.available).length;
    final availableRooms = kHotels
        .expand((h) => h.rooms)
        .where((r) => r.available)
        .length;

    final kpis = [
      _Kpi(bi('المستخدمون', 'Users'), '1,240', Icons.people, TIColors.teal),
      _Kpi(bi('حجوزات اليوم', "Today's Bookings"), '18',
          Icons.receipt_long, TIColors.gold),
      _Kpi(bi('إيراد الشهر', 'Monthly Revenue'), l.money(4200000),
          Icons.trending_up, TIColors.success),
      _Kpi(bi('سيارات متاحة', 'Cars Available'), '$availableCars',
          Icons.directions_car, TIColors.teal),
      _Kpi(bi('غرف متاحة', 'Rooms Available'), '$availableRooms',
          Icons.hotel, TIColors.gold),
      _Kpi(bi('رحلات نشطة', 'Active Trips'), '3', Icons.map, TIColors.teal),
    ];

    final sections = [
      (Icons.hotel, bi('إدارة الفنادق والغرف', 'Hotels & Rooms')),
      (Icons.directions_car, bi('إدارة السيارات', 'Fleet Management')),
      (Icons.badge_outlined, bi('إدارة السائقين', 'Drivers')),
      (Icons.receipt_long, bi('إدارة الحجوزات', 'Bookings')),
      (Icons.price_change, bi('إدارة الأسعار', 'Pricing')),
      (Icons.local_offer_outlined, bi('العروض والمحتوى', 'Offers & Content')),
      (Icons.bar_chart, bi('التقارير والتحليلات', 'Reports & Analytics')),
      (Icons.history, bi('سجل التدقيق', 'Audit Logs')),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel In — Admin'),
        actions: [
          IconButton(
            onPressed: () => state.toggleTheme(),
            icon: Icon(state.isDark ? Icons.light_mode : Icons.dark_mode),
          ),
          IconButton(
            onPressed: () => state.toggleLanguage(),
            icon: Text(ar ? 'EN' : 'ع',
                style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${bi('مرحباً', 'Welcome')} ${state.user?.firstName ?? ''} 👋',
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            bi('بيئة تجريبية — الأرقام توضيحية فقط',
                'Demo environment — figures are illustrative only'),
            style: TextStyle(
                fontSize: 12, color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: kpis.map((k) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(children: [
                      Icon(k.icon, size: 17, color: k.color),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(k.label,
                            style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).hintColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    Text(k.value,
                        style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            color: k.color)),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),
          Text(bi('الإدارة السريعة', 'Quick Management'),
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          ...sections.map((s) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(.4)),
              ),
              child: ListTile(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(bi(
                          'هذا القسم يعمل بالكامل في المرحلة الثانية مع Backend حقيقي',
                          'This section is fully enabled in Phase 2 with a real backend'))),
                ),
                leading: Icon(s.$1, color: TIColors.teal),
                title: Text(s.$2,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right, size: 20),
              ),
            );
          }),
          const SizedBox(height: 12),
          Text(l.t('demoNote'),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10.5, color: Theme.of(context).hintColor)),
        ],
      ),
    );
  }
}

class _Kpi {
  final String label, value;
  final IconData icon;
  final Color color;
  const _Kpi(this.label, this.value, this.icon, this.color);
}
