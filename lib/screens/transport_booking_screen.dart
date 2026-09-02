import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/demo_data.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'booking_screens.dart';

/// ===== شركات النقل (Demo — قابلة للتحديث من الإدارة) =====
class TCompany {
  final String ar, en;
  const TCompany(this.ar, this.en);
}

const List<TCompany> kTransportCompanies = [
  TCompany('أرحب', 'Arhab'),
  TCompany('الوسام', 'Al-Wisam'),
  TCompany('الشركة اليمنية', 'Al-Yemenia'),
  TCompany('VIP', 'VIP'),
];

/// ===== سيارات النقل — أسعار تقريبية (YER) =====
class TCar {
  final String ar, en, imgId;
  final double fullPriceYer, seatPriceYer;
  const TCar(this.ar, this.en, this.fullPriceYer, this.seatPriceYer, this.imgId);
}

const List<TCar> kTransportCars = [
  TCar('لكزس', 'Lexus', 160000, 48000, 'photo-1550355291-bbee04a92027'),
  TCar('لاند كروزر', 'Land Cruiser', 150000, 40000, 'photo-1519641471654-76ce0107ad1b'),
  TCar('برادو', 'Prado', 135000, 35000, 'photo-1519641471654-76ce0107ad1b'),
  TCar('فورتشنر', 'Fortuner', 120000, 27000, 'photo-1568605117036-5fe5e7bab0b7'),
];

const List<String> kTimeSlots = [
  '7:00 ص', '10:00 ص', '1:00 م', '4:00 م', '8:00 م',
];

/// ===== شاشة حجز النقل: شركة ← سيارة ← مقاعد ← مسار ← موعد ← دفع =====
class TransportBookingScreen extends StatefulWidget {
  const TransportBookingScreen({super.key});
  @override
  State<TransportBookingScreen> createState() => _TransportBookingScreenState();
}

class _TransportBookingScreenState extends State<TransportBookingScreen> {
  int? _company;
  int? _car;
  bool _whole = true;
  int _seats = 1;
  String? _from, _to;
  DateTime? _date;
  String _time = kTimeSlots[1];

  TCar? get car => _car == null ? null : kTransportCars[_car!];

  double get price {
    final c = car;
    if (c == null) return 0;
    return _whole ? c.fullPriceYer : c.seatPriceYer * _seats;
  }

