# 📚 Практикум: Функции и операции в SQL

## 🎯 Цель задания
Освоить работу с различными типами функций и операциями объединения в SQL-запросах.

## 📊 Изучаемые темы
✅ Агрегационные функции (MAX, MIN, AVG, COUNT, SUM)  
✅ Строковые функции (REPLACE, CONCAT, SUBSTRING)  
✅ Математические функции (ROUND, ABS, MOD, FLOOR)  
✅ Функции работы с датами (DATE, MONTH, YEAR, DATEDIFF)  
✅ Операции объединения (UNION, UNION ALL)  
✅ Псевдонимы (AS)

## 🗃️ Структура базы данных
Работаем с базой departments, которая содержит таблицы:
- workers - сотрудники
- salaries - зарплаты  
- tasks - задачи
- tags - теги
- tags_tasks - связь тегов и задач

## 📝 Основные задания

### 🔹 Агрегационные функции

**1. Максимальная зарплата**  
Выбрать максимальную зарплату за всё время.

<details>
<summary>Ответ</summary>

```sql
SELECT MAX(salary) AS max_salary FROM salaries;
```
</details>

**2. Средняя зарплата за март**  
Выбрать среднюю зарплату за март 2020 года.

<details>
<summary>Ответ</summary>

```sql
SELECT AVG(salary) AS avg_salary 
FROM salaries 
WHERE YEAR(date) = 2020 AND MONTH(date) = 3;
```
</details>

**3. Количество выплат**  
Найти количество всех выплат с начала января по конец февраля 2020 года.

<details>
<summary>Ответ</summary>

```sql
SELECT COUNT(*) AS payments_count 
FROM salaries 
WHERE date BETWEEN '2020-01-01' AND '2020-02-29';
```
</details>

**4. Сумма зарплат 10 числа**  
Выбрать сумму всех зарплат, выплаченных 10 числа любого месяца.

<details>
<summary>Ответ</summary>

```sql
SELECT SUM(salary) AS total_salary 
FROM salaries 
WHERE DAY(date) = 10;
```
</details>

**5. Количество тегов для задач**  
Подсчитать количество тегов, которые относятся к задачам с id = 10, 13, 22.

<details>
<summary>Ответ</summary>

```sql
SELECT COUNT(*) AS tags_count 
FROM tags_tasks 
WHERE task_id IN (10, 13, 22);
```
</details>

**6. Процент выполненных задач**  
Подсчитать процент выполненных задач, поставленных в январе 2020 года.

<details>
<summary>Ответ</summary>

```sql
SELECT 
    ROUND((SUM(done) / COUNT(*)) * 100, 2) AS completion_percentage
FROM tasks 
WHERE YEAR(created_at) = 2020 AND MONTH(created_at) = 1;
```
</details>

### 🔹 Строковые функции

**7. Замена в описаниях**  
Выбрать описания всех задач, заменив "Починить" на "Исправить".

<details>
<summary>Ответ</summary>

```sql
SELECT REPLACE(description, 'Починить', 'Исправить') AS modified_description 
FROM tasks;
```
</details>

**8. Короткие имена сотрудников**  
Выбрать короткое имя сотрудника (например, не "Збруев Роман", а "Збруев Р.").

<details>
<summary>Ответ</summary>

```sql
SELECT 
    CONCAT(
        SUBSTRING(name, 1, LOCATE(' ', name) - 1), 
        ' ', 
        SUBSTRING(name, LOCATE(' ', name) + 1, 1),
        '.'
    ) AS short_name 
FROM workers;
```
</details>

**9. Первые буквы отделов**  
Вывести первые три буквы названия каждого отдела.

<details>
<summary>Ответ</summary>

```sql
SELECT SUBSTRING(name, 1, 3) AS 'три буквы отдела' FROM departments;

-- или

SELECT SUBSTRING(name, LOCATE(' ', name) + 1, 3) AS 'три буквы отдела' FROM departments;

```
</details>

### 🔹 Функции дат и времени

**10. Время максимальной выплаты**  
Выбрать время, когда была выплачена максимальная зарплата за февраль 2020.

<details>
<summary>Ответ</summary>

```sql
SELECT TIME(date) AS payment_time 
FROM salaries 
WHERE YEAR(date) = 2020 AND MONTH(date) = 2 
ORDER BY salary DESC 
LIMIT 1;
```
</details>

**11. Среднее время выполнения**  
Выбрать среднее время исполнения задачи за всё время (в минутах).

<details>
<summary>Ответ</summary>

```sql
SELECT AVG(TIMESTAMPDIFF(MINUTE, started_at, end_at)) AS avg_completion_minutes 
FROM tasks 
WHERE done = 1 AND started_at IS NOT NULL AND end_at IS NOT NULL;
```
</details>

