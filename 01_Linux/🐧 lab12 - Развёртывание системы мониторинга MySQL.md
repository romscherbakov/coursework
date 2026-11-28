# 🐧 Лабораторная работа № 12 — Развёртывание системы мониторинга MySQL с использованием Prometheus и Grafana

## Цель работы

Научиться развёртывать систему мониторинга серверной инфраструктуры с использованием Prometheus и Grafana.

Освоить сбор и визуализацию метрик сервера MySQL и операционной системы Ubuntu, научиться создавать дашборды и контролировать состояние автоматического резервного копирования базы данных.

## Необходимое программное обеспечение

- Ubuntu Server (виртуальная машина).
- Docker Engine.
- Docker Compose Plugin.
- Работающий Docker-контейнер `mysql84` с MySQL 8.4.
- База данных `test3`.
- Выполненная лабораторная работа № 10 «Автоматизация резервного копирования MySQL».
- Текстовый редактор `nano`.
- Веб-браузер.

## 1. Знакомство с системой мониторинга

В предыдущих лабораторных работах мы развернули MySQL 8.4 в Docker, восстановили базу данных `test3`, настроили пользователей и автоматизировали резервное копирование.

Теперь необходимо научиться контролировать состояние нашей инфраструктуры.

Для этого будем использовать две системы:

**Prometheus** — система сбора и хранения метрик. Она периодически обращается к специальным компонентам (экспортёрам) и получает информацию о состоянии серверов и приложений.

**Grafana** — платформа визуализации данных. Она подключается к Prometheus и позволяет отображать собранные метрики в виде графиков, таблиц и индикаторов.

### 1.1. Архитектура системы мониторинга

В лабораторной работе будут использоваться следующие компоненты:

| Компонент | Назначение |
|---|---|
| MySQL 8.4 | Сервер базы данных |
| Prometheus | Сбор и хранение метрик |
| Grafana | Визуализация метрик |
| MySQL Exporter | Сбор показателей MySQL |
| Node Exporter | Сбор показателей Ubuntu и метрик резервного копирования |

Принцип работы системы:

```text
                  Ubuntu Server
                       |
           +-----------+-----------+
           |                       |
           |                       |
        MySQL 8.4              Linux OS
           |                       |
           |                       |
     MySQL Exporter           Node Exporter
           |                       |
           +-----------+-----------+
                       |
                       |
                  Prometheus
                       |
                       |
                    Grafana
                       |
                       |
                 Web Dashboard
```

Экспортёры предоставляют метрики по HTTP, а Prometheus периодически забирает их и сохраняет.

Grafana обращается к Prometheus и отображает полученные данные.

Дополнительно мы подключим метрики резервного копирования, созданные в лабораторной работе № 10.

## 2. Подготовка инфраструктуры

### 2.1. Проверка состояния Docker

Перейдите в каталог проекта:

```bash
cd /opt/mysql
```

Проверьте состояние контейнеров:

```bash
docker compose ps
```

Убедитесь, что контейнер MySQL работает.

Проверьте наличие базы данных:

```bash
docker compose exec mysql mysql -uroot -p
```

Выполните:

```sql
SHOW DATABASES;
```

Убедитесь, что база `test3` присутствует.

Выйдите из MySQL Client:

```sql
exit;
```

### 2.2. Подготовка каталогов мониторинга

Создадим каталог для конфигурационных файлов:

```bash
sudo mkdir -p /opt/mysql/monitoring/prometheus
```

Создадим каталог для конфигурации MySQL Exporter:

```bash
sudo mkdir -p /opt/mysql/monitoring/mysql-exporter
```

Создадим каталог для хранения метрик резервного копирования:

```bash
sudo mkdir -p /opt/mysql/backup/prometheus
```

Установим права доступа к каталогам:

```bash
sudo chmod 755 /opt/mysql/monitoring
sudo chmod 755 /opt/mysql/monitoring/prometheus
sudo chmod 755 /opt/mysql/backup/prometheus
```

В результате должна получиться следующая структура:

```text
/opt/mysql/
├── docker-compose.yaml
├── backup_mysql.sh
├── backup/
│   ├── backup.log
│   ├── prometheus/
│   └── test3_*.sql.gz
│
└── monitoring/
    ├── prometheus/
    │   └── prometheus.yml
    │
    └── mysql-exporter/
        └── .my.cnf
```

