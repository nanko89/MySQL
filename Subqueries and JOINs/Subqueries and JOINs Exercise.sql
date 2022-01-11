# --------------Ex 1 -------------

SELECT 
    e.`employee_id`,
    e.`job_title`,
    a.`address_id`,
    a.`address_text`
FROM
    `employees` AS e
        JOIN
    `addresses` AS a ON e.`address_id` = a.`address_id`
ORDER BY `address_id`
LIMIT 5;

# --------------Ex 2 -------------

SELECT 
    e.`first_name`, e.`last_name`, t.`name`, a.`address_text`
FROM
    `addresses` AS a
        JOIN
    `towns` AS t USING (`town_id`)
        JOIN
    `employees` AS e USING (`address_id`)
ORDER BY e.`first_name` , e.`last_name`
LIMIT 5;

# --------------Ex 3 -------------

SELECT 
    e.`employee_id`, e.`first_name`, e.`last_name`, d.`name`
FROM
    `employees` AS e
        JOIN
    `departments` AS d ON d.`department_id` = e.`department_id`
WHERE
    d.`name` = 'Sales'
ORDER BY `employee_id` DESC;

# --------------Ex 4 -------------

SELECT 
    e.`employee_id`, e.`first_name`, e.`salary`, d.`name`
FROM
    `employees` AS e
        JOIN
    `departments` AS d USING (`department_id`)
WHERE
    e.`salary` > 15000
ORDER BY d.`department_id` DESC
LIMIT 5;

# --------------Ex 5 -------------

SELECT 
    e.`employee_id`, e.`first_name`
FROM
    `employees` AS e
        LEFT JOIN
    `employees_projects` AS ep ON e.`employee_id` = ep.`employee_id`
WHERE
    ep.`employee_id` IS NULL
ORDER BY e.`employee_id` DESC
LIMIT 3;

# --------------Ex 6 -------------

SELECT 
    e.`first_name`, e.`last_name`, e.`hire_date`, d.`name`
FROM
    `employees` AS e
        JOIN
    `departments` AS d ON e.`department_id` = d.`department_id`
WHERE
    DATE(e.`hire_date`) > '1991-01-01'
        AND d.`name` IN ('Finance' , 'Sales')
ORDER BY `hire_date`;

# --------------Ex 7 -------------

SELECT 
    e.`employee_id`, e.`first_name`, p.`name`
FROM
    `employees_projects` AS ep
        JOIN
    `employees` AS e ON e.`employee_id` = ep.`employee_id`
        JOIN
    `projects` AS p ON ep.`project_id` = p.`project_id`
WHERE
    DATE(p.`start_date`) > '2002-08-13'
        AND p.`end_date` IS NULL
ORDER BY e.`first_name` , p.`name`
LIMIT 5;

# --------------Ex 8 -------------

SELECT 
    e.`employee_id`,
    e.`first_name`,
    IF(YEAR(p.`start_date`) > 2004,
        NULL,
        p.`name`) AS 'p_name'
FROM
    `employees_projects` AS ep
        RIGHT JOIN
    `employees` AS e ON e.`employee_id` = ep.`employee_id`
        LEFT JOIN
    `projects` AS p ON ep.`project_id` = p.`project_id`
WHERE
    e.`employee_id` = 24
ORDER BY `p_name`;

# --------------Ex 9 -------------

SELECT 
    e.`employee_id`,
    e.`first_name`,
    e.`manager_id`,
    m.`first_name`
FROM
    `employees` AS e
        JOIN
    `employees` AS m ON e.`manager_id` = m.`employee_id`
WHERE
    e.`manager_id` IN (3 , 7)
ORDER BY e.`first_name`;

# --------------Ex 10 -------------

SELECT 
    e.`employee_id`,
    CONCAT_WS(' ', e.`first_name`, e.`last_name`) AS `employee_name`,
    CONCAT_WS(' ', m.`first_name`, m.`last_name`) AS `manager_name`,
    d.`name`
