CREATE DATABASE `fsd`;

USE `fsd`;

# ---------- Ex 1 Table Design ------------

CREATE TABLE `coaches` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR (10) NOT NULL,
`last_name` VARCHAR (20) NOT NULL,
`salary` DECIMAL (10,2) NOT NULL DEFAULT 0.00,
`coach_level` INT NOT NULL
);

CREATE TABLE `countries` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR (45) NOT NULL
);

CREATE TABLE `towns` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR (45) NOT NULL,
`country_id` INT NOT NULL ,
CONSTRAINT fk_towns_countrys
FOREIGN KEY (`country_id`)
REFERENCES `countries` (`id`)
);

CREATE TABLE `stadiums` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR (45) NOT NULL,
`capacity` INT NOT NULL,
`town_id` INT NOT NULL,
CONSTRAINT `fk_stadiums_towns`
FOREIGN KEY (`town_id`)
REFERENCES `towns` (`id`) 
);

CREATE TABLE `teams` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR (45) NOT NULL,
`established` DATE NOT NULL,
`fan_base` BIGINT NOT NULL DEFAULT 0,
`stadium_id` INT NOT NULL,
CONSTRAINT `fk_teams_stadiums`
FOREIGN KEY (`stadium_id`)
REFERENCES `stadiums`(`id`) 
);
 
 CREATE TABLE `skills_data`(
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `dribbling` INT DEFAULT 0,
 `pace` INT DEFAULT 0,
 `passing` INT DEFAULT 0,
 `shooting` INT DEFAULT 0,
 `speed` INT DEFAULT 0,
 `strength` INT DEFAULT 0
 );
 
 CREATE TABLE `players` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `first_name` VARCHAR(10) NOT NULL,
 `last_name` VARCHAR (20) NOT NULL,
 `age` INT NOT NULL DEFAULT 0,
 `position` CHAR(1) NOT NULL,
 `salary` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
 `hire_date` DATETIME,
 `skills_data_id` INT NOT NULL,
 `team_id` INT,
 CONSTRAINT fk_players_team
 FOREIGN KEY (`team_id`)
 REFERENCES `teams` (`id`),
 CONSTRAINT fk_players_skills_data
 FOREIGN KEY (`skills_data_id`)
 REFERENCES `skills_data` (`id`)
 );
 
 CREATE TABLE `players_coaches` (
 `player_id` INT,
 `coach_id` INT,
 CONSTRAINT pk_player_coache
 PRIMARY KEY (`player_id`, `coach_id`),
 CONSTRAINT fk_player_coache_player
 FOREIGN KEY (player_id)
 REFERENCES players (id),
 CONSTRAINT fk_player_coache_coache
 FOREIGN KEY (coach_id)
 REFERENCES coaches (id)
 );
 
 # ---------- Ex 2 Insert ------------

INSERT INTO `coaches` (`first_name`, `last_name`, `salary`, `coach_level`)
SELECT `first_name`, `last_name`, `salary` * 2, CHAR_LENGTH(`first_name`)  
FROM `players`
WHERE `age` >= 45;

 # ---------- Ex 3 Update ------------

UPDATE `coaches` 
SET `coach_level` = `coach_level` + 1
WHERE LEFT (`first_name`, 1 ) = 'A' 
AND id IN (SELECT `coach_id` FROM players_coaches);

 # ---------- Ex 4 Delete ------------

DELETE FROM `players`
WHERE `age` >= 45;

 # ---------- Ex 5 Players  ------------

SELECT `first_name`, `age`, `salary`
FROM `players`
ORDER BY `salary` DESC;

 # ---------- Ex 6 Young offense players without contract  ------------

SELECT 
    p.`id`,
    CONCAT(p.first_name, ' ', p.last_name) AS 'full_name',
    p.`age`,
    p.`position`,
    p.`hire_date`
FROM
    `players` AS p
        JOIN
    `skills_data` AS sk ON sk.`id` = p.`skills_data_id`
WHERE
    p.`age` < 23 AND p.`position` = 'A'
        AND p.`hire_date` IS NULL
        AND sk.`strength` > 50
ORDER BY p.`salary` , p.`age`;

 # ---------- Ex 7 Detail info for all teams ------------
 
SELECT DISTINCT
    t.`name` AS 'team_name',
    t.`established`,
    t.`fan_base`,
    (SELECT 
            COUNT(*)
        FROM
            `players` AS p2
        WHERE
            p.`team_id` = p2.`team_id`) AS 'players_count'
FROM
    `teams` AS t
        LEFT JOIN
    `players` AS p ON p.`team_id` = t.`id`
ORDER BY `players_count` DESC , t.`fan_base` DESC;
 
  # ---------- Ex 7 Detail info for all teams ------------
 
SELECT DISTINCT
    t.`name`,
    t.`established`,
    t.`fan_base`,
    COUNT(p.id) AS 'players_count'
FROM
    `teams` AS t
        LEFT JOIN
    `players` AS p ON p.`team_id` = t.`id`
ORDER BY `players_count` DESC , t.`fan_base` DESC;
 
  # ---------- Ex 8 The fastest player by towns ------------

SELECT 
    MAX(sd.`speed`) AS 'max_speed', t.`name`
FROM
    towns AS t
        LEFT JOIN
    stadiums AS s ON s.`town_id` = t.`id`
        LEFT JOIN
    `teams` ON teams.`stadium_id` = s.`id`
        LEFT JOIN
    `players` AS p ON p.`team_id` = teams.`id`
        LEFT JOIN
    `skills_data` AS sd ON p.`skills_data_id` = sd.`id`
WHERE
    teams.`name` != 'Devify'
GROUP BY t.`id`
ORDER BY `max_speed` DESC , t.`name`;

  # ---------- Ex 9 The fastest player by towns ------------

SELECT 
    c.`name`,
    COUNT(p.id) AS 'total_count_of_players',
    SUM(p.salary) AS 'total_sum_of_salaries'
FROM
    countries AS c
        LEFT JOIN
    towns AS t ON c.id = t.country_id
        LEFT JOIN
    stadiums AS s ON t.id = s.town_id
        LEFT JOIN
    teams AS te ON s.id = te.stadium_id
        LEFT JOIN
    players AS p ON te.id = p.team_id
GROUP BY c.id
ORDER BY total_count_of_players DESC , c.`name`;

# ---------- Ex 10 Find all players that play on stadium ------------

DELIMITER %%
CREATE FUNCTION udf_stadium_players_count (stadium_name VARCHAR(30)) 
RETURNS INT
DETERMINISTIC
BEGIN
RETURN (SELECT COUNT(p.id)
FROM players AS p
RIGHT JOIN teams AS t
ON t.id = p.team_id
RIGHT JOIN stadiums AS s
ON s.id = t.stadium_id
WHERE s.name = stadium_name
GROUP BY s.id);
END %%

DELIMITER ;

# ---------- Ex 11 Find good playmaker by teams ------------

DELIMITER %%

CREATE PROCEDURE `udp_find_playmaker` (min_dribble_points INT , team_name VARCHAR (45) )
BEGIN
SELECT CONCAT(p.first_name,' ', p.last_name) AS 'full_name',
p.age, p.salary, sk.dribbling, sk.speed, t.`name`
FROM players AS p
LEFT JOIN skills_data AS sk
ON p.skills_data_id = sk.id  
LEFT JOIN teams AS t
ON t.id = p.team_id
WHERE sk.dribbling > min_dribble_points AND t.`name` = team_name
AND sk.speed > (
SELECT AVG(speed) FROM skills_data
)
ORDER BY sk.speed DESC
LIMIT 1;
END %%
DELIMITER ;
