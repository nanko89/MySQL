CREATE DATABASE sgd;
USE sgd;

-- 1---------------------------

CREATE TABLE addresses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL
);

CREATE TABLE categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(10) NOT NULL
);

CREATE TABLE offices (
    id INT PRIMARY KEY AUTO_INCREMENT,
    workspace_capacity INT NOT NULL,
    website VARCHAR(50),
    address_id INT NOT NULL,
    CONSTRAINT fk_offices_address FOREIGN KEY (address_id)
        REFERENCES addresses (id)
);

CREATE TABLE employees (
    id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    age INT NOT NULL,
    salary DECIMAL(10 , 2 ) NOT NULL,
    job_title VARCHAR(20) NOT NULL,
    happiness_level CHAR(1) NOT NULL
);


CREATE TABLE teams (
    id INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(40) NOT NULL,
    office_id INT NOT NULL,
    leader_id INT UNIQUE NOT NULL,
    CONSTRAINT fk_teams_office FOREIGN KEY (office_id)
        REFERENCES offices (id),
    CONSTRAINT fk_teams_leader FOREIGN KEY (leader_id)
        REFERENCES employees (id)
);

CREATE TABLE games (
    id INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) UNIQUE NOT NULL,
    `description` TEXT,
    rating FLOAT DEFAULT 5.5 NOT NULL,
    budget DECIMAL(10 , 2 ) NOT NULL,
    release_date DATE,
    team_id INT NOT NULL,
    CONSTRAINT fk_games_teams FOREIGN KEY (team_id)
        REFERENCES teams (id)
);

CREATE TABLE games_categories (
    game_id INT NOT NULL,
    category_id INT NOT NULL,
    CONSTRAINT pk_games_categories PRIMARY KEY (game_id , category_id),
    CONSTRAINT fk_games_categories_game FOREIGN KEY (game_id)
        REFERENCES games (id),
    CONSTRAINT fk_games_categories_category FOREIGN KEY (category_id)
        REFERENCES categories (id)
);

-- 2---------------------------

INSERT INTO games (`name`, rating , budget, team_id )
SELECT (LCASE(REVERSE(SUBSTRING(`name`, 2)))), id, leader_id * 1000, id FROM teams
WHERE id BETWEEN 1 AND 9;

-- 3---------------------------

UPDATE employees 
SET 
    salary = salary + 1000
WHERE
    age >= 40
        AND id IN (SELECT 
            leader_id
        FROM
            teams)
        AND salary < 5000;

-- 4---------------------------


DELETE FROM games 
WHERE
    release_date IS NULL
    AND id NOT IN (SELECT 
        game_id
    FROM
        games_categories);

-- 5---------------------------


SELECT 
    first_name, last_name, age, salary, happiness_level
FROM
    employees
ORDER BY salary , id;


-- 6---------------------------


SELECT 
    t.`name` AS teams_name,
    a.`name` AS address_name,
    CHAR_LENGTH(a.name) AS count_of_characters
FROM
    teams AS t
        JOIN
    offices AS o ON t.office_id = o.id
        JOIN
    addresses AS a ON o.address_id = a.id
WHERE
    o.website IS NOT NULL
ORDER BY teams_name , address_name;


-- 7---------------------------

SELECT 
    c.`name`,
    COUNT(gc.game_id) AS count_game,
    ROUND(AVG(g.budget), 2) AS avg_budget,
    MAX(g.rating) AS max_rating
FROM
    categories AS c
        JOIN
    games_categories AS gc ON c.id = gc.category_id
        JOIN
    games AS g ON g.id = gc.game_id
GROUP BY c.`name`
HAVING max_rating >= 9.5
ORDER BY count_game DESC , c.`name`;

-- 8---------------------------

SELECT 
    g.`name`,
    (IF(g.budget > 50000,
        'Insufficient budget',
        'Normal budget')) AS budget_level,
    t.`name` AS team_name,
    a.`name` AS address_name
FROM
    games AS g
        JOIN
    teams AS t ON g.team_id = t.id
        JOIN
    offices AS o ON t.office_id = o.id
        JOIN
    addresses AS a ON o.address_id = a.id
WHERE
    g.release_date IS NULL
        AND g.id NOT IN (SELECT 
            game_id
        FROM
            games_categories)
ORDER BY g.`name`;


-- 10---------------------------

DELIMITER %%

CREATE FUNCTION udf_game_info_by_name (game_name VARCHAR (20))
	RETURNS TEXT
DETERMINISTIC
	BEGIN
		RETURN (
        SELECT CONCAT('The ',g.`name`,' is developed by a ',t.`name`,' in an office with an address ',a.`name`)
 FROM
    games AS g
        JOIN
    teams AS t ON g.team_id = t.id
        JOIN
    offices AS o ON t.office_id = o.id
        JOIN
    addresses AS a ON o.address_id = a.id
WHERE g.`name` = game_name);
    END%%
    
    -- 11---------------------------

    CREATE PROCEDURE udp_update_budget (rating FLOAT)
		BEGIN
        UPDATE games
		SET budget = budget + 100000, 
		release_date = DATE_ADD(release_date, INTERVAL 1 YEAR)  
		WHERE id NOT IN (SELECT game_id FROM games_categories)
			AND rating > rating AND release_date IS NOT NULL;
        END %%