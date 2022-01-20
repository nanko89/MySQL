CREATE DATABASE softuni_stores_system;
USE softuni_stores_system;

# ---------- Ex 1 Table Design ------------

CREATE TABLE pictures (
id INT PRIMARY KEY AUTO_INCREMENT,
url VARCHAR(100) NOT NULL,
added_on DATETIME NOT NULL
);

CREATE TABLE categories (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR (40) NOT NULL UNIQUE
);

CREATE TABLE products (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL UNIQUE,
best_before	DATE,
price DECIMAL (10,2) NOT NULL,
`description` TEXT,
category_id INT NOT NULL, 
picture_id INT NOT NULL,
CONSTRAINT fk_products_category
FOREIGN KEY (category_id)
REFERENCES categories (id),
CONSTRAINT fk_products_picture
FOREIGN KEY (picture_id)
REFERENCES pictures (id)
);

CREATE TABLE towns (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE addresses (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR (50) NOT NULL UNIQUE,
town_id	INT NOT NULL,
CONSTRAINT fk_addresses_town
FOREIGN KEY (town_id)
REFERENCES towns (id)
);

CREATE TABLE stores (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR (20) NOT NULL UNIQUE,
rating FLOAT NOT NULL,
has_parking BOOL DEFAULT FALSE,
address_id INT NOT NULL,
CONSTRAINT fk_stores_addresses
FOREIGN KEY (address_id)
REFERENCES addresses (id)
);

CREATE TABLE products_stores (
product_id INT NOT NULL,
store_id INT NOT NULL,
CONSTRAINT pk_products_stores
PRIMARY KEY (product_id,store_id),
CONSTRAINT fk_products_stores_products
FOREIGN KEY (product_id)
REFERENCES products (id),
CONSTRAINT fk_products_stores_stores
FOREIGN KEY (store_id)
REFERENCES stores (id)
);

CREATE TABLE employees (
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR (15) NOT NULL,
middle_name	CHAR(1),
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

-- # ---------- Ex 2 Insert ------------

INSERT INTO products_stores 
SELECT p.id, 1
FROM products AS p
WHERE p.id NOT IN (SELECT product_id FROM products_stores);

-- # ---------- Ex 3 Update ------------

UPDATE employees AS e
        JOIN
    stores AS s ON s.id = e.store_id 
SET 
    e.manager_id = 1,
    e.salary = e.salary - 500
WHERE
    YEAR(e.hire_date) >= 2003
        AND s.`name` NOT IN ('Cardguard' , 'Veribet');

-- # ---------- Ex 4 Delete ------------

-- DELETE FROM employees 
-- WHERE
--     manager_id IS NOT NULL
--     AND salary >= 6000;

# ---------- Ex 5 Employees ------------

SELECT 
    first_name, middle_name, last_name, salary, hire_date
FROM
    employees
ORDER BY hire_date DESC;

# ---------- Ex 6 Products with old pictures ------------

SELECT 
    pr.`name`,
    pr.price,
    pr.best_before,
    CONCAT(SUBSTR(pr.`description`, 1, 10), '...') AS short_description,
    p.url
FROM
    pictures AS p
        JOIN
    products AS pr ON p.id = pr.picture_id
WHERE
    CHAR_LENGTH(pr.`description`) > 100
        AND YEAR(p.added_on) < 2019
        AND pr.price > 20
ORDER BY pr.price DESC;

# ---------- Ex 7 Counts of products in stores and their average  ------------

SELECT 
    s.`name`,
    COUNT(p.id) AS count_products,
    ROUND(AVG(p.price), 2) AS avg_price
FROM
    stores AS s
        LEFT JOIN
    products_stores AS ps ON s.id = ps.store_id
        LEFT JOIN
    products AS p ON ps.product_id = p.id
GROUP BY s.`name`
ORDER BY count_products DESC , avg_price DESC , s.id;

# ---------- Ex 8 Specific employee  ------------

SELECT 
    CONCAT(first_name, ' ', last_name) AS full_name,
    s.`name`,
    a.`name`,
    e.salary
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
        
# ---------- Ex 9 Find all information of stores ------------

SELECT 
    REVERSE(s.`name`) AS reversed_name,
    CONCAT(UPPER(t.`name`), '-', a.`name`) AS full_address,
    COUNT(e.id) AS count_employee
FROM
    stores AS s
        LEFT JOIN
    addresses AS a ON a.id = s.address_id
        LEFT JOIN
    towns AS t ON t.id = a.town_id
        LEFT JOIN
    employees AS e ON s.id = e.store_id
GROUP BY s.id
HAVING count_employee > 0
ORDER BY full_address;

 # ---------- Ex 10	Find full name of top paid employee by store name ------------
 
 DELIMITER %%
 
CREATE FUNCTION udf_top_paid_employee_by_store(store_name VARCHAR(50))
RETURNS VARCHAR(100)
	DETERMINISTIC
BEGIN
	RETURN (SELECT CONCAT(e.first_name, ' ', e.middle_name,'. ' ,e.last_name, ' works in store for ', 
	YEAR ('2020-10-18') - YEAR(e.hire_date),' years') AS full_info
	FROM employees AS e
	JOIN stores AS s
	ON s.id = e.store_id
	WHERE e.id = (
		SELECT e.id 
		FROM employees AS e
		JOIN stores AS s
		ON s.id = e.store_id
		WHERE s.`name`  = store_name 
		ORDER BY salary DESC
		LIMIT 1
));
END %%

 DELIMITER ;
 
  # ---------- Ex 11 Update product price by address ------------

DELIMITER &&
CREATE PROCEDURE udp_update_product_price (address_name VARCHAR (50))
	BEGIN 
		UPDATE products AS p
		JOIN products_stores AS ps
		ON ps.product_id = p.id
		JOIN stores AS s
		ON ps.store_id = s.id
		JOIN addresses AS a
		ON a.id = s.address_id
			SET p.price = IF (LEFT (a.`name`, 1) = '0', p.price + 100, p.price + 200)
			WHERE a.name = address_name;
    END &&
 DELIMITER ;


