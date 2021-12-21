-- ---------------0----------------
CREATE DATABASE `minions`;

USE `minions`;
-- ---------------1----------------
CREATE TABLE `minions` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL,
    `age` INT
);

CREATE TABLE `towns` (
    `town_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(30) NOT NULL
);

-- ---------------2----------------
ALTER TABLE `minions`
ADD COLUMN `town_id` INT,
ADD CONSTRAINT fk_minions_towns
FOREIGN KEY (`town_id`)
REFERENCES `towns`(`id`);

-- ---------------3----------------
INSERT INTO `towns`
VALUES
(1, 'Sofia'),
(2, 'Plovdiv'),
(3, 'Varna');

INSERT INTO `minions`
VALUE
(1,'Kevin', 22, 1),
(2,'Bob', 15, 3),
(3,'Steward', NULL,2 );

-- ---------------4----------------
TRUNCATE `minions`;

-- ---------------5----------------
DROP TABLE `minions`; 
DROP TABLE `towns`;

SELECT * FROM `minions`;

-- ---------------6----------------
CREATE TABLE `people` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(200) NOT NULL,
    `picture` BLOB ,
    `height` FLOAT(5 , 2 ),
    `weight` FLOAT(5 , 2 ),
    `gender` CHAR(1) NOT NULL,
    `birthday` DATE NOT NULL,
    `biography` TEXT
);

INSERT INTO `minions`.`people` (`id`, `name`, `height`, `weight`, `gender`, `birthday`, `biography`) 
VALUES
('1', 'Nanko', '1.70', '55', 'f', '1989-12-01', 'hello'),
('2', 'Fifi', '1.60', '50', 'f', '1994-06-16', 'hello'),
('3', 'Cu', '1.85', '110', 'm', '1986-12-31', 'hello'),
('4', 'Teo', '1.1', '18', 'm','2017-06-12', 'hello'),
('5', 'Deo', '1.1', '18', 'm', '2017-06-12', 'hello');

SELECT * FROM `people`; 

-- ---------------7----------------
CREATE TABLE `users`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`users` VARCHAR(30) UNIQUE,
`password` VARCHAR(26),
`profile_picture` BLOB,
`last_login_time` DATETIME,
`is_deleted` BOOLEAN
);

INSERT INTO `users`
VALUES
(1, 'Nanko', 'password', NULL, '2020-06-10 09-05-10', true),
(2, 'Teo', 'password1', NULL, '2020-06-10 09-05-10', false),
(3, 'Toto', 'password2', NULL, '2020-06-10 09-05-10', true),
(4, 'Deo', 'password3', NULL, '2020-06-10 09-05-10', false),
(5, 'Dodo', 'password4', NULL, '2020-06-10 09-05-10', true);

-- ---------------8----------------
ALTER TABLE `users`
DROP PRIMARY KEY,
ADD CONSTRAINT pk_users
PRIMARY KEY (`id`, `username`);

-- ---------------9----------------
ALTER TABLE `users`  
MODIFY COLUMN `last_login_time`
TIMESTAMP
NOT NULL DEFAULT CURRENT_TIMESTAMP ;

-- --------------10----------------
ALTER TABLE `users`
DROP PRIMARY KEY,
ADD CONSTRAINT pk_users
PRIMARY KEY (`id`),
ADD CONSTRAINT UNIQUE (`username`); 


-- --------------11----------------
CREATE DATABASE `Movies`;
USE `Movies`;
CREATE TABLE `directors`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `director_name` VARCHAR(50) NOT NULL,
    `notes` TEXT
);

INSERT INTO `directors` (`director_name`)
VALUES 
('Ivan'),
('Gosho'),
('Peter'),
('Qna'),
('Asq');


CREATE TABLE `genres`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `genre_name` VARCHAR(50) NOT NULL,
    `notes` TEXT
);

INSERT INTO `genres`(`genre_name`)
VALUE
('Comedy'),
('Drama'),
('Action'),
('Romance'),
('History');
 

CREATE TABLE `categories` (
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `category_name` VARCHAR(50) NOT NULL,
    `notes` TEXT
);

INSERT INTO `categories` (`category_name`)
VALUE
('Horror'),
('Comedy'),
('Drama'),
('Documentary'),
('Criminal');


CREATE TABLE `movies`(
`id` INT PRIMARY KEY  AUTO_INCREMENT,
`title` VARCHAR(50) NOT NULL,
`director_id` INT,
`copyright_year` INT NOT NULL,
`length` INT NOT NULL,
`genre_id` INT,
`category_id` INT,
`rating` FLOAT,
`notes` TEXT
);

INSERT INTO `movies`
VALUE
(1, 'Movie1', 3, 2010, 116, 1, 2, 4.5, 'text'),
(2, 'Movie2', 3, 2010, 116, 1, 2, 4.5, 'text'),
(3, 'Movie3', 3, 2010, 116, 1, 2, 4.5, 'text'),
(4, 'Movie4', 3, 2010, 116, 1, 2, 4.5, 'text'),
(5, 'Movie5', 3, 2010, 116, 1, 2, 4.5, 'text');

-- --------------12----------------
CREATE DATABASE `car_rental`;

USE `car_rental`;

CREATE TABLE `categories` (
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `category` VARCHAR(50) NOT NULL,
    `daily_rate` FLOAT(5, 2) ,
    `weekly_rate` FLOAT(5, 2) ,
    `monthly_rate` FLOAT(5, 2) ,
    `weekend_rate` FLOAT(5, 2) 
);

INSERT INTO `categories`
VALUES
(1, 'SEDAN', 1.5, 2.5, 2.4, 2.8),
(2, 'COUPE', 2.5, 3.5, 1.5, 3.8),
(3, 'HATCHBACK', 3.5, 4.4, 2.6, 3.8);


CREATE TABLE `cars` (
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `plate_number`INT NOT NULL,
    `make` VARCHAR(50) NOT NULL,
    `model` VARCHAR (50) NOT NULL,
    `car_year` DATETIME NOT NULL,
    `category_id` INT,
    `doors` INT,
    `picture` BLOB,
    `car_condition` VARCHAR (50),
    `available` BOOLEAN
);

INSERT INTO `cars` 
VALUES
(1, 1234, '4355CGJD458745FKK', 'Mustang', '2020-12-12', 1, 5, null, 'excellent', true ),
(2, 12345, '4DSGF346458745FKK', 'Mustang', '2020-12-12', 1, 5, null, 'excellent', true ),
(3, 123456, '435CGJD4587FJUOAW', 'Mustang', '2020-12-12', 1, 5, null, 'excellent', true );

CREATE TABLE `employees` (
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `first_name` VARCHAR (20) NOT NULL,
    `last_name` VARCHAR (20) NOT NULL,
    `title` VARCHAR (50),
    `notes` TEXT
);

INSERT INTO `employees`
VALUES
(1, 'Name1', 'Last Name1', 'title', 'text'),
(2, 'Name2', 'Last Name2', 'title', 'text'),
(3, 'Name3', 'Last Name3', 'title', 'text');

CREATE TABLE `customers` (
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `driver_licence_number` INT NOT NULL,
    `full_name` VARCHAR (50) NOT NULL,
    `address` VARCHAR (50),
    `city` VARCHAR (50) ,
    `zip_code` INT,
    `notes` TEXT
);

INSERT INTO `customers`
VALUES
(1, 126543, 'Full Name1', 'Address','Sofia', 1000, 'notes'),
(2, 498574, 'Full Name2', 'Address','Sofia', 1000, 'notes'),
(3, 123343, 'Full Name3', 'Address','Sofia', 1000, 'notes');

CREATE TABLE `rental_orders` (
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `employee_id` INT NOT NULL,
    `customer_id` INT NOT NULL,
    `car_id` INT NOT NULL,
    `car_condition` VARCHAR (50),
    `tank_level` FLOAT (5, 2) ,
    `kilometrage_start` INT ,
    `kilometrage_end` INT ,
    `total_kilometrage`INT,
    `start_date` DATE ,
    `end_date`DATE ,
    `total_days` INT ,
    `rate_applied` VARCHAR(20),
    `tax_rate` INT,
    `order_status` VARCHAR(50),
    `notes` TEXT
);

INSERT INTO `rental_orders`
VALUES
(1, 1, 1, 1, 'Good', 45.0, 1070, 1090,20, '2021-12-12', '2021-12-14', 2, 'rate', 5, 'finish', 'text'),
(2, 2, 2, 2, 'Excellent', 45.0, 1070, 1090,20, '2021-12-12', '2021-12-14', 2, 'rate', 5, 'finish', 'text'),
(3, 3, 3, 3, 'Very good', 45.0, 1070, 1090,20, '2021-12-12', '2021-12-14', 2, 'rate', 5, 'finish', 'text');

-- --------------13----------------
CREATE DATABASE `soft_uni`;

USE `soft_uni`;

CREATE TABLE `towns` (
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(30) NOT NULL
); 

CREATE TABLE `addresses` (
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `address_text` VARCHAR (100) NOT NULL,
    `town_id` INT NOT NULL, 
    CONSTRAINT fk_addresses_towns
    FOREIGN KEY (`town_id`) REFERENCES `towns`(`id`)
);

CREATE TABLE `departments` (
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(30) NOT NULL
);

CREATE TABLE `employees` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(30) NOT NULL,
`middle_name` VARCHAR(30) NOT NULL,
`last_name` VARCHAR(30) NOT NULL,
`job_title` VARCHAR (30),
`department_id` INT NOT NULL,
CONSTRAINT fk_employees_department
FOREIGN KEY (`department_id`) REFERENCES `departments`(`id`),
`hire_date` DATE,
`salary` DECIMAL (10,2),
`address_id` INT NOT NULL,
CONSTRAINT fk_employees_address
FOREIGN KEY (`address_id`) REFERENCES `addresses` (`id`)
);

INSERT INTO `towns` (`name`) 
VALUES
('Sofia'),
('Plovdiv'),
('Varna'),
('Burgas');

INSERT INTO `departments` (`name`)
VALUES
('Engineering'),
('Sales'),
('Marketing'),
('Software Development'),
('Quality Assurance');

INSERT  INTO `employees` (`first_name`,`middle_name`,`last_name`, `job_title`, `department_id`, `hire_date`, `salary`)
VALUES
('Ivan', 'Ivanov', 'Ivanov', '.NET Developer', 4, '2013-02-01', 3500.00),
('Petar', 'Petrov', 'Petrov', 'Senior Engineer', 1, '2004-03-02', 4000.00),
('Maria', 'Petrova', 'Ivanova', 'Intern', 5, '2016-08-28', 525.25),
('Georgi', 'Terziev', 'Ivanov', 'CEO', 2, '2007-12-09', 3000.00),
('Peter', 'Pan', 'Pan', 'Intern', 3, '2016-08-28', 599.88);

-- --------------14----------------
SELECT * FROM `towns`;
SELECT * FROM `departments`;
SELECT * FROM `employees`;

-- --------------15----------------
SELECT * FROM `towns`
ORDER BY `name`;

SELECT * FROM `departments`
ORDER BY `name`;

SELECT * FROM `employees`
ORDER BY `salary` DESC;

-- --------------16----------------
SELECT `name` FROM `towns`
ORDER BY `name`;

SELECT `name` FROM `departments`
ORDER BY `name`;

SELECT `first_name`, `last_name`, `job_title`, `salary` FROM `employees`
ORDER BY `salary` DESC;

-- --------------17----------------
UPDATE `employees`
SET `salary` = `salary` * 1.1;

SELECT * FROM `employees`
ORDER BY `salary` DESC;

-- --------------18----------------

DELETE FROM occupancies;
