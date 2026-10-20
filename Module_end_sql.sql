USE ecomm;

# Impute mean and round off to the nearest integer

SELECT COUNT(*) -COUNT(WarehouseToHome) AS WarehouseToHome_Nulls,
 COUNT(*) - COUNT(HourSpendOnApp) AS HourSpendOnApp_Nulls,
    COUNT(*) - COUNT(OrderAmountHikeFromlastYear) AS OrderAmountHike_Nulls,
    COUNT(*) - COUNT(DaySinceLastOrder) AS DaySinceLastOrder_Nulls
FROM customer_churn;
SELECT
    ROUND(AVG(WarehouseToHome)) AS WarehouseToHome_Mean,
    ROUND(AVG(HourSpendOnApp)) AS HourSpendOnApp_Mean,
    ROUND(AVG(OrderAmountHikeFromlastYear)) AS OrderAmountHike_Mean,
    ROUND(AVG(DaySinceLastOrder)) AS DaySinceLastOrder_Mean
FROM customer_churn;
UPDATE customer_churn
SET WarehouseToHome = 16
WHERE WarehouseToHome IS NULL;
SELECT COUNT(*) - COUNT(WarehouseToHome) AS Missing_Values
FROM customer_churn;
UPDATE customer_churn
SET HourSpendOnApp = 3
WHERE HourSpendOnApp IS NULL;
UPDATE customer_churn
SET OrderAmountHikeFromlastYear = 16
WHERE OrderAmountHikeFromlastYear IS NULL;
UPDATE customer_churn
SET DaySinceLastOrder = 5
WHERE DaySinceLastOrder IS NULL;
SELECT
    CustomerID,
    WarehouseToHome,
    HourSpendOnApp,
    OrderAmountHikeFromlastYear,
    DaySinceLastOrder
FROM customer_churn;

# Impute mode for the following columns

SELECT
    COUNT(*) - COUNT(Tenure) AS Missing_Tenure,
    COUNT(*) - COUNT(CouponUsed) AS Missing_CouponUsed,
    COUNT(*) - COUNT(OrderCount) AS Missing_OrderCount
FROM customer_churn;
SELECT Tenure, COUNT(*)
FROM customer_churn
WHERE Tenure IS NOT NULL
GROUP BY Tenure
ORDER BY COUNT(*) DESC;
UPDATE customer_churn
SET Tenure = 1
WHERE Tenure IS NULL;
SELECT CouponUsed, COUNT(*) 
FROM customer_churn
WHERE CouponUsed IS NOT NULL
GROUP BY CouponUsed
ORDER BY COUNT(*) DESC;
UPDATE customer_churn
SET CouponUsed =1
WHERE CouponUsed IS NULL;
SELECT OrderCount ,COUNT(*) 
FROM customer_churn
WHERE OrderCount IS NOT NULL
GROUP BY OrderCount
ORDER BY COUNT(*) DESC;
UPDATE customer_churn
SET  OrderCount=2
WHERE  OrderCount IS NULL;

# Handle outliers by deleting rows

SELECT COUNT(*)
FROM customer_churn
WHERE WarehouseToHome > 100;
DELETE FROM customer_churn
WHERE WarehouseToHome > 100;

#Dealing with Inconsistencies Mobile Phone

SELECT * FROM customer_churn;
UPDATE customer_churn
SET PreferredLoginDevice = 'Mobile Phone'
WHERE PreferredLoginDevice = 'Phone';
UPDATE customer_churn
SET PreferedOrderCat = 'Mobile Phone'
WHERE PreferedOrderCat = 'Mobile';

#Dealing with Inconsistencies Cash on Delivery &Credit Card

SELECT * FROM customer_churn;
UPDATE customer_churn
SET PreferredPaymentMode = 'Cash on Delivery'
WHERE PreferredPaymentMode = 'COD';
UPDATE customer_churn
SET PreferredPaymentMode = 'Credit Card'
WHERE PreferredPaymentMode = 'CC';

#Column  Renaming PreferredOrderCat

ALTER TABLE customer_churn
RENAME COLUMN PreferedOrderCat TO PreferredOrderCat;
DESC customer_churn;

#Column  Renaming HoursSpentOnApp

ALTER TABLE customer_churn
RENAME COLUMN HourSpendOnApp TO HoursSpentOnApp;

#Create New Column ComplaintReceived 

ALTER TABLE customer_churn
ADD COLUMN ComplaintReceived VARCHAR(3);
UPDATE customer_churn
SET ComplaintReceived = IF(Complain = 1, 'Yes', 'No');

#Create New Column ChurnStatus

ALTER TABLE customer_churn
ADD COLUMN ChurnStatus VARCHAR(10);
UPDATE customer_churn
SET ChurnStatus = IF(Churn = 1, 'Churned', 'Active');

