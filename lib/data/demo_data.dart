import 'dart:math';
import 'models.dart';

/// ============================================================
/// TRAVEL IN — DEMO DATA (بيئة تطوير فقط)
/// - جميع الأسماء والتوفر توضيحية وليست حقيقية
/// - الأسعار "تقريبية تقديرية" حسب معدلات السوق اليمني
///   وقابلة للتحديث عند توفر بيانات شركاء حقيقية
/// - عند الإطلاق: تُستبدل ببيانات موثّقة من Admin Panel
/// ============================================================

const List<Province> kProvinces = [
  Province('sanaa', Availability.available),
  Province('aden', Availability.available),
  Province('taiz', Availability.available),
  Province('hadramout', Availability.available),
  Province('hodeidah', Availability.available),
  Province('ibb', Availability.available),
  Province('dhamar', Availability.limited),
  Province('marib', Availability.limited),
  Province('lahij', Availability.limited),
  Province('hajjah', Availability.limited),
  Province('amran', Availability.comingSoon),
  Province('sadah', Availability.comingSoon),
  Province('shabwa', Availability.comingSoon),
  Province('abyan', Availability.comingSoon),
  Province('mahrah', Availability.comingSoon),
  Province('rima', Availability.comingSoon),
  Province('bayda', Availability.unavailable),
  Province('dhale', Availability.unavailable),
  Province('jawf', Availability.unavailable),
  Province('socotra', Availability.comingSoon),
];

