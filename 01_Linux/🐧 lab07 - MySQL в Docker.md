# Практическая работа № 6 — Развёртывание MySQL 8.4 в Docker

## Цель работы

Развернуть сервер MySQL 8.4 в Docker-контейнере с использованием Docker Compose, организовать постоянное хранение данных на RAID-1 и освоить основные команды управления контейнером и проверки работоспособности СУБД.

## Необходимое программное обеспечение

- Ubuntu Server.
- Docker Engine.
- Docker Compose Plugin.
- RAID-1, смонтированный в `/mnt/raid1`.

## 1. Проверка готовности системы

Перед началом работы необходимо убедиться, что Docker установлен и RAID-1 доступен.

### 1.1. Проверка Docker Engine

Выполните команду:

```bash
docker --version
```

Проверьте версию Docker Compose:

```bash
docker compose version
```

Если обе команды успешно выполняются, можно переходить к следующему этапу.

### 1.2. Проверка RAID-1

Выполните:

```bash
df -h /mnt/raid1
```

Команда позволяет проверить, что файловая система смонтирована и определить её доступный объём.

**Ожидаемый результат:** в выводе команды отображается файловая система, смонтированная в `/mnt/raid1`.

> Важно! Если RAID-1 не смонтирован, не продолжайте работу. Иначе данные MySQL могут оказаться в обычном каталоге корневой файловой системы Ubuntu вместо RAID-массива.

## 2. Подготовка каталогов проекта

Для размещения конфигурации Docker Compose и файлов MySQL создадим отдельную структуру каталогов.

Создайте каталог проекта:

```bash
sudo mkdir -p -v /opt/mysql/config
sudo mkdir -p -v /opt/mysql/secrets
```

Создайте каталог для хранения данных СУБД на RAID-1:

```bash
sudo mkdir -p -v /mnt/raid1/mysql/data
```

В результате должна получиться следующая структура:

```text
/opt/mysql/
├── docker-compose.yaml
├── config/
│   └── my.cnf
└── secrets/
    └── mysql_root_password.txt

/mnt/raid1/
└── mysql/
    └── data/
```

**Назначение каталогов:**

| Каталог / файл | Назначение |
|---|---|
| `/opt/mysql/` | Файлы проекта Docker Compose |
| `docker-compose.yaml` | Описание конфигурации контейнера |
| `config/my.cnf` | Дополнительные настройки MySQL |
| `secrets/` | Файлы с конфиденциальными данными |
| `/mnt/raid1/mysql/data/` | Постоянное хранение файлов базы данных |

Таким образом, конфигурация проекта отделена от файлов базы данных.

## 3. Создание пароля администратора MySQL

Для первоначальной настройки MySQL необходимо задать пароль пользователя `root`.

Создадим файл с паролем:

```bash
sudo sh -c 'printf "%s" "YourStrongPassword123!" > /opt/mysql/secrets/mysql_root_password.txt'
```

Ограничим доступ к каталогу и файлу:

```bash
sudo chmod -v 700 /opt/mysql/secrets
sudo chmod -v 600 /opt/mysql/secrets/mysql_root_password.txt
```

Вместо `YourStrongPassword123!` необходимо использовать собственный пароль.

**Примечание:** в данной работе используется Docker Compose Secrets. Это позволяет передавать пароль контейнеру через файл, а не указывать его непосредственно в `docker-compose.yaml`.

Файловый механизм Compose Secrets в данном случае не является зашифрованным хранилищем секретов: файл остаётся на сервере Ubuntu. Ограничение доступа к нему обязательно.

## 4. Создание конфигурационного файла MySQL

MySQL поддерживает дополнительную настройку параметров сервера через конфигурационные файлы.

Создадим файл:

```bash
sudo nano /opt/mysql/config/my.cnf
```

Добавьте следующие настройки:

