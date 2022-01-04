# ----------Ex 1----------

SELECT `title` FROM `books`
WHERE SUBSTRING(`title`, 1, 3) = 'The';

# ----------Ex 2----------

SELECT REPLACE (`title` ,'The', '***') AS `title`
 FROM `books`
 WHERE SUBSTRING(`title`, 1, 3) = 'The';
 
# ----------Ex 3----------

SELECT ROUND(SUM(`cost`), 2)
FROM `books`;

# ----------Ex 4----------

SELECT CONCAT(`first_name`, ' ', `last_name`) AS 'Full Name',
TIMESTAMPDIFF(DAY, `born`, `died`) AS 'Days Lived'
FROM `authors`; 
# ----------Ex 5----------

SELECT `title` 
FROM `books`
WHERE `title` LIKE 'Harry Potter%';