-- ============================================================
-- Учебная база данных test3
-- СУБД: MySQL 8.x
-- Инструмент: MySQL Workbench
--
-- Назначение:
--   Создать учебную базу данных для практики SQL-запросов.
--
-- ВНИМАНИЕ:
--   Скрипт удаляет существующую базу test3 вместе со всеми данными
--   и создаёт её заново. Перед запуском убедитесь, что в ней нет
--   нужных вам данных.
--
-- В наборе данных даты перенесены с 2020 на 2026 год.
-- В конце скрипта выводится количество записей в каждой таблице.
-- ============================================================

DROP DATABASE IF EXISTS test3;

CREATE DATABASE test3
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE test3;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE departments (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) DEFAULT NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE projects (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) DEFAULT NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE workers (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    department_id INT UNSIGNED NOT NULL,
    name VARCHAR(255) DEFAULT NULL,
    PRIMARY KEY (id),
    KEY idx_workers_department_id (department_id),
    CONSTRAINT fk_workers_department
        FOREIGN KEY (department_id) REFERENCES departments (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tags (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) DEFAULT NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tasks (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    project_id INT UNSIGNED NOT NULL,
    creator_id INT UNSIGNED NOT NULL,
    worker_id INT UNSIGNED NOT NULL,
    description VARCHAR(255) DEFAULT NULL,
    done TINYINT NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT '2026-01-13 00:00:00',
    started_at DATETIME DEFAULT NULL,
    end_at DATETIME DEFAULT NULL,
    PRIMARY KEY (id),
    KEY idx_tasks_project_id (project_id),
    KEY idx_tasks_creator_id (creator_id),
    KEY idx_tasks_worker_id (worker_id),
    CONSTRAINT fk_tasks_project
        FOREIGN KEY (project_id) REFERENCES projects (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_tasks_creator
        FOREIGN KEY (creator_id) REFERENCES workers (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_tasks_worker
        FOREIGN KEY (worker_id) REFERENCES workers (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE salaries (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    worker_id INT UNSIGNED DEFAULT NULL,
    salary INT DEFAULT NULL,
    `date` DATETIME DEFAULT NULL,
    PRIMARY KEY (id),
    KEY idx_salaries_worker_id (worker_id),
    CONSTRAINT fk_salaries_worker
        FOREIGN KEY (worker_id) REFERENCES workers (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tags_tasks (
    tag_id INT UNSIGNED NOT NULL,
    task_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (tag_id, task_id),
    KEY idx_tags_tasks_task_id (task_id),
    CONSTRAINT fk_tags_tasks_tag
        FOREIGN KEY (tag_id) REFERENCES tags (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_tags_tasks_task
        FOREIGN KEY (task_id) REFERENCES tasks (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO departments (id, name) VALUES
(1,'Отдел разработки'),
(2,'Отдел дизайна'),
(3,'Отдел маркетинга'),
(4,'Отдел аккаунтинга');

INSERT INTO projects (id, name) VALUES
(1,'КайзерДом'),
(2,'Юнитраст.Корпоративный'),
(3,'Юнитраст.Промо'),
(4,'Резина43'),
(5,'Сантехника 888'),
(6,'Автоцифра'),
(7,'Доска почета'),
(8,'Садовник'),
(9,'ООО Тракер'),
(10,'Мир Комфорта');

INSERT INTO workers (id, department_id, name) VALUES
(1,1,'Иванов Михаил'),
(2,1,'Збруев Роман'),
(3,1,'Окулов Ярослав'),
(4,1,'Тарасов Александр'),
(5,1,'Окулов Антон'),
(6,2,'Созинов Илья'),
(7,2,'Орлова Анастасия'),
(8,3,'Глызин Максим'),
(9,3,'Коротаева Диана'),
(10,3,'Москвин Дмитрий'),
(11,4,'Белянин Алексей'),
(12,4,'Суворов Алексей');

INSERT INTO salaries (id, worker_id, salary, `date`) VALUES
(1,1,300,'2026-01-10 17:00:00'),
(2,2,500,'2026-01-10 17:01:00'),
(3,3,400,'2026-01-10 17:02:00'),
(4,1,300,'2026-02-10 16:00:00'),
(5,4,500,'2026-02-10 17:00:00'),
(6,6,700,'2026-02-10 18:00:00'),
(7,4,200,'2026-03-10 16:00:00'),
(8,6,200,'2026-03-10 16:00:00'),
(9,1,400,'2026-03-10 16:01:00'),
(10,4,200,'2026-03-10 16:02:00'),
(11,7,200,'2026-01-10 17:03:00'),
(12,8,1000,'2026-01-10 16:03:00'),
(13,9,300,'2026-03-05 16:00:00'),
(14,12,1200,'2026-03-05 16:20:00'),
(15,11,1000,'2026-03-03 16:20:00'),
(16,7,200,'2026-03-10 12:01:00');

INSERT INTO tags (id, name) VALUES
(1,'переделать'),
(2,'выгрузка'),
(3,'разработка'),
(4,'сделать'),
(5,'саппорт'),
(6,'починить'),
(7,'маркетинг'),
(8,'бюджет'),
(9,'кнопки'),
(10,'верстка'),
(11,'адаптивность'),
(12,'дизайн'),
(13,'треш'),
(14,'ставки'),
(15,'прибраться'),
(16,'кампании'),
(17,'внутреннее'),
(18,'тз'),
(19,'смета'),
(20,'согласование');

INSERT INTO tasks
(id, project_id, creator_id, worker_id, description, done, created_at, started_at, end_at)
VALUES
(1,5,12,2,'Переписать выгрузку',0,'2026-01-13 10:00:00',NULL,NULL),
(2,2,12,1,'Сверстать форму обратной связи',0,'2026-02-10 09:00:00',NULL,NULL),
(3,4,12,3,'Починить страницу сервиса',1,'2026-01-20 15:00:00','2026-01-20 16:00:00','2026-01-20 20:00:00'),
(4,6,11,9,'Посчитать бюджет на январь',0,'2026-02-01 18:00:00','2026-02-02 15:00:00',NULL),
(5,3,12,1,'Пофиксить кнопки уезжают',1,'2026-01-15 08:00:00','2026-01-15 12:00:00','2026-01-16 09:00:00'),
(6,10,12,4,'Поправить выгрузку',1,'2026-01-17 05:00:00','2026-01-17 09:00:00','2026-01-17 12:00:00'),
(7,7,5,3,'Изменить данные на странице контактов',0,'2026-01-11 20:00:00',NULL,NULL),
(8,8,12,2,'Исправить футер',0,'2026-01-04 17:00:00','2026-01-04 19:00:00',NULL),
(9,3,11,1,'Переверстать основной блок на главной',0,'2026-01-09 16:00:00',NULL,NULL),
(10,1,12,4,'Переделать меню',1,'2026-02-01 15:00:00','2026-02-01 17:00:00','2026-02-01 19:00:00'),
(11,9,11,3,'Изменить ширину мобилки',0,'2026-02-23 13:00:00','2026-02-23 19:00:00',NULL),
(12,10,12,4,'Сдвинуть вниз вот этот блок',1,'2026-01-18 12:00:00','2026-01-18 13:00:00','2026-01-18 13:30:00'),
(13,7,11,2,'Переверстываем совсем вот это вот - надо вертикально',0,'2026-01-05 12:00:00',NULL,NULL),
(14,4,6,3,'Добавить еще одну кнопку по макету',1,'2026-01-25 01:00:00','2026-01-26 08:00:00','2026-01-26 10:00:00'),
(15,2,7,1,'Убрать лишние ссылки вникуда',0,'2026-02-20 11:00:00',NULL,NULL),
(16,7,5,4,'SEO - оптимизация',1,'2026-02-03 13:00:00','2026-02-03 13:00:00','2026-02-03 13:20:00'),
(17,8,6,1,'Добавить телефон в шапку',0,'2026-01-19 14:00:00','2026-01-20 21:00:00',NULL),
(18,5,12,2,'Изменить окно входа в личный кабинет',1,'2026-01-22 16:00:00','2026-01-22 18:00:00','2026-01-22 18:10:00'),
(19,2,12,7,'Перерисовать блок сертификатов',0,'2026-01-29 17:00:00',NULL,NULL),
(20,10,11,6,'Отрисовать страницу галереи',1,'2026-02-21 07:00:00','2026-02-21 09:00:00','2026-02-21 10:00:00'),
(21,8,11,7,'Изменить фон на более темный',1,'2026-02-04 10:00:00','2026-02-04 13:00:00','2026-02-04 17:00:00'),
(22,8,12,6,'Поиграть со шрифтами',0,'2026-02-14 11:00:00',NULL,NULL),
(23,5,12,10,'Посчитать бюджет на гугл на февраль',1,'2026-01-30 18:00:00','2026-02-03 09:00:00','2026-02-03 12:00:00'),
(24,7,11,8,'Поднять ставки на старых кампаниях!',0,'2026-02-16 19:00:00','2026-02-17 10:00:00',NULL),
(25,7,11,8,'Почистить кампании',1,'2026-01-01 20:00:00','2026-01-05 08:00:00','2026-01-07 12:00:00'),
(26,2,12,9,'Проверить ставки',0,'2026-01-12 14:00:00',NULL,NULL),
(27,3,12,8,'Разработать новую кампанию',1,'2026-01-19 11:00:00','2026-01-19 11:00:00','2026-01-19 19:00:00'),
(28,6,11,9,'Снизить ставки для новых кампании - много жрут',0,'2026-01-27 10:00:00',NULL,NULL),
(29,3,12,12,'Подготовить ТЗ на новую страницу',1,'2026-02-23 18:00:00','2026-02-23 20:00:00','2026-02-24 20:00:00'),
(30,4,11,11,'Созвониться с клиентом и утвердить смету на саппорт',1,'2026-02-02 10:00:00','2026-02-05 08:00:00','2026-02-05 09:00:00'),
(31,1,12,12,'Согласовать макеты',0,'2026-01-13 12:00:00','2026-01-17 11:00:00',NULL);

INSERT INTO tags_tasks (tag_id, task_id) VALUES
(1,1),(2,1),(3,1),
(4,2),(3,2),(5,2),(10,2),
(6,3),(3,3),
(7,4),(8,4),
(6,5),(9,5),(10,5),(3,5),
(6,6),(2,6),(3,6),
(6,7),(3,7),
(6,8),(10,8),(3,8),
(4,9),(10,9),(5,9),(3,9),
(4,10),(10,10),(3,10),
(4,11),(11,11),
(6,12),(10,12),(11,12),
(4,13),(10,13),(3,13),(11,13),
(6,14),(10,14),(5,14),(3,14),
(6,15),(10,15),(3,15),
(4,16),(3,16),
(4,17),(10,17),(3,17),(11,17),
(4,18),(10,18),(3,18),(11,18),
(4,19),(12,19),
(4,20),(12,20),
(6,21),(12,21),
(6,22),(12,22),(13,22),
(7,23),(8,23),
(7,24),(14,24),
(7,25),(15,25),
(7,26),(15,26),
(7,27),(16,27),
(7,28),(14,28),
(17,29),(18,29),
(17,30),(5,30),(19,30),(20,30),
(17,31),(12,31),(20,31);

SET FOREIGN_KEY_CHECKS = 1;

-- Проверка количества записей
SELECT 'departments' AS table_name, COUNT(*) AS row_count FROM departments
UNION ALL SELECT 'projects', COUNT(*) FROM projects
UNION ALL SELECT 'workers', COUNT(*) FROM workers
UNION ALL SELECT 'tasks', COUNT(*) FROM tasks
UNION ALL SELECT 'salaries', COUNT(*) FROM salaries
UNION ALL SELECT 'tags', COUNT(*) FROM tags
UNION ALL SELECT 'tags_tasks', COUNT(*) FROM tags_tasks;

-- Проверка внешних ключей:
-- SHOW CREATE TABLE workers;
-- SHOW CREATE TABLE tasks;
-- SHOW CREATE TABLE salaries;
-- SHOW CREATE TABLE tags_tasks;
