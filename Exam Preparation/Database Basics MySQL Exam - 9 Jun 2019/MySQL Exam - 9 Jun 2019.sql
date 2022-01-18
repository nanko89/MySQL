CREATE DATABASE ruk_database;
USE ruk_database;

# ---------- Ex 1 Table Design ------------

CREATE TABLE branches (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR (30) UNIQUE NOT NULL
);

CREATE TABLE employees (
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(20) NOT NULL,
last_name VARCHAR(20) NOT NULL,
salary DECIMAL (10,2) NOT NULL,
started_on DATE NOT NULL,
branch_id INT NOT NULL,
CONSTRAINT fk_employees_branches
FOREIGN KEY (`branch_id`)
REFERENCES branches (id)
);

CREATE TABLE clients (
id INT PRIMARY KEY AUTO_INCREMENT,
full_name VARCHAR(50) NOT NULL,
age INT NOT NULL
);

CREATE TABLE bank_accounts (
id INT PRIMARY KEY AUTO_INCREMENT,
account_number	VARCHAR (10) NOT NULL,
balance DECIMAL (10,2) NOT NULL,
client_id INT UNIQUE NOT NULL,
CONSTRAINT fk_bank_account_client
FOREIGN KEY (client_id)
REFERENCES clients(id)
);

CREATE TABLE cards (
id INT PRIMARY KEY AUTO_INCREMENT,
card_number VARCHAR (19) NOT NULL,
card_status	VARCHAR( 7) NOT NULL,
bank_account_id	INT NOT NULL,
CONSTRAINT fk_cards_bank_account
FOREIGN KEY (bank_account_id)
REFERENCES bank_accounts (id) 
);

CREATE TABLE employees_clients (
employee_id INT,
client_id INT,
CONSTRAINT fk_employees_clients_employees
FOREIGN KEY (employee_id)
REFERENCES employees (id),
CONSTRAINT fk_employees_clients_clients
FOREIGN KEY (client_id)
REFERENCES clients(id)
);

# ---------- Ex 2 Insert ------------

INSERT INTO cards (card_number, card_status, bank_account_id)
SELECT REVERSE(full_name), 'Active', id
FROM clients
WHERE id BETWEEN 191 AND 200;

# ---------- Ex 3 Update ------------

UPDATE employees_clients AS ec
SET ec.employee_id =
(
SELECT ec2.employee_id FROM (SELECT * FROM employees_clients) AS ec2
GROUP BY employee_id
ORDER BY COUNT(ec2.client_id), ec2.employee_id
LIMIT 1
)
WHERE ec.employee_id = ec.client_id;

# ---------- Ex 3 Update ------------

UPDATE `employees_clients` AS `ec`
JOIN (
    SELECT `ec2`.`employee_id` FROM `employees_clients` AS `ec2`
    GROUP BY ec2.`employee_id`
    ORDER BY count(ec2.`client_id`), ec2.`employee_id`
    LIMIT 1) AS `result`
SET ec.`employee_id` = `result`.employee_id
WHERE ec.`employee_id` = ec.`client_id`;

# ---------- Ex 4 Delete ------------

DELETE e FROM employees AS e
LEFT JOIN employees_clients AS ec
ON e.id = ec.employee_id
WHERE client_id IS NULL;
 
 # ---------- Ex 4 Delete ------------

DELETE FROM employees
WHERE id NOT IN (SELECT ec.employee_id FROM employees_clients AS ec);

 # ---------- Ex 5 Clients ------------

SELECT id, full_name
FROM clients;

 # ---------- Ex 6 Newbies ------------

SELECT id, CONCAT(first_name, ' ', last_name) AS full_name, 
CONCAT('$',salary) AS salary, started_on
FROM employees
WHERE salary > 100000  AND YEAR(started_on) > 2017
ORDER BY salary DESC, id ;

 # ---------- Ex 7 Cards against Humanity ------------

SELECT c.id, CONCAT(c.card_number, ' : ', cl.full_name)
FROM cards AS c
LEFT JOIN bank_accounts AS ba
ON c.bank_account_id = ba.id
LEFT JOIN clients AS cl
ON ba.client_id = cl.id
ORDER BY c.id DESC;

 # ---------- Ex 8 Top 5 Employees ------------

SELECT CONCAT (e.first_name, ' ' , e.last_name) AS `name`, e.started_on, COUNT(ec.client_id) AS count_of_clients
FROM employees AS e
LEFT JOIN employees_clients AS ec
ON e.id = ec.employee_id
GROUP BY e.id 
ORDER BY count_of_clients DESC, e.id
LIMIT 5;

 # ---------- Ex 9 Branch cards ------------

SELECT b.`name`, COUNT(c.id) AS count_of_cards
FROM branches AS b
LEFT JOIN employees AS e
ON b.id = e.branch_id
LEFT JOIN employees_clients AS ec
ON e.id = ec.employee_id
LEFT JOIN clients AS cl
ON ec.client_id = cl.id
LEFT JOIN bank_accounts AS ba
ON ba.client_id = cl.id
LEFT JOIN cards AS c
ON ba.id = c.bank_account_id
GROUP BY b.id
ORDER BY count_of_cards DESC, b.`name`; 

 # ---------- Ex 10 Extract client cards count ------------
DELIMITER &&
CREATE FUNCTION udf_client_cards_count(`name` VARCHAR(30))  
RETURNS INT
DETERMINISTIC
BEGIN 
	RETURN (
	SELECT COUNT(c.id) 
	FROM clients AS cl
	JOIN bank_accounts AS ba
	ON ba.client_id = cl.id
	JOIN cards AS c
	ON c.bank_account_id = ba.id
	WHERE cl.full_name = `name`);
    END &&

DELIMITER ;

 # ---------- Ex 11 Extract Client Info ------------
 DELIMITER &&
 
CREATE PROCEDURE udp_clientinfo (client_name VARCHAR (50))
BEGIN 
	SELECT c.full_name, c.age, ba.account_number, CONCAT ('$', ba.balance)
	FROM clients AS c
	JOIN bank_accounts AS ba
	ON ba.client_id = c.id
	WHERE c.full_name = client_name;
END &&
DELIMITER ;