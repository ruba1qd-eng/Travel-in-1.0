-- ============================================================
-- Travel In — PostgreSQL Database Schema
-- منصة السفر والتنقل اليمنية
-- ============================================================

-- ============ الجغرافيا ============

CREATE TABLE provinces (
  province_id   SERIAL PRIMARY KEY,
  name_ar       VARCHAR(50) NOT NULL,
  name_en       VARCHAR(50) NOT NULL,
  availability  VARCHAR(20) DEFAULT 'available'
);

CREATE TABLE cities (
  city_id       SERIAL PRIMARY KEY,
  province_id   INT NOT NULL REFERENCES provinces(province_id),
  name_ar       VARCHAR(50) NOT NULL,
  name_en       VARCHAR(50) NOT NULL
);

-- ============ المستخدمون والأمان ============

CREATE TABLE users (
  user_id       SERIAL PRIMARY KEY,
  first_name    VARCHAR(50) NOT NULL,
  second_name   VARCHAR(50) NOT NULL,
  age           INT CHECK (age BETWEEN 10 AND 100),
  phone         VARCHAR(15) UNIQUE,
  email         VARCHAR(100) UNIQUE,
  password_hash VARCHAR(255),
  role          VARCHAR(20) DEFAULT 'customer',
  membership    VARCHAR(20) DEFAULT 'basic',
  created_at    TIMESTAMP DEFAULT NOW()
);