#DROP Column

ALTER TABLE customer_churn
DROP COLUMN Churn,
DROP COLUMN Complain;

#Retrieve Churnstatus

SELECT ChurnStatus, COUNT(*)
FROM customer_churn
GROUP BY ChurnStatus;

#Average Tensure and Total cashback

SELECT AVG(Tenure), SUM(CashbackAmount)
FROM customer_churn
WHERE ChurnStatus = 'Churned';

#Percentage of Churned

SELECT COUNT(IF(ComplaintReceived = 'Yes', 1, NULL)) * 100.0 / COUNT(*) AS Percentage_Churned
FROM customer_churn
WHERE ChurnStatus = 'Churned';

#Highest Customers in Laptops and Accessory

SELECT CityTier, COUNT(*)
FROM customer_churn
WHERE ChurnStatus = 'Churned'
AND PreferredOrderCat = 'Laptop & Accessory'
GROUP BY CityTier
ORDER BY COUNT(*) DESC
LIMIT 1;

#Preferred Payment

SELECT PreferredPaymentMode, COUNT(*)
FROM customer_churn
WHERE ChurnStatus = 'Active'
GROUP BY PreferredPaymentMode
ORDER BY COUNT(*) DESC
LIMIT 1;

#Total Order Amount Hike
SELECT SUM(OrderAmountHikeFromlastYear)
FROM customer_churn
WHERE MaritalStatus = 'Single'
AND PreferredLoginDevice = 'Mobile Phone';

#average number of devices registered

SELECT AVG(NumberOfDeviceRegistered)
FROM customer_churn
WHERE PreferredPaymentMode = 'UPI';

#City tier with the highest number of Customers

SELECT CityTier, COUNT(*)
FROM customer_churn
GROUP BY CityTier
ORDER BY COUNT(*) DESC
LIMIT 1;

#Highest number of coupons

SELECT Gender, SUM(CouponUsed)
FROM customer_churn
GROUP BY Gender
ORDER BY SUM(CouponUsed) DESC
LIMIT 1;

#Number of Customers and the maximum hours spent

SELECT PreferredOrderCat, COUNT(*), MAX(HourSpendOnApp)
FROM customer_churn
GROUP BY PreferredOrderCat;

#Customers who prefer using credit cards

SELECT SUM(OrderCount)
FROM customer_churn
WHERE PreferredPaymentMode = 'Credit Card'
AND SatisfactionScore = 5;

#Average satisfaction score of customers

SELECT AVG(SatisfactionScore)
FROM customer_churn
WHERE ComplaintReceived = 'Yes';

#Customers who used more than 5 coupons

SELECT DISTINCT PreferredOrderCat
FROM customer_churn
WHERE CouponUsed > 5;

#Top 3 Preferred order categories

SELECT PreferredOrderCat, AVG(CashbackAmount)
FROM customer_churn
GROUP BY PreferredOrderCat
ORDER BY AVG(CashbackAmount) DESC
LIMIT 3;

#Preferred payment modes of customers

SELECT DISTINCT PreferredPaymentMode
FROM customer_churn
WHERE Tenure = 10
AND OrderCount > 500;

#Categorization Based on Distance

SELECT
    IF(WarehouseToHome <= 5, 'Very Close Distance',
    IF(WarehouseToHome <= 10, 'Close Distance',
    IF(WarehouseToHome <= 15, 'Moderate Distance',
    'Far Distance'))) AS DistanceCategory,
    ChurnStatus,
    COUNT(*)
FROM customer_churn
GROUP BY DistanceCategory, ChurnStatus;

#Customer’s order details who are married

SELECT *
FROM customer_churn
WHERE MaritalStatus = 'Married'
AND CityTier = 1
AND OrderCount > (SELECT AVG(OrderCount) FROM customer_churn);

#customer_returns

CREATE TABLE customer_returns (
    ReturnID INT PRIMARY KEY,
    CustomerID INT,
    ReturnDate DATE,
    RefundAmount INT
);
INSERT INTO customer_returns VALUES
(1001, 50022, '2023-01-01', 2130),
(1002, 50316, '2023-01-23', 2000),
(1003, 51099, '2023-02-14', 2290),
(1004, 52321, '2023-03-08', 2510),
(1005, 52928, '2023-03-20', 3000),
(1006, 53749, '2023-04-17', 1740),
(1007, 54206, '2023-04-21', 3250),
(1008, 54838, '2023-04-30', 1990);

SELECT * FROM customer_returns;

#Display return details along with customer details


SELECT *
FROM customer_returns r
INNER JOIN customer_churn c
ON r.CustomerID = c.CustomerID
WHERE c.ChurnStatus = 'Churned'
AND c.ComplaintReceived = 'Yes';