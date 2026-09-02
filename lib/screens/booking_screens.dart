import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';

/// ============ ورقة الحجز والدفع (Bottom Sheet) ============
class BookingSheet extends StatefulWidget {
  final ServiceType service;
  final String title, provinceId, cityId, dateLabel;
  final double basePriceYer;
  final Map<String, dynamic> details;

  const BookingSheet({
    super.key,
    required this.service,
    required this.title,
    required this.provinceId,
    required this.cityId,
    required this.basePriceYer,
    required this.dateLabel,
    this.details = const {},
  });

  @override
  State<BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<BookingSheet> {
  PaymentMethod _pay = PaymentMethod.cash;
  final _ref = TextEditingController();

  @override
  void dispose() {
    _ref.dispose();
    super.dispose();
  }

  void _confirm() {
    final l = context.l;
    final state = context.read<AppState>();

    if ((_pay == PaymentMethod.kuraimi || _pay == PaymentMethod.digitalWallet) &&
        _ref.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.t('errRequired'))));
      return;
    }

    final ok = state.createBooking(
      service: widget.service,
      title: widget.title,
      provinceId: widget.provinceId,
      cityId: widget.cityId,
      dateText: widget.dateLabel,
      totalYer: widget.basePriceYer,
      payment: _pay,
      details: {
        ...widget.details,
        if (_ref.text.trim().isNotEmpty) 'ref': _ref.text.trim(),
      },
    );

    Navigator.pop(context);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.t('insufficient'))));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ConfirmationScreen(
              bookingId: 'LAST',
              title: widget.title,
              totalYer: widget.basePriceYer,
            )));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final state = context.watch<AppState>();

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Center(
            child: SizedBox(
                width: 40,
                height: 4,
                child: ClipRRect(
                    child: LinearProgressIndicator(value: 1))),
          ),
          const SizedBox(height: 14),
          Text(widget.title,
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(widget.dateLabel,
              style: TextStyle(
                  fontSize: 12.5, color: Theme.of(context).hintColor)),
          const Divider(height: 24),

          Text(l.t('paymentMethod'),
              style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          _payTile(PaymentMethod.cash, Icons.payments, l.t('cashOnService')),
          _payTile(PaymentMethod.wallet, Icons.account_balance_wallet,
              '${l.t('walletPay')} — ${l.money(state.walletBalanceYer)}'),
          _payTile(PaymentMethod.kuraimi, Icons.account_balance, l.t('kuraimi')),
          _payTile(PaymentMethod.digitalWallet, Icons.phone_android,
              l.t('digitalWallet')),

          if (_pay == PaymentMethod.kuraimi ||
              _pay == PaymentMethod.digitalWallet) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _ref,
              decoration: InputDecoration(
                  labelText: l.t('depositRef'),
                  prefixIcon: const Icon(Icons.receipt_long)),
            ),
          ],

          const SizedBox(height: 18),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(l.t('total'),
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800)),
            Text(l.money(widget.basePriceYer),
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: TIColors.teal)),
          ]),
          const SizedBox(height: 14),
          ElevatedButton(
              onPressed: _confirm, child: Text(l.t('confirmBooking'))),
          const SizedBox(height: 8),
          Text(l.t('demoNote'),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10.5, color: Theme.of(context).hintColor)),
        ]),
      ),
    );
  }

  Widget _payTile(PaymentMethod m, IconData icon, String label) {
    final sel = _pay == m;
    return GestureDetector(
      onTap: () => setState(() => _pay = m),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: sel ? TIColors.teal.withOpacity(.08) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: sel ? TIColors.teal : Theme.of(context).dividerColor,
              width: sel ? 1.6 : 1),
        ),
        child: Row(children: [
          Icon(icon, size: 20, color: sel ? TIColors.teal : null),
          const SizedBox(width: 10),
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600))),
          Icon(
              sel ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 20,
              color: sel ? TIColors.teal : Theme.of(context).hintColor),
        ]),
      ),
    );
  }
}

/// ============ شاشة تأكيد الحجز + QR ============
class ConfirmationScreen extends StatelessWidget {
  final String bookingId, title;
  final double totalYer;

