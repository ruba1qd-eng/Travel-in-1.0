import 'models.dart';
import 'demo_data.dart';

/// ============================================================
/// TRAVEL IN — فنادق يمنية بأسماء حقيقية معروفة
/// الأسعار: تقديرية تقريبية حسب السوق — تُحدَّث عند توفر شركاء
/// الصور: توضيحية (Unsplash) — تُستبدل بصور الشركاء فعلياً
/// ============================================================

final List<Hotel> kRealHotels = [
  // ===== صنعاء =====
  Hotel(
    id: 'rh1', name: 'موفنبيك صنعاء Movenpick Sanaa', provinceId: 'sanaa', cityId: 'sanaa_city',
    rating: 4.7, reviewsCount: 850, verified: false,
    description: 'فندق 5 نجوم في حدة صنعاء — إطلالة على المدينة القديمة، مطاعم متعددة، مسبح وصالة رياضية.',
    amenities: ['Wi-Fi', 'مسبح', 'مطعم', 'جيم', 'موقف سيارات', 'Room Service'],
    lat: 15.3480, lng: 44.2060,
    rooms: [
      HotelRoom(id: 'rh1r1', name: 'غرفة Deluxe مزدوجة', typeId: 'double', bedType: 'King Bed', pricePerNightYer: 85000, capacity: 2, amenities: ['Wi-Fi', 'AC', 'إفطار']),
      HotelRoom(id: 'rh1r2', name: 'جناح Executive', typeId: 'suite', bedType: 'King Bed', pricePerNightYer: 160000, capacity: 3, amenities: ['Wi-Fi', 'AC', 'Lounge', 'إفطار']),
      HotelRoom(id: 'rh1r3', name: 'جناح رئاسي', typeId: 'presidential', bedType: 'King Bed', pricePerNightYer: 350000, capacity: 4, amenities: ['Wi-Fi', 'AC', 'VIP Service', 'إفطار'], available: false),
    ],
  ),
  Hotel(
    id: 'rh2', name: 'فندق شيراتون صنعاء Sheraton', provinceId: 'sanaa', cityId: 'sanaa_city',
    rating: 4.6, reviewsCount: 720, verified: false,
    description: 'فندق عريق بمعايير عالمية في قلب صنعاء، قاعات مؤتمرات، مسبح، حدائق واسعة.',
    amenities: ['Wi-Fi', 'مسبح', 'مطاعم', 'مؤتمرات', 'Gym'],
    lat: 15.3520, lng: 44.2000,
    rooms: [
      HotelRoom(id: 'rh2r1', name: 'غرفة Standard', typeId: 'double', bedType: 'Double Bed', pricePerNightYer: 75000, capacity: 2, amenities: ['Wi-Fi', 'AC']),
      HotelRoom(id: 'rh2r2', name: 'غرفة Club Floor', typeId: 'deluxe', bedType: 'King Bed', pricePerNightYer: 120000, capacity: 2, amenities: ['Wi-Fi', 'AC', 'Club Access']),
      HotelRoom(id: 'rh2r3', name: 'جناح عائلي', typeId: 'family', bedType: '2 Beds', pricePerNightYer: 145000, capacity: 4, amenities: ['Wi-Fi', 'AC', 'إفطار']),
    ],
  ),
  Hotel(
    id: 'rh3', name: 'فندق بريميه صنعاء Premiere', provinceId: 'sanaa', cityId: 'sanaa_city',
    rating: 4.4, reviewsCount: 410, verified: false,
    description: 'فندق 4 نجوم حديث قرب شارع الستين، مناسب لرجال الأعمال والعائلات.',
    amenities: ['Wi-Fi', 'مطعم', 'Gym', 'موقف'],
    lat: 15.3290, lng: 44.2310,
    rooms: [
      HotelRoom(id: 'rh3r1', name: 'غرفة مزدوجة', typeId: 'double', bedType: 'Double Bed', pricePerNightYer: 48000, capacity: 2, amenities: ['Wi-Fi', 'AC']),
      HotelRoom(id: 'rh3r2', name: 'غرفة ثلاثية', typeId: 'triple', bedType: '3 Beds', pricePerNightYer: 68000, capacity: 3, amenities: ['Wi-Fi', 'AC']),
    ],
  ),
  Hotel(
    id: 'rh4', name: 'برج السلام صنعاء Burj Al-Salam', provinceId: 'sanaa', cityId: 'sanaa_city',
    rating: 4.3, reviewsCount: 290, verified: false,
    description: 'فندق برجي حديث بإطلالة بانورامية على صنعاء، مطعم دوار في القمة.',
    amenities: ['Wi-Fi', 'مطعم دوار', 'موقف', 'Cafe'],
    lat: 15.3390, lng: 44.2150,
    rooms: [
      HotelRoom(id: 'rh4r1', name: 'غرفة إطلالة', typeId: 'double', bedType: 'King Bed', pricePerNightYer: 52000, capacity: 2, amenities: ['Wi-Fi', 'AC']),
      HotelRoom(id: 'rh4r2', name: 'جناح صغير', typeId: 'suite', bedType: 'King Bed', pricePerNightYer: 95000, capacity: 2, amenities: ['Wi-Fi', 'AC', 'Living Room']),
    ],
  ),

  // ===== عدن =====
  Hotel(
    id: 'rh5', name: 'راديسون بلو عدن Radisson Blu', provinceId: 'aden', cityId: 'aden_crater',
    rating: 4.8, reviewsCount: 960, verified: false,
    description: 'أفخم فنادق عدن على الكورنيش، إطلالة على خليج عدن، مسبح خارجي، مطاعم عالمية.',
    amenities: ['Wi-Fi', 'مسبح', 'شاطئ خاص', 'مطاعم', 'Gym', 'Spa'],
    lat: 12.7900, lng: 45.0250,
    rooms: [
      HotelRoom(id: 'rh5r1', name: 'غرفة Sea View', typeId: 'double', bedType: 'King Bed', pricePerNightYer: 130000, capacity: 2, amenities: ['Wi-Fi', 'AC', 'Sea View', 'إفطار']),
      HotelRoom(id: 'rh5r2', name: 'جناح Bay Suite', typeId: 'suite', bedType: 'King Bed', pricePerNightYer: 220000, capacity: 3, amenities: ['Wi-Fi', 'AC', 'Lounge', 'إفطار']),
      HotelRoom(id: 'rh5r3', name: 'غرفة Twin عائلية', typeId: 'family', bedType: '2 Beds', pricePerNightYer: 165000, capacity: 4, amenities: ['Wi-Fi', 'AC', 'إفطار']),
    ],
  ),
  Hotel(
    id: 'rh6', name: 'فندق كريسنت عدن Crescent', provinceId: 'aden', cityId: 'aden_crater',
    rating: 4.4, reviewsCount: 380, verified: false,
    description: 'فندق كلاسيكي في كريتر عدن، قريب من سوق التوابيت والمواقع التاريخية.',
    amenities: ['Wi-Fi', 'مطعم', 'Cafe', 'موقف'],
    lat: 12.7780, lng: 45.0330,
    rooms: [
      HotelRoom(id: 'rh6r1', name: 'غرفة مزدوجة', typeId: 'double', bedType: 'Double Bed', pricePerNightYer: 62000, capacity: 2, amenities: ['Wi-Fi', 'AC']),
      HotelRoom(id: 'rh6r2', name: 'غرفة Deluxe', typeId: 'deluxe', bedType: 'King Bed', pricePerNightYer: 88000, capacity: 2, amenities: ['Wi-Fi', 'AC', 'View']),
    ],
  ),

  // ===== تعز =====
  Hotel(
    id: 'rh7', name: 'فندق السعيد تعز Al-Saeed', provinceId: 'taiz', cityId: 'taiz_city',
    rating: 4.5, reviewsCount: 540, verified: false,
    description: 'أشهر فنادق تعز، بإطلالة ساحرة على المدينة والجبال.',
    amenities: ['Wi-Fi', 'مطعم', 'موقف', 'Gym'],
    lat: 13.5820, lng: 44.0170,
    rooms: [
      HotelRoom(id: 'rh7r1', name: 'غرفة مزدوجة', typeId: 'double', bedType: 'Double Bed', pricePerNightYer: 45000, capacity: 2, amenities: ['Wi-Fi', 'AC']),
      HotelRoom(id: 'rh7r2', name: 'جناح جبل صابر', typeId: 'suite', bedType: 'King Bed', pricePerNightYer: 82000, capacity: 2, amenities: ['Wi-Fi', 'AC', 'Mountain View']),
    ],
  ),
  Hotel(
    id: 'rh8', name: 'فندق صنعاء للضيافة تعز', provinceId: 'taiz', cityId: 'taiz_city',
    rating: 4.2, reviewsCount: 230, verified: false,
    description: 'فندق مريح في وسط تعز بأسعار اقتصادية ممتازة.',
    amenities: ['Wi-Fi', 'مطعم'],
    lat: 13.5750, lng: 44.0230,
    rooms: [
      HotelRoom(id: 'rh8r1', name: 'غرفة اقتصادية', typeId: 'single', bedType: 'Single Bed', pricePerNightYer: 24000, capacity: 1, amenities: ['Wi-Fi']),
      HotelRoom(id: 'rh8r2', name: 'غرفة مزدوجة', typeId: 'double', bedType: 'Double Bed', pricePerNightYer: 38000, capacity: 2, amenities: ['Wi-Fi', 'AC']),
    ],
  ),

  // ===== حضرموت =====
  Hotel(
    id: 'rh9', name: 'فندق السيالة المكلا Al-Seelah', provinceId: 'hadramout', cityId: 'mukalla',
    rating: 4.4, reviewsCount: 320, verified: false,
    description: 'فندق على كورنيش المكلا مباشرة، إطلالة بحرية وخدمة ممتازة.',
    amenities: ['Wi-Fi', 'شاطئ قريب', 'مطعم', 'Sea View'],
    lat: 14.5380, lng: 49.1300,
    rooms: [
      HotelRoom(id: 'rh9r1', name: 'غرفة Sea View', typeId: 'double', bedType: 'King Bed', pricePerNightYer: 55000, capacity: 2, amenities: ['Wi-Fi', 'AC', 'Sea View']),
      HotelRoom(id: 'rh9r2', name: 'جناح بحري', typeId: 'suite', bedType: 'King Bed', pricePerNightYer: 95000, capacity: 3, amenities: ['Wi-Fi', 'AC', 'Balcony']),
    ],
  ),
  Hotel(
    id: 'rh10', name: 'فندق سيئون Grand Seiyun', provinceId: 'hadramout', cityId: 'seiyun',
    rating: 4.2, reviewsCount: 210, verified: false,
    description: 'فندق تجاري في سيئون قرب قصر السلطان الكثيري وقلعة شِبام التاريخية.',
    amenities: ['Wi-Fi', 'مطعم', 'Tour Desk'],
    lat: 15.9540, lng: 48.8190,
    rooms: [
      HotelRoom(id: 'rh10r1', name: 'غرفة مزدوجة', typeId: 'double', bedType: 'Double Bed', pricePerNightYer: 40000, capacity: 2, amenities: ['Wi-Fi', 'AC']),
      HotelRoom(id: 'rh10r2', name: 'غرفة عائلية', typeId: 'family', bedType: '2 Beds', pricePerNightYer: 62000, capacity: 4, amenities: ['Wi-Fi', 'AC']),
    ],
  ),

  // ===== الحديدة =====
  Hotel(
    id: 'rh11', name: 'فندق كورنيش الحديدة Corniche', provinceId: 'hodeidah', cityId: 'hodeidah_city',
    rating: 4.0, reviewsCount: 150, verified: false,
    description: 'فندق على البحر الأحمر، سمك طازج يومياً وأجواء ريفية ساحلية.',
    amenities: ['Wi-Fi', 'مطعم بحري'],
    lat: 14.8020, lng: 42.9510,
    rooms: [
      HotelRoom(id: 'rh11r1', name: 'غرفة مزدوجة', typeId: 'double', bedType: 'Double Bed', pricePerNightYer: 30000, capacity: 2, amenities: ['Wi-Fi', 'Fan']),
    ],
  ),

  // ===== إب =====
  Hotel(
    id: 'rh12', name: 'فندق خضراء إب Green Ibb', provinceId: 'ibb', cityId: 'ibb_city',
    rating: 4.3, reviewsCount: 180, verified: false,
    description: 'في خضراء إب المعتدلة، هواء منعش وإطلالات جبلية خضراء على مدار السنة.',
    amenities: ['Wi-Fi', 'مطعم', 'Garden'],
    lat: 13.9630, lng: 44.1860,
    rooms: [
      HotelRoom(id: 'rh12r1', name: 'غرفة مزدوجة', typeId: 'double', bedType: 'Double Bed', pricePerNightYer: 32000, capacity: 2, amenities: ['Wi-Fi']),
      HotelRoom(id: 'rh12r2', name: 'جناح جبلي', typeId: 'suite', bedType: 'King Bed', pricePerNightYer: 58000, capacity: 2, amenities: ['Wi-Fi', 'Balcony']),
    ],
  ),

  // ===== مأرب =====
  Hotel(
    id: 'rh13', name: 'فندق مأرب الدولي Marib International', provinceId: 'marib', cityId: 'marib_city',
    rating: 4.5, reviewsCount: 350, verified: false,
    description: 'الوجهة الأولى لرجال الأعمال في مأرب، قرب سد مأرب الأثري.',
    amenities: ['Wi-Fi', 'مطعم', 'Meeting Rooms', 'موقف'],
    lat: 15.4670, lng: 45.3290,
    rooms: [
      HotelRoom(id: 'rh13r1', name: 'غرفة Business', typeId: 'double', bedType: 'King Bed', pricePerNightYer: 65000, capacity: 2, amenities: ['Wi-Fi', 'AC', 'Desk']),
      HotelRoom(id: 'rh13r2', name: 'غرفة Suite', typeId: 'suite', bedType: 'King Bed', pricePerNightYer: 110000, capacity: 2, amenities: ['Wi-Fi', 'AC', 'Living Room']),
    ],
  ),

  // ===== حجة =====
  Hotel(
    id: 'rh14', name: 'فندق حجة المركزي Hajjah Central', provinceId: 'hajjah', cityId: 'houta',
    rating: 4.1, reviewsCount: 95, verified: false,
    description: 'فندق بسيط نظيف في مركز حجة، نقطة انطلاق لرحلات جبال الحيمة.',
    amenities: ['Wi-Fi', 'مطعم'],
    lat: 15.6940, lng: 43.6060,
    rooms: [
      HotelRoom(id: 'rh14r1', name: 'غرفة مزدوجة', typeId: 'double', bedType: 'Double Bed', pricePerNightYer: 28000, capacity: 2, amenities: ['Wi-Fi']),
    ],
  ),

  // ===== ذمار =====
  Hotel(
    id: 'rh15', name: 'فندق ذمار بالاس Damat Palace', provinceId: 'dhamar', cityId: 'dhamar_city',
    rating: 4.2, reviewsCount: 130, verified: false,
    description: 'فندق بلمسة معمارية يمنية قديمة، في مدينة ذمار الباردة.',
    amenities: ['Wi-Fi', 'مطعم تراثي'],
    lat: 14.5690, lng: 44.1970,
    rooms: [
      HotelRoom(id: 'rh15r1', name: 'غرفة تراثية', typeId: 'double', bedType: 'Double Bed', pricePerNightYer: 35000, capacity: 2, amenities: ['Wi-Fi']),
    ],
  ),
];

/// دمج: الفنادق الحقيقية أولاً ثم القديمة التجريبية
List<Hotel> getAllHotels() => [...kRealHotels, ...kHotels];
