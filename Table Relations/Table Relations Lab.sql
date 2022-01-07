 # --------Ex 1 ---------
 
 CREATE TABLE `mountains`(
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `name` VARCHAR (30) NOT NULL);
 
 CREATE TABLE `peaks` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `name` VARCHAR (30) NOT NULL,
 `mountain_id` INT,
 CONSTRAINT fk_peak_mountain
 FOREIGN KEY (`mountain_id`)
 REFERENCES `mountains`(id)
  );
  
 # --------Ex 2 ---------
 
 SELECT `driver_id`, `vehicle_type`, CONCAT(`first_name`, ' ' , `last_name`) AS `driver_name`
 FROM `campers` AS c
 JOIN `vehicles` AS v
 ON v.`driver_id` = c.`id`;
 
 # --------Ex 3 ---------
 
 SELECT `starting_point`, `end_point`, `leader_id`, CONCAT(first_name, ' ', `last_name`) AS 'leader_name'
 FROM `routes` AS r
 JOIN `campers` AS c
 ON r.`leader_id` = c.`id`;
 # --------Ex 4 ---------
 CREATE TABLE `mountains`(
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `name` VARCHAR (30) NOT NULL);
 
 CREATE TABLE `peaks` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `name` VARCHAR (30) NOT NULL,
 `mountain_id` INT,
 CONSTRAINT fk_peak_mountain
 FOREIGN KEY (`mountain_id`)
 REFERENCES `mountains`(id)
 ON DELETE CASCADE
  );