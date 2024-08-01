use amazon_database;
SELECT * FROM AMAZON;

-- Feature Engineering

ALTER TABLE amazon
MODIFY Date DATE;

/* Add a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening.
This will help answer the question on which part of the day most sales are made*/
ALTER TABLE amazon
ADD COLUMN timeofday VARCHAR(10);
UPDATE amazon
SET timeofday = CASE
    WHEN HOUR(time) >= 0 AND HOUR(time) < 12 THEN 'Morning'
    WHEN HOUR(time) >= 12 AND HOUR(time) < 18 THEN 'Afternoon'
    ELSE 'Evening'
END;

/* Add a new column named dayname that contains the extracted days of the week on which the given 
transaction took place (Mon, Tue, Wed, Thur, Fri). 
This will help answer the question on which week of the day each branch is busiest.*/
ALTER TABLE amazon
ADD COLUMN dayname VARCHAR(10);
UPDATE amazon
SET dayname = DAYNAME(Date);

/* Add a new column named monthname that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar).
 Help determine which month of the year has the most sales and profit.  */
ALTER TABLE amazon
ADD COLUMN monthname VARCHAR(10);
UPDATE amazon
SET monthname = MONTHNAME(Date);


-- 1. What is the count of distinct cities in the dataset?
select count(DISTINCT(city)) as Distinct_Cities from amazon;

-- 2. For each branch, what is the corresponding city?
select distinct branch,city from amazon order by 1;

-- 3. What is the count of distinct product lines in the dataset?
SELECT COUNT(DISTINCT product_line) AS distinct_product_lines_count
FROM amazon;

-- 4. Which payment method occurs most frequently?
SELECT payment AS most_frequent_payment_method, COUNT(payment) AS total_count
FROM amazon
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 5. Which product line has the highest sales?
SELECT product_line, SUM(total) AS total_sales
FROM amazon
GROUP BY product_line
ORDER BY total_sales DESC
LIMIT 1;

-- 6. How much revenue is generated each month?
SELECT monthname, SUM(total) AS total_revenue
FROM amazon
GROUP BY monthname;

-- 7. In which month did the cost of goods sold reach its peak?
select monthname,  sum(cogs) as total_cogs from amazon group by monthname order by total_cogs desc limit 1; 

-- 8. Which product line generated the highest revenue?
SELECT Product_line, SUM(total) AS total_revenue
FROM amazon
GROUP BY Product_line
ORDER BY total_revenue DESC
LIMIT 1;

-- 9. In which city was the highest revenue recorded?
select city , sum(total) as total_revenue
from amazon
group by 1
order by  2 desc 
limit 1;

-- 10. Which product line incurred the highest Value Added Tax?
SELECT Product_line, SUM(VAT) AS Total_VAT
FROM amazon
GROUP BY Product_line
ORDER BY Total_VAT DESC
LIMIT 1;

-- 11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."

SELECT *,
    CASE 
        WHEN Total > avg_sales THEN 'Good'
        ELSE 'Bad'
    END AS Sales_Status
FROM (
    SELECT Product_line, 
           AVG(Total) AS avg_sales
    FROM amazon
    GROUP BY Product_line
) AS avg_table
JOIN amazon ON avg_table.Product_line = amazon.Product_line;


-- 12. Identify the branch that exceeded the average number of products sold.
SELECT Branch, AVG(Quantity) AS Average_Products_Sold
FROM amazon
GROUP BY Branch;

SELECT Branch
FROM (
    SELECT Branch, AVG(Quantity) AS Average_Products_Sold
    FROM amazon
    GROUP BY Branch
) AS avg_table
WHERE Average_Products_Sold > (SELECT AVG(Quantity) FROM amazon);

-- 13. Which product line is most frequently associated with each gender?
SELECT Gender, Product_line, COUNT(*) AS Frequency
FROM amazon
GROUP BY Gender, Product_line
ORDER BY Gender, Frequency DESC

-- 14. Calculate the average rating for each product line.
SELECT Product_line, AVG(Rating) AS Average_Rating
FROM amazon
GROUP BY Product_line;

-- 15. Count the sales occurrences for each time of day on every weekday.

