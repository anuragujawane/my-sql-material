# JOINS 
# 1. List the top 5 countries (by order count) that Classic Models ships to. (Use the Customers and Orders tables)

SELECT country,
    COUNT(*) AS order_count
FROM Customers
WHERE customerNumber IN (SELECT customerNumber FROM Orders)
GROUP BY country
ORDER BY order_count DESC
LIMIT 5;

# Self Joins 
# 2. Create a table project with below fields
CREATE TABLE Project (
EmployeeID INT PRIMARY KEY,
FullName VARCHAR(50),
Gender VARCHAR(10),
ManagerID INT
);
INSERT INTO Project (EmployeeID, FullName, Gender, ManagerID) VALUES
(1, 'Pranaya', 'Male', 3),
(2, 'Priyanka', 'Female', 1),
(3, 'Preety', 'Female', NULL),
(4, 'Anurag', 'Male', 1),
(5, 'Sambit', 'Male', 1),
(6, 'Rajesh', 'Male', 3),
(7, 'Hina', 'Female', 3);
SELECT * FROM Project;

# Find out the names of employees and their related managers

SELECT 
	m.FullName AS ManagerName,
    e.FullName AS EmployeeName
FROM Project e
LEFT JOIN Project m ON e.ManagerID = m.EmployeeID
WHERE e.ManagerID IS NOT NULL
ORDER BY ManagerName;

# TRIGGERS
-- Create the table Emp_BIT. Add below fields in it.
-- Name
-- Occupation
-- Working_date
-- Working_hours

-- Insert the data as shown in below query.
-- INSERT INTO Emp_BIT VALUES
-- ('Robin', 'Scientist', '2020-10-04', 12),  
-- ('Warner', 'Engineer', '2020-10-04', 10),  
-- ('Peter', 'Actor', '2020-10-04', 13),  
-- ('Marco', 'Doctor', '2020-10-04', 14),  
-- ('Brayden', 'Teacher', '2020-10-04', 12),  
-- ('Antonio', 'Business', '2020-10-04', 11);  
-- Create before insert trigger to make sure any new value of Working_hours, if it is negative, then it should be inserted as positive.

CREATE TABLE Emp_BIT (
    Name VARCHAR(50),
    Occupation VARCHAR(50),
    Working_date DATE,
    Working_hours INT
);
INSERT INTO Emp_BIT (Name, Occupation, Working_date, Working_hours) VALUES
('Robin', 'Scientist', '2020-10-04', 12),
('Warner', 'Engineer', '2020-10-04', 10),
('Peter', 'Actor', '2020-10-04', 13),
('Marco', 'Doctor', '2020-10-04', 14),
('Brayden', 'Teacher', '2020-10-04', 12),
('Antonio', 'Business', '2020-10-04', 11);
DELIMITER $$

CREATE TRIGGER Before_Insert_Emp_BIT
BEFORE INSERT ON Emp_BIT
FOR EACH ROW
BEGIN
    IF NEW.Working_hours < 0 THEN
        SET NEW.Working_hours = -NEW.Working_hours;
    END IF;
END;
$$
DELIMITER ;

# ERROR HANDLING in SQL
-- Create the table Emp_EH. Below are its fields.
-- EmpID (Primary Key)
-- EmpName
-- EmailAddress
-- Create a procedure to accept the values for the columns in Emp_EH. Handle the error using exception handling concept. 
-- Show the message as “Error occurred” in case of anything wrong.

CREATE TABLE Emp_EH (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(50),
    EmailAddress VARCHAR(100)
);

DELIMITER //
DELIMITER $$