```ini
[mysqld]

# Кодировка и сортировка
character-set-server = utf8mb4
collation-server = utf8mb4_0900_ai_ci

# Управление подключениями
max_connections = 100

# Журналирование медленных запросов
slow_query_log = ON
slow_query_log_file = /var/lib/mysql/slow-query.log
long_query_time = 2

# Настройки InnoDB
innodb_buffer_pool_size = 256M
```

Сохраните файл.

**Пояснение параметров:**

| Параметр | Значение | Назначение |
|---|---|---|
| `character-set-server` | `utf8mb4` | Кодировка по умолчанию |
| `collation-server` | `utf8mb4_0900_ai_ci` | Правила сравнения и сортировки строк |
| `max_connections` | `100` | Максимальное количество одновременных подключений |
| `slow_query_log` | `ON` | Включение журнала медленных запросов |
| `long_query_time` | `2` | Порог времени выполнения запроса в секундах |
| `innodb_buffer_pool_size` | `256M` | Размер буферного пула InnoDB |

> Примечание: размер буферного пула выбран для учебной виртуальной машины. В реальной эксплуатации его необходимо рассчитывать с учётом объёма оперативной памяти и нагрузки на сервер.

## 5. Создание docker-compose.yaml

Docker Compose позволяет описать параметры контейнера в отдельном YAML-файле и управлять его жизненным циклом с помощью команд `docker compose`.

Перейдите в каталог проекта:

```bash
cd /opt/mysql
```

Создайте файл:

```bash
sudo nano docker-compose.yaml
```

Добавьте следующую конфигурацию:

```yaml
name: mysql-infrastructure

services:
  mysql:
    image: mysql:8.4
    container_name: mysql84

    restart: unless-stopped

    environment:
      MYSQL_ROOT_PASSWORD_FILE: /run/secrets/mysql_root_password
      TZ: Asia/Novosibirsk

    secrets:
      - mysql_root_password

    ports:
      - "3306:3306"

    volumes:
      # Постоянное хранение данных на RAID-1
      - type: bind
        source: /mnt/raid1/mysql/data
        target: /var/lib/mysql

      # Дополнительная конфигурация MySQL
      - type: bind
        source: ./config/my.cnf
        target: /etc/mysql/conf.d/my.cnf
        read_only: true

    command:
      - --default-time-zone=+07:00

    healthcheck:
      test:
        - CMD
        - mysqladmin
        - ping
        - -h
        - 127.0.0.1
        - --silent
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 60s

    stop_grace_period: 1m

    logging:
      driver: local
      options:
        max-size: "10m"
        max-file: "3"

secrets:
  mysql_root_password:
    file: ./secrets/mysql_root_password.txt
```

### 5.1. Разбор основных параметров

| Параметр | Назначение |
|---|---|
| `name` | Имя проекта Docker Compose |
| `services` | Описание сервисов проекта |
| `image` | Docker-образ MySQL |
| `container_name` | Имя создаваемого контейнера |
| `restart` | Политика автоматического перезапуска |
| `environment` | Переменные окружения контейнера |
| `secrets` | Подключение файла с паролем |
| `ports` | Публикация сетевого порта |
| `volumes` | Подключение каталогов Ubuntu к контейнеру |
| `command` | Дополнительный параметр запуска MySQL |
| `healthcheck` | Проверка работоспособности MySQL |
| `stop_grace_period` | Время на корректную остановку |
| `logging` | Настройки хранения журналов контейнера |

### 5.2. Разбор подключения хранилища

Особое внимание обратите на следующий фрагмент:

```yaml
volumes:
  - type: bind
    source: /mnt/raid1/mysql/data
    target: /var/lib/mysql
```

Здесь используется механизм **Bind Mount**.

- `source` — каталог на хостовой операционной системе Ubuntu.
- `target` — каталог внутри Docker-контейнера.

MySQL хранит файлы баз данных в `/var/lib/mysql`. Благодаря Bind Mount эти файлы физически размещаются на RAID-1 в `/mnt/raid1/mysql/data`.

Это позволяет сохранить данные при удалении или пересоздании Docker-контейнера.

