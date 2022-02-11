# ------------- Ex 1 ---------------
DELIMITER &&
CREATE PROCEDURE `usp_get_employees_salary_above_35000` ()
BEGIN
	SELECT `first_name`, `last_name`
    FROM `employees`
    WHERE `salary` > 35000
    ORDER BY `first_name`, `last_name`;
END &&

# ------------- Ex 2 ---------------

CREATE PROCEDURE `usp_get_employees_salary_above`(`decimal_salary` DECIMAL(19,4))
BEGIN
	SELECT `first_name`, `last_name`
    FROM `employees`
    WHERE `salary` >= `decimal_salary`
    ORDER BY `first_name`, `last_name`, `employee_id`;
END &&

# ------------- Ex 3 ---------------

CREATE PROCEDURE `usp_get_towns_starting_with` (`start_town` VARCHAR (20))
BEGIN 
	SELECT `name`
    FROM `towns`
    WHERE `name` LIKE CONCAT(`start_town`, '%')
    ORDER BY `name`;
END &&

# ------------- Ex 4 ---------------

CREATE PROCEDURE `usp_get_employees_from_town` (`town_name` VARCHAR (30))
BEGIN
	SELECT e.`first_name`, e.`last_name`
    FROM `employees` AS e
    JOIN `addresses` AS a
    USING (`address_id`)
    JOIN `towns` AS t
    USING (`town_id`)
    WHERE `town_name` = t.`name`
    ORDER BY e.`first_name`, e.`last_name`, e.`employee_id`;
END &&

# ------------- Ex 5 ---------------

CREATE FUNCTION `ufn_get_salary_level` (`salary_of_employee` DECIMAL (19,4))
RETURNS VARCHAR (20)
DETERMINISTIC
BEGIN
	DECLARE `salary_level` VARCHAR (20);
		IF `salary_of_employee` < 30000 THEN 
			SET `salary_level` = 'Low';
		ELSEIF `salary_of_employee` BETWEEN 30000 AND 50000 THEN
			SET `salary_level` = 'Average';
		ELSE 
			SET `salary_level` = 'High';
            END IF;
	RETURN `salary_level`;
END &&

# ------------- Ex 6 ---------------

CREATE PROCEDURE `usp_get_employees_by_salary_level` (`l_salary` VARCHAR (30))
	BEGIN
		SELECT `first_name`, `last_name`
        FROM `employees`
        WHERE `ufn_get_salary_level` (`salary`) = `l_salary`
        ORDER BY `first_name` DESC, `last_name` DESC;
	END &&
    
# ------------- Ex 7 ---------------

CREATE FUNCTION `ufn_is_word_comprised`(`set_of_letters` VARCHAR(50), `word` VARCHAR(50)) 
RETURNS BIT
DETERMINISTIC
BEGIN
	 DECLARE `regex` VARCHAR(200);
     DECLARE `result` BIT;
     SET `regex` = CONCAT('^[', `set_of_letters`, ']+$');
    CASE
        WHEN `word` REGEXP `regex` THEN SET `result` = 1;
        ELSE SET `result` = 0;
    END CASE;
    RETURN `result`;
END &&

# ------------- Ex 8 ---------------

CREATE PROCEDURE `usp_get_holders_full_name` ()
BEGIN
	SELECT CONCAT(ah.`first_name`, ' ', ah.`last_name`) AS 'full_name'
    FROM `account_holders` AS ah
    ORDER BY `full_name`, ah.`id`;
END &&

# ------------- Ex 9 ---------------

CREATE PROCEDURE `usp_get_holders_with_balance_higher_than` (`sum` DECIMAL (19,4))
BEGIN
	SELECT ah.`first_name` ,ah.`last_name` 
	FROM `account_holders` AS ah
	JOIN `accounts` AS a
	ON a.`account_holder_id`  = ah.`id`
	WHERE `sum` < (
		SELECT SUM(a2.`balance`) 
		FROM `accounts` AS a2
		WHERE a2.`account_holder_id` = a.`account_holder_id`
		GROUP BY `account_holder_id`
	)
    GROUP BY `account_holder_id`
	ORDER BY a.`account_holder_id`;
END &&

# ------------- Ex 10 ---------------

CREATE FUNCTION `ufn_calculate_future_value` (`sum` DECIMAL (19,4), `rate` DOUBLE, `year` INT)
RETURNS DECIMAL (19,4)
DETERMINISTIC
BEGIN
	RETURN `sum` * POW(1 + `rate`, `year`);
END &&

# ------------- Ex 11 ---------------

