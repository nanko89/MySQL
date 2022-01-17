CREATE DATABASE colonial_journey_management_system_db; 
USE colonial_journey_management_system_db;

# ---------- Ex 0 Table Design ------------
CREATE TABLE planets (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(30) NOT NULL
);

CREATE TABLE spaceports (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR (50) NOT NULL,
planet_id INT,
CONSTRAINT fk_spaceports_planets
FOREIGN KEY (`planet_id`)
REFERENCES planets(id)
);

CREATE TABLE spaceships (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR (50) NOT NULL,
manufacturer VARCHAR (30) NOT NULL,
light_speed_rate INT DEFAULT 0
);

CREATE TABLE journeys (
id INT PRIMARY KEY AUTO_INCREMENT,
journey_start DATETIME,
journey_end DATETIME,
purpose ENUM ('Medical', 'Technical', 'Educational', 'Military') NOT NULL,
destination_spaceport_id INT,
spaceship_id INT,
CONSTRAINT fk_journeys_spaceport
FOREIGN KEY (destination_spaceport_id)
REFERENCES spaceports (id),
CONSTRAINT fk_journeys_spaceships
FOREIGN KEY (spaceship_id)
REFERENCES spaceships (id)
);

CREATE TABLE colonists (
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR (20) NOT NULL,
last_name VARCHAR (20) NOT NULL,
ucn CHAR(10) UNIQUE NOT NULL,
birth_date DATE NOT NULL 
);

CREATE TABLE travel_cards (
id INT PRIMARY KEY AUTO_INCREMENT,
card_number CHAR(10) UNIQUE NOT NULL,
job_during_journey ENUM ('Pilot', 'Engineer', 'Trooper', 'Cleaner', 'Cook') NOT NULL,
colonist_id INT,
journey_id INT,
CONSTRAINT fk_travel_cards_colonists
FOREIGN KEY (colonist_id)
REFERENCES colonists (id),
CONSTRAINT fk_travel_cards_journeys
FOREIGN KEY (journey_id)
REFERENCES journeys(id)
);

# ---------- Ex 1 Data Insertion ------------

INSERT INTO travel_cards (card_number, job_during_journey, colonist_id, journey_id)
SELECT
 (
	IF (c.birth_date > '1980-01-01', 
	CONCAT(YEAR(c.birth_date), DAY(c.birth_date), LEFT(c.ucn, 4)), 
	CONCAT(YEAR(c.birth_date), MONTH(c.birth_date), RIGHT(c.ucn,4)))) AS card_numer,
(
	CASE 
    WHEN c.id % 2 = 0 THEN 'Pilot'
    WHEN c.id % 3 = 0 THEN 'Cook'
    ELSE 'Engineer'
    END 
) AS job_during_journey,
c.id,
(LEFT(c.ucn,1)) AS journey_id
FROM colonists AS c
WHERE c.id BETWEEN 96 AND 100;

# ---------- Ex 2 Data Update ------------

UPDATE journeys
SET purpose = 
	CASE 
	WHEN id % 2 = 0 THEN 'Medical'
    WHEN id % 3 = 0 THEN 'Technical'
    WHEN id % 5 = 0 THEN 'Educational'
    WHEN id % 7 = 0 THEN 'Military'
    ELSE purpose
	END;

# ---------- Ex 3 Data Deletion ------------

DELETE FROM colonists AS c
WHERE c.id NOT IN (
	SELECT colonist_id FROM travel_cards);
    
# ---------- Ex 4 Extract all travel cards ------------

SELECT card_number, job_during_journey
FROM travel_cards
ORDER BY card_number;

# ---------- Ex 5 Extract all colonists ------------

SELECT id, CONCAT(first_name, ' ', last_name ) AS full_name, ucn
FROM colonists
ORDER BY first_name, last_name, id;

# ---------- Ex 6 Extract all military journeys ------------

SELECT id, journey_start, journey_end
FROM  journeys
WHERE purpose = 'Military'
ORDER BY journey_start;

# ---------- Ex 7 Extract all pilots ------------

SELECT c.id, CONCAT(c.first_name, ' ' , c.last_name) AS full_name
FROM colonists AS c
JOIN travel_cards As tc
ON c.id = tc.colonist_id
WHERE tc.job_during_journey = 'Pilot'
ORDER BY c.id;