CREATE PROCEDURE InsertEmp_EH(
    IN p_EmpID INT,
    IN p_EmpName VARCHAR(50),
    IN p_EmailAddress VARCHAR(100)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT 'Error occurred' AS Message;
    END;

    INSERT INTO Emp_EH (EmpID, EmpName, EmailAddress)
    VALUES (p_EmpID, p_EmpName, p_EmailAddress);

    SELECT 'Data inserted successfully' AS Message;
END $$

DELIMITER ;

# Subqueries and their applications
-- find out how many product lines are there for which the buy price value is greater than the  average of MSRP value. Show the output as product line and its count.

SELECT ProductLine, COUNT(*) AS LineCount
FROM Products
WHERE BuyPrice > (SELECT AVG(BuyPrice) FROM Products)
GROUP BY ProductLine;

# DDL Commands: Create, Alter, Rename
-- Create table facility. Add the below fields into it.
-- Facility_ID
-- Name
-- State
-- Country

-- Create the facility table with fields
CREATE TABLE facility (
    Facility_ID INT,
    Name VARCHAR(50),
    State VARCHAR(50),
    Country VARCHAR(50)
);
-- i) Alter the table by adding the primary key and auto increment to Facility_ID column.
ALTER TABLE facility
ADD PRIMARY KEY (Facility_ID);

ALTER TABLE facility
MODIFY COLUMN Facility_ID INT AUTO_INCREMENT;

-- ii) Add a new column city after name with data type as varchar which should not accept any null values.
ALTER TABLE facility
ADD City VARCHAR(50) NOT NULL AFTER Name;

DESCRIBE facility;

# SELECT clause with WHERE, AND,DISTINCT, Wild Card (LIKE)
-- Show the unique productline values containing the word cars at the end from the products table.

select distinct productline
from products
where productline like '%cars';

-- Fetch the employee number, first name and last name of those employees who are working as Sales Rep reporting to employee with  employeenumber 1102 (Refer employee table)

SELECT 
	e.employeeNumber, 
	CONCAT(e.firstName, ' ', e.lastName) AS Sales_Person,
	COUNT(DISTINCT c.customerNumber) AS unique_customers
FROM Employees AS e
LEFT JOIN Customers AS c ON e.employeeNumber = c.salesRepEmployeeNumber
GROUP BY e.employeeNumber, Sales_Person
ORDER BY unique_customers DESC;

# Stored Procedures in SQL with parameters
-- Create a stored procedure Get_country_payments which takes in year and country as inputs and gives year wise, country wise total amount as an output. Format the total amount to nearest thousand unit (K)

DELIMITER //
CREATE PROCEDURE `Get_country_payments`(IN inout_Year INT, IN input_country VARCHAR(255))
BEGIN
    SELECT
        YEAR(paymentdate) AS Year,
        country AS Country,
        CONCAT(FORMAT(SUM(amount)/1000, 0), 'K') AS Totalamount
    FROM Payments 
    INNER JOIN CUSTOMERS ON PAYMENTS.customerNumber = CUSTOMERS.customerNumber
    WHERE YEAR(paymentDate) = inout_Year AND country = input_country
    GROUP BY Year, Country;
END //

DELIMITER ;

call Get_country_payments(2003, 'France');

# Window functions - Rank, dense_rank, lead and lag
-- 1. Using customers and orders tables, rank the customers based on their order frequency
SELECT customerName,
    Order_count,
    DENSE_RANK() OVER (ORDER BY Order_count DESC) AS order_frequency_rnk
FROM (
    SELECT 
        c.customerName,
        COUNT(o.orderNumber) AS Order_count
    FROM 
        Customers c
    LEFT JOIN 
        Orders o ON c.customerNumber = o.customerNumber
    GROUP BY 
        c.customerNumber, c.customerName
) AS order_counts;

-- 2 .Calculate year wise, month name wise count of orders and year over year (YoY) percentage change. Format the YoY values in no decimals and show in % sign.

SHOW COLUMNS FROM Orders;
WITH YearMonthOrders AS (
  SELECT
    EXTRACT(YEAR FROM orderDate) AS order_year,
    DATE_FORMAT(orderDate, '%M') AS order_month,
    COUNT(*) AS order_count
  FROM
    Orders
  GROUP BY
    order_year, order_month
  ORDER BY
    order_year, order_month
),