## 3. Создание пользователя MySQL для мониторинга

Для сбора метрик MySQL Exporter должен подключаться к серверу базы данных.

Не следует использовать для этой задачи административную учётную запись `root`.

Создадим отдельного пользователя `exporter` с ограниченными правами.

### 3.1. Создание пользователя

Подключитесь к MySQL:

```bash
cd /opt/mysql
docker compose exec mysql mysql -uroot -p
```

Создайте пользователя:

```sql
CREATE USER 'exporter'@'%'
IDENTIFIED BY 'ExporterPassword2026!'
WITH MAX_USER_CONNECTIONS 3;
```

Назначьте необходимые привилегии:

```sql
GRANT PROCESS, REPLICATION CLIENT, SELECT
ON *.*
TO 'exporter'@'%';
```

Проверьте назначенные привилегии:

```sql
SHOW GRANTS FOR 'exporter'@'%';
```

Выйдите из MySQL Client:

```sql
exit;
```

**Примечание:** пользователь `exporter` предназначен исключительно для чтения статистики и служебной информации MySQL. Он не должен использоваться для изменения данных базы.

### 3.2. Создание файла конфигурации MySQL Exporter

Перейдите в каталог:

```bash
cd /opt/mysql/monitoring/mysql-exporter
```

Создайте конфигурационный файл:

```bash
sudo nano .my.cnf
```

Добавьте:

```ini
[client]
user=exporter
password=ExporterPassword2026!
```

Вместо указанного примера пароля используйте пароль, который был задан при создании пользователя MySQL.

Сохраните файл.

Ограничьте права доступа:

```bash
sudo chown root:root .my.cnf
sudo chmod 600 .my.cnf
```

Проверьте права:

```bash
ls -l .my.cnf
```

Ожидаемый результат:

```text
-rw------- 1 root root ... .my.cnf
```

**Важно!** Файл содержит пароль пользователя MySQL. Не публикуйте его в GitHub и не предоставляйте к нему доступ посторонним пользователям.

## 4. Настройка Prometheus

Prometheus использует конфигурационный файл `prometheus.yml`, в котором указываются источники метрик, за которыми необходимо наблюдать.

Перейдите в каталог:

```bash
cd /opt/mysql/monitoring/prometheus
```

Создайте файл:

```bash
sudo nano prometheus.yml
```

Добавьте следующую конфигурацию:

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:

  # Мониторинг самого Prometheus
  - job_name: 'prometheus'
    static_configs:
      - targets: ['prometheus:9090']

  # Мониторинг MySQL
  - job_name: 'mysql'
    static_configs:
      - targets: ['mysql-exporter:9104']

  # Мониторинг Ubuntu Server
  - job_name: 'node'
    static_configs:
      - targets: ['node-exporter:9100']
```

Сохраните файл.

### 4.1. Разбор конфигурации

| Параметр | Назначение |
|---|---|
| `global` | Общие настройки Prometheus |
| `scrape_interval` | Периодичность сбора метрик |
| `evaluation_interval` | Периодичность проверки правил |
| `scrape_configs` | Список объектов мониторинга |
| `job_name` | Имя задания мониторинга |
| `static_configs` | Статически заданные источники метрик |
| `targets` | Адреса экспортёров |

В нашей конфигурации Prometheus будет обращаться к трём источникам:

1. `prometheus:9090` — собственные метрики Prometheus.
2. `mysql-exporter:9104` — метрики MySQL.
3. `node-exporter:9100` — метрики Ubuntu.

Интервал сбора метрик установлен на уровне 15 секунд.

**Важно!** Имена `prometheus`, `mysql-exporter` и `node-exporter` являются именами сервисов Docker Compose. Контейнеры смогут обращаться друг к другу по этим именам внутри общей Docker-сети проекта.

## 5. Подключение компонентов мониторинга к Docker Compose

Теперь необходимо добавить новые сервисы в существующий файл `docker-compose.yaml`.

Перейдите в каталог проекта:

```bash
cd /opt/mysql
```

Создайте резервную копию текущего файла конфигурации:

```bash
sudo cp docker-compose.yaml docker-compose.yaml.bak
```

Откройте файл:

```bash
sudo nano docker-compose.yaml
```

Внутри существующего раздела `services:` добавьте следующие сервисы.

**Не удаляйте и не заменяйте существующие настройки MySQL!** Необходимо дополнить текущую конфигурацию.

### 5.1. MySQL Exporter

Добавьте сервис:

```yaml
  mysql-exporter:
    image: prom/mysqld-exporter:latest
    container_name: mysql-exporter
    restart: unless-stopped
    command:
      - '--config.my-cnf=/etc/mysql-exporter/.my.cnf'
      - '--mysqld.address=mysql:3306'
    volumes:
      - ./monitoring/mysql-exporter/.my.cnf:/etc/mysql-exporter/.my.cnf:ro
    depends_on:
      - mysql
