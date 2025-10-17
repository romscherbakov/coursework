# Шпаргалка: Управление пользователями и привилегиями в MySQL

## 🔐 Создание пользователей

```sql
-- Создать пользователя с паролем
CREATE USER 'username'@'host' IDENTIFIED BY 'password';

-- Примеры:
CREATE USER 'ivan'@'localhost' IDENTIFIED BY 'securepass123';
CREATE USER 'app_user'@'%' IDENTIFIED BY 'apppass';  -- доступ с любого хоста
CREATE USER 'remote'@'192.168.1.%' IDENTIFIED BY 'remotepass';  -- доступ с подсети
```

## 👁️ Просмотр пользователей

```sql
-- Список всех пользователей
SELECT user, host FROM mysql.user;

-- Информация о привилегиях пользователя
SHOW GRANTS FOR 'username'@'host';
```

## 🛡️ Назначение привилегий

```sql
-- Базовый синтаксис
GRANT privilege_type ON database.table TO 'username'@'host';

-- Примеры привилегий:
GRANT SELECT ON mydb.* TO 'user'@'localhost';
GRANT INSERT, UPDATE ON mydb.users TO 'user'@'localhost';
GRANT ALL PRIVILEGES ON mydb.* TO 'admin'@'localhost';
```

### Основные типы привилегий:

| Привилегия | Описание |
|------------|----------|
| `SELECT` | Чтение данных |
| `INSERT` | Вставка данных |
| `UPDATE` | Обновление данных |
| `DELETE` | Удаление данных |
| `CREATE` | Создание таблиц/БД |
| `DROP` | Удаление таблиц/БД |
| `ALTER` | Изменение структуры |
| `ALL PRIVILEGES` | Все права |

## 🌐 Уровни привилегий

```sql
-- На всю базу данных
GRANT SELECT ON mydatabase.* TO 'user'@'localhost';

-- На конкретную таблицу
GRANT SELECT, INSERT ON mydatabase.users TO 'user'@'localhost';

-- На все базы данных (только для админов!)
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost';

-- Только на определенные столбцы
GRANT SELECT (id, name), UPDATE (name) ON mydb.users TO 'user'@'localhost';
```

## ❌ Отзыв привилегий

```sql
-- Отозвать конкретные привилегии
REVOKE privilege_type ON database.table FROM 'username'@'host';

-- Примеры:
REVOKE DELETE ON mydb.* FROM 'user'@'localhost';
REVOKE ALL PRIVILEGES ON mydb.* FROM 'user'@'localhost';
```

## ✏️ Изменение пользователей

```sql
-- Изменить пароль
ALTER USER 'username'@'host' IDENTIFIED BY 'newpassword';

-- Переименовать пользователя
RENAME USER 'olduser'@'host' TO 'newuser'@'host';
```

## 🗑️ Удаление пользователей

```sql
-- Удалить пользователя
DROP USER 'username'@'host';

-- Удалить несколько пользователей
DROP USER 'user1'@'localhost', 'user2'@'%';
```

## 🔄 Применение изменений

```sql
-- Обязательно после изменения привилегий!
FLUSH PRIVILEGES;
```

## 🎯 Практические примеры

### Создание пользователя для веб-приложения:
```sql
CREATE USER 'webapp'@'localhost' IDENTIFIED BY 'strongpassword';
GRANT SELECT, INSERT, UPDATE, DELETE ON shop.* TO 'webapp'@'localhost';
FLUSH PRIVILEGES;
```

### Создание администратора БД:
```sql
CREATE USER 'dba'@'localhost' IDENTIFIED BY 'dbapassword';
GRANT ALL PRIVILEGES ON *.* TO 'dba'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

### Создание пользователя только для чтения:
```sql
CREATE USER 'reporter'@'%' IDENTIFIED BY 'readonlypass';
GRANT SELECT ON analytics.* TO 'reporter'@'%';
FLUSH PRIVILEGES;
```

## ⚠️ Важные замечания

- Всегда указывайте хост при работе с пользователями
- Используйте `FLUSH PRIVILEGES` после изменений
- Избегайте `'user'@'%'` в продакшене если возможно
- Регулярно проверяйте список пользователей
- Используйте сложные пароли

## 🔍 Полезные запросы

```sql
-- Текущий пользователь
SELECT CURRENT_USER();

-- Активные привилегии
SHOW GRANTS;

-- Пользователи без пароля
SELECT user, host FROM mysql.user WHERE authentication_string = '';
```

Эта шпаргалка покрывает основные операции по управлению пользователями и привилегиями в MySQL! 🚀