final List<Hotel> kHotels = [
  Hotel(
    id: 'h1', name: 'Sanaa Grand Hotel', provinceId: 'sanaa', cityId: 'sanaa_city',
    rating: 4.6, reviewsCount: 312, verified: false,
    description: 'Demo hotel in the heart of old Sanaa with traditional architecture.',
    amenities: ['Wi-Fi', 'Parking', 'Restaurant', 'Room Service', 'Gym'],
    lat: 15.3694, lng: 44.1910,
    rooms: [
      HotelRoom(id: 'h1r1', name: 'Standard Single', typeId: 'single', bedType: 'Single Bed', pricePerNightYer: 22000, capacity: 1, amenities: ['Wi-Fi', 'AC']),
      HotelRoom(id: 'h1r2', name: 'Deluxe Double', typeId: 'double', bedType: 'King Bed', pricePerNightYer: 38000, capacity: 2, amenities: ['Wi-Fi', 'AC', 'Breakfast']),
      HotelRoom(id: 'h1r3', name: 'Family Suite', typeId: 'family', bedType: '2 Beds', pricePerNightYer: 62000, capacity: 4, amenities: ['Wi-Fi', 'AC', 'Breakfast', 'Living Room']),
      HotelRoom(id: 'h1r4', name: 'Presidential Suite', typeId: 'presidential', bedType: 'King Bed', pricePerNightYer: 150000, capacity: 2, amenities: ['Wi-Fi', 'AC', 'Lounge', 'VIP Service'], available: false),
    ],
  ),
  Hotel(
    id: 'h2', name: 'Aden Bay Resort', provinceId: 'aden', cityId: 'aden_crater',
    rating: 4.7, reviewsCount: 256, verified: false,
    description: 'Demo seaside resort overlooking Aden bay with pool access.',
    amenities: ['Wi-Fi', 'Pool', 'Restaurant', 'Beach Access', 'Parking'],
    lat: 12.7855, lng: 45.0187,
    rooms: [
      HotelRoom(id: 'h2r1', name: 'Sea View Double', typeId: 'double', bedType: 'King Bed', pricePerNightYer: 52000, capacity: 2, amenities: ['Wi-Fi', 'AC', 'Sea View']),
      HotelRoom(id: 'h2r2', name: 'Twin Room', typeId: 'twin', bedType: '2 Single Beds', pricePerNightYer: 35000, capacity: 2, amenities: ['Wi-Fi', 'AC']),
      HotelRoom(id: 'h2r3', name: 'Deluxe Suite', typeId: 'suite', bedType: 'King Bed', pricePerNightYer: 90000, capacity: 3, amenities: ['Wi-Fi', 'AC', 'Pool Access'], available: false),
    ],
  ),
  Hotel(
    id: 'h3', name: 'Taiz Mountain View', provinceId: 'taiz', cityId: 'taiz_city',
    rating: 4.4, reviewsCount: 178, verified: false,
    description: 'Demo hotel with panoramic mountain views of Taiz city.',
    amenities: ['Wi-Fi', 'Restaurant', 'Parking'],
    lat: 13.5789, lng: 44.0219,
    rooms: [
      HotelRoom(id: 'h3r1', name: 'Standard Double', typeId: 'double', bedType: 'Double Bed', pricePerNightYer: 28000, capacity: 2, amenities: ['Wi-Fi', 'AC']),
      HotelRoom(id: 'h3r2', name: 'Triple Room', typeId: 'triple', bedType: '3 Beds', pricePerNightYer: 42000, capacity: 3, amenities: ['Wi-Fi']),
    ],
  ),
  Hotel(
    id: 'h4', name: 'Mukalla Beach Hotel', provinceId: 'hadramout', cityId: 'mukalla',
    rating: 4.5, reviewsCount: 201, verified: false,
    description: 'Demo coastal hotel near Mukalla corniche.',
    amenities: ['Wi-Fi', 'Restaurant', 'Beach Access', 'Room Service'],
    lat: 14.5425, lng: 49.1242,
    rooms: [
      HotelRoom(id: 'h4r1', name: 'Double Sea View', typeId: 'double', bedType: 'King Bed', pricePerNightYer: 45000, capacity: 2, amenities: ['Wi-Fi', 'AC', 'Sea View']),
      HotelRoom(id: 'h4r2', name: 'Family Room', typeId: 'family', bedType: '2 Beds', pricePerNightYer: 68000, capacity: 5, amenities: ['Wi-Fi', 'AC', 'Breakfast']),
    ],
  ),
  Hotel(
    id: 'h5', name: 'Seiyun Palace Hotel', provinceId: 'hadramout', cityId: 'seiyun',
    rating: 4.3, reviewsCount: 144, verified: false,
    description: 'Demo hotel near the famous Seiyun Palace in Wadi Hadramout.',
    amenities: ['Wi-Fi', 'Restaurant', 'Parking', 'Tour Desk'],
    lat: 15.9575, lng: 48.8162,
    rooms: [
      HotelRoom(id: 'h5r1', name: 'Standard Single', typeId: 'single', bedType: 'Single Bed', pricePerNightYer: 20000, capacity: 1, amenities: ['Wi-Fi']),
      HotelRoom(id: 'h5r2', name: 'Double Room', typeId: 'double', bedType: 'Double Bed', pricePerNightYer: 33000, capacity: 2, amenities: ['Wi-Fi', 'AC']),
    ],
  ),
  Hotel(
    id: 'h6', name: 'Hodeidah Corniche Hotel', provinceId: 'hodeidah', cityId: 'hodeidah_city',
    rating: 4.1, reviewsCount: 98, verified: false,
    description: 'Demo hotel on the Red Sea corniche of Hodeidah.',
    amenities: ['Wi-Fi', 'Restaurant', 'Sea View'],
    lat: 14.7978, lng: 42.9545,
    rooms: [
      HotelRoom(id: 'h6r1', name: 'Double Room', typeId: 'double', bedType: 'Double Bed', pricePerNightYer: 26000, capacity: 2, amenities: ['Wi-Fi', 'AC']),
    ],
  ),
  Hotel(
    id: 'h7', name: 'Ibb Green City Hotel', provinceId: 'ibb', cityId: 'ibb_city',
    rating: 4.2, reviewsCount: 121, verified: false,
    description: 'Demo hotel in the green highlands of Ibb.',
    amenities: ['Wi-Fi', 'Restaurant', 'Garden'],
    lat: 13.9662, lng: 44.1847,
    rooms: [
      HotelRoom(id: 'h7r1', name: 'Standard Double', typeId: 'double', bedType: 'Double Bed', pricePerNightYer: 24000, capacity: 2, amenities: ['Wi-Fi']),
      HotelRoom(id: 'h7r2', name: 'Suite', typeId: 'suite', bedType: 'King Bed', pricePerNightYer: 55000, capacity: 2, amenities: ['Wi-Fi', 'AC', 'Living Room'], available: false),
    ],
  ),
  Hotel(
    id: 'h8', name: 'Marib Business Hotel', provinceId: 'marib', cityId: 'marib_city',
    rating: 4.4, reviewsCount: 156, verified: false,
    description: 'Demo business hotel serving Marib oil sector travelers.',
    amenities: ['Wi-Fi', 'Restaurant', 'Meeting Room', 'Parking'],
    lat: 15.4625, lng: 45.3266,
    rooms: [
      HotelRoom(id: 'h8r1', name: 'Business Single', typeId: 'single', bedType: 'Single Bed', pricePerNightYer: 30000, capacity: 1, amenities: ['Wi-Fi', 'AC', 'Desk']),
      HotelRoom(id: 'h8r2', name: 'Executive Double', typeId: 'double', bedType: 'King Bed', pricePerNightYer: 50000, capacity: 2, amenities: ['Wi-Fi', 'AC', 'Breakfast']),
    ],
  ),
];

