CREATE DATABASE instd ;
USE instd;

-- 1-------------------------

CREATE TABLE users (
    id INT PRIMARY KEY,
    username VARCHAR(30) NOT NULL UNIQUE,
    `password` VARCHAR(30) NOT NULL,
    email VARCHAR(50) NOT NULL,
    gender CHAR NOT NULL,
    age INT NOT NULL,
    job_title VARCHAR(40) NOT NULL,
    ip VARCHAR(30) NOT NULL
);

CREATE TABLE addresses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    address VARCHAR(30) NOT NULL,
    town VARCHAR(30) NOT NULL,
    country VARCHAR(30) NOT NULL,
    user_id INT NOT NULL,
    CONSTRAINT fk_address_user FOREIGN KEY (user_id)
        REFERENCES users (id)
);

CREATE TABLE photos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    `description` TEXT NOT NULL,
    `date` DATETIME NOT NULL,
    views INT DEFAULT 0 NOT NULL
);

CREATE TABLE comments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    `comment` VARCHAR(255) NOT NULL,
    `date` DATETIME NOT NULL,
    photo_id INT NOT NULL,
    CONSTRAINT fk_comments_photo FOREIGN KEY (photo_id)
        REFERENCES photos (id)
);
 
CREATE TABLE users_photos (
    user_id INT NOT NULL,
    photo_id INT NOT NULL,
    CONSTRAINT fk_users_photos_user FOREIGN KEY (user_id)
        REFERENCES users (id),
    CONSTRAINT fk_users_photos_photo FOREIGN KEY (photo_id)
        REFERENCES photos (id)
);
 
CREATE TABLE likes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    photo_id INT,
    user_id INT,
    CONSTRAINT fk_like_photo FOREIGN KEY (photo_id)
        REFERENCES photos (id),
    CONSTRAINT fk_like_user FOREIGN KEY (user_id)
        REFERENCES users (id)
);

-- 2-------------------------

INSERT INTO addresses (address ,town, country , user_id )
SELECT username, `password`, ip, age FROM users 
WHERE gender = 'M';

-- 3-------------------------

UPDATE addresses 
SET 
    country = (CASE
        WHEN country LIKE 'B%' THEN 'Blocked'
        WHEN country LIKE 'T%' THEN 'Test'
        WHEN country LIKE 'P%' THEN 'In Progress'
        ELSE country
    END);

-- 4-------------------------

DELETE FROM addresses 
WHERE
    id % 3 = 0;

-- 5-------------------------

SELECT username,gender, age
	FROM 	
		users
ORDER BY age DESC, username;

-- 6-------------------------

SELECT 
    p.id,
    p.`date`,
    p.`description`,
    COUNT(c.id) AS comment_count
FROM
    photos AS p
        JOIN
    comments AS c ON p.id = c.photo_id
GROUP BY p.id
ORDER BY comment_count DESC , p.id;

-- 7-------------------------
SELECT 
    CONCAT(u.id, '', u.username) AS id_username, u.email
FROM
    users AS u
        JOIN
    users_photos AS up ON up.user_id = u.id
WHERE
    up.user_id = up.photo_id
ORDER BY u.id;

-- 8-------------------------

SELECT 
    p.id,
    COUNT(DISTINCT l.id) AS likes_count,
    COUNT(DISTINCT c.id) AS comments_count
FROM
    photos AS p
        LEFT JOIN
    likes AS l ON p.id = l.photo_id
        LEFT JOIN
    comments AS c ON p.id = c.photo_id
GROUP BY p.id
ORDER BY likes_count DESC , comments_count DESC , p.id; 

-- 9-------------------------

SELECT CONCAT(SUBSTRING(`description`,1,30), '...') AS `descroption`, `date` FROM photos
WHERE DAY(`date`) = 10
ORDER BY `date` DESC;

-- 10-------------------------

DELiMITER %%
CREATE FUNCTION udf_users_photos_count(username VARCHAR(30))
	RETURNS INTEGER
DETERMINISTIC
BEGIN

RETURN (
		SELECT COUNT(photo_id) FROM users_photos AS up
		WHERE user_id = (
			SELECT id FROM users AS u
			WHERE u.username = username
));
END%%

-- 11-------------------------

CREATE PROCEDURE udp_modify_user (address VARCHAR(30), town VARCHAR(30)) 
BEGIN
		UPDATE users AS u
		JOIN addresses AS a 
		ON u.id = a.user_id
        SET u.age = u.age + 10
		WHERE a.address = address AND a.town = town;
END
