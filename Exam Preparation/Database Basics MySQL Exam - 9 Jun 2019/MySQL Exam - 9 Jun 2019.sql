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

