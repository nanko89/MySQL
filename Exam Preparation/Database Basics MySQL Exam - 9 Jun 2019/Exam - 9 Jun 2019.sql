CREATE SCHEMA ruk_database;
USE ruk_database;

-- 1----------------------------

CREATE TABLE branches (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR (30) UNIQUE NOT NULL
);

CREATE TABLE employees (
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR (20) NOT NULL,
last_name VARCHAR (20) NOT NULL,
salary DECIMAL (10,2) NOT NULL,
started_on DATE NOT NULL,
branch_id INT NOT NULL,
CONSTRAINT fk_employee_branch
FOREIGN KEY (branch_id)
REFERENCES branches (id)
);

CREATE TABLE clients(
id INT PRIMARY KEY AUTO_INCREMENT,
full_name VARCHAR(50) NOT NULL,
age INT NOT NULL
);

CREATE TABLE employees_clients (
employee_id INT,
client_id INT,
CONSTRAINT fk_employees_clients_employee
FOREIGN KEY (employee_id)
REFERENCES employees (id),
CONSTRAINT fk_employees_clients_clients
FOREIGN KEY (client_id)
REFERENCES clients (id)
);

CREATE TABLE bank_accounts (
id INT PRIMARY KEY AUTO_INCREMENT,
account_number VARCHAR (10) NOT NULL,
balance DECIMAL (10,2) NOT NULL,
client_id	INT NOT NULL UNIQUE,
CONSTRAINT fk_bank_account_client
FOREIGN KEY (client_id)
REFERENCES clients (id)
);

CREATE TABLE cards (
id INT PRIMARY KEY AUTO_INCREMENT,
card_number VARCHAR (19) NOT NULL,
card_status VARCHAR (7) NOT NULL,
bank_account_id INT NOT NULL,
CONSTRAINT fk_cards_bank_account
FOREIGN KEY (bank_account_id)
REFERENCES bank_accounts (id)
);

-- 2----------------------------

INSERT 
		INTO cards (card_number , card_status, bank_account_id  )
SELECT 	
		REVERSE(full_name) ,
        'Active' ,
        id  
			FROM clients
WHERE id BETWEEN 191 AND 200;

-- 3----------------------------
UPDATE employees_clients AS ec
SET ec.employee_id = (
	SELECT ec2.employee_id FROM (SELECT * FROM `employees_clients`) AS ec2
    GROUP BY ec2.employee_id
    ORDER BY COUNT(ec2.client_id), ec2.employee_id
    LIMIT 1
) 
WHERE ec.employee_id = ec.client_id;


-- 3----------------------------

UPDATE employee_clients AS ec
JOIN (
    SELECT `ec2`.`employee_id` FROM `employees_clients` AS `ec2`
    GROUP BY ec2.`employee_id`
    ORDER BY count(ec2.`client_id`), ec2.`employee_id`
    LIMIT 1) AS `result`
SET ec.`employee_id` = `result`.employee_id
WHERE ec.`employee_id` = ec.`client_id`;

-- 4----------------------------

DELETE 
		FROM
	employees AS e
WHERE id NOT IN (SELECT employee_id FROM employees_clients);

-- 5----------------------------

SELECT 
    id, full_name
FROM
    clients
ORDER BY id;

-- 6----------------------------

SELECT 
    id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    CONCAT('$', salary),
    started_on
FROM
    employees
WHERE
    salary >= 100000
        AND started_on >= '2018-01-01'
ORDER BY salary DESC , id;

-- 7----------------------------

SELECT 
    c.id,
    CONCAT(c.card_number, ' : ', cl.full_name) AS card_token
FROM
    cards AS c
        JOIN
    bank_accounts AS ba ON ba.id = c.bank_account_id
        JOIN
    clients AS cl ON cl.id = ba.client_id
ORDER BY id DESC;

-- 8----------------------------

SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    e.started_on,
    COUNT(c.id) AS count_clients
FROM
    employees AS e
        JOIN
    employees_clients AS ec ON ec.employee_id = e.id
        JOIN
    clients AS c ON ec.client_id = c.id
GROUP BY e.id
ORDER BY count_clients DESC , e.id
LIMIT 5;

-- 9----------------------------

SELECT 
    b.`name`, COUNT(ca.id) AS count_cards
FROM
    branches AS b
        LEFT JOIN
    employees AS e ON b.id = e.branch_id
        LEFT JOIN
    employees_clients AS ec ON e.id = ec.employee_id
        LEFT JOIN
    clients AS cl ON ec.client_id = cl.id
        LEFT JOIN
    bank_accounts AS ba ON ba.client_id = cl.id
        LEFT JOIN
    cards AS ca ON ca.bank_account_id = ba.id
GROUP BY b.`name`
ORDER BY count_cards DESC, b.`name`;

-- 10---------------------------

DELIMITER %%

CREATE FUNCTION udf_client_cards_count(`name` VARCHAR(30)) 
RETURNS INTEGER
	DETERMINISTIC
	BEGIN
		RETURN (SELECT COUNT(c.id) FROM
    cards AS c
        JOIN
    bank_accounts AS ba ON ba.id = c.bank_account_id
        JOIN
    clients AS cl ON cl.id = ba.client_id
WHERE 
	cl.full_name = `name`);
	END %%
    
-- 11---------------------------

CREATE PROCEDURE udp_clientinfo (full_name VARCHAR(50))
	BEGIN 
		SELECT 
			c.full_name, c.age, ba.account_number, CONCAT('$',ba.balance)
		FROM
			bank_accounts AS ba 
				JOIN
			clients AS c ON c.id = ba.client_id
		WHERE
			c.full_name = full_name;
    END %%
