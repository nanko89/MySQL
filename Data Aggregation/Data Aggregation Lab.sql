 # --------Ex 1 ---------
 
SELECT `department_id`, COUNT(*) AS 'Number of employees'
FROM  `employees` 
GROUP BY `department_id`
ORDER BY 'Number of employees';

 # --------Ex 2 ---------
SELECT `department_id`, ROUND(AVG (`salary`),2) AS 'Average Salary'
FROM `employees`
GROUP BY `department_id`
ORDER BY `Average Salary`;

 # --------Ex 3 ---------

SELECT `department_id`,ROUND(MIN(`salary`), 2 )AS 'Min Salary'
FROM `employees` 
GROUP BY `department_id`
HAVING `Min Salary` > 800;

 # --------Ex 4 ---------

SELECT COUNT(*)
FROM `products`
WHERE `price`  > 8
GROUP BY `category_id` 
HAVING `category_id` = 2 ;

 # --------Ex 5 ---------

SELECT `category_id`,
 ROUND((AVG(`price`)), 2) AS 'Average Price',
 ROUND(MIN(`price`), 2) AS 'Cheapest Product',
 ROUND(MAX(`price`), 2) AS 'Most Expensive Product'

 FROM `products`
 GROUP BY `category_id`
 