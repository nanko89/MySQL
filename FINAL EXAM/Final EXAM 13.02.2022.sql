CREATE DATABASE online_store;
USE  online_store;


-- 1-------------------------

CREATE TABLE brands(
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR (40) NOT NULL UNIQUE
);

CREATE TABLE categories (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR (40) NOT NULL UNIQUE
);

CREATE TABLE reviews (
id INT PRIMARY KEY AUTO_INCREMENT,
content TEXT,
rating DECIMAL (10,2) NOT NULL,
picture_url VARCHAR (80) NOT NULL,
published_at DATETIME NOT NULL
);

CREATE TABLE products (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR (40) NOT NULL,
price DECIMAL (19,2) NOT NULL,
quantity_in_stock INT,
`description` TEXT,
brand_id INT NOT NULL,
category_id INT NOT  NULL,
review_id INT ,
CONSTRAINT fk_produst_brand
FOREIGN KEY (brand_id)
REFERENCES brands (id),
CONSTRAINT fk_produst_category
FOREIGN KEY (category_id)
REFERENCES categories (id),
CONSTRAINT fk_produst_review
FOREIGN KEY (review_id)
REFERENCES reviews (id)
);

CREATE TABLE customers (
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR (20) NOT NULL,
last_name VARCHAR (20) NOT NULL,
phone VARCHAR (30) NOT NULL UNIQUE,
address VARCHAR (60) NOT NULL,
discount_card BIT DEFAULT FALSE NOT NULL
);

CREATE TABLE orders (
id INT PRIMARY KEY AUTO_INCREMENT,
order_datetime DATETIME NOT NULL,
customer_id	INT NOT NULL,
CONSTRAINT fk_oreder_customer
FOREIGN KEY (customer_id)
REFERENCES customers(id)
);

CREATE TABLE orders_products (
order_id INT,
product_id INT,
CONSTRAINT fk_orders_products_orser
FOREIGN KEY (order_id)
REFERENCES orders(id),
CONSTRAINT fk_orders_products_product
FOREIGN KEY (product_id)
REFERENCES products(id)
);

-- 2-------------------------
INSERT INTO reviews (content , picture_url , published_at, rating )
SELECT SUBSTRING(`description`, 1,15), REVERSE(`name`), '2010-10-10', price/8 FROM products 
WHERE id >= 5 ;

-- 3-------------------------

UPDATE products
SET quantity_in_stock = quantity_in_stock -5
WHERE quantity_in_stock >= 60 AND quantity_in_stock <=70;

-- 4-------------------------

DELETE FROM customers
WHERE id NOT IN (SELECT customer_id FROM orders);

-- 5-------------------------

SELECT id, `name` AS category_name  FROM categories
ORDER BY `name` DESC;

-- 6-------------------------

SELECT p.id, b.id, p.`name`, p.quantity_in_stock
FROM products AS p
JOIN brands AS b
ON p.brand_id = b.id
WHERE p.price > 1000 AND quantity_in_stock < 30
ORDER BY quantity_in_stock, p.id;

-- 7-------------------------

SELECT r.id, r.content, r.rating, r.picture_url, r.published_at
FROM reviews AS r
WHERE content LIKE 'My%' AND CHAR_LENGTH(content) > 61
ORDER BY r.rating DESC;

-- 8-------------------------

 
	SELECT DISTINCT(CONCAT(c.first_name, ' ', c.last_name)) AS full_name,
	c.address,
    o.order_datetime
    FROM customers AS c
    JOIN orders AS o
    ON c.id = o.customer_id
    WHERE YEAR(order_datetime) <= 2018
    ORDER BY full_name DESC;
    
-- 9-------------------------

SELECT 
    COUNT(p.id) AS item_count,
    c.`name`,
    (SELECT 
            SUM(p2.quantity_in_stock)
        FROM
            products AS p2
        WHERE
            p2.category_id = p.category_id) AS total_quantity
FROM
    products AS p
        JOIN
    categories AS c ON p.category_id = c.id
GROUP BY c.id
ORDER BY item_count DESC , total_quantity
LIMIT 5;

-- 10-------------------------
DELIMITER %%

CREATE FUNCTION udf_customer_products_count(`name` VARCHAR(30)) 
RETURNS INTEGER
DETERMINISTIC
BEGIN
		RETURN (SELECT COUNT(o.id) FROM customers AS c
		JOIN 
		orders AS o ON o.customer_id = c.id
		JOIN
		orders_products AS op
		ON o.id = op.order_id
		WHERE c.first_name = `name`);
END %% 

-- 11-------------------------

CREATE PROCEDURE udp_reduce_price (category_name VARCHAR(50))
		BEGIN 
			UPDATE categories AS c
			JOIN products AS p ON p.category_id =c.id
			JOIN reviews AS r ON p.review_id = r.id
			SET price = price - price * 0.3
			WHERE r.rating < 4 AND c.`name` = category_name;
        END %%