```

Назначение:

MySQL Exporter подключается к существующему серверу MySQL и предоставляет метрики для Prometheus.

Порт `9104` используется для публикации метрик MySQL Exporter внутри Docker-сети.

### 5.2. Node Exporter

Добавьте сервис:

```yaml
  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    restart: unless-stopped
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--path.rootfs=/host'
      - '--collector.textfile.directory=/var/lib/node_exporter/textfile_collector'
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/host:ro,rslave
      - ./backup/prometheus:/var/lib/node_exporter/textfile_collector:ro
```

Назначение:

Node Exporter собирает информацию о состоянии операционной системы:

- Загрузка процессора.
- Использование оперативной памяти.
- Состояние файловых систем.
- Использование дискового пространства.
- Системная информация.

Дополнительно используется Textfile Collector.

Он позволяет передавать в Prometheus пользовательские метрики из файлов, размещённых в каталоге:

```text
/var/lib/node_exporter/textfile_collector
```

Именно через этот механизм мы будем передавать информацию о резервном копировании MySQL.

### 5.3. Prometheus

Добавьте сервис:

```yaml
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    restart: unless-stopped
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=15d'
    depends_on:
      - mysql-exporter
      - node-exporter
```

Назначение:

Prometheus получает метрики от экспортёров и сохраняет их в собственной базе временных рядов.

Порт `9090` используется для доступа к веб-интерфейсу Prometheus.

Параметр `retention.time=15d` задаёт срок хранения метрик — 15 дней.

### 5.4. Grafana

Добавьте сервис:

```yaml
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      GF_SECURITY_ADMIN_USER: admin
      GF_SECURITY_ADMIN_PASSWORD: "ChangeMe_Grafana_2026!"
    volumes:
      - grafana_data:/var/lib/grafana
    depends_on:
      - prometheus
```

Назначение:

Grafana используется для построения графиков, таблиц и визуальных индикаторов на основе данных Prometheus.

Порт `3000` используется для доступа к веб-интерфейсу Grafana.

Пароль администратора необходимо заменить на собственный.

### 5.5. Добавление Docker Volumes

В конце файла `docker-compose.yaml` необходимо дополнить существующий раздел `volumes:`.

Добавьте:

```yaml
volumes:
  prometheus_data:
  grafana_data:
