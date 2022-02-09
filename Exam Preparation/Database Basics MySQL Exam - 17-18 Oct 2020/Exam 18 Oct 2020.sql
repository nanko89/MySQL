CREATE DATABASE softuni_stores_system;
USE softuni_stores_system;

CREATE TABLE pictures (
id INT PRIMARY KEY AUTO_INCREMENT,
url	VARCHAR (100) NOT NULL,
added_on DATETIME NOT NULL
);

CREATE TABLE categories (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR (40) NOT NULL UNIQUE
);

CREATE TABLE products (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR (40) NOT NULL UNIQUE,
best_before DATE,
price DECIMAL (10,2) NOT NULL,
`description` TEXT,
category_id INT NOT NULL,
picture_id INT NOT NULL,
CONSTRAINT fk_product_category
FOREIGN KEY (category_id)
REFERENCES categories (id),
CONSTRAINT fk_product_picture
FOREIGN KEY (picture_id)
REFERENCES pictures (id)
);

CREATE TABLE towns (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR (20) NOT NULL UNIQUE
);

CREATE TABLE addresses (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR (50) NOT NULL UNIQUE,
town_id INT NOT NULL,
CONSTRAINT fk_addresses_town
FOREIGN KEY (town_id)
REFERENCES towns(id)
);

CREATE TABLE stores (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR (20) NOT NULL UNIQUE,
rating FLOAT NOT NULL,
has_parking BOOL DEFAULT FALSE,
address_id INT NOT NULL,
CONSTRAINT fk_stores_addresses
FOREIGN KEY (address_id)
REFERENCES addresses(id)
);

CREATE TABLE products_stores (
product_id	INT NOT NULL,
store_id INT NOT NULL,
CONSTRAINT pk_products_stores
PRIMARY KEY (product_id,store_id),
CONSTRAINT fk_products_stores_products
FOREIGN KEY (product_id)
REFERENCES products(id),
CONSTRAINT fk_products_stores_stores
FOREIGN KEY (store_id)
REFERENCES stores(id)
);

CREATE TABLE employees (
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR (15) NOT NULL,
middle_name CHAR(1) NOT NULL,
last_name VARCHAR (20) NOT NULL,
salary DECIMAL (19,2) NOT NULL DEFAULT 0,
hire_date DATE NOT NULL,
manager_id INT,
store_id INT NOT NULL,
CONSTRAINT fk_employee_manager
FOREIGN KEY (manager_id)
REFERENCES employees (id),
CONSTRAINT fk_employee_store
FOREIGN KEY (store_id)
REFERENCES stores (id)
);

INSERT INTO products_stores
SELECT id, 1 
FROM products
WHERE id NOT IN (SELECT product_id FROM products_stores);

-- ----------------------

UPDATE employees 
SET 
    manager_id = 3,
    salary = salary + 500
WHERE
    YEAR(hire_date) >= 2003
        AND store_id NOT IN (14 , 5);

-- ----------------------

DELETE FROM employees 
WHERE
    manager_id IS NOT NULL
    AND salary >= 6000;
    
    
-- ----------------------

SELECT first_name, middle_name, last_name, salary, hire_date
FROM employees
ORDER BY hire_date DESC;

-- ----------------------

SELECT 
    pr.`name` AS product_name,
    pr.price AS price,
    pr.best_before ASbest_before,
    CONCAT(SUBSTRING(pr.`description`, 1, 10),
            '...') AS short_description,
    pi.url AS url
FROM
    products AS pr
        JOIN
    pictures AS pi ON pr.picture_id = pi.id
WHERE
    CHAR_LENGTH(pr.`description`) > 100
        AND YEAR(pi.added_on) < 2019
        AND pr.price > 20
ORDER BY pr.price DESC;


-- ----------------------

SELECT 
    s.`name`,
    COUNT(p.id) AS count_product,
    ROUND(AVG(p.price), 2) AS avg_price
FROM
    stores AS s
        LEFT JOIN
    products_stores AS ps ON ps.store_id = s.id
        LEFT JOIN
    products AS p ON ps.product_id = p.id
GROUP BY s.id
ORDER BY count_product DESC , avg_price DESC , s.id;

-- ----------------------

SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    s.`name` AS store_name,
    a.`name` AS addresses,
    e.salary AS salary
FROM
    employees AS e
        JOIN
    stores AS s ON s.id = e.store_id
        JOIN
    addresses AS a ON a.id = s.address_id
WHERE
    e.salary < 4000
        AND a.`name` LIKE ('%5%')
        AND CHAR_LENGTH(s.`name`) > 8
        AND RIGHT(e.last_name, 1) = 'n';

-- ----------------------

SELECT 
    REVERSE(s.`name`) AS reversed_name,
    CONCAT(UCASE(t.`name`), '-', a.`name`) AS full_address,
    COUNT(e.id) AS count_employee
FROM
    employees AS e
        JOIN
    stores AS s ON e.store_id = s.id
        JOIN
    addresses AS a ON s.address_id = a.id
        JOIN
    towns AS t ON a.town_id = t.id
GROUP BY s.id
HAVING count_employee > 0
ORDER BY full_address;

-- ----------------------

DELIMITER %%

CREATE FUNCTION udf_top_paid_employee_by_store(store_name VARCHAR(50))
	RETURNS VARCHAR (200)
DETERMINISTIC
	BEGIN 
			RETURN(SELECT CONCAT(first_name,' ', middle_name,'. ', last_name,' works in store for ',YEAR ('2020-10-18') - YEAR(hire_date),' years') AS full_info
				FROM employees
				WHERE id = (
						SELECT e.id FROM stores AS s
								JOIN 
                        employees AS e ON e.store_id = s.id
						WHERE s.`name` = store_name
						ORDER BY salary DESC
						LIMIT 1));
    END %%
    
-- ----------------------

CREATE PROCEDURE udp_update_product_price (address_name VARCHAR (50)) 
BEGIN 
	UPDATE 
    products AS p
        JOIN
    products_stores AS ps ON ps.product_id = p.id
        JOIN
    stores AS s ON ps.store_id = s.id
        JOIN
    addresses AS a ON s.address_id = a.id
	SET p.price = 
    (IF (LEFT(a.`name`,1) = '0', price + 100, price + 200 ))
	WHERE a.`name` = address_name;
END %%