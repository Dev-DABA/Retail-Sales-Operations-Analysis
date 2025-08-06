use supermarket;
select * from sales;
DESCRIBE Sales;
ALTER TABLE Sales 
ADD COLUMN order_date_clean DATE,
ADD COLUMN ship_date_clean DATE;

UPDATE Sales
SET 
  order_date_clean = CASE
    WHEN `Order Date` LIKE '%/%/%' THEN STR_TO_DATE(`Order Date`, '%m/%d/%Y')
    WHEN `Order Date` LIKE '%-%-%' AND LENGTH(`Order Date`) = 10 THEN STR_TO_DATE(`Order Date`, '%d-%m-%Y')
    WHEN `Order Date` LIKE '%-%-%' AND LENGTH(`Order Date`) = 8 THEN STR_TO_DATE(`Order Date`, '%d-%m-%y')
    ELSE NULL
  END,
  
  ship_date_clean = CASE
    WHEN `Ship Date` LIKE '%/%/%' THEN STR_TO_DATE(`Ship Date`, '%m/%d/%Y')
    WHEN `Ship Date` LIKE '%-%-%' AND LENGTH(`Ship Date`) = 10 THEN STR_TO_DATE(`Ship Date`, '%d-%m-%Y')
    WHEN `Ship Date` LIKE '%-%-%' AND LENGTH(`Ship Date`) = 8 THEN STR_TO_DATE(`Ship Date`, '%d-%m-%y')
    ELSE NULL
  END;
ALTER TABLE Sales 
DROP COLUMN `Order Date`, 
DROP COLUMN `Ship Date`;

ALTER TABLE Sales 
RENAME COLUMN order_date_clean TO `Order Date`, 
RENAME COLUMN ship_date_clean TO `Ship Date`;

ALTER TABLE Sales 
DROP COLUMN `MyUnknownColumn`, 
DROP COLUMN `MyUnknownColumn_[0]`;

SELECT `Product Name`, 
ROUND(SUM(Sales), 0) AS Total_Sales
FROM Sales
GROUP BY `Product Name`
ORDER BY Total_Sales DESC
LIMIT 10;

SELECT 
  Region,
  ROUND(AVG(DATEDIFF(`Ship Date`, `Order Date`)), 2) AS Avg_Shipping_Delay
FROM Sales
WHERE `Ship Date` IS NOT NULL AND `Order Date` IS NOT NULL
GROUP BY Region
ORDER BY Avg_Shipping_Delay DESC;

SELECT * FROM Sales
WHERE 
  DATEDIFF(`Ship Date`, `Order Date`) > 5
  AND `Return Status` = 'Yes';
  
  SELECT 
  DATE_FORMAT(`Order Date`, '%Y-%m') AS Order_Month,
  ROUND(SUM(Sales), 2) AS Total_Sales,
  ROUND(SUM(Profit), 2) AS Total_Profit
FROM Sales
WHERE `Order Date` IS NOT NULL
GROUP BY Order_Month
ORDER BY Order_Month;

SELECT 
  `Segment` AS Customer_Segment,
  ROUND(SUM(Sales), 2) AS Total_Sales,
  ROUND(SUM(Profit), 2) AS Total_Profit
FROM Sales
GROUP BY `Segment`
ORDER BY Total_Sales DESC;


(
  SELECT `Sub-Category`, 
   ROUND(SUM(`Profit`), 2) AS Total_Profit
  FROM Sales
   WHERE `Profit` IS NOT NULL
  GROUP BY `Sub-Category`
  ORDER BY Total_Profit DESC
  LIMIT 1
)
(
  SELECT `Sub-Category`, 
    ROUND(SUM(`Profit`), 2) AS Total_Profit
  FROM Sales
  WHERE `Profit` IS NOT NULL
  GROUP BY `Sub-Category`
  ORDER BY Total_Profit ASC
  LIMIT 1
);