```

Если раздел `volumes:` уже существует, не создавайте второй. Добавьте новые элементы в существующий раздел, сохранив остальные тома.

**Важно!** Docker Volumes обеспечивают сохранность данных Prometheus и Grafana при пересоздании контейнеров.

### 5.6. Проверка конфигурации Docker Compose

Перед запуском необходимо проверить корректность YAML-файла.

Выполните:

```bash
docker compose config
```

Если ошибок нет, Docker Compose выведет итоговую конфигурацию проекта.

При наличии ошибок проверьте:
- Отступы YAML.
- Расположение новых сервисов внутри `services:`.
- Расположение томов внутри `volumes:`.
- Отсутствие повторяющихся ключей верхнего уровня.

## 6. Запуск системы мониторинга

Перейдите в каталог проекта:

```bash
cd /opt/mysql
```

Загрузите образы:

```bash
docker compose pull
```

Запустите инфраструктуру:

```bash
docker compose up -d
```

Проверьте состояние контейнеров:

```bash
docker compose ps
```

В списке должны присутствовать:

| Контейнер | Назначение |
|---|---|
| mysql84 | Сервер MySQL |
| mysql-exporter | Сбор метрик MySQL |
| node-exporter | Сбор метрик Ubuntu |
| prometheus | Сбор и хранение метрик |
| grafana | Визуализация метрик |

Проверьте логи новых сервисов:

```bash
docker compose logs --tail=30 prometheus
```

```bash
docker compose logs --tail=30 grafana
```

```bash
docker compose logs --tail=30 mysql-exporter
```

```bash
docker compose logs --tail=30 node-exporter
```

Убедитесь, что сервисы запустились без критических ошибок.

## 7. Проверка работы Prometheus

Откройте веб-браузер и перейдите по адресу:

```text
http://IP-АДРЕС-UBUNTU:9090
```

Например:

```text
http://192.168.1.100:9090
```

Откроется веб-интерфейс Prometheus.

### 7.1. Проверка источников метрик

Перейдите в раздел:

```text
Status → Targets
```

Должны отображаться три источника:

| Job | Target | Состояние |
|---|---|---|
| prometheus | prometheus:9090 | UP |
| mysql | mysql-exporter:9104 | UP |
| node | node-exporter:9100 | UP |

Статус `UP` означает, что Prometheus успешно получает метрики от соответствующего источника.

Статус `DOWN` означает, что источник недоступен или не отвечает корректно.

### 7.2. Проверка метрик MySQL

Перейдите в раздел Expression Browser.

Выполните запрос:

```promql
mysql_up
```

Ожидаемый результат:

```text
mysql_up = 1
```

Это означает, что MySQL Exporter успешно подключился к серверу базы данных.

Выполните дополнительные запросы:

```promql
mysql_global_status_threads_connected
```

Показывает количество подключений к MySQL.

```promql
mysql_global_status_threads_running
```

Показывает количество активных потоков.

```promql
mysql_global_status_queries
```

Показывает общее количество выполненных запросов с момента запуска сервера.

```promql
mysql_global_status_uptime
```

Показывает время работы MySQL в секундах.

### 7.3. Проверка метрик Ubuntu

Выполните запрос:

```promql
node_memory_MemTotal_bytes
```

Показывает общий объём оперативной памяти.

```promql
node_memory_MemAvailable_bytes
```

Показывает доступный объём оперативной памяти.

```promql
node_cpu_seconds_total
```

Показывает накопленное время работы процессоров в различных режимах.

```promql
node_filesystem_size_bytes
```

Показывает общий размер файловых систем.

Если запросы возвращают значения, значит Prometheus получает метрики от Node Exporter.

## 8. Подключение Prometheus к Grafana

Теперь необходимо подключить Prometheus в качестве источника данных Grafana.

Откройте браузер:

```text
http://IP-АДРЕС-UBUNTU:3000
```

Выполните вход:

| Параметр | Значение |
|---|---|
| Username | admin |
| Password | Пароль, указанный в Docker Compose |

При первом входе Grafana может предложить сменить пароль администратора.

Установите собственный пароль.

### 8.1. Добавление источника данных

В интерфейсе Grafana:

1. Откройте раздел **Connections**.
2. Выберите **Data sources**.
3. Нажмите **Add data source**.
4. Выберите **Prometheus**.

В поле URL укажите:

```text
http://prometheus:9090
```

**Важно!** Здесь используется имя Docker-сервиса `prometheus`, а не IP-адрес Ubuntu.

Grafana и Prometheus находятся в одной Docker-сети и могут обращаться друг к другу по именам сервисов.

Нажмите:

```text
Save & test
```

При успешном подключении Grafana сообщит, что источник данных работает.

## 9. Создание собственного дашборда Grafana

Теперь создадим собственную панель мониторинга MySQL и Ubuntu.

Перейдите:

```text
Dashboards → New → New dashboard
```

Нажмите:

```text
Add visualization
```

Выберите источник данных:

```text
Prometheus
```

Для каждой панели будем использовать запросы PromQL.

### 9.1. Панель № 1 — Доступность MySQL

Название:

```text
MySQL Availability
```

Запрос:

```promql
mysql_up
```

Тип визуализации:

```text
Stat
```

Настройте отображение значений:
- `1` — ONLINE.
- `0` — OFFLINE.

Панель должна показывать текущее состояние подключения к MySQL.

### 9.2. Панель № 2 — Количество подключений

Название:

```text
MySQL Connections
```

Запрос:

```promql
mysql_global_status_threads_connected
```

Тип визуализации:

```text
Time series
```

Панель отображает изменение количества подключений к базе данных во времени.

### 9.3. Панель № 3 — Активные потоки MySQL

Название:

```text
MySQL Active Threads
```

Запрос:

```promql
mysql_global_status_threads_running
```

Тип визуализации:

```text
Time series
```

Позволяет наблюдать за количеством активных потоков MySQL.

### 9.4. Панель № 4 — Загрузка процессора

Название:

```text
CPU Usage
```

Запрос:

```promql
100 * (
  1 - avg by(instance) (
    rate(node_cpu_seconds_total{mode="idle"}[5m])
  )
)
```

Тип визуализации:

```text
Time series
```

Запрос вычисляет приблизительную загрузку процессора в процентах за последние пять минут.

### 9.5. Панель № 5 — Использование оперативной памяти

Название:

```text
Memory Usage
```

Запрос:

```promql
100 * (
  1 - node_memory_MemAvailable_bytes
  / node_memory_MemTotal_bytes
)
```

Тип визуализации:

```text
Time series
```

Показывает процент используемой оперативной памяти.

### 9.6. Панель № 6 — Использование дискового пространства

Название:

```text
Disk Usage
```

Запрос:

```promql
100 * (
  1 -
  node_filesystem_avail_bytes{
    mountpoint="/",
    fstype!~"tmpfs|overlay"
  }
  /
  node_filesystem_size_bytes{
    mountpoint="/",
    fstype!~"tmpfs|overlay"
  }
)
```

Тип визуализации:

```text
Gauge
```

Показывает процент занятого пространства корневой файловой системы.

### 9.7. Сохранение дашборда

Нажмите:

```text
Save dashboard
```

Укажите название:

```text
MySQL Server Monitoring
```

В результате должен получиться дашборд, отображающий состояние MySQL и операционной системы Ubuntu.

## 10. Мониторинг автоматического резервного копирования

В лабораторной работе № 10 мы создали Bash-скрипт `backup_mysql.sh`, который выполняет резервное копирование базы данных `test3`.

Теперь необходимо научить Prometheus получать информацию о результатах его работы.

Для этого будем использовать Textfile Collector Node Exporter.

Принцип работы:

```text
backup_mysql.sh
       |
       |
