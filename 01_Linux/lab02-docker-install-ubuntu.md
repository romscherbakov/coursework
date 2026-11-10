# Лабораторная работа № 2
# Установка и первоначальная настройка Docker в Ubuntu

## Цель работы

Установить Docker Engine в виртуальную машину Ubuntu, проверить его работу и освоить основные команды управления контейнерами.

## Необходимое

- Виртуальная машина Ubuntu в Oracle VirtualBox.
- Пользователь Ubuntu с правами `sudo`.
- Доступ виртуальной машины в Интернет.

**Регистрация не требуется.** Аккаунты Docker Hub и GitHub не нужны. Используемые в работе образы `hello-world` и `nginx:alpine` общедоступны и загружаются без авторизации.

**Сеть VirtualBox:** для этой работы достаточно режима NAT. Подключение к Docker из Windows пока не требуется.

## Результат работы

Docker Engine установлен и запущен. Студент умеет загружать образы, создавать, просматривать, запускать, останавливать и удалять контейнеры.

---

## 1. Подготовка виртуальной машины

Запустите Ubuntu и откройте терминал.

Проверьте доступ в Интернет:

```bash
ping -c 4 ubuntu.com
```

Посмотрите версию Ubuntu и архитектуру:

```bash
lsb_release -a
dpkg --print-architecture
```

Для типовой виртуальной машины на ПК ожидается архитектура `amd64`.

## 2. Установка Docker Engine

Установим Docker Engine из официального репозитория Docker.

### 2.1. Подготовка системы

```bash
sudo apt update
sudo apt install ca-certificates curl
```

`apt update` обновляет сведения о пакетах, `ca-certificates` обеспечивает проверку сертификатов HTTPS, `curl` позволяет загружать файлы из Интернета.

### 2.2. Добавление ключа Docker

```bash
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

Ключ позволяет менеджеру пакетов проверять подлинность пакетов из репозитория Docker.

### 2.3. Добавление официального репозитория

Выполните команду целиком:

```bash
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
```

Обновите сведения о пакетах:

```bash
sudo apt update
```

### 2.4. Установка компонентов Docker

```bash
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Подтвердите установку, если `apt` запросит подтверждение.

| Компонент | Назначение |
|---|---|
| `docker-ce` | Docker Engine — служба управления контейнерами |
| `docker-ce-cli` | Командная строка `docker` |
| `containerd.io` | Среда выполнения контейнеров |
| `docker-buildx-plugin` | Инструменты сборки образов |
| `docker-compose-plugin` | Управление многоконтейнерными приложениями |

## 3. Проверка установки и службы

Проверьте версию:

```bash
docker --version
```

Проверьте состояние службы:

```bash
sudo systemctl status docker
```

Найдите состояние `Active: active (running)`.

Если служба не запущена, выполните:

```bash
sudo systemctl enable --now docker
```

Команда включает автозапуск Docker при старте Ubuntu и запускает службу сейчас.

Проверьте взаимодействие клиента с сервером Docker:

```bash
sudo docker version
```

В выводе должны присутствовать разделы `Client` и `Server`.

## 4. Первый контейнер: hello-world

Запустите тестовый контейнер:

```bash
sudo docker run hello-world
```

При первом запуске Docker загрузит образ из публичного реестра Docker Hub. После этого появится сообщение, начинающееся примерно так:

