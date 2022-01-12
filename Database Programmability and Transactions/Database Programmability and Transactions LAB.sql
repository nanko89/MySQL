# ----------- Ex 1 ------------

DELIMITER &&&
CREATE FUNCTION `ufn_count_employees_by_town` (`town_name` VARCHAR(20))
RETURNS INTEGER
DETERMINISTIC
BEGIN
RETURN 
(SELECT COUNT(*) 
FROM `employees` AS e
JOIN `addresses` AS a
USING (`address_id`)
JOIN `towns` as t
USING (`town_id`)
WHERE t.`name` =  `town_name`
);
END &&&
DELIMITER ;

# ----------- Ex 2 ------------

DELIMITER %%
CREATE PROCEDURE `usp_raise_salaries` (`department_name` VARCHAR(30))
BEGIN
UPDATE `employees` AS e
JOIN `departments` AS d
USING (`department_id`)
SET `salary` = `salary` * 1.05
WHERE d.`name` = `department_name`;
END %%

DELIMITER ;

# ----------- Ex 3 ------------

DELIMITER &&
CREATE PROCEDURE `usp_raise_salary_by_id`(`id` INT)
	BEGIN
		IF((SELECT COUNT(*) FROM `employees` WHERE `employee_id` = `id`) = 1)
		THEN
			UPDATE `employees`
			SET `salary` = `salary` * 1.05
			WHERE `employee_id` = `id`;
		END IF;
    END &&
    
    DELIMITER ;
    
# ----------- Ex 4 ------------

CREATE TABLE `deleted_employees`(
`employee_id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR (50),
`last_name` VARCHAR (50),
`middle_name` VARCHAR (50),
`job_title` VARCHAR (50),
`department_id` INT,
`salary` DECIMAL(19,4)
);

DELIMITER &&
CREATE TRIGGER `tr_deleted_employees`
AFTER DELETE
ON `employees`
FOR EACH ROW
BEGIN 
	INSERT INTO `deleted_employees`(`first_name`,`last_name`, `middle_name`,`job_title`,`department_id`,`salary`)
    VALUES (OLD.`first_name`,OLD.`last_name`, OLD.`middle_name`,OLD.`job_title`,OLD.`department_id`,OLD.`salary`);
END &&