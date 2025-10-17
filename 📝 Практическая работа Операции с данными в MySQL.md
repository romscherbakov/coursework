# Практическая работа: Операции с данными в MySQL

## База данных "Автосалон"

В этой практической работе вы будете работать с базой данных автосалона, которая включает следующие таблицы:
- `model` - модели автомобилей
- `config` - комплектации моделей  
- `car` - конкретные автомобили в наличии
- `client` - клиенты автосалона
- `agent` - агенты по продажам
- `booking` - бронирования автомобилей
- `sale` - продажи автомобилей
- `service` - сервисное обслуживание

---

## 📝 Часть 1: Добавление данных (INSERT)

### 1.1 Добавление моделей автомобилей

```sql
-- Добавляем основные модели автомобилей
INSERT INTO model (brand, model_name, year) VALUES
('Toyota', 'Camry', 2024),
('BMW', 'X5', 2024),
('Mercedes-Benz', 'E-Class', 2024),
('Audi', 'A6', 2024),
('Honda', 'CR-V', 2024);
```

### 1.2 Добавление комплектаций

```sql
-- Добавляем комплектации для каждой модели
INSERT INTO config (model_id, name, config_price, description) VALUES
(1, 'Standart', 2800000.00, 'Базовая комплектация'),
(1, 'Comfort', 3200000.00, 'Комфортная комплектация с климат-контролем'),
(1, 'Premium', 3800000.00, 'Премиум комплектация с кожаным салоном'),
(2, 'xDrive30d', 5500000.00, 'Дизельная версия с полным приводом'),
(2, 'xDrive40i', 6200000.00, 'Бензиновая версия с полным приводом');
```

### 1.3 Добавление клиентов

```sql
-- Добавляем клиентов автосалона
INSERT INTO client (first_name, last_name, phone, email) VALUES
('Иван', 'Петров', '+7-912-345-67-89', 'ivan.petrov@mail.ru'),
('Мария', 'Сидорова', '+7-923-456-78-90', 'maria.sidorova@gmail.com'),
('Алексей', 'Кузнецов', '+7-934-567-89-01', 'aleksey.kuznetsov@yandex.ru'),
('Екатерина', 'Волкова', '+7-945-678-90-12', 'ekaterina.volkova@mail.ru');
```

### 1.4 Добавление агентов

```sql
-- Добавляем агентов по продажам
INSERT INTO agent (first_name, last_name, position, phone, email) VALUES
('Дмитрий', 'Смирнов', 'Старший менеджер', '+7-911-111-11-11', 'dmitry.smirnov@autosalon.ru'),
('Ольга', 'Иванова', 'Менеджер по продажам', '+7-922-222-22-22', 'olga.ivanova@autosalon.ru'),
('Сергей', 'Попов', 'Менеджер', '+7-933-333-33-33', 'sergey.popov@autosalon.ru');
```

### 1.5 Добавление автомобилей в наличии

```sql
-- Добавляем конкретные автомобили
INSERT INTO car (id_config, vin, color, model_year, final_price, status) VALUES
(1, 'JTDKBRFU902345678', 'Белый', 2024, 2850000.00, 'available'),
(2, 'JTDKBRFU902345679', 'Черный', 2024, 3250000.00, 'available'),
(3, 'WBA12345678901234', 'Серый', 2024, 3850000.00, 'available'),
(4, 'WBA12345678901235', 'Синий', 2024, 5550000.00, 'in_transit'),
(5, 'WBA12345678901236', 'Красный', 2024, 6250000.00, 'booked');
```

### 1.6 Добавление бронирований

```sql
-- Добавляем бронирования
INSERT INTO booking (car_id, client_id, agent_id, status, booking_date, expiry_date) VALUES
(5, 1, 1, 'active', '2024-01-15 10:00:00', '2024-01-22 10:00:00'),
(3, 2, 2, 'confirmed', '2024-01-14 14:30:00', '2024-01-21 14:30:00');
```

---

## 🗑️ Часть 2: Удаление данных (DELETE)

### 2.1 Простое удаление

```sql
-- Удаляем клиента (осторожно - может нарушить целостность данных!)
DELETE FROM client WHERE client_id = 4;
```

### 2.2 Безопасное удаление с проверкой связей

```sql
-- Проверяем, есть ли связанные записи перед удалением
SELECT * FROM booking WHERE client_id = 4;
SELECT * FROM sale WHERE client_id = 4;

-- Если связанных записей нет, можно удалить
DELETE FROM client WHERE client_id = 4;
```

## ✏️ Часть 3: Обновление данных (UPDATE)

### 3.1 Обновление цен

```sql
-- Повышаем цены на все комплектации на 5%
UPDATE config SET config_price = config_price * 1.05;

-- Обновляем финальную цену автомобиля
UPDATE car SET final_price = 3000000.00 WHERE car_id = 1;
```

### 3.2 Обновление статусов

```sql
-- Изменяем статус автомобиля на "продан"
UPDATE car SET status = 'sold' WHERE car_id = 3;

-- Обновляем статус бронирования
UPDATE booking SET status = 'completed' WHERE book_id = 1;
```

### 3.3 Обновление информации о клиентах

```sql
-- Обновляем email клиента
UPDATE client SET email = 'new.email@mail.ru' WHERE client_id = 1;

-- Обновляем телефон нескольких клиентов
UPDATE client SET phone = '+7-999-999-99-99' 
WHERE client_id IN (2, 3);
```
---

## 🎯 Задания для самостоятельной работы

### Задание 1: Добавление данных
1. Добавьте 3 новые модели автомобилей разных марок
2. Создайте по 2 комплектации для каждой новой модели
3. Добавьте 5 новых автомобилей в наличии
4. Зарегистрируйте 3 новых клиента
5. Создайте 2 новых бронирования

### Задание 2: Обновление данных
1. Увеличьте цены всех комплектаций на 10%
2. Обновите контактные данные для двух клиентов

### Задание 3: Удаление данных
1. Попробуйте удалить клиента, у которого есть активные бронирования
2. Удалите автомобиль, который не связан с бронированиями или продажами
3. Удалите комплектацию, которая не используется в автомобилях
---

## 📊 Проверка результатов

После выполнения заданий проверьте свои данные:

```sql
-- Проверка моделей и комплектаций
SELECT m.brand, m.model_name, c.name, c.config_price
FROM model m
JOIN config c ON m.model_id = c.model_id;

-- Проверка автомобилей в наличии
SELECT c.car_id, m.brand, m.model_name, conf.name, c.color, c.status, c.final_price
FROM car c
JOIN config conf ON c.id_config = conf.config_id
JOIN model m ON conf.model_id = m.model_id;

-- Проверка бронирований
SELECT b.book_id, cl.first_name, cl.last_name, m.brand, m.model_name, b.status
FROM booking b
JOIN client cl ON b.client_id = cl.client_id
JOIN car c ON b.car_id = c.car_id
JOIN config conf ON c.id_config = conf.config_id
JOIN model m ON conf.model_id = m.model_id;
```

Удачи в выполнении заданий! 🚗💨