import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'details_screens.dart';

/// تبويب استكشاف: بحث موحّد + فلاتر + نتائج كل الخدمات
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _query = '';
  String? _province;
  ServiceType? _type;
  double _maxPriceK = 250; // بالآلاف YER

  @override
  Widget build(BuildContext context) {
    final l = context.l;
  

    // ===== بناء النتائج حسب الفلاتر =====
    final results = <_ResultItem>[];

    for (final h in kHotels) {
      if (_type != null && _type != ServiceType.hotel) continue;
      if (_province != null && h.provinceId != _province) continue;
      if (_query.isNotEmpty &&
          !h.name.toLowerCase().contains(_query.toLowerCase())) continue;
      if (h.rooms.isNotEmpty && h.rooms.first.pricePerNightYer / 1000 > _maxPriceK) {
        continue;
      }
      results.add(_ResultItem(
        id: h.id,
        service: ServiceType.hotel,
        title: h.name,
        subtitle: l.province(h.provinceId),
        rating: h.rating,
        price: h.rooms.isNotEmpty ? h.rooms.first.pricePerNightYer : 0,
        priceUnit: l.t('perNight'),
        verified: h.verified,
      ));
    }

    for (final c in kCars) {
      if (_type != null && _type != (c.withDriver ? ServiceType.localRide : ServiceType.rentCar)) {
        continue;
      }
      if (_province != null) continue; // السيارات Demo عامة
      if (_query.isNotEmpty &&
          !c.name.toLowerCase().contains(_query.toLowerCase())) continue;
      if (c.pricePerDayYer / 1000 > _maxPriceK) continue;
      results.add(_ResultItem(
        id: c.id,
        service: c.withDriver ? ServiceType.localRide : ServiceType.rentCar,
        title: c.name,
        subtitle:
            '${l.carCat(c.categoryId)} • ${c.seats} ${l.t('seats')}',
        rating: c.driverRating,
        price: c.pricePerDayYer,
        priceUnit: l.t('perDay'),
        verified: true,
      ));
    }

    for (final t in kTours) {
      if (_type != null && _type != ServiceType.tour && _type != ServiceType.package) {
        continue;
      }
      if (_province != null && t.provinceId != _province) continue;
      if (_query.isNotEmpty &&
          !t.name.toLowerCase().contains(_query.toLowerCase())) continue;
      if (t.priceYer / 1000 > _maxPriceK * 4) continue;
      results.add(_ResultItem(
        id: t.id,
        service: ServiceType.tour,
        title: t.name,
        subtitle:
            '${l.province(t.provinceId)} • ${t.days} ${l.t('days')}',
        rating: 4.7,
        price: t.priceYer,
        priceUnit: l.t('total'),
        verified: false,
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('explore')),
      ),
      body: Column(children: [
        // ===== خانة البحث =====
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: l.t('searchHint'),
              prefixIcon: const Icon(Icons.search, color: TIColors.teal),
              suffixIcon: IconButton(
                icon: const Icon(Icons.tune, color: TIColors.gold),
                onPressed: _openFilters,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // ===== شرائح نوع الخدمة =====
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _chip(null, l.t('services')),
              _chip(ServiceType.hotel, l.t('hotels')),
              _chip(ServiceType.localRide, l.t('localRide')),
              _chip(ServiceType.rentCar, l.t('rentCar')),
              _chip(ServiceType.tour, l.t('tours')),
              _chip(ServiceType.airport, l.t('airport')),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // ===== النتائج =====
        Expanded(
          child: results.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off,
                          size: 56,
                          color: Theme.of(context).hintColor),
                      const SizedBox(height: 12),
                      Text(l.t('noResults'),
                          style: TextStyle(
                              color: Theme.of(context).hintColor)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final r = results[i];
                    return GestureDetector(
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => DetailsScreen(
                                  service: r.service, targetId: r.id))),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withOpacity(.4)),
                        ),
                        child: Row(children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: TIColors.teal.withOpacity(.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                                switch (r.service) {
                                  ServiceType.hotel => Icons.hotel,
                                  ServiceType.localRide =>
                                    Icons.directions_car,
                                  ServiceType.rentCar => Icons.car_rental,
                                  ServiceType.tour => Icons.map,
                                  ServiceType.airport =>
                                    Icons.flight_takeoff,
                                  _ => Icons.card_giftcard,
                                },
                                color: TIColors.teal),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Expanded(
                                      child: Text(r.title,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w800),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                    if (!r.verified)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: TIColors.warning
                                              .withOpacity(.15),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(l.t('demoDataBadge'),
                                            style: const TextStyle(
                                                fontSize: 9)),
                                      ),
                                  ]),
                                  const SizedBox(height: 4),
                                  Text(r.subtitle,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).hintColor)),
                                  const SizedBox(height: 4),
                                  Row(children: [
                                    const Icon(Icons.star,
                                        size: 14, color: TIColors.gold),
                                    const SizedBox(width: 3),
                                    Text('${r.rating}',
                                        style: const TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700)),
                                  ]),
                                ]),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(l.money(r.price),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: TIColors.teal)),
                              Text(r.priceUnit,
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Theme.of(context).hintColor)),
                            ],
                          ),
                        ]),
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }

  Widget _chip(ServiceType? type, String label) {
    final selected = _type == type;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: GestureDetector(
        onTap: () => setState(() => _type = type),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? TIColors.teal : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: selected
                    ? TIColors.teal
                    : Theme.of(context).dividerColor),
          ),
          child: Text(label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : null,
              )),
        ),
      ),
    );
  }

  void _openFilters() {
    final l = context.l;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(l.t('filters'),
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _province,
              decoration: InputDecoration(
                  labelText: l.t('province'),
                  prefixIcon: const Icon(Icons.public)),
              items: [
                DropdownMenuItem(value: null, child: Text(l.t('all'))),
                ...kProvinces.map((p) => DropdownMenuItem(
                    value: p.id, child: Text(l.province(p.id)))),
              ],
              onChanged: (v) => setSheet(() => _province = v),
            ),
            const SizedBox(height: 16),
            Text('${l.t('price')}: ≤ ${_maxPriceK.toStringAsFixed(0)}K YER',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            Slider(
              value: _maxPriceK,
              min: 20,
              max: 250,
              divisions: 23,
              activeColor: TIColors.teal,
              onChanged: (v) => setSheet(() => _maxPriceK = v),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                    onPressed: () {
                      setSheet(() {
                        _province = null;
                        _maxPriceK = 250;
                      });
                    },
                    child: Text(l.t('reset'))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(context);
                    },
                    child: Text(l.t('apply'))),
              ),
            ]),
            const SizedBox(height: 12),
          ]),
        ),
      ),
    );
  }
}

class _ResultItem {
  final String id, title, subtitle, priceUnit;
  final ServiceType service;
  final double rating, price;
  final bool verified;
  _ResultItem({
    required this.id,
    required this.service,
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.price,
    required this.priceUnit,
    required this.verified,
  });
}