YoYPercentageChange AS (
  SELECT
    a.order_year,
    a.order_month,
    a.order_count,
    b.order_count AS prev_year_order_count,
    CASE
      WHEN b.order_count IS NULL THEN 'N/A' 
      ELSE
        CONCAT(
          ROUND(((a.order_count - b.order_count) / b.order_count) * 100),
          '%'
        )
    END AS yoy_percentage_change
  FROM
    YearMonthOrders a
  LEFT JOIN
    YearMonthOrders b
  ON
    a.order_year = b.order_year + 1
    AND a.order_month = b.order_month
)

SELECT
  order_year,
  order_month,
  order_count,
  yoy_percentage_change
FROM
  YoYPercentageChange;
  
# CASE STATEMENTS for Segmentation
--  Using a CASE statement, segment customers into three categories based on their country:(Refer Customers table) "North America" for customers from USA or Canada
-- "Europe" for customers from UK, France, or Germany "Other" for all remaining countries Select the customerNumber, customerName, and the assigned region as "CustomerSegment".

  SELECT 
    customerNumber,
    customerName,
    CASE
        WHEN country IN ('USA', 'Canada') THEN 'North America'
        WHEN country IN ('UK', 'France', 'Germany') THEN 'Europe'
        ELSE 'Other'
    END AS CustomerSegment
FROM 
    Customers;

# Group By with Aggregation functions and Having clause, Date and Time functions
-- Using the OrderDetails table, identify the top 10 products (by productCode) with the highest total order quantity across all orders

SELECT 
    productCode,
    SUM(quantityOrdered) AS total_ordered
FROM OrderDetails
GROUP BY productCode
ORDER BY total_ordered DESC
LIMIT 10;

-- Company wants to analyze payment frequency by month. 
-- Extract the month name from the payment date to count the total number of payments for each month and include only those months with a payment count exceeding 20 
-- (Refer Payments table). 

SELECT MONTHNAME(paymentDate) AS payment_month,
    COUNT(*) AS num_payments
FROM Payments
GROUP BY MONTHNAME(paymentDate)
HAVING COUNT(*) > 20;

# Views in SQL
-- 1.	Create a view named product_category_sales that provides insights into sales performance by product category. This view should include the following information:
-- productLine: The category name of the product (from the ProductLines table).

-- total_sales: The total revenue generated by products within that category (calculated by summing the orderDetails.quantity * orderDetails.priceEach for each product in the category).

-- number_of_orders: The total number of orders containing products from that category.(Hint: Tables to be used: Products, orders, orderdetails and productlines)

CREATE VIEW product_category_sales AS
SELECT 
    pl.productLine,
    SUM(od.quantityOrdered * od.priceEach) AS total_sales,
    COUNT(DISTINCT o.orderNumber) AS number_of_orders
FROM Products p
JOIN ProductLines pl ON p.productLine = pl.productLine
JOIN OrderDetails od ON p.productCode = od.productCode
JOIN Orders o ON od.orderNumber = o.orderNumber
GROUP BY p1.productLine;

# CONSTRAINTS: Primary, key, foreign key, Unique, check, not null, default
-- 	Create a new database named Customers_Orders and add the following tables as per the description
-- Create a table named Customers to store customer information. Include the following columns:
-- customer_id: This should be an integer set as the PRIMARY KEY and AUTO_INCREMENT.
-- first_name: This should be a VARCHAR(50) to store the customer's first name.
-- last_name: This should be a VARCHAR(50) to store the customer's last name.
-- email: This should be a VARCHAR(255) set as UNIQUE to ensure no duplicate email addresses exist.
-- phone_number: This can be a VARCHAR(20) to allow for different phone number formats.
-- Add a NOT NULL constraint to the first_name and last_name columns to ensure they always have a value.