final List<Car> kCars = [
  // === نقل مع سائق ===
  Car(id: 'c1', name: 'Toyota Camry 2022', categoryId: 'comfort', year: 2022, seats: 4, pricePerDayYer: 45000, withDriver: true),
  Car(id: 'c2', name: 'Hyundai Sonata 2023', categoryId: 'comfort', year: 2023, seats: 4, pricePerDayYer: 50000, withDriver: true),
  Car(id: 'c3', name: 'Toyota Land Cruiser 2023', categoryId: 'suv', year: 2023, seats: 6, pricePerDayYer: 95000, withDriver: true),
  Car(id: 'c4', name: 'Lexus LX 2023', categoryId: 'luxury', year: 2023, seats: 6, pricePerDayYer: 150000, withDriver: true),
  Car(id: 'c5', name: 'Mercedes S-Class 2022', categoryId: 'vip', year: 2022, seats: 4, pricePerDayYer: 220000, withDriver: true, driverName: 'Ahmed Salem', driverRating: 4.9),
  Car(id: 'c6', name: 'Kia Picanto 2021', categoryId: 'economy', year: 2021, seats: 4, pricePerDayYer: 25000, withDriver: true),
  Car(id: 'c7', name: 'Toyota Hiace Van 2021', categoryId: 'economy', year: 2021, seats: 12, pricePerDayYer: 60000, withDriver: true, status: Availability.limited),
  // === تأجير بدون سائق ===
  Car(id: 'r1', name: 'Toyota Corolla 2022', categoryId: 'economy', year: 2022, seats: 5, pricePerDayYer: 30000, withDriver: false, transmission: 'Automatic'),
  Car(id: 'r2', name: 'Hyundai Elantra 2023', categoryId: 'economy', year: 2023, seats: 5, pricePerDayYer: 35000, withDriver: false),
  Car(id: 'r3', name: 'Toyota Prado 2022', categoryId: 'suv', year: 2022, seats: 7, pricePerDayYer: 85000, withDriver: false, status: Availability.limited),
  Car(id: 'r4', name: 'Toyota Hilux 2023', categoryId: 'suv', year: 2023, seats: 5, pricePerDayYer: 70000, withDriver: false),
  Car(id: 'r5', name: 'Lexus ES 2023', categoryId: 'premium', year: 2023, seats: 5, pricePerDayYer: 120000, withDriver: false, status: Availability.limited),
];