CREATE TABLE roles (
  role_id   SERIAL PRIMARY KEY,
  name      VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE user_roles (
  user_id INT REFERENCES users(user_id),
  role_id INT REFERENCES roles(role_id),
  PRIMARY KEY (user_id, role_id)
);

CREATE TABLE audit_logs (
  log_id     SERIAL PRIMARY KEY,
  user_id    INT REFERENCES users(user_id),
  action     VARCHAR(200),
  old_value  TEXT,
  new_value  TEXT,
  changed_at TIMESTAMP DEFAULT NOW()
);

-- ============ الفنادق ============

CREATE TABLE hotels (
  hotel_id    SERIAL PRIMARY KEY,
  name_ar     VARCHAR(100) NOT NULL,
  province_id INT REFERENCES provinces(province_id),
  rating      NUMERIC(2,1),
  verified    BOOLEAN DEFAULT FALSE,
  lat         NUMERIC(9,6),
  lng         NUMERIC(9,6),
  created_at  TIMESTAMP DEFAULT NOW()
);

CREATE TABLE room_types (
  type_id  SERIAL PRIMARY KEY,
  name_en  VARCHAR(30) NOT NULL,
  name_ar  VARCHAR(30) NOT NULL
);

CREATE TABLE hotel_rooms (
  room_id     SERIAL PRIMARY KEY,
  hotel_id    INT NOT NULL REFERENCES hotels(hotel_id),
  type_id     INT REFERENCES room_types(type_id),
  name        VARCHAR(100),
  bed_type    VARCHAR(50),
  price_night NUMERIC(12,2) NOT NULL,
  capacity    INT,
  amenities   JSONB,
  available   BOOLEAN DEFAULT TRUE
);

CREATE TABLE room_availability (
  availability_id SERIAL PRIMARY KEY,
  room_id   INT REFERENCES hotel_rooms(room_id),
  date      DATE NOT NULL,
  is_booked BOOLEAN DEFAULT FALSE,
  UNIQUE (room_id, date)
);

-- ============ السيارات والسائقون ============

CREATE TABLE car_categories (
  category_id SERIAL PRIMARY KEY,
  name_en     VARCHAR(30),
  name_ar     VARCHAR(30)
);

CREATE TABLE transport_companies (
  company_id SERIAL PRIMARY KEY,
  name_ar    VARCHAR(50),
  name_en    VARCHAR(50)
);

CREATE TABLE drivers (
  driver_id  SERIAL PRIMARY KEY,
  full_name  VARCHAR(100),
  license_no VARCHAR(30),
  rating     NUMERIC(2,1) DEFAULT 4.5
);

CREATE TABLE vehicles (
  vehicle_id  SERIAL PRIMARY KEY,
  name        VARCHAR(100),
  category_id INT REFERENCES car_categories(category_id),
  company_id  INT REFERENCES transport_companies(company_id),
  driver_id   INT REFERENCES drivers(driver_id),
  year        INT,
  seats       INT,
  full_price  NUMERIC(12,2),
  seat_price  NUMERIC(12,2),
  with_driver BOOLEAN DEFAULT TRUE,
  status      VARCHAR(20) DEFAULT 'available'
);

-- ============ الرحلات السياحية ============

CREATE TABLE tours (
  tour_id     SERIAL PRIMARY KEY,
  name        VARCHAR(150),
  province_id INT REFERENCES provinces(province_id),
  days        INT,
  price       NUMERIC(12,2),
  seats_left  INT
);

CREATE TABLE tour_schedules (
  schedule_id SERIAL PRIMARY KEY,
  tour_id     INT REFERENCES tours(tour_id),
  day_no      INT,
  title       VARCHAR(150),
  details     TEXT
);

-- ============ الحجوزات ============

CREATE TABLE bookings (
  booking_id  VARCHAR(10) PRIMARY KEY,
  user_id     INT NOT NULL REFERENCES users(user_id),
  service     VARCHAR(20) NOT NULL,
  title       VARCHAR(200),
  province_id INT REFERENCES provinces(province_id),
  date_text   VARCHAR(50),
  total_yer   NUMERIC(12,2) NOT NULL,
  payment     VARCHAR(20),
  status      VARCHAR(20) DEFAULT 'confirmed',
  created_at  TIMESTAMP DEFAULT NOW()
);

CREATE TABLE booking_items (
  item_id     SERIAL PRIMARY KEY,
  booking_id  VARCHAR(10) REFERENCES bookings(booking_id),
  description VARCHAR(200),
  quantity    INT DEFAULT 1,
  price       NUMERIC(12,2)
);

CREATE TABLE waiting_list (
  waiting_id  SERIAL PRIMARY KEY,
  booking_req VARCHAR(200),
  user_id     INT REFERENCES users(user_id),
  position    INT,
  is_vip      BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMP DEFAULT NOW()
);

-- ============ المدفوعات والمحفظة ============

CREATE TABLE payments (
  payment_id SERIAL PRIMARY KEY,
  booking_id VARCHAR(10) REFERENCES bookings(booking_id),
  method     VARCHAR(20),
  amount     NUMERIC(12,2),
  status     VARCHAR(20) DEFAULT 'pending',
  ref_number VARCHAR(50),
  paid_at    TIMESTAMP
);

CREATE TABLE wallets (
  wallet_id SERIAL PRIMARY KEY,
  user_id   INT UNIQUE REFERENCES users(user_id),
  balance   NUMERIC(14,2) DEFAULT 0,
  currency  VARCHAR(5) DEFAULT 'YER'
);

CREATE TABLE wallet_transactions (
  tx_id      SERIAL PRIMARY KEY,
  wallet_id  INT REFERENCES wallets(wallet_id),
  amount     NUMERIC(12,2),
  reason     VARCHAR(150),
  status     VARCHAR(20) DEFAULT 'completed',
  created_at TIMESTAMP DEFAULT NOW()
);

-- ============ الاشتراكات ============

CREATE TABLE subscription_plans (
  plan_id        SERIAL PRIMARY KEY,
  name           VARCHAR(20),
  price_usd      NUMERIC(6,2),
  priority_level INT
);

CREATE TABLE subscriptions (
  sub_id     SERIAL PRIMARY KEY,
  user_id    INT REFERENCES users(user_id),
  plan_id    INT REFERENCES subscription_plans(plan_id),
  start_date DATE,
  end_date   DATE,
  active     BOOLEAN DEFAULT TRUE
);

-- ============ التقييمات والمفضلة والعروض ============

CREATE TABLE reviews (
  review_id  SERIAL PRIMARY KEY,
  user_id    INT REFERENCES users(user_id),
  target_id  INT,
  stars      INT CHECK (stars BETWEEN 1 AND 5),
  comment    TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE favorites (
  fav_id   SERIAL PRIMARY KEY,
  user_id  INT REFERENCES users(user_id),
  item_id  INT,
  added_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE offers (
  offer_id SERIAL PRIMARY KEY,
  title    VARCHAR(100),
  subtitle VARCHAR(200),
  discount INT,
  active   BOOLEAN DEFAULT TRUE
);

-- ============ العملات وأسعار الصرف ============

CREATE TABLE currencies (
  code VARCHAR(5) PRIMARY KEY,
  name VARCHAR(30)
);

CREATE TABLE exchange_rates (
  rate_id    SERIAL PRIMARY KEY,
  from_cur   VARCHAR(5),
  to_cur     VARCHAR(5),
  rate       NUMERIC(10,4),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- ============ بيانات أساسية ============

INSERT INTO currencies VALUES
  ('YER', 'الريال اليمني'),
  ('USD', 'الدولار الأمريكي'),
  ('SAR', 'الريال السعودي');

INSERT INTO exchange_rates (from_cur, to_cur, rate) VALUES
  ('YER', 'USD', 0.0019),
  ('USD', 'YER', 530.0),
  ('USD', 'SAR', 3.75);

INSERT INTO roles (name) VALUES
  ('customer'), ('driver'), ('partner'),
  ('operations_manager'), ('hotel_manager'),
  ('fleet_manager'), ('finance_manager'),
  ('support'), ('content_manager'), ('super_admin');

INSERT INTO subscription_plans (name, price_usd, priority_level) VALUES
  ('Basic', 0, 10),
  ('Priority', 15, 3),
  ('VIP', 30, 1);

-- ============ فهارس لتسريع الاستعلامات ============

CREATE INDEX idx_bookings_user   ON bookings(user_id);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_rooms_hotel     ON hotel_rooms(hotel_id);
CREATE INDEX idx_avail_room_date ON room_availability(room_id, date);
