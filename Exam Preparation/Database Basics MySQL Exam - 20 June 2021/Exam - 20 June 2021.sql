CREATE DATABASE stc;
USE stc;

-- 1----------------------------

CREATE TABLE addresses (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR (100) NOT NULL
);

CREATE TABLE categories (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR (10) NOT NULL
);

CREATE TABLE clients (
id INT PRIMARY KEY AUTO_INCREMENT,
full_name VARCHAR (50) NOT NULL,
phone_number VARCHAR (20) NOT NULL
);

CREATE TABLE drivers (
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR (30) NOT NULL,
last_name VARCHAR (30) NOT NULL,
age INT NOT NULL,
rating FLOAT DEFAULT 5.5
);

CREATE TABLE cars(
id INT PRIMARY KEY AUTO_INCREMENT,
make VARCHAR (20) NOT NULL,
model VARCHAR (20),
`year` INT NOT NULL DEFAULT 0,
mileage INT DEFAULT 0,
`condition` CHAR NOT NULL,
category_id INT NOT NULL,
CONSTRAINT fk_cars_category
FOREIGN KEY (category_id)
REFERENCES categories (id)
);

CREATE TABLE courses (
id INT PRIMARY KEY AUTO_INCREMENT,
from_address_id	INT NOT NULL,
`start` DATETIME NOT NULL,
bill DECIMAL (10,2) DEFAULT 10,
car_id INT NOT NULL,
client_id INT NOT NULL,
CONSTRAINT fk_courses_address
FOREIGN KEY (from_address_id)
REFERENCES addresses (id),
CONSTRAINT fk_courses_car
FOREIGN KEY (car_id)
REFERENCES cars (id), 
CONSTRAINT fk_courses_client
FOREIGN KEY (client_id)
REFERENCES clients (id)
);

CREATE TABLE cars_drivers (
car_id INT NOT NULL,
driver_id INT NOT NULL,
CONSTRAINT pk_cars_drivers
PRIMARY KEY (car_id,driver_id),
CONSTRAINT fk_cars_drivers_car
FOREIGN KEY (car_id)
REFERENCES cars (id),
CONSTRAINT fk_cars_drivers_driver
FOREIGN KEY (driver_id)
REFERENCES drivers (id)
);


-- 2----------------------------

INSERT INTO clients(full_name, phone_number)
	SELECT 
		CONCAT(first_name, last_name), 
		CONCAT('(088) 9999', id * 2 ) 
	FROM 
		drivers 
	WHERE 
		id BETWEEN 10 AND 20;

-- 3----------------------------

UPDATE cars 
SET 
    `condition` = 'C'
WHERE
    (mileage >= 800000 OR mileage IS NULL)
        AND `year` <= 2010
        AND make != 'Mercedes-Benz';

-- 4----------------------------

DELETE FROM clients 
WHERE
    id NOT IN (SELECT 
        client_id
    FROM
        courses)
    AND CHAR_LENGTH(full_name) > 3;

-- 5----------------------------

SELECT 
    make, model, `condition`
FROM
    cars
ORDER BY id;

-- 6----------------------------


-- 7----------------------------
-- 8----------------------------
-- 9----------------------------
-- 1o----------------------------
-- 11----------------------------
