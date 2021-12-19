CREATE DATABASE `minions`;

USE `minions`;

CREATE TABLE `minions`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL,
    `age`INT 
);

CREATE TABLE `towns` (
    `town_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(30) NOT NULL
);

ALTER TABLE `minions`
ADD COLUMN `town_id` INT,
ADD CONSTRAINT fk_minions_towns
FOREIGN KEY (`town_id`)
REFERENCES `towns`(`id`);

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

TRUNCATE `minions`;

DROP TABLE `minions`; 
DROP TABLE `towns`;

SELECT * FROM `minions`;


