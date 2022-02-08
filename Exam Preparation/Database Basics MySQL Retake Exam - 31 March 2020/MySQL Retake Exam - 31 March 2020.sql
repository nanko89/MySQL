CREATE DATABASE instd ;
USE instd ;

------------------- 1 ---------------

CREATE TABLE users (
id INT PRIMARY KEY,
username VARCHAR(30) UNIQUE NOT NULL,
`password` VARCHAR (30) NOT NULL,
email VARCHAR (50) NOT NULL,
gender CHAR(1) NOT NULL,
age INT NOT NULL,
job_title VARCHAR (40) NOT NULL,
ip VARCHAR (30) NOT NULL
);

CREATE TABLE addresses (
id INT PRIMARY KEY AUTO_INCREMENT,
address VARCHAR (30) NOT NULL,
town VARCHAR (30) NOT NULL,
country VARCHAR (30) NOT NULL,
user_id	INT NOT NULL,
CONSTRAINT fk_addresses_user
FOREIGN KEY (user_id)
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
`comment` VARCHAR (255) NOT NULL,
`date` DATETIME NOT NULL,
photo_id	INT NOT NULL,
CONSTRAINT fk_comments_photos
FOREIGN KEY (photo_id)
REFERENCES photos(id)
);

CREATE TABLE users_photos (
user_id	INT NOT NULL,
photo_id INT NOT NULL,
CONSTRAINT fk_users_photos_user
FOREIGN KEY (user_id)
REFERENCES users (id),
CONSTRAINT fk_users_photos_photo
FOREIGN KEY (photo_id)
REFERENCES photos(id)
);

CREATE TABLE likes (
id INT PRIMARY KEY AUTO_INCREMENT,
photo_id INT,
user_id INT,
CONSTRAINT fk_likes_photo
FOREIGN KEY (photo_id)
REFERENCES photos(id),
CONSTRAINT fk_likes_user
FOREIGN KEY (user_id)
REFERENCES users(id)
);

------------------- 2 ---------------

INSERT INTO addresses (address,town,country,user_id)
SELECT username,`password`, ip,age 
FROM users
WHERE gender = 'M';

------------------- 3 ---------------

UPDATE addresses
SET country = 
		(CASE 
        WHEN country LIKE ('B%') THEN 'Blocked'
        WHEN country LIKE ('T%') THEN 'Test'
        WHEN country LIKE ('P%') THEN 'In Progress'
        ELSE country
        END
		);
        
------------------- 4 ---------------

DELETE FROM addresses
WHERE id % 3 = 0;

------------------- 5 ---------------

SELECT username, gender, age FROM users
ORDER BY age DESC, username;

------------------- 6 ---------------

SELECT p.id, p.`date`, p.`description`, COUNT(c.photo_id) AS comments_count
FROM photos AS p
JOIN comments AS c
ON p.id = c.photo_id
GROUP BY c.photo_id
ORDER BY comments_count DESC, c.photo_id
LIMIT 5;

------------------- 7 ---------------

SELECT  CONCAT(u.id, ' ' , u.username) AS id_username, u.email 
FROM  users_photos up
JOIN users AS u
ON u.id = up.user_id
WHERE up.user_id = up.photo_id
ORDER BY u.id;

------------------- 8 ---------------

SELECT p.id, (
	SELECT COUNT(l.photo_id)
    FROM likes AS l 
    JOIN photos AS p2
	ON p2.id = l.photo_id
    WHERE p.id = p2.id
) AS count_likes, (SELECT COUNT(c.photo_id)
    FROM comments AS c 
    JOIN photos AS p2
	ON p2.id = c.photo_id
    WHERE p.id = p2.id) AS count_comments
FROM photos AS p
GROUP BY p.id
ORDER BY count_likes DESC, count_comments DESC, p.id;

------------------- 9 ---------------

SELECT CONCAT(SUBSTRING(`description`,1,30), '...') AS `descroption`, `date` FROM photos
WHERE DAY(`date`) = 10
ORDER BY `date` DESC;

------------------ 10 ---------------
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

------------------ 11 ---------------

CREATE PROCEDURE udp_modify_user (address VARCHAR(30), town VARCHAR(30)) 
BEGIN
		UPDATE users AS u
		JOIN addresses AS a 
		ON u.id = a.user_id
        SET u.age = u.age + 10
		WHERE a.address = address AND a.town = town;
END
