import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/demo_data.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'details_screens.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final state = context.watch<AppState>();
    final user = state.user;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        title: Row(children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: TIColors.teal.withOpacity(.15),
            child: Text(
              user?.firstName.isNotEmpty == true
                  ? user!.firstName[0].toUpperCase()
                  : 'T',
              style: const TextStyle(
                  color: TIColors.teal, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${l.t('hello')} ${user?.fullName ?? ''}',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800),
                    overflow: TextOverflow.ellipsis),
                if (user != null)
                  Text('${user.age} ${l.t('years')}',
                      style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).hintColor)),
              ],
            ),
          ),
        ]),
        actions: [
          // مبدّل العملة YER/USD/SAR
          PopupMenuButton<String>(
            onSelected: state.setCurrency,
            icon: Text(state.currency,
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: TIColors.gold,
                    fontSize: 13)),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'YER', child: Text('YER')),
              PopupMenuItem(value: 'USD', child: Text('USD')),
              PopupMenuItem(value: 'SAR', child: Text('SAR')),
            ],
          ),
          Stack(children: [
            IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none)),
            if (state.notifications.isNotEmpty)
              Positioned(
                top: 10,
                end: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: TIColors.danger, shape: BoxShape.circle),
                ),
              ),
          ]),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== البحث =====
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: Theme.of(context).dividerColor.withOpacity(.4)),
              ),
              child: Row(children: [
                const Icon(Icons.search, color: TIColors.teal),
                const SizedBox(width: 10),
                Text(l.t('searchHint'),
                    style: TextStyle(color: Theme.of(context).hintColor)),
              ]),
            ),
          ),
          const SizedBox(height: 20),

          // ===== العروض المميزة (Carousel) =====
          _sectionHeader(l.t('featuredOffers'), onAll: () {}),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: PageView.builder(
              itemCount: kOffers.length,
              controller:
                  PageController(viewportFraction: .88),
              itemBuilder: (_, i) {
                final o = kOffers[i];
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => DetailsScreen(
                          service: o.service, targetId: o.targetId))),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [TIColors.navy, Color(0xFF14335F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: TIColors.gold.withOpacity(.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(o.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w900)),
                        const SizedBox(height: 6),
                        Text(o.subtitle,
                            style: TextStyle(
                                color: Colors.white.withOpacity(.8),
                                fontSize: 12)),
                        const SizedBox(height: 10),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: FilledButton(
                              onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => DetailsScreen(
                                          service: o.service,
                                          targetId: o.targetId))),
                              child: Text(l.t('bookNow'))),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 22),

          // ===== الخدمات =====
          _sectionHeader(l.t('services'), onAll: () {}),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.05,
            children: [
              _service(context, Icons.directions_car, l.t('localRide'),
                  ServiceType.localRide),
              _service(context, Icons.car_rental, l.t('rentCar'),
                  ServiceType.rentCar),
              _service(context, Icons.hotel, l.t('hotels'), ServiceType.hotel),
              _service(context, Icons.flight_takeoff, l.t('airport'),
                  ServiceType.airport),
              _service(context, Icons.map, l.t('tours'), ServiceType.tour),
              _service(context, Icons.card_giftcard, l.t('packages'),
                  ServiceType.package),
            ],
          ),
          const SizedBox(height: 22),

          // ===== المحافظات مع حالة التوفر =====
          _sectionHeader(l.t('provinces'), onAll: () {}),
          const SizedBox(height: 10),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: kProvinces.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final p = kProvinces[i];
                final (color, label) = switch (p.status) {
                  Availability.available => (TIColors.success, l.t('available')),
                  Availability.limited => (TIColors.warning, l.t('limited')),
                  Availability.comingSoon => (TIColors.teal, l.t('comingSoon')),
                  Availability.unavailable => (TIColors.danger, l.t('unavailable')),
                };
                return Container(
                  width: 120,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(.4)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l.province(p.id),
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withOpacity(.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(label,
                            style:
                                TextStyle(fontSize: 10, color: color)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 22),

          // ===== مقترح لك =====
          _sectionHeader(l.t('recommended'), onAll: () {}),
          const SizedBox(height: 10),
          ...kHotels.take(3).map((h) => GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        DetailsScreen(service: ServiceType.hotel, targetId: h.id))),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(.4)),
                  ),
                  child: Row(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(kDemoImg,
                          width: 74,
                          height: 74,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                              width: 74,
                              height: 74,
                              color: TIColors.teal.withOpacity(.15),
                              child: const Icon(Icons.hotel,
                                  color: TIColors.teal))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(h.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(l.province(h.provinceId),
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).hintColor)),
                            const SizedBox(height: 6),
                            Row(children: [
                              const Icon(Icons.star,
                                  size: 15, color: TIColors.gold),
                              const SizedBox(width: 3),
                              Text('${h.rating}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700)),
                              if (!h.verified) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: TIColors.warning.withOpacity(.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(l.t('demoDataBadge'),
                                      style: const TextStyle(fontSize: 9)),
                                ),
                              ],
                            ]),
                          ]),
                    ),
                    Text(l.money(h.rooms.first.pricePerNightYer),
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: TIColors.teal)),
                  ]),
                ),
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, {required VoidCallback onAll}) => Row(
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const Spacer(),
          TextButton(
              onPressed: onAll,
              child: Text(title.contains('Offers') || title.contains('عروض')
                  ? ''
                  : ''),
          ),
        ],
      );

  Widget _service(BuildContext context, IconData icon, String label,
      ServiceType type) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => DetailsScreen(service: type, targetId: 'list'))),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: Theme.of(context).dividerColor.withOpacity(.4)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: TIColors.teal.withOpacity(.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: TIColors.teal, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