Создание резервной копии
       |
       |
Формирование backup.prom
       |
       |
Node Exporter
       |
       |
Prometheus
       |
       |
Grafana
```

### 10.1. Создание скрипта передачи метрик

Создадим дополнительный скрипт, который будет запускать резервное копирование и формировать метрики для Prometheus.

Перейдите в каталог проекта:

```bash
cd /opt/mysql
```

Создайте файл:

```bash
sudo nano backup_with_metrics.sh
```

Добавьте:

```bash
#!/bin/bash

set -u

BACKUP_SCRIPT="/opt/mysql/backup_mysql.sh"
BACKUP_DIR="/opt/mysql/backup"
METRICS_DIR="/opt/mysql/backup/prometheus"
METRICS_FILE="${METRICS_DIR}/backup.prom"

DB_NAME="test3"

START_TIME=$(date +%s)

# Получение предыдущих успешных показателей
LAST_SUCCESS=0
LAST_SIZE=0

if [[ -f "$METRICS_FILE" ]]; then
    LAST_SUCCESS=$(awk '$1 == "mysql_backup_last_success_timestamp" {print $2}' "$METRICS_FILE")
    LAST_SIZE=$(awk '$1 == "mysql_backup_size_bytes" {print $2}' "$METRICS_FILE")

    LAST_SUCCESS=${LAST_SUCCESS:-0}
    LAST_SIZE=${LAST_SIZE:-0}
fi

# Выполнение резервного копирования
if "$BACKUP_SCRIPT"; then

    BACKUP_STATUS=1
    LAST_SUCCESS=$(date +%s)

    LATEST_BACKUP=$(
        find "$BACKUP_DIR" \
            -maxdepth 1 \
            -type f \
            -name "${DB_NAME}_*.sql.gz" \
            -printf '%T@ %p\n' \
            | sort -nr \
            | head -n 1 \
            | cut -d' ' -f2-
    )

    if [[ -n "$LATEST_BACKUP" ]]; then
        LAST_SIZE=$(stat -c%s "$LATEST_BACKUP")
    fi

else

    BACKUP_STATUS=0
    echo "Ошибка резервного копирования"

fi

END_TIME=$(date +%s)