### 5.3. Разбор проверки работоспособности

Параметр `healthcheck` задаёт проверку доступности сервера MySQL.

Docker периодически выполняет команду:

```bash
mysqladmin ping -h 127.0.0.1 --silent
```

Если сервер отвечает, контейнер получает статус `healthy`.

Основные параметры:

- `interval` — интервал между проверками.
- `timeout` — максимальное время выполнения проверки.
- `retries` — количество неудачных проверок до признания сервиса неисправным.
- `start_period` — период первоначального запуска, в течение которого ошибки проверки не учитываются как окончательный отказ.

Важно: `healthcheck` проверяет доступность сервера, но не подтверждает корректность входа под каждым пользователем.

## 6. Проверка конфигурации и запуск MySQL

Перед запуском рекомендуется проверить корректность YAML-файла и итоговую конфигурацию Compose.

Выполните:

```bash
docker compose config --quiet
```

Если ошибок нет, можно переходить к запуску.

Загрузите образ MySQL 8.4:

```bash
docker compose pull
```

Запустите контейнер в фоновом режиме:

```bash
cd /opt/mysql
docker compose up -d
```

Docker Compose создаст контейнер и запустит сервер MySQL.

## 7. Проверка работоспособности контейнера

Проверьте состояние контейнера:

```bash
docker compose ps
```

Пример ожидаемого результата:

```text
NAME      IMAGE       STATUS
mysql84   mysql:8.4   Up ... (healthy)
```

Если контейнер ещё запускается, подождите некоторое время и повторите проверку.

Посмотрите журналы контейнера:

```bash
docker compose logs mysql
```

Для просмотра журналов в режиме реального времени:

```bash
docker compose logs -f mysql
```

Для выхода из режима просмотра нажмите `Ctrl + C`. Это не останавливает контейнер.

## 8. Подключение к серверу MySQL

После того как контейнер получил статус `healthy`, можно подключиться к серверу.

Выполните:

```bash
docker compose exec mysql mysql -uroot -p
```

Введите пароль, который ранее был сохранён в файле `mysql_root_password.txt`.

После успешного подключения появится приглашение MySQL:

```text
mysql>
```

### 8.1. Проверка версии MySQL

Выполните SQL-запрос:

```sql
SELECT VERSION();
```

В результате должна отобразиться версия MySQL 8.4.x.

### 8.2. Проверка кодировки

Выполните:

```sql
SHOW VARIABLES LIKE 'character_set_server';
```

Ожидаемый результат:

```text
character_set_server | utf8mb4
```

### 8.3. Проверка параметров сервера

Проверьте максимальное количество подключений:

```sql
SHOW VARIABLES LIKE 'max_connections';
```

Проверьте размер буферного пула:

```sql
SHOW VARIABLES LIKE 'innodb_buffer_pool_size';
```

Выход из MySQL Client:

```sql
exit;
```

## 9. Проверка постоянного хранения данных

На этом этапе необходимо убедиться, что файлы MySQL действительно размещаются на RAID-1.

На Ubuntu выполните:

```bash
sudo ls -lah /mnt/raid1/mysql/data/
```

После первоначальной инициализации MySQL в каталоге должны появиться файлы и подкаталоги СУБД.

Проверьте подключённые тома контейнера:

```bash
docker inspect mysql84
```

Найдите раздел `Mounts`.

В нём должна присутствовать информация:

- `Source`: `/mnt/raid1/mysql/data`
- `Destination`: `/var/lib/mysql`
- `Type`: `bind`

Это подтверждает, что каталог RAID-1 подключён к каталогу данных MySQL.

## 10. Проверка сохранности данных при пересоздании контейнера

Проведём эксперимент, который позволит убедиться в правильности организации постоянного хранилища.

Подключитесь к MySQL:

```bash
docker compose exec mysql mysql -uroot -p
```

Создайте тестовую базу данных:

```sql
CREATE DATABASE persistence_test;
```

