import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/demo_data.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'booking_screens.dart';

/// شاشة تفاصيل موحّدة: فندق / سيارة / رحلة / مطار
class DetailsScreen extends StatelessWidget {
  final ServiceType service;
  final String targetId;
  const DetailsScreen({super.key, required this.service, required this.targetId});

  @override
  Widget build(BuildContext context) {
    switch (service) {
      case ServiceType.hotel:
        return _HotelDetails(hotelId: targetId);
      case ServiceType.localRide:
      case ServiceType.rentCar:
        return _CarDetails(carId: targetId, withDriver: service == ServiceType.localRide);
      case ServiceType.tour:
      case ServiceType.package:
        return _TourDetails(tourId: targetId);
      case ServiceType.airport:
        return _AirportDetails();
    }
  }
}

// ============================================================
// فندق
// ============================================================
class _HotelDetails extends StatelessWidget {
  final String hotelId;
  const _HotelDetails({required this.hotelId});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final state = context.watch<AppState>();
    final hotel = kHotels.firstWhere((h) => h.id == hotelId);

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          actions: [
            IconButton(
              icon: Icon(
                  state.isFavorite(hotel.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: TIColors.danger),
              onPressed: () => state.toggleFavorite(hotel.id),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Image.network(kDemoImg,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: TIColors.navy)),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(hotel.name,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w900)),
                    ),
                    if (!hotel.verified)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: TIColors.warning.withOpacity(.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(l.t('pendingVerify'),
                            style: const TextStyle(
                                fontSize: 10, color: TIColors.warning)),
                      ),
                  ]),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.star, size: 17, color: TIColors.gold),
                    const SizedBox(width: 4),
                    Text('${hotel.rating} • ${hotel.reviewsCount} ${l.t('reviews')}'),
                    const SizedBox(width: 12),
                    Icon(Icons.location_on_outlined,
                        size: 16, color: Theme.of(context).hintColor),
                    Text(l.province(hotel.provinceId),
                        style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).hintColor)),
                  ]),
                  const SizedBox(height: 16),
                  Text(l.t('description'),
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(hotel.description,
                      style: TextStyle(
                          height: 1.5, color: Theme.of(context).hintColor)),
                  const SizedBox(height: 16),
                  Text(l.t('amenities'),
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: hotel.amenities
                        .map((a) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: TIColors.teal.withOpacity(.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(a,
                                  style: const TextStyle(fontSize: 12)),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  Text(l.t('selectRoom'),
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 10),
                  ...hotel.rooms.map((r) => _roomCard(context, l, hotel, r)),
                  const SizedBox(height: 20),
                ]),
          ),
        ),
      ]),
    );
  }

  Widget _roomCard(BuildContext context, AppLocalizations l, Hotel hotel,
      HotelRoom r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Theme.of(context).dividerColor.withOpacity(.4)),
      ),
      child: Row(children: [
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.name,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(
                    '${l.roomType(r.typeId)} • ${r.bedType} • ${r.capacity} 👤',
                    style: TextStyle(
                        fontSize: 11.5,
                        color: Theme.of(context).hintColor)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  children: r.amenities
                      .take(3)
                      .map((a) => Text('• $a',
                          style: TextStyle(
                              fontSize: 10.5,
                              color: Theme.of(context).hintColor)))
                      .toList(),
                ),
              ]),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(l.money(r.pricePerNightYer),
                style: const TextStyle(
                    fontWeight: FontWeight.w900, color: TIColors.teal)),
            Text(l.t('perNight'),
                style: TextStyle(
                    fontSize: 10, color: Theme.of(context).hintColor)),
            const SizedBox(height: 6),
            r.available
                ? SizedBox(
                    height: 32,
                    child: FilledButton(
                        onPressed: () => _bookRoom(context, l, hotel, r),
                        child: Text(l.t('bookNow'),
                            style: const TextStyle(fontSize: 12))),
                  )
                : Text(l.t('unavailable'),
                    style: const TextStyle(
                        fontSize: 11, color: TIColors.danger)),
          ],
        ),
      ]),
    );
  }

  void _bookRoom(BuildContext context, AppLocalizations l, Hotel hotel,
      HotelRoom room) {
    final nights = 2; // Demo
    final total = room.pricePerNightYer * nights;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => BookingSheet(
        service: ServiceType.hotel,
        title: '${hotel.name} — ${room.name}',
        provinceId: hotel.provinceId,
        cityId: hotel.cityId,
        basePriceYer: total,
        dateLabel: '${l.t('checkIn')} → ${l.t('checkOut')} ($nights ${l.t('days')})',
        details: {'room': room.name, 'nights': nights},
      ),
    );
  }
}

// ============================================================
// سيارة (مع سائق أو تأجير)
// ============================================================
class _CarDetails extends StatelessWidget {
  final String carId;
  final bool withDriver;
  const _CarDetails({required this.carId, required this.withDriver});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final state = context.watch<AppState>();
    final car = kCars.firstWhere((c) => c.id == carId);