WITH Cleaned_Profit AS (
  SELECT 
    `Sub-Category`, 
    CAST(TRIM(`Profit`) AS DECIMAL(10, 2)) AS Profit_Cleaned
  FROM Sales
  WHERE TRIM(`Profit`) REGEXP '^-?[0-9]+(\.[0-9]+)?$'
)
(
  SELECT `Sub-Category`, SUM(Profit_Cleaned) AS Total_Profit
  FROM Cleaned_Profit
  GROUP BY `Sub-Category`
  ORDER BY Total_Profit DESC
  LIMIT 1
)
UNION ALL
(
  SELECT `Sub-Category`, SUM(Profit_Cleaned) AS Total_Profit
  FROM Cleaned_Profit
  GROUP BY `Sub-Category`
  ORDER BY Total_Profit ASC
  LIMIT 1
);

SELECT 
  Category,
  COUNT(*) AS Total_Orders,
  SUM(CASE WHEN `Return Status` = 'Yes' THEN 1 ELSE 0 END) AS Returned_Orders,
  ROUND((SUM(CASE WHEN `Return Status` = 'Yes' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS Return_Rate_Percentage
FROM Sales
GROUP BY Category
ORDER BY Return_Rate_Percentage DESC;

SELECT * FROM Sales
WHERE 
  CAST(Profit AS DECIMAL(10,2)) < 0
  AND CAST(Discount AS DECIMAL(5,2)) > 0.30;

SELECT 
  CASE 
    WHEN Discount >= 0.4 THEN 'Clearance'
    WHEN Discount >= 0.2 THEN 'Seasonal Promo'
    WHEN Discount > 0 THEN 'Minor Discount'
    ELSE 'No Discount'
  END AS Discount_Reason,
  ROUND(SUM(CAST(Sales AS DECIMAL(10,2))), 2) AS Total_Sales,
  SUM(CASE 
        WHEN LOWER(TRIM(`Return Status`)) = 'yes' THEN 1 
        ELSE 0 
      END) AS Total_Returns
FROM Sales
GROUP BY Discount_Reason
ORDER BY Total_Returns DESC;

SELECT 
  CASE 
    WHEN `Return Status` = 'Yes' THEN 'Returned'
    ELSE 'Not Returned'
  END AS Return_Category,
  ROUND(AVG(CAST(Sales AS DECIMAL(10,2))), 2) AS Avg_Sales
FROM Sales
WHERE Sales IS NOT NULL
GROUP BY Return_Category;

SELECT 
  State,
  ROUND(SUM(CAST(Sales AS DECIMAL(10,2))), 2) AS Total_Sales,
  ROUND(SUM(CAST(Profit AS DECIMAL(10,2))), 2) AS Total_Profit,
  COUNT(`Order ID`) AS Number_of_Orders
FROM Sales
GROUP BY State
HAVING SUM(CAST(Sales AS DECIMAL(10,2))) > 400000
ORDER BY Total_Sales DESC;

SELECT 
  COUNT(*) AS Customers_With_More_Than_5_Orders
FROM (
  SELECT 
    `Customer ID`,
    COUNT(`Order ID`) AS Order_Count
  FROM Sales
  GROUP BY `Customer ID`
  HAVING COUNT(`Order ID`) > 5
) AS sub;

SELECT 
  `Customer Name`,
  COUNT(DISTINCT `Order ID`) AS Total_Orders,
  ROUND(SUM(Sales), 2) AS Total_Sales
FROM Sales
GROUP BY `Customer Name`
ORDER BY Total_Sales DESC;

SELECT 
  Category,
  COUNT(DISTINCT `Product Name`) AS Unique_Products_Sold
FROM Sales
GROUP BY Category
ORDER BY Unique_Products_Sold DESC;

SELECT Region, Segment,
  ROUND(AVG(Discount) * 100, 2) AS Average_Discount_Percentage
FROM Sales
GROUP BY Region, Segment
ORDER BY Region, Segment;

SELECT * FROM Sales
WHERE 
  `Order Date` >= '2015-01-01'
  AND Sales > 200
  AND Segment IN ('Consumer', 'Corporate')
  AND Region IN ('East', 'South', 'Central')
  AND (
    `Return Status` = 'Yes' OR       
    Profit < 0 OR                    
    Discount >= 0.2                
  );


Select * From sales;