Проверьте её наличие:

```sql
SHOW DATABASES;
```

Выйдите из MySQL Client:

```sql
exit;
```

Остановите и удалите контейнер вместе с сетью проекта:

```bash
docker compose down
```

Проверьте, что контейнер удалён:

```bash
docker compose ps -a
```

Теперь создайте контейнер заново:

```bash
docker compose up -d
```

Дождитесь статуса `healthy`.

Подключитесь к MySQL:

```bash
docker compose exec mysql mysql -uroot -p
```

Проверьте наличие ранее созданной базы:

```sql
SHOW DATABASES;
```

**Ожидаемый результат:** база `persistence_test` присутствует в списке.

Это подтверждает, что данные MySQL сохраняются вне жизненного цикла Docker-контейнера.

> Важно! Не удаляйте каталог `/mnt/raid1/mysql/data`. Команда `docker compose down` не удаляет данные Bind Mount. Не используйте `rm -rf` для очистки каталога с данными MySQL.

## 11. Основные команды управления MySQL

Для дальнейшей работы с контейнером необходимо освоить основные команды Docker Compose.

| Команда | Назначение |
|---|---|
| `docker compose ps` | Просмотр состояния сервисов |
| `docker compose logs mysql` | Просмотр журналов MySQL |
| `docker compose logs -f mysql` | Просмотр журналов в реальном времени |
| `docker compose stop` | Остановка контейнера |
| `docker compose start` | Запуск остановленного контейнера |
| `docker compose restart` | Перезапуск контейнера |
| `docker compose down` | Остановка и удаление контейнера и сети проекта |
| `docker compose up -d` | Создание и запуск контейнера |
| `docker compose pull` | Загрузка обновлённого образа |

Обратите внимание: удаление контейнера не означает удаление данных, поскольку они размещены в отдельном каталоге RAID-1.

## Контрольные вопросы

1. Что такое Docker Compose и для чего он используется?
2. Чем Docker Image отличается от Docker Container?
3. Для чего используется файл `docker-compose.yaml`?
4. Какую задачу решает параметр `restart: unless-stopped`?
5. Для чего используется параметр `ports`?
6. Что такое Bind Mount и для чего он применяется?
7. Почему данные MySQL размещаются на RAID-1, а не только внутри контейнера?
8. Для чего используется `healthcheck`?
9. Чем отличаются команды `docker compose stop` и `docker compose down`?
10. Почему после удаления и повторного создания контейнера данные базы данных сохранились?

## Итоговый результат работы

После выполнения практической работы должны быть получены следующие результаты:

- [ ] Создан проект `/opt/mysql`.
- [ ] Создан каталог данных `/mnt/raid1/mysql/data`.
- [ ] Подготовлен файл `docker-compose.yaml`.
- [ ] Подготовлен конфигурационный файл `my.cnf`.
- [ ] Создан файл с паролем администратора MySQL.
- [ ] Запущен контейнер `mysql84`.
- [ ] Контейнер имеет статус `healthy`.
- [ ] Выполнено подключение к MySQL под пользователем `root`.
- [ ] Проверена версия MySQL 8.4.
- [ ] Проверена кодировка `utf8mb4`.
- [ ] Подтверждено размещение файлов БД на RAID-1.
- [ ] Проверена сохранность данных после пересоздания контейнера.

**Итог:** развёрнут работающий сервер MySQL 8.4 в Docker с постоянным хранением данных на RAID-1.

## Полезные материалы

1. [Официальная документация MySQL 8.4 — Deploying MySQL with Docker](https://dev.mysql.com/doc/refman/8.4/en/docker-mysql-getting-started.html).
2. [Официальная документация Docker Compose](https://docs.docker.com/compose/).
3. [Docker Compose — Secrets](https://docs.docker.com/compose/how-tos/use-secrets/).
4. [MySQL 8.4 — Configuration Files](https://dev.mysql.com/doc/refman/8.4/en/option-files.html).
