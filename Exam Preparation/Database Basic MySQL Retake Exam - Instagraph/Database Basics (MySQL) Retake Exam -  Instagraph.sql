CREATE DATABASE instagraph_db;
USE instagraph_db;

---------------- 1 -----------------

CREATE TABLE pictures (
id INT PRIMARY KEY AUTO_INCREMENT,
`path` VARCHAR (255) NOT NULL,
size DECIMAL (10,2) NOT NULL 
);

CREATE TABLE users(
id INT PRIMARY KEY AUTO_INCREMENT,
username VARCHAR (30) NOT NULL UNIQUE,
`password` VARCHAR (30) NOT NULL,
profile_picture_id INT, 
CONSTRAINT fk_user_picture
FOREIGN KEY (profile_picture_id)
REFERENCES pictures (id)
);

CREATE TABLE posts (
id INT PRIMARY KEY AUTO_INCREMENT,
caption VARCHAR (255) NOT NULL,
user_id INT NOT NULL,
picture_id INT NOT NULL,
CONSTRAINT fk_post_user
FOREIGN KEY (user_id)
REFERENCES users (id),
CONSTRAINT fk_post_picture
FOREIGN KEY (picture_id)
REFERENCES pictures (id) 
);

CREATE TABLE comments (
id INT PRIMARY KEY AUTO_INCREMENT,
content VARCHAR (255) NOT NULL,
user_id INT NOT NULL,
post_id INT NOT NULL,
CONSTRAINT fk_comment_user
FOREIGN KEY (user_id)
REFERENCES users (id),
CONSTRAINT fk_comment_post
FOREIGN KEY (post_id)
REFERENCES posts(id)
);

CREATE TABLE users_followers (
user_id	INT,
follower_id	INT,
KEY key_user_follower (user_id, follower_id),
CONSTRAINT fk_users_followers_users
FOREIGN KEY (user_id)
REFERENCES users (id),
CONSTRAINT fk_users_followers_follower
FOREIGN KEY (follower_id)
REFERENCES users(id)
);

---------------- 2 -----------------

INSERT INTO comments (content, user_id, post_id)
SELECT CONCAT('Omg!',u.`username`,'!This is so cool!'), 
		CEIL(p.id * 3 / 2), p.id 
	FROM posts AS p
			JOIN 
	users AS u ON u.id  = p.user_id
WHERE p.id BETWEEN 1 AND 10;


---------------- 3 -----------------

UPDATE users
        JOIN
    (SELECT 
        COUNT(uf.follower_id) AS follower
    FROM
        users AS u
    JOIN users_followers AS uf ON u.id = uf.user_id
    GROUP BY u.id) AS result 
SET 
    profile_picture_id = (IF(result.follower != 0,
        result.follower,
        id))
WHERE
    profile_picture_id IS NULL;

---------------- 4 -----------------

DELETE FROM users 
WHERE
    id NOT IN (SELECT 
        user_id
    FROM
        users_followers)
    AND id NOT IN (SELECT 
        follower_id
    FROM
        users_followers);
 
---------------- 5 -----------------

SELECT 
    id, username
FROM
    users
ORDER BY id;

---------------- 6 -----------------

SELECT 
    u.id, u.username
FROM
    users AS u
        JOIN
    users_followers AS uf ON u.id = uf.user_id
WHERE
    uf.user_id = uf.follower_id
ORDER BY u.id;

---------------- 7 -----------------

SELECT 
    *
FROM
    pictures
WHERE
    size > 50000
        AND (`path` LIKE ('%jpeg%')
        OR `path` LIKE ('%png%'))
ORDER BY size DESC;

---------------- 8 -----------------

SELECT 
    c.id, CONCAT(u.username, ' : ', c.content) AS full_name
FROM
    users AS u
        JOIN
    comments AS c ON c.user_id = u.id
ORDER BY c.id DESC;

---------------- 9 -----------------

SELECT 
    u.id, u.username, CONCAT(p.size, 'KB') AS size
FROM
    users AS u
        JOIN
    pictures AS p ON p.id = u.profile_picture_id
WHERE
    (SELECT 
            COUNT(u2.profile_picture_id)
        FROM
            users AS u2
        WHERE
            u.profile_picture_id = u2.profile_picture_id) > 1
ORDER BY u.id;
	
---------------- 10 -----------------

SELECT p.id, p.caption, COUNT(c.id) AS count_comments
	FROM posts AS p
				JOIN
		comments AS c ON p.id = c.post_id
GROUP BY p.id
ORDER BY count_comments DESC, p.id
LIMIT 5;

---------------- 11 -----------------


SELECT 
    u.id,
    u.username,
    (SELECT 
            COUNT(p2.user_id)
        FROM
            posts AS p2
        WHERE
            p2.user_id = p.user_id) AS posts,
    (SELECT 
            COUNT(uf2.follower_id)
        FROM
            users_followers AS uf2
        WHERE
            uf2.user_id = uf.user_id) AS followers
FROM
    users AS u
        JOIN
    posts AS p ON p.user_id = u.id
        JOIN
    comments AS c ON c.user_id = u.id
        JOIN
    users_followers AS uf ON uf.user_id = u.id
GROUP BY u.id
ORDER BY followers DESC
LIMIT 1;

---------------- 12 -----------------

SELECT 
    u.id, u.username, COUNT(c.id) AS my_comments
FROM
    users AS u
        LEFT JOIN
    posts AS p ON p.user_id = u.id
        LEFT JOIN
    comments AS c ON c.user_id = u.id AND p.id = c.post_id
GROUP BY u.id
ORDER BY my_comments DESC , u.id;

---------------- 12 -----------------