DURATION=$((END_TIME - START_TIME))

# Создание временного файла метрик
TMP_FILE=$(mktemp "${METRICS_DIR}/.backup_XXXXXX")

cat > "$TMP_FILE" <<EOF
mysql_backup_status ${BACKUP_STATUS}
mysql_backup_last_attempt_timestamp ${END_TIME}
mysql_backup_last_success_timestamp ${LAST_SUCCESS}
mysql_backup_size_bytes ${LAST_SIZE}
mysql_backup_duration_seconds ${DURATION}
EOF

# Установка прав доступа и публикация метрик
chmod 644 "$TMP_FILE"
mv "$TMP_FILE" "$METRICS_FILE"

echo "Метрики резервного копирования обновлены"

exit $((1 - BACKUP_STATUS))
```

Сохраните файл.

Установите права доступа:

```bash
sudo chown root:root /opt/mysql/backup_with_metrics.sh
sudo chmod 700 /opt/mysql/backup_with_metrics.sh
```

### 10.2. Разбор формируемых метрик

Скрипт создаёт файл:

```text
/opt/mysql/backup/prometheus/backup.prom
```

В нём будут храниться следующие показатели:

| Метрика | Назначение |
|---|---|
| `mysql_backup_status` | Результат последнего резервного копирования |
| `mysql_backup_last_attempt_timestamp` | Время последней попытки резервного копирования |
| `mysql_backup_last_success_timestamp` | Время последней успешной резервной копии |
| `mysql_backup_size_bytes` | Размер последней успешной резервной копии |
| `mysql_backup_duration_seconds` | Продолжительность последней попытки |

Значение `mysql_backup_status`:
- `1` — резервное копирование прошло успешно.
- `0` — произошла ошибка.

Обратите внимание: время передаётся в формате Unix Timestamp — количество секунд, прошедших с 1 января 1970 года.

Это позволяет Prometheus выполнять вычисления времени без дополнительного преобразования даты.

### 10.3. Изменение расписания резервного копирования

В лабораторной работе № 10 мы настроили автоматический запуск:

```cron
0 2 * * * /opt/mysql/backup_mysql.sh
```

Теперь необходимо заменить его на новый скрипт:

```cron
0 2 * * * /opt/mysql/backup_with_metrics.sh
```

Откройте таблицу заданий:

```bash
sudo crontab -e
```

Замените существующую строку.

Сохраните изменения.

Проверьте:

```bash
sudo crontab -l
```

Теперь резервное копирование будет запускаться через новый скрипт, который дополнительно формирует метрики для Prometheus.

**Важно!** Не оставляйте одновременно обе записи. Иначе резервное копирование будет запускаться дважды.

### 10.4. Проверка формирования метрик

Выполните новый скрипт вручную:

```bash
sudo /opt/mysql/backup_with_metrics.sh
```

После завершения проверьте содержимое файла:

```bash
sudo cat /opt/mysql/backup/prometheus/backup.prom
```

Пример содержимого:

```text
mysql_backup_status 1
mysql_backup_last_attempt_timestamp 1795561200
mysql_backup_last_success_timestamp 1795561200
mysql_backup_size_bytes 131072000
mysql_backup_duration_seconds 18
```

Числовые значения приведены для примера.

Убедитесь, что файл создан и содержит все пять метрик.

### 10.5. Проверка метрик в Prometheus

Откройте Prometheus:

```text
http://IP-АДРЕС-UBUNTU:9090
```

Выполните запросы:

Проверка результата резервного копирования:

```promql
mysql_backup_status
```

Время последней успешной копии:

```promql
mysql_backup_last_success_timestamp
```

Размер резервной копии:

```promql
mysql_backup_size_bytes
```

Продолжительность резервного копирования:

```promql
mysql_backup_duration_seconds
```

Если запросы возвращают значения, значит Node Exporter успешно передаёт пользовательские метрики в Prometheus.

## 11. Добавление мониторинга резервного копирования в Grafana

Вернитесь в Grafana:

```text
http://IP-АДРЕС-UBUNTU:3000
```

Откройте ранее созданный дашборд:

```text
MySQL Server Monitoring
```

Добавьте новые панели.

### 11.1. Панель Backup Status

Название:

```text
Backup Status
```

Запрос:

```promql
mysql_backup_status
```

Тип визуализации:

```text
Stat
```

Настройте отображение:

| Значение | Состояние |
|---|---|
| 1 | SUCCESS |
| 0 | FAILED |

Для значения `1` установите зелёный цвет, для `0` — красный.

### 11.2. Панель Last Successful Backup

Название:

```text
Last Successful Backup
```

Запрос:

```promql
time() - mysql_backup_last_success_timestamp
```

Тип визуализации:

```text
Stat
```

Единица измерения:

```text
seconds
```

Панель будет показывать, сколько секунд прошло с момента последней успешной резервной копии.

Для удобства отображения можно выбрать единицу времени `duration (s)`.

### 11.3. Панель Backup Size

Название:

```text
Backup Size
```

Запрос:

```promql
mysql_backup_size_bytes
```

Тип визуализации:

```text
Stat
```

Единица измерения:

```text
bytes (IEC)
```

Grafana автоматически преобразует значение в KB, MB или GB.

### 11.4. Панель Backup Duration

Название:

```text
Backup Duration
```

Запрос:

```promql
mysql_backup_duration_seconds
```

Тип визуализации:

```text
Stat
```

Единица измерения:

```text
seconds
```

Панель будет показывать продолжительность последней попытки резервного копирования.

### 11.5. Панель Backup Age

Название:

```text
Backup Age
```

Запрос:

```promql
(time() - mysql_backup_last_success_timestamp) / 3600
```

Тип визуализации:

```text
Gauge
```

Единица измерения:

```text
hours
```

Настройте пороги:
- До 24 часов — нормальное состояние.
- От 24 до 26 часов — предупреждение.
- Более 26 часов — критическое состояние.

Таким образом, можно определить, насколько давно создавалась последняя успешная резервная копия.

Сохраните дашборд.

## 12. Проверка работы системы мониторинга

Теперь необходимо проверить не только наличие графиков, но и реакцию системы на изменение состояния инфраструктуры.

### 12.1. Проверка отказа MySQL

Откройте терминал Ubuntu.

Остановите контейнер MySQL:

```bash
cd /opt/mysql
docker compose stop mysql
```

Подождите 15–30 секунд.

Откройте Prometheus:

```text
Status → Targets
```

Обратите внимание: MySQL Exporter может оставаться в состоянии `UP`, поскольку сам экспортёр продолжает работать, но не может подключиться к MySQL.

Выполните запрос:

```promql
mysql_up
```

Ожидаемый результат:

```text
mysql_up = 0
```

Перейдите в Grafana.

Панель `MySQL Availability` должна показать состояние OFFLINE.

### 12.2. Восстановление MySQL

Запустите контейнер:

```bash
docker compose start mysql
```

Подождите некоторое время, пока MySQL полностью запустится.

Проверьте:

```bash
docker compose ps
```

В Prometheus снова выполните:

```promql
mysql_up
```

Ожидаемый результат:

```text
mysql_up = 1
```

Убедитесь, что Grafana снова показывает состояние ONLINE.

### 12.3. Проверка ошибки резервного копирования

Необходимо проверить, что система мониторинга может обнаруживать неудачное резервное копирование.

Для этого временно остановите MySQL:

```bash
docker compose stop mysql
```

Запустите скрипт:

```bash
sudo /opt/mysql/backup_with_metrics.sh
```

Поскольку MySQL недоступен, резервное копирование должно завершиться ошибкой.

Проверьте метрики:

```bash
sudo cat /opt/mysql/backup/prometheus/backup.prom
```

Ожидаемое значение:

```text
mysql_backup_status 0
```

При этом время последней успешной резервной копии должно остаться прежним.

Откройте Grafana и убедитесь, что панель `Backup Status` показывает FAILED.

Запустите MySQL обратно:

```bash
docker compose start mysql
```

После восстановления MySQL повторите резервное копирование:

```bash
sudo /opt/mysql/backup_with_metrics.sh
```

Проверьте, что:

```text
mysql_backup_status 1
```

Система мониторинга должна отобразить успешное резервное копирование.

**Важно!** При проверке отказа резервного копирования существующие резервные копии не удаляются. Ошибка подключения к MySQL не должна приводить к удалению ранее созданных копий.

## 13. Итоговая архитектура системы

После выполнения лабораторной работы инфраструктура должна выглядеть следующим образом:

```text
                         Ubuntu Server
                              |
              +---------------+---------------+
              |                               |
              |                               |
          MySQL 8.4                       Linux OS
              |                               |
              |                               |
       MySQL Exporter                   Node Exporter
              |                               |
              |                         +-----+------+
              |                         |            |
              |                    System Metrics  backup.prom
              |                                      |
              +------------------+-------------------+
                                 |
                                 |
                            Prometheus
                                 |
                                 |
                              Grafana
                                 |
                                 |
                       MySQL Server Monitoring
