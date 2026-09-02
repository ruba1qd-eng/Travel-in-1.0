/// Travel In — Data Models (Phase 1)
/// كل النماذج جاهزة للربط بـ Backend حقيقي مستقبلاً ( toJson / fromJson )

enum Availability { available, limited, comingSoon, unavailable }
enum ServiceType { localRide, rentCar, hotel, airport, tour, package }
enum BookingStatus { pending, confirmed, assigned, active, completed, cancelled, refunded }
enum PaymentMethod { wallet, cash, kuraimi, digitalWallet }
enum TxStatus { pending, completed, failed, refunded }
enum Membership { basic, priority, vip }

class AppUser {
  final String id;
  final String firstName, secondName;
  final int age;
  final String? phone, email, photoUrl;
  final String role; // customer | developer
  final Membership membership;
  final bool demo;

  AppUser({
    required this.id,
    required this.firstName,
    required this.secondName,
    required this.age,
    this.phone,
    this.email,
    this.photoUrl,
    this.role = 'customer',
    this.membership = Membership.basic,
    this.demo = true,
  });

  String get fullName => '$firstName $secondName';

  Map<String, dynamic> toJson() => {
        'id': id, 'firstName': firstName, 'secondName': secondName, 'age': age,
        'phone': phone, 'email': email, 'photoUrl': photoUrl, 'role': role,
        'membership': membership.name, 'demo': demo,
      };

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: j['id'], firstName: j['firstName'] ?? '', secondName: j['secondName'] ?? '',
        age: (j['age'] as num?)?.toInt() ?? 0,
        phone: j['phone'], email: j['email'], photoUrl: j['photoUrl'],
        role: j['role'] ?? 'customer',
        membership: Membership.values.firstWhere((m) => m.name == j['membership'],
            orElse: () => Membership.basic),
        demo: j['demo'] ?? true,
      );
}

/// عنوان صورة عام — جميع الصور توضيحية (Demo) وليست صوراً حقيقية للفنادق
const String kDemoImg =
    'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=600&q=60';

class Province {
  final String id;
  final Availability status;
  const Province(this.id, this.status);
}

class Hotel {
  final String id, name;
  final String provinceId, cityId;
  final double rating;
  final int reviewsCount;
  final String description;
  final List<String> amenities;
  final List<HotelRoom> rooms;
  final bool verified; // موثّق = بيانات حقيقية، غير موثّق = Demo
  final double lat, lng;

  const Hotel({
    required this.id,
    required this.name,
    required this.provinceId,
    required this.cityId,
    required this.rating,
    required this.reviewsCount,
    required this.description,
    required this.amenities,
    required this.rooms,
    this.verified = false,
    this.lat = 0,
    this.lng = 0,
  });

  Availability get availability => rooms.any((r) => r.available)
      ? Availability.available
      : Availability.limited;
}

class HotelRoom {
  final String id, name, typeId, bedType;
  final double pricePerNightYer;
  final int capacity;
  final List<String> amenities;
  final bool available;

  const HotelRoom({
    required this.id,
    required this.name,
    required this.typeId,
    required this.bedType,
    required this.pricePerNightYer,
    required this.capacity,
    required this.amenities,
    this.available = true,
  });
}

class Car {
  final String id, name, categoryId;
  final int year, seats;
  final double pricePerDayYer;
  final bool withDriver; // true = نقل مع سائق، false = تأجير
  final String transmission, fuel;
  final Availability status;
  final String? driverName;
  final double driverRating;

  const Car({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.year,
    required this.seats,
    required this.pricePerDayYer,
    required this.withDriver,
    this.transmission = 'Automatic',
    this.fuel = 'Petrol',
    this.status = Availability.available,
    this.driverName,
    this.driverRating = 4.8,
  });
}

class Tour {
  final String id, name, provinceId;
  final int days;
  final double priceYer;
  final List<String> includes, excludes;
  final List<TourDay> plan;
  final int seatsLeft;

  const Tour({
    required this.id,
    required this.name,
    required this.provinceId,
    required this.days,
    required this.priceYer,
    required this.includes,
    required this.excludes,
    required this.plan,
    this.seatsLeft = 8,
  });
}

class TourDay {
  final String day, title, details;
  const TourDay(this.day, this.title, this.details);
}

class Offer {
  final String id, title, subtitle;
  final ServiceType service;
  final String targetId;
  final int discountPercent;

  const Offer({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.service,
    required this.targetId,
    required this.discountPercent,
  });
}

class Booking {
  final String id;
  final ServiceType service;
  final String title;
  final String provinceId, cityId;
  final String dateText;
  final double totalYer;
  final PaymentMethod payment;
  final BookingStatus status;
  final String createdAt;
  final Map<String, dynamic> details;

  Booking({
    required this.id,
    required this.service,
    required this.title,
    required this.provinceId,
    required this.cityId,
    required this.dateText,
    required this.totalYer,
    required this.payment,
    this.status = BookingStatus.confirmed,
    required this.createdAt,
    this.details = const {},
  });

  bool get isUpcoming =>
      status == BookingStatus.confirmed || status == BookingStatus.pending;
  bool get isActive => status == BookingStatus.active;

  Map<String, dynamic> toJson() => {
        'id': id, 'service': service.name, 'title': title,
        'provinceId': provinceId, 'cityId': cityId, 'dateText': dateText,
        'totalYer': totalYer, 'payment': payment.name, 'status': status.name,
        'createdAt': createdAt, 'details': details,
      };

  factory Booking.fromJson(Map<String, dynamic> j) => Booking(
        id: j['id'],
        service: ServiceType.values.firstWhere((s) => s.name == j['service'],
            orElse: () => ServiceType.localRide),
        title: j['title'] ?? '',
        provinceId: j['provinceId'] ?? '',
        cityId: j['cityId'] ?? '',
        dateText: j['dateText'] ?? '',
        totalYer: (j['totalYer'] as num?)?.toDouble() ?? 0,
        payment: PaymentMethod.values.firstWhere((p) => p.name == j['payment'],
            orElse: () => PaymentMethod.cash),
        status: BookingStatus.values.firstWhere((s) => s.name == j['status'],
            orElse: () => BookingStatus.confirmed),
        createdAt: j['createdAt'] ?? '',
        details: Map<String, dynamic>.from(j['details'] ?? {}),
      );
}

class WalletTx {
  final String id, reason, createdAt;
  final double amountYer;
  final TxStatus status;

  WalletTx({
    required this.id,
    required this.reason,
    required this.amountYer,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id, 'reason': reason, 'amountYer': amountYer,
        'status': status.name, 'createdAt': createdAt,
      };

  factory WalletTx.fromJson(Map<String, dynamic> j) => WalletTx(
        id: j['id'], reason: j['reason'] ?? '',
        amountYer: (j['amountYer'] as num?)?.toDouble() ?? 0,
        status: TxStatus.values.firstWhere((s) => s.name == j['status'],
            orElse: () => TxStatus.completed),
        createdAt: j['createdAt'] ?? '',
      );
}

class Review {
  final String id, targetId, userName, comment;
  final int stars;

  const Review({
    required this.id,
    required this.targetId,
    required this.userName,
    required this.stars,
    this.comment = '',
  });
}