  double? get dist =>
      (_from != null && _to != null && _from != _to) ? distanceKm(_from!, _to!) : null;

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (d != null) setState(() => _date = d);
  }

  void _swap() => setState(() {
        final t = _from;
        _from = _to;
        _to = t;
      });

  void _continue() {
    final l = context.l;
    void err(String m) =>
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
    if (_company == null) return err(l.t('errCompany'));
    if (_car == null) return err(l.t('errCar'));
    if (_from == null || _to == null) return err(l.t('chooseCity'));
    if (_from == _to) return err(l.t('sameCity'));
    if (_date == null) return err(l.t('errRequired'));

    final c = car!;
    final comp = kTransportCompanies[_company!];
    final compName = l.isArabic ? comp.ar : comp.en;
    final carName = l.isArabic ? c.ar : c.en;
    final fromName = l.province(_from!);
    final toName = l.province(_to!);
    String two(int n) => n.toString().padLeft(2, '0');
    final dateText =
        '${two(_date!.day)}/${two(_date!.month)}/${_date!.year} — $_time';

    final typeLabel = _whole
        ? l.t('wholeCar')
        : (_seats == 1 ? l.t('seatOne') : '$_seats ${l.t('seatsMany')}');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => BookingSheet(
        service: ServiceType.localRide,
        title: '$compName • $carName: $fromName → $toName ($typeLabel)',
        provinceId: _from!,
        cityId: '',
        basePriceYer: price,
        dateLabel: dateText,
        details: {
          'company': compName,
          'car': carName,
          'type': _whole ? 'whole' : 'seats',
          'seats': _whole ? 0 : _seats,
          'km': dist?.toStringAsFixed(0),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final state = context.watch<AppState>();
    final dark = Theme.of(context).brightness == Brightness.dark;
    final d = dist;
    final mins = d == null ? null : travelMinutes(d);

    return Scaffold(
      appBar: AppBar(title: Text(l.t('localRide'))),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(l.t('total'),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800)),
              Text(l.money(price),
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: TIColors.teal)),
            ]),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: _continue, child: Text(l.t('continuePay'))),
          ]),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (state.membership == Membership.vip)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: TIColors.gold.withOpacity(.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TIColors.gold),
              ),
              child: Row(children: [
                const Icon(Icons.workspace_premium,
                    size: 18, color: TIColors.gold),
                const SizedBox(width: 8),
                Text(
                    l.isArabic
                        ? 'عضو VIP — أولوية الحجز عند الامتلاء'
                        : 'VIP member — priority when full',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: TIColors.gold)),
              ]),
            ),

          // ===== 1) شركة النقل =====
          _title(l.isArabic ? '1) اختر شركة النقل' : '1) Transport company'),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 3.2,
            children: [
              for (var i = 0; i < kTransportCompanies.length; i++)
                _pick(
                  selected: _company == i,
                  label: l.isArabic
                      ? kTransportCompanies[i].ar
                      : kTransportCompanies[i].en,
                  onTap: () => setState(() => _company = i),
                ),
            ],
          ),
          const SizedBox(height: 18),

          // ===== 2) السيارة =====
          _title(l.isArabic ? '2) اختر السيارة' : '2) Choose car'),
          const SizedBox(height: 8),
          ...List.generate(kTransportCars.length, (i) {
            final c = kTransportCars[i];
            final sel = _car == i;
            return GestureDetector(
              onTap: () => setState(() => _car = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: sel
                      ? TIColors.teal.withOpacity(.08)
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: sel
                          ? TIColors.teal
                          : Theme.of(context).dividerColor.withOpacity(.4),
                      width: sel ? 1.6 : 1),
                ),
                child: Row(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                        'https://images.unsplash.com/${c.imgId}?w=200&q=60',
                        width: 64,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                            width: 64,
                            height: 52,
                            color: TIColors.teal.withOpacity(.12),
                            child: const Icon(Icons.directions_car,
                                color: TIColors.teal))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.isArabic ? c.ar : c.en,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text(
                              '${l.t('wholeCar')}: ${l.money(c.fullPriceYer)} • ${l.t('perSeat')}: ${l.money(c.seatPriceYer)}',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).hintColor)),
                        ]),
                  ),
                  Icon(
                      sel
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: sel
                          ? TIColors.teal
                          : Theme.of(context).hintColor),
                ]),
              ),
            );
          }),
          const SizedBox(height: 18),

          // ===== 3) نوع الحجز =====
          _title(l.isArabic ? '3) نوع الحجز' : '3) Booking type'),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: _pick(
                selected: _whole,
                label: l.t('wholeCar'),
                onTap: () => setState(() => _whole = true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _pick(
                selected: !_whole,
                label: l.t('perSeat'),
                onTap: () => setState(() => _whole = false),
              ),
            ),
          ]),
          if (!_whole) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: dark ? Colors.white10 : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(.4)),
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l.t('seatsCount'),
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Row(children: [
                      IconButton(
                          onPressed: _seats > 1
                              ? () => setState(() => _seats--)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline)),
                      Text('$_seats',
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w900)),
                      IconButton(
                          onPressed: _seats < 4
                              ? () => setState(() => _seats++)
                              : null,
                          icon: const Icon(Icons.add_circle_outline)),
                    ]),
                  ]),
            ),
          ],
          const SizedBox(height: 18),

          // ===== 4) المسار =====
          _title(l.isArabic ? '4) المسار' : '4) Route'),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
                child: _provinceDrop(
                    value: _from,
                    label: l.t('from'),
                    onChanged: (v) => setState(() => _from = v))),
            IconButton(onPressed: _swap, icon: const Icon(Icons.swap_horiz)),
            Expanded(
                child: _provinceDrop(
                    value: _to,
                    label: l.t('to'),
                    onChanged: (v) => setState(() => _to = v))),
          ]),
          if (d != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TIColors.teal.withOpacity(.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(children: [
                const Icon(Icons.straighten,
                    size: 18, color: TIColors.teal),
                const SizedBox(width: 8),
                Text('≈ ${d.toStringAsFixed(0)} ${l.t('km')}'),
                const SizedBox(width: 16),
                const Icon(Icons.schedule,
                    size: 18, color: TIColors.teal),
                const SizedBox(width: 8),
                Text('≈ ${l.duration(mins!)}'),
              ]),
            ),
          ],
          const SizedBox(height: 18),

          // ===== 5) التاريخ والوقت =====
          _title(l.isArabic ? '5) الموعد' : '5) Date & time'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: dark ? Colors.white10 : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(.4)),
              ),
              child: Row(children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 10),
                Text(
                  _date == null
                      ? l.t('date')
                      : '${_date!.day}/${_date!.month}/${_date!.year}',
                  style: TextStyle(
                      color: _date == null
                          ? Theme.of(context).hintColor
                          : null),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: kTimeSlots.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final sel = _time == kTimeSlots[i];
                return GestureDetector(
                  onTap: () => setState(() => _time = kTimeSlots[i]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: sel
                          ? TIColors.teal
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel
                              ? TIColors.teal
                              : Theme.of(context).dividerColor),
                    ),
                    child: Text(kTimeSlots[i],
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: sel ? Colors.white : null)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(l.t('demoNote'),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10.5, color: Theme.of(context).hintColor)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _title(String s) => Text(s,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800));

  Widget _pick(
      {required bool selected,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: selected
              ? TIColors.teal.withOpacity(.12)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected
                  ? TIColors.teal
                  : Theme.of(context).dividerColor.withOpacity(.4),
              width: selected ? 1.6 : 1),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: selected ? TIColors.teal : null)),
      ),
    );
  }

  Widget _provinceDrop({
    required String? value,
    required String label,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final p in kProvinces)
          DropdownMenuItem(
              value: p.id, child: Text(context.l.province(p.id))),
      ],
      onChanged: onChanged,
    );
  }
}