    return Scaffold(
      appBar: AppBar(title: Text(withDriver ? l.t('localRide') : l.t('rentCar'))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: TIColors.teal.withOpacity(.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.directions_car_filled,
              size: 80, color: TIColors.teal),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: Text(car.name,
                style:
                    const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
          ),
          IconButton(
            icon: Icon(
                state.isFavorite(car.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: TIColors.danger),
            onPressed: () => state.toggleFavorite(car.id),
          ),
        ]),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _pill(context, l.carCat(car.categoryId)),
          _pill(context, '${car.year}'),
          _pill(context, '${car.seats} ${l.t('seats')}'),
          _pill(context, car.transmission),
          _pill(context, car.fuel),
        ]),
        if (car.status != Availability.available) ...[
          const SizedBox(height: 12),
          Text(l.t('limited'),
              style: const TextStyle(color: TIColors.warning)),
        ],
        if (withDriver && car.driverName != null) ...[
          const SizedBox(height: 16),
          Row(children: [
            const CircleAvatar(
              child: Icon(Icons.person),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${l.t('driver')}: ${car.driverName}'),
                    Row(children: [
                      const Icon(Icons.star, size: 14, color: TIColors.gold),
                      Text(' ${car.driverRating}',
                          style: const TextStyle(fontSize: 12)),
                    ]),
                  ]),
            ),
          ]),
        ],
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.money(car.pricePerDayYer),
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: TIColors.teal)),
            Text(l.t('perDay'),
                style: TextStyle(
                    fontSize: 11, color: Theme.of(context).hintColor)),
          ]),
          FilledButton(
              onPressed: () {
                final days = 1;
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24))),
                  builder: (_) => BookingSheet(
                    service:
                        withDriver ? ServiceType.localRide : ServiceType.rentCar,
                    title: car.name,
                    provinceId: 'sanaa',
                    cityId: 'sanaa_city',
                    basePriceYer: car.pricePerDayYer * days,
                    dateLabel: '$days ${l.t('days')}',
                    details: {'days': days, 'driver': car.driverName},
                  ),
                );
              },
              child: Text(l.t('bookNow'))),
        ]),
      ]),
    );
  }

  Widget _pill(BuildContext context, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Text(text, style: const TextStyle(fontSize: 12)),
      );
}

// ============================================================
// رحلة سياحية
// ============================================================
class _TourDetails extends StatelessWidget {
  final String tourId;
  const _TourDetails({required this.tourId});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final tour = kTours.firstWhere((t) => t.id == tourId);

    return Scaffold(
      appBar: AppBar(title: Text(l.t('tours'))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(tour.name,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text(
            '${l.province(tour.provinceId)} • ${tour.days} ${l.t('days')} • ${tour.seatsLeft} ${l.t('available')}',
            style: TextStyle(color: Theme.of(context).hintColor)),
        const SizedBox(height: 16),
        _listBlock(context, l.t('includes'), tour.includes, TIColors.success),
        const SizedBox(height: 12),
        _listBlock(context, l.t('excludes'), tour.excludes, TIColors.danger),
        const SizedBox(height: 16),
        Text(l.t('dayPlan'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 10),
        ...tour.plan.map((d) => IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(children: [
                    Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                            color: TIColors.gold, shape: BoxShape.circle)),
                    Expanded(
                        child: Container(width: 2, color: TIColors.gold.withOpacity(.4))),
                  ]),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${d.day} — ${d.title}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 2),
                            Text(d.details,
                                style: TextStyle(
                                    fontSize: 12.5,
                                    color: Theme.of(context).hintColor,
                                    height: 1.4)),
                          ]),
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(l.money(tour.priceYer),
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w900, color: TIColors.teal)),
          FilledButton(
              onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24))),
                    builder: (_) => BookingSheet(
                      service: ServiceType.tour,
                      title: tour.name,
                      provinceId: tour.provinceId,
                      cityId: '',
                      basePriceYer: tour.priceYer,
                      dateLabel: '${tour.days} ${l.t('days')}',
                      details: {'days': tour.days},
                    ),
                  ),
              child: Text(l.t('bookNow'))),
        ]),
      ]),
    );
  }

  Widget _listBlock(
      BuildContext context, String title, List<String> items, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: TextStyle(fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 6),
        ...items.map((e) => Text('• $e',
            style: const TextStyle(fontSize: 13, height: 1.6))),
      ]),
    );
  }
}

// ============================================================
// نقل المطار
// ============================================================
class _AirportDetails extends StatelessWidget {
  const _AirportDetails();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final vipCar = kCars.firstWhere((c) => c.id == 'c5');

    return Scaffold(
      appBar: AppBar(title: Text(l.t('airport'))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            border:
                Border.all(color: Theme.of(context).dividerColor.withOpacity(.4)),
          ),
          child: Column(children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'arrival', label: Icon(Icons.flight_land)),
                ButtonSegment(value: 'depart', label: Icon(Icons.flight_takeoff)),
              ],
              selected: const {'arrival'},
            ),
            const SizedBox(height: 16),
            TextField(
                decoration:
                    InputDecoration(labelText: l.t('flightNo'))),
            const SizedBox(height: 12),
            TextField(
                decoration: InputDecoration(labelText: l.t('date'))),
            const SizedBox(height: 12),
            TextField(
                decoration: InputDecoration(labelText: l.t('passengers'))),
            const SizedBox(height: 12),
            TextField(
                decoration: InputDecoration(labelText: l.t('luggage'))),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(l.money(vipCar.pricePerDayYer),
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: TIColors.teal)),
              FilledButton(
                  onPressed: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24))),
                        builder: (_) => BookingSheet(
                          service: ServiceType.airport,
                          title: 'Airport Transfer — ${vipCar.name}',
                          provinceId: 'sanaa',
                          cityId: 'sanaa_city',
                          basePriceYer: vipCar.pricePerDayYer,
                          dateLabel: l.t('oneWay'),
                          details: {'type': 'airport'},
                        ),
                      ),
                  child: Text(l.t('bookNow'))),
            ]),
          ]),
        ),
      ]),
    );
  }
}