**12. Кварталы создания задач**  
Вывести количество задач, созданных в каждом квартале 2020 года (тут через GROUP BY и QUARTER(квартал)).

<details>
<summary>Ответ</summary>

```sql
SELECT 
    QUARTER(created_at) AS quarter,
    COUNT(*) AS tasks_count
FROM tasks 
WHERE YEAR(created_at) = 2020
GROUP BY QUARTER(created_at)
ORDER BY quarter;
```
</details>

### 🔹 Математические функции

**13. Ближайшие к 330 зарплаты**  
Выбрать 5 зарплат максимально близких к 330.

<details>
<summary>Ответ</summary>

```sql
SELECT salary 
FROM salaries 
ORDER BY ABS(salary - 330) ASC 
LIMIT 5;
```
</details>

**14. Разница от средней**  
Для каждой зарплаты вывести разницу между зарплатой и средней зарплатой по всем выплатам (через подзапрос).

<details>
<summary>Ответ</summary>

```sql
SELECT 
    salary,
    salary - (SELECT AVG(salary) FROM salaries) AS difference_from_avg
FROM salaries;
```
</details>

### 🧩 Задания на UNION

**15. Объединение отделов и проектов**  
Вывести объединенный список названий отделов и проектов.

<details>
<summary>Ответ</summary>

```sql
SELECT name FROM departments
UNION
SELECT name FROM projects;
```
</details>

**16. Зарплаты в диапазонах**  
Разделите все зарплаты на три категории: "Высокая" (>500), "Средняя" (300-500) и "Низкая" (<300), и объедините их в один список, отсортированный по категориям и убыванию суммы.

<details>
<summary>Ответ</summary>

```sql
SELECT salary, 'Высокая' AS category FROM salaries WHERE salary > 500
UNION ALL
SELECT salary, 'Средняя' AS category FROM salaries WHERE salary BETWEEN 300 AND 500
UNION ALL
SELECT salary, 'Низкая' AS category FROM salaries WHERE salary < 300
ORDER BY category, salary DESC;
```
</details>

**17. Фильтрованное объединение отделов**  
Объединить список сотрудников отдела разработки (id=1) и отдела дизайна (id=2).

<details>
<summary>Ответ</summary>

```sql
SELECT name FROM workers WHERE department_id = 1
UNION ALL
SELECT name FROM workers WHERE department_id = 2;
```
</details>

**18. Объединение зарплатных периодов**  
Объединить список зарплат за январь и февраль 2020 года.

<details>
<summary>Ответ</summary>

```sql
SELECT salary, date FROM salaries WHERE YEAR(date) = 2020 AND MONTH(date) = 1
UNION ALL
SELECT salary, date FROM salaries WHERE YEAR(date) = 2020 AND MONTH(date) = 2
ORDER BY date;
```
</details>

**19. Задачи по статусам через UNION**  
Объединить список завершенных и незавершенных задач с указанием статуса в отдельном столбце.

<details>
<summary>Ответ</summary>

```sql
SELECT id, description, 'Завершена' AS status FROM tasks WHERE done = 1
UNION ALL
SELECT id, description, 'Не завершена' AS status FROM tasks WHERE done = 0
ORDER BY status, id;
```
</details>

## 🎮 Ещё задачки

**20. Дни недели создания задач**  
Вывести количество задач, созданных в каждый день недели.

<details>
<summary>Ответ</summary>

```sql
SELECT 
    DAYNAME(created_at) AS day_of_week,
    COUNT(*) AS tasks_count
FROM tasks
GROUP BY DAYNAME(created_at), DAYOFWEEK(created_at)
ORDER BY DAYOFWEEK(created_at);
```
</details>

**21. Длина описаний задач**  
Вывести id задачи и длину её описания в символах, отсортировать по убыванию длины.

<details>
<summary>Ответ</summary>

```sql
SELECT 
    id,
    LENGTH(description) AS description_length
FROM tasks
ORDER BY description_length DESC;
```
</details>

**22. Зарплаты в разных валютах**  
Вывести зарплаты в условных "евро" (курс 0.85) и "йенах" (курс 110).

<details>
<summary>Ответ</summary>

```sql
SELECT 
    salary AS salary_rub,
    ROUND(salary * 0.85, 2) AS salary_eur,
    salary * 110 AS salary_yen
FROM salaries;
```
</details>

**23. Возраст задач**  
Вывести сколько дней прошло с момента создания каждой задачи на текущую дату.

<details>
<summary>Ответ</summary>

```sql
SELECT 
    id,
    DATEDIFF(CURDATE(), created_at) AS days_since_creation
FROM tasks;
```
</details>