FROM
    `employees` AS e
        JOIN
    `employees` AS m ON e.`manager_id` = m.`employee_id`
        JOIN
    `departments` AS d ON d.`department_id` = e.`department_id`
ORDER BY e.`employee_id`
LIMIT 5;

# -------------- Ex.11 --------------

SELECT 
    AVG(`salary`) AS `avg_salary`
FROM
    `employees` AS e
GROUP BY `department_id`
ORDER BY `avg_salary`
LIMIT 1;

# -------------- Ex.12 --------------

SELECT 
    c.`country_code`,
    m.`mountain_range`,
    p.`peak_name`,
    p.`elevation`
FROM
    `countries` AS c
        JOIN
    `mountains_countries` AS mc ON c.`country_code` = mc.`country_code`
        JOIN
    `mountains` AS m ON mc.`mountain_id` = m.`id`
        JOIN
    `peaks` AS p ON m.`id` = p.`mountain_id`
WHERE
    c.`country_code` = 'BG'
        AND p.`elevation` > 2835
ORDER BY p.`elevation` DESC;

# -------------- Ex.13 --------------/1
SELECT 
    c.`country_code`, COUNT(m.`mountain_range`) AS 'count'
FROM
    `countries` AS c
        JOIN
    `mountains_countries` AS mc USING (`country_code`)
        JOIN
    `mountains` AS m ON mc.`mountain_id` = m.`id`
WHERE
    c.`country_code` IN ('BG' , 'RU', 'US')
GROUP BY c.`country_code`
ORDER BY `count` DESC;
# -------------- Ex.13 --------------/2
SELECT 
    mc.`country_code`, COUNT(m.`id`) AS 'count'
FROM
    `mountains` AS m
        JOIN
    `mountains_countries` AS mc ON mc.`mountain_id` = m.`id`
WHERE
    mc.`country_code` IN ('BG' , 'RU', 'US')
GROUP BY c.`country_code`
ORDER BY `count` DESC;

# -------------- Ex.14 --------------

SELECT 
    c.`country_name`, r.`river_name`
FROM
    `countries` AS c
        LEFT JOIN
    `countries_rivers` AS cr USING (`country_code`)
        LEFT JOIN
    `rivers` AS r ON r.`id` = cr.`river_id`
WHERE
    c.`continent_code` = 'AF'
ORDER BY c.`country_name`
LIMIT 5;

# -------------- Ex.15 --------------

SELECT 
    c.`continent_code`,
    c.`currency_code`,
    COUNT(c.`currency_code`) AS 'count'
FROM
    `countries` AS c
GROUP BY `continent_code` , `currency_code`
HAVING `count` = (SELECT 
        COUNT(c2.`currency_code`) AS 'c_count'
    FROM
        `countries` AS c2
    WHERE
        c2.`continent_code` = c.`continent_code`
    GROUP BY `currency_code`
    ORDER BY `c_count` DESC
    LIMIT 1)
    AND `count` > 1
ORDER BY `continent_code` , `currency_code`;


# -------------- Ex.16 --------------

SELECT COUNT(*) AS 'count_country'
FROM `countries` AS c 
WHERE c.`country_code` NOT IN 
(
SELECT `country_code` FROM `mountains_countries`
);
# -------------- Ex.17 --------------

SELECT 
    c.`country_name`,
    MAX(p.elevation) AS 'max_peaks',
    MAX(r.`length`) AS 'max_river'
FROM
    `countries` AS c
        JOIN
    `mountains_countries` AS mc ON mc.`country_code` = c.`country_code`
        JOIN
    `mountains` AS m ON m.`id` = mc.`mountain_id`
        JOIN
    `peaks` AS p ON p.`mountain_id` = m.`id`
        JOIN
    `countries_rivers` AS cr ON cr.`country_code` = c.`country_code`
        JOIN
    `rivers` AS r ON r.`id` = cr.`river_id`
GROUP BY c.`country_name`
ORDER BY `max_peaks` DESC , `max_river` DESC , `country_name`
LIMIT 5;