# ---------- Ex 8 Count all colonists that are on technical journey ------------

SELECT COUNT(c.id) AS count
FROM colonists AS c
JOIN travel_cards AS tc
ON tc.colonist_id = c.id
JOIN journeys AS j
ON j.id = tc.journey_id
WHERE j.purpose = 'Technical';

# ---------- Ex 9 Extract the fastest spaceshipy ------------

SELECT ss.`name` AS spaceship_name, sp.`name` AS spaceport_name
FROM spaceports AS sp
RIGHT JOIN journeys AS j
ON j.destination_spaceport_id = sp.id
RIGHT JOIN spaceships AS ss
ON  j.spaceship_id = ss.id
ORDER BY ss.light_speed_rate DESC
LIMIT 1;

# ---------- Ex 10 Extract spaceships with pilots younger than 30 years ------------

SELECT ss.`name` , ss.manufacturer
FROM colonists AS c
JOIN travel_cards as tc
ON c.id = tc.colonist_id
JOIN journeys AS j
ON j.id = tc.journey_id
JOIN spaceships AS ss
ON ss.id = j.spaceship_id
WHERE c.birth_date >  DATE_SUB('2019-01-01', INTERVAL 30 YEAR) AND tc.job_during_journey = 'Pilot'
ORDER BY ss.`name`;

# ---------- Ex 11 Extract all educational mission ------------

SELECT p.`name`, sp.`name`
 FROM planets AS p
 JOIN spaceports AS sp
 ON sp.planet_id = p. id
 JOIN journeys AS j
 ON j.destination_spaceport_id = sp.id
 WHERE j.purpose = 'Educational'
 ORDER BY sp.`name` DESC;

# ---------- Ex 12 Extract all planets and their journey count ------------

SELECT p.`name`, COUNT(j.id) AS counts
FROM planets AS p
JOIN spaceports AS sp
ON p.id = sp.planet_id
JOIN journeys AS j
ON j.destination_spaceport_id = sp.id
GROUP BY p.`name` 
ORDER BY counts DESC, p.`name`;

# ---------- Ex 13 Extract the shortest journey ------------

SELECT j.id, p.`name`, sp.`name`, j.purpose
FROM journeys AS j
JOIN spaceports AS sp
ON j.destination_spaceport_id = sp.id
JOIN planets AS p
ON p.id = sp.planet_id
ORDER BY DATEDIFF(j.journey_end, j.journey_start)
LIMIT 1;

# ---------- Ex 14 Extract the less popular job ------------

SELECT tc.job_during_journey 
FROM travel_cards AS tc
WHERE tc.journey_id = (
		SELECT j.id
		FROM journeys AS j
        ORDER BY datediff(j.journey_end, journey_start) DESC
        LIMIT 1
)
GROUP BY tc.job_during_journey
ORDER BY COUNT(tc.job_during_journey)
LIMIT 1;

# ---------- Ex 15 Get colonists count ------------
DELIMITER &&

CREATE FUNCTION `udf_count_colonists_by_destination_planet` (planet_name VARCHAR (30))
RETURNS INTEGER
DETERMINISTIC
BEGIN
RETURN (SELECT COUNT(c.id)
FROM colonists AS c
JOIN travel_cards AS tc
ON c.id = tc.colonist_id
JOIN journeys AS j
ON j.id = tc.journey_id
JOIN spaceports AS sp
ON j.destination_spaceport_id = sp.id
JOIN planets AS p
ON p.id = sp.planet_id
WHERE p.`name` = planet_name);
END &&

DELIMITER ;

# ---------- Ex 16 Modify spaceship ------------
DELIMITER &&

CREATE PROCEDURE udp_modify_spaceship_light_speed_rate(spaceship_name VARCHAR(50), light_speed_rate_increse INT(11))
BEGIN 
	START TRANSACTION;
	IF ((SELECT COUNT(*) FROM spaceships AS ss WHERE spaceship_name = ss.name) = 0) THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Spaceship you are trying to modify does not exists.';
		ROLLBACK;
	ELSE 
		UPDATE spaceships
        SET light_speed_rate = light_speed_rate + light_speed_rate_increse
        WHERE `name` =  spaceship_name;
	END IF;
END &&

DELIMITER ;



