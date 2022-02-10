CREATE DATABASE fsd;
USE fsd;

-- 1----------------------------------------


CREATE TABLE countries (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45) NOT NULL
);

CREATE TABLE towns (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45) NOT NULL,
country_id INT NOT NULL,
CONSTRAINT fk_towns_country
FOREIGN KEY (country_id)
REFERENCES countries (id)
);

CREATE TABLE stadiums (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45) NOT NULL,
capacity INT NOT NULL,
town_id	INT NOT NULL,
CONSTRAINT fk_stadiums_towns
FOREIGN KEY (town_id)
REFERENCES towns (id)
);

CREATE TABLE teams (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45) NOT NULL,
established DATE NOT NULL,
fan_base BIGINT DEFAULT 0 NOT NULL,
stadium_id INT NOT NULL,
CONSTRAINT fk_teams_stadium
FOREIGN KEY (stadium_id)
REFERENCES stadiums (id)
);

CREATE TABLE skills_data(
id INT PRIMARY KEY AUTO_INCREMENT,
dribbling INT DEFAULT 0,
pace INT DEFAULT 0,
passing INT DEFAULT 0,
shooting INT DEFAULT 0,
speed INT DEFAULT 0,
strength INT DEFAULT 0
);

CREATE TABLE coaches (
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(10) NOT NULL,
last_name VARCHAR(20) NOT NULL,
salary DECIMAL (10,2) NOT NULL DEFAULT 0,
coach_level INT DEFAULT 0 NOT NULL
);

CREATE TABLE players (
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(10) NOT NULL,
last_name VARCHAR(20) NOT NULL,
age INT NOT NULL,
position CHAR NOT NULL,
salary DECIMAL (10,2) NOT NULL DEFAULT 0,
hire_date DATETIME ,
skills_data_id INT NOT NULL,
team_id INT,
 CONSTRAINT fk_player_skills
 FOREIGN KEY (skills_data_id)
 REFERENCES skills_data(id),
 CONSTRAINT fk_player_team
 FOREIGN KEY (team_id)
 REFERENCES teams(id)
);

CREATE TABLE players_coaches (
player_id INT,
coach_id INT,
CONSTRAINT pk_players_coaches
PRIMARY KEY (player_id, coach_id),
CONSTRAINT fk_players_coaches_palyers
FOREIGN KEY (player_id)
REFERENCES players(id),
CONSTRAINT fk_players_coaches_coache
FOREIGN KEY (coach_id)
REFERENCES coaches(id)
);

-- 2----------------------------------------

INSERT 
	INTO coaches (first_name, last_name, salary, coach_level)
SELECT first_name, last_name, salary * 2, CHAR_LENGTH(first_name) 
	FROM players
WHERE age >= 45;

-- 3----------------------------------------


UPDATE coaches 
SET 
    coach_level = coach_level + 1
WHERE
    id IN (SELECT 
            coach_id
        FROM
            players_coaches)
        AND LEFT(`first_name`, 1) = 'A';


-- 4----------------------------------------

DELETE FROM players 
WHERE
    age >= 45;

-- 5----------------------------------------

SELECT 
    first_name, age, salary
FROM
    players
ORDER BY salary DESC;
    
-- 6----------------------------------------

SELECT 
    p.id,
    CONCAT_WS(' ', p.first_name, p.last_name) AS full_name,
    p.age,
    p.position,
    p.hire_date
FROM
    players AS p
        JOIN
    skills_data AS sd ON p.skills_data_id = sd.id
WHERE
    age < 23 AND position = 'A'
        AND hire_date IS NULL
        AND sd.strength > 50
ORDER BY p.salary , p.age;

-- 7----------------------------------------

SELECT 
    t.`name` AS team_name,
    t.established,
    t.fan_base,
    COUNT(p.id) AS player_count
FROM
    teams AS t
        LEFT JOIN
    players AS p ON p.team_id = t.id
GROUP BY 
		t.id
ORDER BY
		player_count DESC ,
		t.fan_base DESC;
        
        
-- 8----------------------------------------

	SELECT 
    MAX(sd.speed) AS max_speed, t.`name` AS town_name
FROM
    skills_data AS sd
        RIGHT JOIN
    players AS p ON p.skills_data_id = sd.id
        RIGHT JOIN
    teams AS te ON te.id = p.team_id
        RIGHT JOIN
    stadiums AS s ON s.id = te.stadium_id
        RIGHT JOIN
    towns AS t ON t.id = s.town_id
WHERE
    te.name != 'Devify'
GROUP BY t.name
ORDER BY max_speed DESC , t.name;

-- 9----------------------------------------

SELECT c.`name`, COUNT(p.id) AS total_count_of_players, SUM(p.salary) AS total_sum_of_salaries
FROM players AS p 
        RIGHT JOIN
    teams AS te ON te.id = p.team_id
        RIGHT JOIN
    stadiums AS s ON s.id = te.stadium_id
        RIGHT JOIN
    towns AS t ON t.id = s.town_id
		RIGHT JOIN
	countries AS c ON c.id = t.country_id
GROUP BY c.`name`
ORDER BY total_count_of_players DESC, c.`name`;


-- 10---------------------------------------


DELIMITER %%
CREATE FUNCTION udf_stadium_players_count (stadium_name VARCHAR(30)) 
RETURNS INTEGER
	DETERMINISTIC
BEGIN 
	RETURN (SELECT COUNT(p.id) 
	FROM players AS p 
        RIGHT JOIN
    teams AS te ON te.id = p.team_id
        RIGHT JOIN
    stadiums AS s ON s.id = te.stadium_id
WHERE s.`name` = stadium_name);
END %%


-- 11---------------------------------------

CREATE PROCEDURE udp_find_playmaker (min_dribble_points INT , t_name VARCHAR (45))
	BEGIN
		SELECT CONCAT(p.first_name, ' ' , p.last_name) AS full_name, p.age, p.salary, sd.dribbling, sd.speed, t.`name` AS team_name 
		FROM
			skills_data AS sd
				RIGHT JOIN
			players AS p ON p.skills_data_id = sd.id
				RIGHT JOIN
			teams AS t ON t.id = p.team_id
		WHERE t.`name` = t_name AND sd.dribbling > min_dribble_points
		ORDER BY sd.speed DESC
		LIMIT 1;
    END %%