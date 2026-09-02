Travel In — ERD & Database Schema

مخطط الكيانات والعلاقات ومخطط قاعدة البيانات

1. نظرة عامة

قاعدة بيانات علائقية (PostgreSQL) تدعم منظومة Travel In:تطبيق عميل + موقع ويب + لوحة إدارة + بوابة شركاء + واجهة سائق،جميعها تعمل على نفس القاعدة ونفس الحساب الموحد.

2. مخطط ERD — العلاقات الرئيسية

USERS (المستخدمون)

1:N مع USER_PROFILES (الملف الشخصي)
1:N مع BOOKINGS (الحجوزات)
1:1 مع WALLETS (المحفظة) — ثم 1:N مع WALLET_TRANSACTIONS
1:N مع REVIEWS (التقييمات)
1:N مع FAVORITES (المفضلة)
1:N مع SUBSCRIPTIONS (الاشتراكات)
1:N مع SUPPORT_TICKETS (الدعم)
PROVINCES (المحافظات) — 1:N مع CITIES (المدن)

1:N مع HOTELS (الفنادق)
1:N مع HOTEL_ROOMS (الغرف)
1:N مع ROOM_AVAILABILITY (توفّر الأيام)
1:N مع HOTEL_IMAGES (الصور)
CARS (السيارات) — N:1 مع CAR_CATEGORIES (الفئات)

N:1 مع DRIVERS (السائقون)
N:1 مع PARTNERS (الشركاء)
TOURS (الرحلات) — 1:N مع TOUR_PACKAGES (الباقات)

1:N مع TOUR_SCHEDULES (البرنامج اليومي)
BOOKINGS — N:1 مع HOTELS أو CARS أو TOURSBOOKINGS — 1:1 مع PAYMENTS (المدفوعات)BOOKINGS — 1:N مع BOOKING_ITEMS (تفاصيل الحجز)

ROLES — N:M مع USERS (عبر USER_ROLES — RBAC)

3. جداول النظام (38 جدولاً)

أ) المستخدمون والأمان

الجدول	الوصف	العلاقة
users	جميع المستخدمين (عميل/سائق/مدير)	1:N مع الأنظمة
user_profiles	الاسم الأول والثاني والعمر والصورة	1:1 مع users
roles	الأدوار (12 دوراً)	N:M مع users
user_roles	جدول وسيط يربط users و roles	يربط الصلاحيات
permissions	صلاحيات النظام التفصيلية	N:M مع roles
audit_logs	سجل كل عملية إدارية	N:1 مع users
ب) الجغرافيا

الجدول	الوصف
provinces	20 محافظة يمنية
cities	المدن داخل كل محافظة
ج) الفنادق

الجدول	الوصف
hotels	الفنادق (15–20 لكل محافظة مستقبلاً)
hotel_rooms	الغرف والأجنحة بأنواعها وأسعارها
room_types	Single / Double / Suite / Presidential
room_availability	توفّر كل يوم (Calendar — منع الحجز المزدوج)
hotel_images	صور الفندق والغرف (source, license, verified)
د) السيارات والسائقون

الجدول	الوصف
car_categories	Economy / Comfort / Premium / Luxury / SUV / VIP
vehicles	السيارات وحالتها (available / rented / maintenance)
drivers	السائقون وترخيصهم وتقييمهم
transport_companies	أرحب / الوسام / اليمنية / VIP
trips	الرحلات الجارية (تتبع مباشر مستقبلاً)
هـ) الرحلات السياحية

الجدول	الوصف
tours	الرحلات (حضرموت 7 أيام...)
tour_packages	الباقات والأسعار
tour_schedules	البرنامج اليومي (Day 1 ... Day 7)
و) الحجوزات والمدفوعات

الجدول	الوصف
bookings	كل الحجوزات بكل حالاتها
booking_items	تفاصيل كل حجز (غرفة / مقاعد / أيام)
payments	المدفوعات (cash / kuraimi / wallet / jaib / oneCash)
waiting_list	قائمة الانتظار — VIP أولاً (Priority Queue)
ز) المالية

الجدول	الوصف
wallets	محفظة كل مستخدم
wallet_transactions	كل حركة مالية (إيداع / خصم / استرداد)
currencies	YER / USD / SAR
exchange_rates	أسعار الصرف — قابلة للتحديث من الإدارة
subscription_plans	Basic / Priority / VIP (30$ سنوياً)
subscriptions	اشتراكات العملاء
partner_payouts	مستحقات الشركاء بعد العمولة
ح) المحتوى والدعم

الجدول	الوصف
offers	العروض في الصفحة الرئيسية (مساحة إعلانات)
reviews	التقييمات 1–5 نجوم
favorites	المفضلة
notifications	الإشعارات
support_tickets	تذاكر الدعم الفني
4. قواعد التصميم

التسوية (Normalization)

1NF: كل خلية تحتوي قيمة واحدة (لا قوائم داخل الخلايا)
2NF: لا اعتماد جزئي على المفتاح المركب
3NF: لا اعتماد انتقالي (سعر الصرف في جدول مستقل لا داخل الحجوزات)
الاستثناءات العملية المتعمدة

amenities في hotel_rooms مصفوفة JSONB — لأنها خصائص وصفية غير قابلة للاستعلامات الثقيلة، والهدف التوازن بين النظرية والأداء (Denormalization محسوبة)
منع الحجز المزدوج (Double Booking)

جدول room_availability يُقفل الصف (Row Lock) أثناء عملية الحجز
Constraint: لا يمكن حجز نفس الغرفة بنفس التاريخ مرتين
UNIQUE (room_id, date) في جدول الحجوزات اليومية
الأمان

Password Hashing (bcrypt) — لا كلمات مرور صريحة أبداً
RBAC صارم: الدور يتحقق منه الخادم وليس الواجهة فقط
Audit Logs لكل عملية إدارية (من غيّر ماذا ومتى)
