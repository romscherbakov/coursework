USE autosalon;

-- 1. Модели автомобилей: 12 записей
INSERT INTO model
    (model_id, brand, name, release_year)
VALUES
    (1,  'Toyota',    'Camry',       2024),
    (2,  'Toyota',    'Corolla',     2025),
    (3,  'Kia',       'Sportage',    2024),
    (4,  'Kia',       'Rio',         2023),
    (5,  'Hyundai',   'Tucson',      2025),
    (6,  'Hyundai',   'Solaris',     2024),
    (7,  'Volkswagen','Tiguan',      2025),
    (8,  'Volkswagen','Polo',        2024),
    (9,  'Skoda',     'Octavia',     2025),
    (10, 'Skoda',     'Kodiaq',      2024),
    (11, 'Mazda',     'CX-5',        2025),
    (12, 'Mazda',     'Mazda 3',     2024);


-- 2. Комплектации: 12 записей
-- Для первых шести моделей предусмотрено по две комплектации.
INSERT INTO config
    (config_id, name, config_price, description, model_id)
VALUES
    (1,  'Camry Comfort',       2800000.00, 'Базовая комплектация',       1),
    (2,  'Camry Premium',       3400000.00, 'Расширенная комплектация',  1),
    (3,  'Corolla Standard',    1900000.00, 'Базовая комплектация',       2),
    (4,  'Corolla Elegance',    2200000.00, 'Комфортная комплектация',   2),
    (5,  'Sportage Classic',    2600000.00, 'Базовая комплектация',       3),
    (6,  'Sportage Prestige',   3100000.00, 'Расширенная комплектация',  3),
    (7,  'Rio Comfort',         1500000.00, 'Базовая комплектация',       4),
    (8,  'Rio Luxe',            1750000.00, 'Комфортная комплектация',   4),
    (9,  'Tucson Prime',        2900000.00, 'Базовая комплектация',       5),
    (10, 'Tucson High-Tech',    3500000.00, 'Расширенная комплектация',  5),
    (11, 'Solaris Active',      1400000.00, 'Базовая комплектация',       6),
    (12, 'Solaris Comfort',     1650000.00, 'Комфортная комплектация',   6);


-- 3. Автомобили: 12 записей
INSERT INTO car
    (car_id, vin, color, production_year, config_id)
VALUES
    (1,  'JTNB11HK0R3000001', 'Белый',       2024, 1),
    (2,  'JTNB11HK0R3000002', 'Черный',      2024, 2),
    (3,  'JTDBR32E250000003', 'Серебристый', 2025, 3),
    (4,  'JTDBR32E250000004', 'Синий',       2025, 4),
    (5,  'KNAPU81BDR7000005', 'Серый',       2024, 5),
    (6,  'KNAPU81BDR7000006', 'Белый',       2024, 6),
    (7,  'Z94C251BBPR000007', 'Красный',     2023, 7),
    (8,  'Z94C251BBPR000008', 'Серебристый', 2023, 8),
    (9,  'KMHJB81BDFU000009', 'Черный',      2025, 9),
    (10, 'KMHJB81BDFU000010', 'Белый',       2025, 10),
    (11, 'WVGZZZ5NZPW000011', 'Синий',       2024, 11),
    (12, 'WVGZZZ5NZPW000012', 'Серый',       2024, 12);


-- 4. Клиенты: 12 записей
INSERT INTO client
    (client_id, first_name, last_name, phone, email)
VALUES
    (1,  'Иван',      'Петров',       '+79000000001', 'ivan.petrov@example.com'),
    (2,  'Анна',      'Сидорова',     '+79000000002', 'anna.sidorova@example.com'),
    (3,  'Павел',     'Иванов',       '+79000000003', 'pavel.ivanov@example.com'),
    (4,  'Мария',     'Смирнова',     '+79000000004', 'maria.smirnova@example.com'),
    (5,  'Алексей',   'Кузнецов',     '+79000000005', 'alex.kuznetsov@example.com'),
    (6,  'Елена',     'Попова',       '+79000000006', 'elena.popova@example.com'),
    (7,  'Дмитрий',   'Васильев',     '+79000000007', 'dmitry.vasiliev@example.com'),
    (8,  'Ольга',     'Михайлова',    '+79000000008', 'olga.mikhailova@example.com'),
    (9,  'Сергей',    'Новиков',      '+79000000009', 'sergey.novikov@example.com'),
    (10, 'Наталья',   'Федорова',     '+79000000010', 'natalia.fedorova@example.com'),
    (11, 'Андрей',    'Морозов',      '+79000000011', 'andrey.morozov@example.com'),
    (12, 'Татьяна',   'Волкова',      '+79000000012', 'tatiana.volkova@example.com');


