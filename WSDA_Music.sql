
--How many transactions took place between the years 2011 and 2012? 

SELECT COUNT(*) AS transaction_count
FROM Invoice
WHERE InvoiceDate BETWEEN '2011-01-01' AND '2012-12-31';


--How much money did WSDA Music make during the same period? 

SELECT SUM(Total) || '$' AS total_money
FROM Invoice
WHERE InvoiceDate BETWEEN '2011-01-01' AND '2012-12-31';

--Get a list of customers who made purchases between 2011 and 2012.

SELECT DISTINCT c.CustomerId, c.firstname || ' ' || c.lastname AS FullName
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
WHERE i.InvoiceDate BETWEEN '2011-01-01' AND '2012-12-31';

--Get a list of customers, sales reps, and total transaction amounts for 
-- each customer between 2011 and 2012

SELECT c.CustomerId, c.FirstName || ' ' || c.LastName AS CustomerName, 
e.FirstName || ' ' || e.LastName AS SalesRepName, SUM(i.Total) AS TotalAmount
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
LEFT JOIN  Employee e ON c.SupportRepId = e.EmployeeId
WHERE i.InvoiceDate BETWEEN '2011-01-01' AND '2012-12-31'
GROUP BY c.CustomerId, CustomerName, SalesRepName;


--How many transactions are above the average transaction amount during the same time period? 

WITH AvgTransaction AS (SELECT AVG(Total) AS avg_transaction_amount
FROM Invoice
WHERE InvoiceDate BETWEEN '2011-01-01' AND '2012-12-31')
SELECT COUNT(*) AS transactions_above_average
FROM Invoice, AvgTransaction
WHERE InvoiceDate BETWEEN '2011-01-01' AND '2012-12-31'
AND Total > AvgTransaction.avg_transaction_amount;

--What is the average transaction amount for each year that WSDA Music has been in business? 

SELECT strftime('%Y', InvoiceDate) AS Year, AVG(Total) AS avg_transaction_amount
FROM Invoice
GROUP BY Year
ORDER BY Year;


--Get a list of employees who exceeded the average transaction amount from 
--sales they generated during 2011 and 2012. 

WITH AvgTransaction AS (SELECT AVG(Total) AS avg_transaction_amount
FROM Invoice
WHERE InvoiceDate BETWEEN '2011-01-01' AND '2012-12-31')
SELECT e.EmployeeId, i.InvoiceId, i.Total, e.FirstName || ' ' || e.LastName AS EmployeeName
FROM Invoice i
JOIN Customer c ON i.CustomerId = c.CustomerId
JOIN Employee e ON c.SupportRepId = e.EmployeeId
WHERE i.InvoiceDate BETWEEN '2011-01-01' AND '2012-12-31'
AND i.Total > (SELECT avg_transaction_amount FROM AvgTransaction)
ORDER BY e.EmployeeId, i.Total DESC;


--Create a Commission Payout column that displays each employee’s commission based on 15% of the sales transaction amount.

WITH AvgTransaction AS (SELECT AVG(Total) AS avg_transaction_amount
FROM Invoice
WHERE InvoiceDate BETWEEN '2011-01-01' AND '2012-12-31')
SELECT e.EmployeeId, e.FirstName || ' ' || e.LastName AS EmployeeName, i.InvoiceId,
i.Total,(i.Total * 0.15) AS CommissionPayout, (i.Total * 0.15) || '$' AS CommissionInDollars
FROM Invoice i
JOIN Customer c ON i.CustomerId = c.CustomerId
JOIN Employee e ON c.SupportRepId = e.EmployeeId
JOIN AvgTransaction at
WHERE i.InvoiceDate BETWEEN '2011-01-01' AND '2012-12-31'
AND i.Total > at.avg_transaction_amount
ORDER BY e.EmployeeId, i.Total DESC;

--Which employee made the highest commission? 

WITH EmployeeCommissions AS (SELECT e.EmployeeId, e.FirstName || ' ' || e.LastName AS EmployeeName,
SUM(i.Total * 0.15) AS TotalCommission
FROM Invoice as i
JOIN Customer as c ON i.CustomerId = c.CustomerId
JOIN Employee as e ON c.SupportRepId = e.EmployeeId
WHERE i.InvoiceDate BETWEEN '2011-01-01' AND '2012-12-31'
GROUP BY e.EmployeeId, e.FirstName,e.LastName)
SELECT EmployeeId,EmployeeName, TotalCommission
FROM EmployeeCommissions
ORDER BY TotalCommission DESC
LIMIT 1;

--List the customers that the employee identified in the last question.

SELECT c.CustomerId, c.FirstName || ' ' || c.LastName AS CustomerName
FROM Customer c
WHERE c.SupportRepId = 3;

--Which customer made the highest purchase?

SELECT c.CustomerId, c.FirstName || ' ' || c.LastName AS CustomerName,
SUM(i.Total) AS TotalSpent,(SUM(i.Total) )|| '$' AS TotalSpentDollars
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId, c.FirstName,c.LastName
ORDER BY TotalSpent DESC
LIMIT 1;

--Look at this customer record—do you see anything suspicious?

SELECT  *, SUM(i.Total) AS TotalSpent
FROM Customer AS c
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId
ORDER BY TotalSpent DESC
LIMIT 1;

SELECT *, SUM(i.Total) AS TotalSpent
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
WHERE c.SupportRepId = 3
GROUP BY c.CustomerId
ORDER BY TotalSpent DESC;

SELECT *
FROM Invoice as i
WHERE i.CustomerId = 60
ORDER BY i.InvoiceDate;
