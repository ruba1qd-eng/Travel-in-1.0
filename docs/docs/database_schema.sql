Travel In — ERD & Database Schema

(مخطط الكيانات والعلاقات ومخطط قاعدة البيانات)

1. نظرة عامة

قاعدة بيانات علائقية (PostgreSQL) تدعم منظومة Travel In — تطبيق عميل + موقع + لوحة إدارة + بوابة شركاء + واجهة سائق،جميعها على نفس القاعدة (حساب موحد).

2. مخطط ERD — العلاقات الرئيسية

USERS (المستخدمون) ├──1:N──> USER_PROFILES (بيانات الملف الشخصي) ├──1:N──> BOOKINGS (الحجوزات) ├──1:1──> WALLETS (المحفظة) │ └──1:N──> WALLET_TRANSACTIONS (المعاملات) ├──1:N──> REVIEWS (التقييمات) ├──1:N──> FAVORITES (المفضلة) ├──1:N──> SUBSCRIPTIONS (الاشتراكات) └──1:N──> SUPPORT_TICKETS (الدعم الفني)

PROVINCES (المحافظات) ──1:N──> CITIES (المدن) │ └──1:N──> HOTELS (الفنادق) ├──1:N──> HOTEL_ROOMS (الغرف) │ └──1:N──> ROOM_AVAILABILITY (توفر الأيام) └──1:N──> HOTEL_IMAGES (الصور)

CARS (السيارات) ──N:1──> CAR_CATEGORIES (فئات السيارات) ├──N:1──> DRIVERS (السائقون) └──N:1──> PARTNERS (الشركاء)

TOURS (الرحلات) ──1:N──> TOUR_PACKAGES (الباقات) └──1:N──> TOUR_SCHEDULES (البرنامج اليومي)

BOOKINGS ──N:1──> {HOTELS | CARS | TOURS} BOOKINGS ──1:1──> PAYMENTS (المدفوعات) BOOKINGS ──1:N──> BOOKING_ITEMS (تفاصيل الحجز)

ROLES ──N:M──> USERS (عبر جدول USER_ROLES — RBAC)

---

## 3. كيانات النظام (38 جدولاً)

### أ) المستخدمون والأمان
| الجدول | الوصف | العلاقات |
|--------|-------|----------|
| users | جميع المستخدمين (عميل/سائق/مدير...) | 1:N مع كل شيء |
| user_profiles | الاسم الأول والثاني والعمر والصورة | 1:1 مع users |
| roles | الأدوار (12 دوراً) | N:M مع users |
| user_roles | جدول وسيط للصلاحيات | يربط users و roles |
| permissions | صلاحيات النظام | N:M مع roles |
| audit_logs | سجل كل عملية إدارية | 1:N مع users |

### ب) الجغرافيا
| الجدول | الوصف |
|--------|-------|
| provinces | 20 محافظة يمنية |
| cities | المدن داخل كل محافظة |

### ج) الفنادق
| الجدول | الوصف |
|--------|-------|
| hotels | الفنادق (15-20 لكل محافظة مستقبلاً) |
| hotel_rooms | الغرف والأجنحة بأنواعها |
| room_types | Single/Double/Suite/Presidential... |
| room_availability | توفر كل يوم (Calendar — منع الحجز المزدوج) |
| hotel_images | صور الفندق والغرف (source, license, verified) |

### د) السيارات والسائقون
| الجدول | الوصف |
|--------|-------|
| car_categories | Economy/Comfort/Premium/Luxury/SUV/VIP |
| vehicles | السيارات بحالتها (available/rented/maintenance) |
| drivers | السائقون وترخيصهم وتقييمهم |
| transport_companies | أرحب/الوسام/اليمنية/VIP |
| trips | الرحلات الجارية (تتبع مباشر مستقبلاً) |

### هـ) الرحلات السياحية
| الجدول | الوصف |
|--------|-------|
| tours | الرحلات (حضرموت 7 أيام...) |
| tour_packages | الباقات والأسعار |
| tour_schedules | البرنامج اليومي (Day 1...Day 7) |

### و) الحجوزات والمدفوعات
| الجدول | الوصف |
|--------|-------|
| bookings | كل الحجوزات بكل حالاتها |
| booking_items | تفاصيل كل حجز (غرفة/مقاعد/أيام) |
| payments | المدفوعات (cash/kuraimi/wallet/jaib/onCash) |
| waiting_list | قائمة الانتظار — VIP أولاً (Priority Queue) |

### ز) المالية
| الجدول | الوصف |
|--------|-------|
| wallets | محفظة كل مستخدم |
| wallet_transactions | كل حركة مالية (إيداع/خصم/استرداد) |
| currencies | YER/USD/SAR |
| exchange_rates | أسعار الصرف — قابلة للتحديث من الإدارة |
| subscription_plans | Basic/Priority/VIP ($30/سنة) |
| subscriptions | اشتراكات العملاء |
| partner_payouts | مستحقات الشركاء بعد العمولة |

### ح) المحتوى والدعم
| الجدول | الوصف |
|--------|-------|
| offers | العروض في الصفحة الرئيسية (ميدان إعلانات) |
| reviews | التقييمات 1-5 نجوم |
| favorites | المفضلة |
| notifications | الإشعارات |
| support_tickets | تذاكر الدعم |

---

## 4. قواعد التصميم

### Normalization (التسوية)
- **1NF**: كل خلية قيمة واحدة (لا قوائم داخل خلايا)
- **2NF**: لا اعتماد جزئي على المفتاح المركب
- **3NF**: لا اعتماد انتقالي (سعر الصرف في جدول مستقل وليس في الحجوزات)

### الاستثناءات العملية المتعمدة
- amenities في hotel_rooms مصفوفة JSONB — لأنها خصائص وصفية غير قابلة للاستعلام الثقيل
- O宗旨: التوازن بين النظرية والأداء (Denormalization محسوبة)

### منع الحجز المزدوج (Double Booking)
- جدول room_availability يُقفل الصف (Row Lock) أثناء الحجز
- Constraint: لا يمكن حجز نفس الغرفة بنفس التاريخ مرتين
- UNIQUE (room_id, date) في جدول الحجوزات اليومية

### الأمان
- Password Hashing (bcrypt) — لا كلمات مرور صريحة
- RBAC صارم: role يتحقق منه الخادم لا الواجهة
- Audit Logs لكل عملية إدارية (من غيّر ماذا ومتى)