```text
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

Это означает, что Docker установлен и может запускать контейнеры.

Что произошло:

1. Docker проверил, есть ли образ `hello-world` на виртуальной машине.
2. Если образ отсутствовал, Docker скачал его из Docker Hub.
3. На основе образа был создан контейнер.
4. Контейнер выполнил программу, вывел сообщение и завершил работу.

Входить в Docker Hub для загрузки этого общедоступного образа не требуется.

## 5. Просмотр образов и контейнеров

Список загруженных образов:

```bash
sudo docker images
```

Список работающих контейнеров:

```bash
sudo docker ps
```

Контейнер `hello-world` не отображается, потому что уже завершил работу.

Список всех контейнеров, в том числе остановленных:

```bash
sudo docker ps -a
```

В списке должен присутствовать `hello-world` со статусом `Exited`.

## 6. Практика: управление работающим контейнером

Теперь запустим простой веб-сервер Nginx. Его образ также общедоступен, регистрация не нужна.

### 6.1. Запуск контейнера

```bash
sudo docker run -d --name web-lab -p 8080:80 nginx:alpine
```

| Параметр | Назначение |
|---|---|
| `-d` | Запуск в фоновом режиме |
| `--name web-lab` | Имя контейнера |
| `-p 8080:80` | Порт 8080 Ubuntu перенаправляется на порт 80 контейнера |
| `nginx:alpine` | Используемый образ Nginx |

Проверьте, что контейнер работает:

```bash
sudo docker ps
```

В списке должен появиться `web-lab` со статусом `Up`.

### 6.2. Проверка веб-сервера

```bash
curl http://localhost:8080
```

В ответ должен прийти HTML-код стартовой страницы Nginx.

`localhost` здесь означает саму виртуальную машину Ubuntu. Docker перенаправляет запрос с порта `8080` Ubuntu на порт `80` внутри контейнера.

### 6.3. Просмотр журналов

```bash
sudo docker logs web-lab
```

Команда показывает сообщения контейнера.

### 6.4. Остановка и повторный запуск

Остановите контейнер:

```bash
sudo docker stop web-lab
```

Посмотрите его состояние:

```bash
sudo docker ps -a
```

Запустите этот же контейнер снова:

```bash
sudo docker start web-lab
```

Проверьте:

```bash
sudo docker ps
```

### 6.5. Удаление контейнера

Остановите контейнер и удалите его:

```bash
sudo docker stop web-lab
sudo docker rm web-lab
```

Проверьте список:

```bash
sudo docker ps -a
```

Контейнер `web-lab` должен исчезнуть. Образ Nginx при этом останется на виртуальной машине:

```bash
sudo docker images
```

**Важно различать:**
- **Образ (image)** — шаблон, из которого создают контейнеры.
- **Контейнер (container)** — созданный на основе образа экземпляр приложения, который может работать или быть остановлен.

Удаление контейнера само по себе не удаляет образ.

## 7. Основные команды Docker

| Команда | Назначение |
|---|---|
| `sudo docker version` | Версия и состояние клиента/сервера |
| `sudo docker images` | Список образов |
| `sudo docker ps` | Список работающих контейнеров |
| `sudo docker ps -a` | Список всех контейнеров |
| `sudo docker run IMAGE` | Создать и запустить контейнер |
| `sudo docker start NAME` | Запустить остановленный контейнер |
| `sudo docker stop NAME` | Остановить контейнер |
| `sudo docker logs NAME` | Посмотреть журналы контейнера |
| `sudo docker rm NAME` | Удалить остановленный контейнер |
| `sudo docker rmi IMAGE` | Удалить образ |

## 8. Контрольное задание

Покажите преподавателю:

1. Состояние службы Docker: `sudo systemctl status docker` — `active (running)`.
2. Вывод `sudo docker images` с образами `hello-world` и `nginx`.
3. Вывод `sudo docker ps -a` с завершённым контейнером `hello-world`.
4. Результат `curl http://localhost:8080` во время работы Nginx.
5. Остановку и повторный запуск `web-lab`.
6. Список контейнеров после удаления `web-lab`.

## 9. Контрольные вопросы

1. Что такое Docker Engine?
2. Чем образ отличается от контейнера?
3. Для чего нужна команда `docker run`?
4. Чем отличаются `docker ps` и `docker ps -a`?
5. Что означает параметр `-d`?
6. Что означает запись `-p 8080:80`?
7. Почему `hello-world` не отображается в `docker ps`?
8. Удаляется ли образ при удалении контейнера?
9. Для чего нужна служба Docker и зачем включать её автозапуск?
10. Нужна ли регистрация в Docker Hub для загрузки общедоступного образа?

## 10. Дополнительное задание

1. Запустите второй контейнер Nginx с именем `web-lab-2`, опубликовав порт `8081` Ubuntu на порт `80` контейнера.
2. Проверьте его командой `curl http://localhost:8081`.
3. Посмотрите список двух работающих контейнеров.
4. Остановите и удалите оба контейнера.

---

## Примечания по безопасности

- В этой работе команды Docker выполняются через `sudo`.
- Не добавляйте учебного пользователя в группу `docker` без необходимости: членство в ней фактически предоставляет привилегии уровня `root`.
- Порт `8080` нужен для проверки внутри виртуальной машины. Не настраивайте проброс портов VirtualBox на основной компьютер.
- Не используйте учебную виртуальную машину для размещения общедоступных сервисов.

## Официальная документация

- [Установка Docker Engine в Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
- [Команда docker run](https://docs.docker.com/reference/cli/docker/container/run/)
- [Команда docker ps](https://docs.docker.com/reference/cli/docker/container/ls/)
- [Команда docker stop](https://docs.docker.com/reference/cli/docker/container/stop/)
- [Команда docker rm](https://docs.docker.com/reference/cli/docker/container/rm/)