final List<Tour> kTours = [
  Tour(
    id: 't1', name: 'Weekly Hadramout Experience', provinceId: 'hadramout',
    days: 7, priceYer: 850000,
    includes: ['Transport + Driver', '4-Star Hotel', 'Breakfast + Dinner', 'Tour Guide', 'Tourist Sites'],
    excludes: ['Lunch', 'Personal Expenses', 'Flight Tickets'],
    plan: [
      TourDay('Day 1', 'Arrival - Seiyun', 'Airport pickup → Hotel check-in → Welcome dinner'),
      TourDay('Day 2', 'Seiyun & Tarim', 'Seiyun Palace → Tarim Museums → Mudbrick old town walk'),
      TourDay('Day 3', 'Shibam Visit', 'UNESCO Shibam mudbrick city → Sunset viewpoint'),
      TourDay('Day 4', 'Wadi Doan', 'Cliff villages → Traditional honey farms → Lunch in palm gardens'),
      TourDay('Day 5', 'Mukalla Coast', 'Beach day → Corniche → Seafood dinner'),
      TourDay('Day 6', 'Desert Experience', 'Dune trip → Camel ride → Stargazing dinner'),
      TourDay('Day 7', 'Farewell', 'Souvenir shopping → Airport transfer'),
    ],
    seatsLeft: 6,
  ),
  Tour(
    id: 't2', name: 'Sanaa Heritage Weekend', provinceId: 'sanaa',
    days: 3, priceYer: 320000,
    includes: ['Transport', 'Hotel', 'Breakfast', 'Old City Guided Tour'],
    excludes: ['Lunch', 'Dinner', 'Museum Tickets'],
    plan: [
      TourDay('Day 1', 'Old Sanaa', 'Old city walk → Souq Al-Milh → National Museum'),
      TourDay('Day 2', 'Highlands', 'Jabal Sabr viewpoint → Traditional crafts workshop'),
      TourDay('Day 3', 'Markets & Farewell', 'Shopping → Traditional dinner → Departure'),
    ],
    seatsLeft: 10,
  ),
  Tour(
    id: 't3', name: 'Aden Coastal Escape', provinceId: 'aden',
    days: 4, priceYer: 420000,
    includes: ['Transport', 'Beach Hotel', 'Breakfast', 'City Tour'],
    excludes: ['Lunch', 'Personal Expenses'],
    plan: [
      TourDay('Day 1', 'Aden Arrival', 'Hotel check-in → Crater district walk'),
      TourDay('Day 2', 'Aden Beaches', 'Big Ben → Sira fortress → Sunset beach'),
      TourDay('Day 3', 'Water Activities', 'Swimming → Boat trip → Seafood lunch'),
      TourDay('Day 4', 'Departure', 'Free morning → Airport transfer'),
    ],
    seatsLeft: 4,
  ),
];

final List<Offer> kOffers = [
  Offer(id: 'o1', title: 'Luxury Weekend in Aden', subtitle: 'Hotel + Private Car — 20% OFF', service: ServiceType.hotel, targetId: 'h2', discountPercent: 20),
  Offer(id: 'o2', title: 'Hadramout Weekly Tour', subtitle: 'Full package — 15% OFF', service: ServiceType.tour, targetId: 't1', discountPercent: 15),
  Offer(id: 'o3', title: 'VIP Airport Pickup', subtitle: 'S-Class transfer — 25% OFF', service: ServiceType.airport, targetId: 'c5', discountPercent: 25),
  Offer(id: 'o4', title: 'Rent 3 Days Pay 2', subtitle: 'Self-drive offer', service: ServiceType.rentCar, targetId: 'r1', discountPercent: 33),
];

/// إحداثيات عواصم المحافظات — لحساب المسافات التقريبية
const Map<String, List<double>> kProvinceCoords = {
  'sanaa': [15.3694, 44.1910], 'aden': [12.7855, 45.0187], 'taiz': [13.5789, 44.0219],
  'hadramout': [14.5425, 49.1242], 'hodeidah': [14.7978, 42.9545], 'ibb': [13.9662, 44.1847],
  'dhamar': [14.5686, 44.1972], 'marib': [15.4625, 45.3266], 'shabwa': [14.9958, 46.6625],
  'abyan': [13.6258, 46.9403], 'lahij': [13.5367, 44.7339], 'mahrah': [16.1272, 52.1683],
  'rima': [14.6303, 43.7303], 'hajjah': [15.6945, 43.6058], 'amran': [15.6539, 43.9436],
  'sadah': [16.9375, 43.7642], 'bayda': [14.3458, 45.5758], 'dhale': [13.7075, 44.7303],
  'jawf': [16.0172, 44.9311], 'socotra': [12.6519, 54.0244],
};

/// المسافة التقريبية بالكيلومتر بين محافظتين (Haversine)
double distanceKm(String a, String b) {
  final p1 = kProvinceCoords[a];
  final p2 = kProvinceCoords[b];
  if (p1 == null || p2 == null) return 0;
  const r = 6371.0;
  double rad(double d) => d * pi / 180;
  final dLat = rad(p2[0] - p1[0]);
  final dLng = rad(p2[1] - p1[1]);
  final s = sin(dLat / 2) * sin(dLat / 2) +
      cos(rad(p1[0])) * cos(rad(p2[0])) * sin(dLng / 2) * sin(dLng / 2);
  return 2 * r * asin(sqrt(s));
}

/// تقدير مدة الرحلة: متوسط سرعة 65 كم/س + معامل طرق 1.25
int travelMinutes(double km) => ((km * 1.25) / 65 * 60).round();