CREATE PROCEDURE `usp_calculate_future_value_for_account`(`id_account` INT, `interest_rate` DECIMAL(19,4))
BEGIN
	SELECT a.`id`, ah.`first_name` ,ah.`last_name` , a.`balance`,
    `ufn_calculate_future_value` (a.`balance`, `interest_rate`, 5 )  AS 'ballance_in_5_yesr'
	FROM `account_holders` AS ah
	JOIN `accounts` AS a
	ON a.`account_holder_id`  = ah.`id`
    WHERE `id_account` = a.`id`;
END &&

# ------------- Ex 12 ---------------

CREATE PROCEDURE `usp_deposit_money`(`account_id` INT , `money_amount` DECIMAL(19,4))
BEGIN
	START TRANSACTION;
		IF (`money_amount` <= 0  OR (
        SELECT COUNT(*) FROM `accounts` AS a WHERE `account_id` = a.`id`) = 0 ) 
			THEN ROLLBACK;
		ELSE 
			UPDATE `accounts`
            SET `balance` = `balance` + `money_amount`
            WHERE `id` = `account_id`;
		END IF;

END &&
# ------------- Ex 13 ---------------

CREATE PROCEDURE `usp_withdraw_money`(`account_id` INT, `money_amount` DECIMAL (19,4))
BEGIN
	START TRANSACTION;
		IF (`money_amount` <=  0 
			OR (SELECT `balance` FROM `accounts` WHERE `id`= `account_id`) <= `money_amount`
            OR ((SELECT COUNT(*) FROM `accounts` WHERE `id` = `account_id`) = 0))
				THEN ROLLBACK;
        ELSE
			UPDATE `accounts`
            SET `balance` = `balance` - `money_amount`
            WHERE `id` = `account_id`;
        END IF;
END &&

# ------------- Ex 14 ---------------

CREATE PROCEDURE `usp_transfer_money`(`from_account_id` INT,`to_account_id` INT, `amount`DECIMAl(19,4)) 
BEGIN
	START TRANSACTION;
		IF((SELECT COUNT(*) FROM `accounts` WHERE `id` = `from_account_id`) = 0
			OR (SELECT COUNT(*) FROM `accounts` WHERE `id` = `to_account_id`) = 0
            OR `amount` <= 0
            OR (SELECT `balance` FROM `accounts` WHERE `id`= `from_account_id`) <= `amount`)
             THEN ROLLBACK;
		ELSE 
			UPDATE `accounts`
            SET `balance` = `balance` - `amount`
            WHERE `id` = `from_account_id`;
            UPDATE `accounts`
            SET `balance` = `balance` + `amount`
            WHERE `id`= `to_account_id`;
		END IF;
END &&

# ------------- Ex 15 ---------------
DELIMITER ;
 
CREATE TABLE `logs` (
`log_id` INT PRIMARY KEY AUTO_INCREMENT,
`account_id` INT,
`old_sum` DECIMAL (19,4),
`new_sum` DECIMAL (19,4)
);

DELIMITER &&

CREATE TRIGGER tr_on_uppdate 
AFTER UPDATE
ON `accounts`
FOR EACH ROW
	BEGIN
		INSERT INTO `logs` (`account_id`, `old_sum`, `new_sum`)
        VALUES (OLD.`id`, OLD.`balance`, NEW.`balance`);
    END &&

# ------------- Ex 16 ---------------
DELIMITER ;

CREATE TABLE `logs` (
`log_id` INT PRIMARY KEY AUTO_INCREMENT,
`account_id` INT,
`old_sum` DECIMAL (19,4),
`new_sum` DECIMAL (19,4)
);

DELIMITER %%
CREATE TRIGGER tr_on_uppdate 
AFTER UPDATE
ON `accounts`
FOR EACH ROW
	BEGIN
		INSERT INTO `logs` (`account_id`, `old_sum`, `new_sum`)
        VALUES (OLD.`id`, OLD.`balance`, NEW.`balance`);
    END %%

CREATE TABLE notification_emails(
id INT PRIMARY KEY AUTO_INCREMENT,
recipient INT NOT NULL,
`subject` VARCHAR (150),
body TEXT
 ) %% 
 
 
 CREATE TRIGGER tr_notification
 BEFORE INSERT
 ON `logs`
 FOR EACH ROW
	BEGIN
		INSERT INTO `notification_emails`(`recipient`, `subject`, `body`)
        VALUE (NEW.`account_id`,
        CONCAT('Balance change for account: ', NEW.`account_id`),
        CONCAT('On', DATE_FORMAT(NOW(), '%b %d %Y %r'),' your balance was changed from ',
        ROUND(NEW.old_sum, 2), ' to ', ROUND(NEW.new_sum, 2), '.'));
    END %%

 