-- 5. Сотрудники: 12 записей
INSERT INTO employee
    (employee_id, first_name, last_name, position, phone, email)
VALUES
    (1,  'Артем',     'Орлов',        'Менеджер продаж', '+79100000001', 'artem.orlov@example.com'),
    (2,  'Ирина',     'Белова',       'Менеджер продаж', '+79100000002', 'irina.belova@example.com'),
    (3,  'Михаил',    'Соколов',      'Менеджер продаж', '+79100000003', 'mikhail.sokolov@example.com'),
    (4,  'Юлия',      'Лебедева',     'Менеджер продаж', '+79100000004', 'yulia.lebedeva@example.com'),
    (5,  'Роман',     'Козлов',       'Менеджер продаж', '+79100000005', 'roman.kozlov@example.com'),
    (6,  'Екатерина', 'Семенова',     'Менеджер продаж', '+79100000006', 'ekaterina.semenova@example.com'),
    (7,  'Денис',     'Егоров',       'Консультант',     '+79100000007', 'denis.egorov@example.com'),
    (8,  'Алина',     'Павлова',      'Консультант',     '+79100000008', 'alina.pavlova@example.com'),
    (9,  'Виктор',    'Козлов',       'Консультант',     '+79100000009', 'viktor.kozlov@example.com'),
    (10, 'Светлана',  'Степанова',    'Консультант',     '+79100000010', 'svetlana.stepanova@example.com'),
    (11, 'Никита',    'Николаев',     'Консультант',     '+79100000011', 'nikita.nikolaev@example.com'),
    (12, 'Дарья',     'Захарова',     'Консультант',     '+79100000012', 'daria.zakharova@example.com');


-- 6. Продажи: 6 записей
-- Проданы автомобили с car_id от 1 до 6.
INSERT INTO sale
    (sale_id, sale_price, sale_date, car_id,
     client_id, employee_id, payment_method, sale_status)
VALUES
    (1, 2750000.00, '2026-10-01 10:00:00', 1,  1, 1, 'cash',   'completed'),
    (2, 3300000.00, '2026-10-02 11:30:00', 2,  2, 2, 'credit', 'completed'),
    (3, 1850000.00, '2026-10-03 12:00:00', 3,  3, 3, 'cash',   'completed'),
    (4, 2150000.00, '2026-10-04 14:15:00', 4,  4, 4, 'lease',  'completed'),
    (5, 2550000.00, '2026-10-05 15:00:00', 5,  5, 5, 'credit', 'completed'),
    (6, 3050000.00, '2026-10-06 16:30:00', 6,  6, 6, 'cash',   'completed');


-- 7. Бронирования: 5 записей
-- Зарезервированы автомобили с car_id от 7 до 11.
-- Ни один из них не включен в таблицу sale.
INSERT INTO booking
    (booking_id, car_id, client_id, booking_status,
     booking_date, expiry_date, employee_id)
VALUES
    (1,  7,  7,  'active',    '2026-10-10 10:00:00', '2026-10-17 10:00:00', 7),
    (2,  8,  8,  'confirmed', '2026-10-11 11:00:00', '2026-10-18 11:00:00', 8),
    (3,  9,  9,  'active',    '2026-10-12 12:00:00', '2026-10-19 12:00:00', 9),
    (4, 10, 10,  'confirmed', '2026-10-13 13:00:00', '2026-10-20 13:00:00', 10),
    (5, 11, 11,  'active',    '2026-10-14 14:00:00', '2026-10-21 14:00:00', 11);