```

Prometheus собирает:
- Состояние MySQL.
- Количество подключений.
- Количество активных потоков.
- Время работы MySQL.
- Загрузку процессора.
- Использование оперативной памяти.
- Использование дискового пространства.
- Результаты резервного копирования.
- Размер и продолжительность создания резервных копий.

Grafana отображает собранные показатели на едином дашборде.

## Контрольные вопросы

1. Что такое мониторинг серверной инфраструктуры?
2. Для чего используется Prometheus?
3. Для чего используется Grafana?
4. В чём заключается разница между Prometheus и Grafana?
5. Что такое Exporter?
6. Для чего предназначен MySQL Exporter?
7. Какие показатели можно получить с помощью Node Exporter?
8. Что такое Prometheus Target?
9. Что означает состояние `UP` и `DOWN`?
10. Для чего используется конфигурационный файл `prometheus.yml`?
11. Что такое PromQL?
12. Для чего используется Docker Volume в Prometheus и Grafana?
13. Почему для мониторинга MySQL создаётся отдельный пользователь `exporter`?
14. Для чего используется Textfile Collector?
15. Как Prometheus получает информацию о результате резервного копирования?
16. Чем отличается успешное создание резервной копии от проверки её возможности восстановления?
17. Почему наличие файла резервной копии не гарантирует возможность восстановления базы данных?
18. Что произойдёт с метриками MySQL при остановке контейнера базы данных?

## Итоговый результат работы

После выполнения лабораторной работы должны быть получены следующие результаты:

- [ ] Проверена работоспособность существующего MySQL 8.4.
- [ ] Подготовлены каталоги мониторинга.
- [ ] Создан отдельный пользователь MySQL `exporter`.
- [ ] Подготовлен конфигурационный файл MySQL Exporter.
- [ ] Создан конфигурационный файл `prometheus.yml`.
- [ ] Добавлены новые сервисы в Docker Compose.
- [ ] Развёрнут Prometheus.
- [ ] Развёрнута Grafana.
- [ ] Развёрнут MySQL Exporter.
- [ ] Развёрнут Node Exporter.
- [ ] Проверено состояние всех источников метрик в Prometheus.
- [ ] Проверен сбор метрик MySQL.
- [ ] Проверен сбор метрик Ubuntu.
- [ ] Prometheus подключён к Grafana.
- [ ] Создан дашборд `MySQL Server Monitoring`.
- [ ] Добавлены панели мониторинга MySQL.
- [ ] Добавлены панели мониторинга ресурсов Ubuntu.
- [ ] Настроена передача метрик резервного копирования.
- [ ] Добавлены панели мониторинга резервных копий.
- [ ] Проверена реакция мониторинга на остановку MySQL.
- [ ] Проверено обнаружение ошибки резервного копирования.
- [ ] Проверено восстановление мониторинга после запуска MySQL.

**Итог:** развёрнута система мониторинга серверной инфраструктуры на базе Prometheus и Grafana. Организован сбор метрик MySQL и Ubuntu, создан дашборд и настроен контроль автоматического резервного копирования базы данных.

## Полезные материалы

1. [Prometheus — официальная документация](https://prometheus.io/docs/introduction/first_steps/).
2. [Prometheus — конфигурация](https://prometheus.io/docs/prometheus/latest/configuration/configuration/).
3. [Grafana — официальная документация](https://grafana.com/docs/grafana/latest/).
4. [Grafana — подключение Prometheus](https://grafana.com/docs/grafana/latest/datasources/prometheus/).
5. [MySQL Exporter — GitHub](https://github.com/prometheus/mysqld_exporter).
6. [Node Exporter — GitHub](https://github.com/prometheus/node_exporter).
7. [Prometheus — Getting Started](https://prometheus.io/docs/prometheus/latest/getting_started/).