SELECT 
    CASE 
        WHEN HOUR(Time) >= 6 AND HOUR(Time) < 12 THEN 'Morning'
        WHEN HOUR(Time) >= 12 AND HOUR(Time) < 18 THEN 'Afternoon'
        ELSE 'Evening'
    END AS Time_of_Day,
    DAYNAME(Date) AS Weekday,
    COUNT(*) AS Sales_Occurrences
FROM 
    amazon
GROUP BY 
    Time_of_Day, Weekday
ORDER BY 
    Weekday, FIELD(Time_of_Day, 'Morning', 'Afternoon', 'Evening');

-- 16. Identify the customer type contributing the highest revenue.

SELECT Customer_type, SUM(Total) AS Total_Revenue
FROM amazon
GROUP BY Customer_type
ORDER BY Total_Revenue DESC
LIMIT 1;

-- 17. Determine the city with the highest VAT percentage.

SELECT City, 
       (SUM(VAT) / SUM(Total)) * 100 AS VAT_Percentage
FROM amazon
GROUP BY City
ORDER BY VAT_Percentage DESC
LIMIT 1;

-- 18. Identify the customer type with the highest VAT payments.

SELECT Customer_type, SUM(VAT) AS Total_VAT_Payments
FROM amazon
GROUP BY Customer_type
ORDER BY Total_VAT_Payments DESC
LIMIT 1;

-- 19. What is the count of distinct customer types in the dataset?

SELECT COUNT(DISTINCT Customer_type) AS Distinct_Customer_Types
FROM amazon;

-- 20. What is the count of distinct payment methods in the dataset?

SELECT COUNT(DISTINCT Payment) AS Distinct_Payment_Methods
FROM amazon;

-- 21. Which customer type occurs most frequently?

SELECT Customer_type, COUNT(*) AS Frequency
FROM amazon
GROUP BY Customer_type
ORDER BY Frequency DESC
LIMIT 1;

-- 22. Identify the customer type with the highest purchase frequency.
SELECT Customer_type, COUNT(*) AS Purchase_Frequency
FROM amazon
GROUP BY Customer_type
ORDER BY Purchase_Frequency DESC
LIMIT 1;

-- 23. Determine the predominant gender among customers.

SELECT Gender, COUNT(*) AS Gender_Count
FROM amazon
WHERE Gender IS NOT NULL
GROUP BY Gender
ORDER BY Gender_Count DESC
LIMIT 1;

-- 24. Examine the distribution of genders within each branch.

SELECT Branch, Gender, COUNT(*) AS Gender_Count
FROM amazon
WHERE Gender IS NOT NULL
GROUP BY Branch, Gender
ORDER BY Branch, Gender_Count DESC;

-- 25. Identify the time of day when customers provide the most ratings.

SELECT TIME_FORMAT(Time, '%H:%i') AS Time_of_Day, COUNT(*) AS Rating_Count
FROM amazon
WHERE Rating IS NOT NULL
GROUP BY Time_of_Day
ORDER BY Rating_Count DESC
LIMIT 1;

-- 26. Determine the time of day with the highest customer ratings for each branch.

SELECT Branch, 
       TIME_FORMAT(Time, '%H:%i') AS Time_of_Day, 
       COUNT(*) AS Rating_Count
FROM amazon
WHERE Rating IS NOT NULL
GROUP BY Branch, Time_of_Day
ORDER BY Branch, Rating_Count DESC;

-- 27.Identify the day of the week with the highest average ratings.


SELECT DAYNAME(Date) AS Day_of_Week, AVG(Rating) AS Average_Rating
FROM amazon
WHERE Rating IS NOT NULL
GROUP BY Day_of_Week
ORDER BY Average_Rating DESC
LIMIT 1;

-- 28.Determine the day of the week with the highest average ratings for each branch.

SELECT Branch, 
       DAYNAME(Date) AS Day_of_Week, 
       AVG(Rating) AS Average_Rating
FROM amazon
WHERE Rating IS NOT NULL
GROUP BY Branch, Day_of_Week
ORDER BY Branch, Average_Rating DESC ;


