  const ConfirmationScreen({
    super.key,
    required this.bookingId,
    required this.title,
    required this.totalYer,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final state = context.watch<AppState>();
    // آخر حجز هو الحجز المنشأ للتو
    final booking =
        state.bookings.isNotEmpty ? state.bookings.first : null;
    final id = booking?.id ?? bookingId;

    return Scaffold(
      appBar: AppBar(title: Text(l.t('bookingConfirmed'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                  color: TIColors.success, shape: BoxShape.circle),
              child: const Icon(Icons.check, size: 54, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text(l.t('bookingConfirmed'),
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).hintColor)),
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: TIColors.gold, width: 1.5),
              ),
              child: QrImageView(
                data: 'TRAVELIN|$id|${totalYer.toStringAsFixed(0)}',
                size: 170,
                eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square, color: TIColors.navy),
                dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: TIColors.navy),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
              child: Text('${l.t('bookingId')}: $id',
                  style: const TextStyle(fontWeight: FontWeight.w900))),
          const SizedBox(height: 4),
          Text(l.t('showQr'),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12, color: Theme.of(context).hintColor)),
          const SizedBox(height: 24),
          ElevatedButton(
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MainShell()),
                  (r) => false),
              child: Text(l.t('backHome'))),
        ],
      ),
    );
  }
}

/// ============ تبويب حجوزاتي ============
class BookingsTab extends StatelessWidget {
  const BookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final state = context.watch<AppState>();
    final bookings = state.bookings;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.t('myBookings')),
          bottom: TabBar(
              labelColor: TIColors.teal,
              unselectedLabelColor: Theme.of(context).hintColor,
              indicatorColor: TIColors.teal,
              isScrollable: true,
              tabs: [
                Tab(text: l.t('upcoming')),
                Tab(text: l.t('active')),
                Tab(text: l.t('completed')),
                Tab(text: l.t('cancelled')),
              ]),
        ),
        body: bookings.isEmpty
            ? Center(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.confirmation_number_outlined,
                          size: 64, color: Theme.of(context).hintColor),
                      const SizedBox(height: 12),
                      Text(l.t('noBookings'),
                          style: const TextStyle(
                              fontWeight: FontWeight.w800)),
                      Text(l.t('noBookingsHint'),
                          style: TextStyle(
                              fontSize: 12.5,
                              color: Theme.of(context).hintColor)),
                    ]),
              )
            : TabBarView(children: [
                _list(context, bookings.where((b) => b.isUpcoming).toList()),
                _list(context,
                    bookings.where((b) => b.isActive).toList()),
                _list(context,
                    bookings.where((b) => b.status == BookingStatus.completed).toList()),
                _list(context,
                    bookings.where((b) => b.status == BookingStatus.cancelled).toList()),
              ]),
      ),
    );
  }

  Widget _list(BuildContext context, List<Booking> list) {
    final l = context.l;
    if (list.isEmpty) {
      return Center(
          child: Text(l.t('noBookings'),
              style: TextStyle(color: Theme.of(context).hintColor)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final b = list[i];
        final cancelled = b.status == BookingStatus.cancelled;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(.4)),
          ),
          child: Row(children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: TIColors.teal.withOpacity(.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                  switch (b.service) {
                    ServiceType.hotel => Icons.hotel,
                    ServiceType.localRide => Icons.directions_car,
                    ServiceType.rentCar => Icons.car_rental,
                    ServiceType.tour => Icons.map,
                    ServiceType.airport => Icons.flight_takeoff,
                    _ => Icons.card_giftcard,
                  },
                  color: TIColors.teal),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.title,
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            decoration:
                                cancelled ? TextDecoration.lineThrough : null),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text('${b.id} • ${b.dateText}',
                        style: TextStyle(
                            fontSize: 11.5,
                            color: Theme.of(context).hintColor)),
                  ]),
            ),
            Text(l.money(b.totalYer),
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: cancelled
                        ? Theme.of(context).hintColor
                        : TIColors.teal)),
            if (!cancelled)
              IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => _cancel(context, b.id)),
          ]),
        );
      },
    );
  }

  void _cancel(BuildContext context, String id) {
    final l = context.l;
    showDialog(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l.t('cancelBooking')),
        content: Text(l.t('cancelSure')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(d),
              child: Text(l.t('no'))),
          TextButton(
              onPressed: () {
                context.read<AppState>().cancelBooking(id);
                Navigator.pop(d);
              },
              child: Text(l.t('yes'),
                  style: const TextStyle(color: TIColors.danger))),
        ],
      ),
    );
  }
}
