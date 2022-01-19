CREATE DATABASE sgd;
USE sgd;

# ---------- Ex 1 Table Design ------------

CREATE TABLE addresses (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR (50) NOT NULL
);

CREATE TABLE offices (
id INT PRIMARY KEY AUTO_INCREMENT,
workspace_capacity INT NOT NULL,
website VARCHAR (50),
address_id INT NOT NULL,
CONSTRAINT fk_offices_addresses
FOREIGN KEY (address_id)
REFERENCES addresses (id)
);

CREATE TABLE employees (
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR (30) NOT NULL,
last_name VARCHAR (30) NOT NULL,
age INT NOT NULL,
salary DECIMAL (10,2) NOT NULL,
job_title VARCHAR (20) NOT NULL,
happiness_level CHAR (1) NOT NULL
);

CREATE TABLE teams (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR (40) NOT NULL,
office_id INT NOT NULL,
leader_id INT UNIQUE NOT NULL,
CONSTRAINT fk_teams_office
FOREIGN KEY (office_id)
REFERENCES offices (id),
CONSTRAINT fk_offices_employee
FOREIGN KEY (leader_id)
REFERENCES employees (id)
);

CREATE TABLE games (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR (50) UNIQUE NOT NULL,
`description` TEXT,
rating FLOAT  NOT NULL DEFAULT 5.5,
budget DECIMAL(10,2) NOT NULL, 
release_date DATE,
team_id INT NOT NULL,
CONSTRAINT fk_games_teams
FOREIGN KEY  (team_id)
REFERENCES teams (id)
);

CREATE TABLE categories (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR (10) NOT NULL
);

CREATE TABLE games_categories (
game_id	INT	NOT NULL, 
category_id	INT NOT NULL,
CONSTRAINT pk_games_categories
PRIMARY KEY (game_id, category_id),
CONSTRAINT fk_games_categories_games
FOREIGN KEY (game_id)
REFERENCES games(id),
CONSTRAINT fk_games_categories_categories
FOREIGN KEY (category_id)
REFERENCES categories(id)
);

# ---------- Ex 2 Insert ------------

INSERT INTO games (`name`, rating, budget, team_id )
SELECT REVERSE(LCASE(SUBSTR(`name`, 2))), id, leader_id * 1000, id 
FROM teams
WHERE id BETWEEN 1 AND 9;

# ---------- Ex 3 Update ------------

UPDATE employees 
SET 
    salary = salary + 1000
WHERE
    age <= 40 AND salary < 5000
        AND id IN (SELECT 
            leader_id
        FROM
            teams);

# ---------- Ex 4 Delete ------------

DELETE FROM games 
WHERE
    id NOT IN (SELECT 
        game_id
    FROM
        games_categories)
    AND release_date IS NULL;

# ---------- Ex 5 Employees ------------

SELECT 
    first_name, last_name, age, salary, happiness_level
FROM
    employees
ORDER BY salary , id;

# ---------- Ex 6 Addresses of the teams ------------

SELECT 
    t.`name` AS team_name,
    a.`name` AS address_name,
    CHAR_LENGTH(a.`name`) AS count_of_characters
FROM
    addresses AS a
        JOIN
    offices AS o ON o.address_id = a.id
        JOIN
    teams AS t ON t.office_id = o.id
WHERE
    o.website IS NOT NULL
ORDER BY team_name , address_name;

# ---------- Ex 7 Categories Info ------------

SELECT 
    c.`name`,
    COUNT(g.id) AS count_of_games,
    ROUND(AVG(g.budget), 2) AS avg_budget,
    MAX(g.rating) AS max_rating
FROM
    categories AS c
        JOIN
    games_categories AS gc ON c.id = gc.category_id
        JOIN
    games AS g ON gc.game_id = g.id
GROUP BY c.id
HAVING max_rating >= 9.5
ORDER BY count_of_games DESC , c.`name`;

# ---------- Ex 8 Games of 2022 ------------

SELECT 
    g.`name`,
    g.release_date,
    CONCAT(SUBSTR(g.`description`, 1, 10), '...') AS summary,
    (CASE
        WHEN MONTH(g.release_date) IN (1 , 2, 3) THEN 'Q1'
        WHEN MONTH(g.release_date) IN (4 , 5, 6) THEN 'Q2'
        WHEN MONTH(g.release_date) IN (7 , 8, 9) THEN 'Q3'
        WHEN MONTH(g.release_date) IN (10 , 11, 12) THEN 'Q4'
    END) AS `quarter`,
    t.`name`
FROM
    games AS g
        JOIN
    teams AS t ON g.team_id = t.id
WHERE
    YEAR(g.release_date) >= 2022
        AND MONTH(g.release_date) % 2 = 0
        AND RIGHT(g.`name`, 1) = '2'
ORDER BY `quarter`;

# ---------- Ex 9 Full info for games  ------------

SELECT 
    g.`name`,
    IF(g.budget < 50000,
        'Normal budget',
        'Insufficient budget') AS budget_level,
    t.`name` AS team_name,
    a.`name` AS address_name
FROM
    games AS g
        LEFT JOIN
    teams AS t ON t.id = g.team_id
        LEFT JOIN
    offices AS o ON t.office_id = o.id
        LEFT JOIN
    addresses AS a ON o.address_id = a.id
WHERE
    g.release_date IS NULL
        AND g.id NOT IN (SELECT 
            game_id
        FROM
            games_categories)
ORDER BY g.`name`;

# ---------- Ex 10 Find all basic information for a game  ------------

DELIMITER %%

CREATE FUNCTION udf_game_info_by_name (game_name VARCHAR (20)) 
RETURNS TEXT
	DETERMINISTIC
BEGIN
	RETURN (SELECT CONCAT('The ',g.`name`,' is developed by a ',t.`name`,' in an office with an address ',a.`name`) AS info FROM 
    games AS g
        LEFT JOIN
    teams AS t ON t.id = g.team_id
        LEFT JOIN
    offices AS o ON t.office_id = o.id
        LEFT JOIN
    addresses AS a ON o.address_id = a.id
WHERE g.`name` = game_name);
END %%

DELIMITER ;

# ---------- Ex 11 Update Budget of the Games  ------------
DELIMITER &&

CREATE PROCEDURE udp_update_budget (min_game_rating FLOAT)
BEGIN
 UPDATE games
 SET budget = budget + 100000.00 , release_date = DATE_ADD(release_date, INTERVAL 1 YEAR )
 WHERE rating > min_game_rating 
 AND release_date IS NOT NULL
 AND id NOT IN (SELECT game_id FROM games_categories );
 END &&
 
 DELIMITER ;
