-- ==============================================================================
-- SOLUTIONS TO FUNCTIONAL REQUIREMENTS
-- Developer: i2i Systems Technical Candidate
-- Dataset Name: Telecom Data
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Tariff-Based Customer Queries
-- ------------------------------------------------------------------------------

-- 1.1 List the customers who are subscribed to the 'Kobiye Destek' tariff.
/* 
   Approach: 
   To find customers based on their tariff name, we need to bring together the CUSTOMERS and TARIFFS tables. 
   We achieve this by fully joining the CUSTOMERS table with the TARIFFS table on the foreign key TARIFF_ID. 
   Then, we apply a WHERE clause filter specifically targeting the exact string 'Kobiye Destek' inside the tariff name column.
*/
SELECT 
    c.CUSTOMER_ID, 
    c.NAME, 
    c.CITY 
FROM 
    CUSTOMERS c
JOIN 
    TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE 
    t.NAME = 'Kobiye Destek';

-- 1.2 Find the newest customer who subscribed to this tariff.
/* 
   Approach: 
   We need to determine the most recent specific customer associated with the 'Kobiye Destek' plan. 
   First, we retrieve customers joined with the tariff and then sort the result set in descending order by SIGNUP_DATE so the newest is at the top. 
   Finally, we wrap this sorted subset in an outer check to grab only the very first row utilizing the ROWNUM filter.
*/
SELECT * FROM (
    SELECT 
        c.CUSTOMER_ID, 
        c.NAME, 
        c.CITY, 
        c.SIGNUP_DATE 
    FROM 
        CUSTOMERS c
    JOIN 
        TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
    WHERE 
        t.NAME = 'Kobiye Destek'
    ORDER BY 
        c.SIGNUP_DATE DESC
) 
WHERE ROWNUM = 1;


-- ------------------------------------------------------------------------------
-- 2. Tariff Distribution
-- ------------------------------------------------------------------------------

-- 2.1 Find the distribution of tariffs among the customers.
/* 
   Approach: 
   Understanding the distribution of tariffs across the customer base requires grouping the data appropriately. 
   We perform a LEFT JOIN FROM SYS.TARIFFS to CUSTOMERS to ensure all tariffs are included, even those without active customers. 
   Then, we group by the tariff name and count the occurrences, ordering the final numbers in descending fashion for better perspective.
*/
SELECT 
    t.NAME AS TARIFF_NAME, 
    COUNT(c.CUSTOMER_ID) AS CUSTOMER_COUNT
FROM 
    TARIFFS t
LEFT JOIN 
    CUSTOMERS c ON t.TARIFF_ID = c.TARIFF_ID
GROUP BY 
    t.NAME
ORDER BY 
    CUSTOMER_COUNT DESC;


-- ------------------------------------------------------------------------------
-- 3. Customer Signup Analysis
-- ------------------------------------------------------------------------------

-- 3.1 Identify the earliest customers to sign up.
/* 
   Approach: 
   The lowest IDs do not reliably indicate the earliest registration timing, so we must rely purely on the SIGNUP_DATE explicitly. 
   To solve this, we compute the absolute minimum date existing in the overall CUSTOMERS table via a subquery. 
   Then, we return all customer records that perfectly match this exact minimum date.
*/
SELECT 
    CUSTOMER_ID, 
    NAME, 
    CITY, 
    SIGNUP_DATE 
FROM 
    CUSTOMERS
WHERE 
    SIGNUP_DATE = (SELECT MIN(SIGNUP_DATE) FROM SYS.CUSTOMERS);

-- 3.2 Find the distribution of these earliest customers across different cities, including the total count for each city.
/* 
   Approach: 
   Building upon the previous solution, we filter the customer base again just to match those who registered on the earliest possible date. 
   Once isolated, we introduce a GROUP BY clause to aggregate this historical subset specifically by their CITY values. 
   Finally, we count the distribution of these founding users and present the aggregate values ordered from highest to lowest block counts per city.
*/
SELECT 
    CITY, 
    COUNT(*) AS TOTAL_EARLIEST_CUSTOMERS
FROM 
    CUSTOMERS
WHERE 
    SIGNUP_DATE = (SELECT MIN(SIGNUP_DATE) FROM SYS.CUSTOMERS)
GROUP BY 
    CITY
ORDER BY 
    TOTAL_EARLIEST_CUSTOMERS DESC;


-- ------------------------------------------------------------------------------
-- 4. Missing Monthly Records
-- ------------------------------------------------------------------------------

-- 4.1 Identify the IDs of missing customers (customers without monthly records).
/* 
   Approach: 
   Finding customers with unlogged statistical data is a classic un-matched join problem. 
   By conducting a LEFT OUTER JOIN FROM SYS.CUSTOMERS onto MONTHLY_STATS using the CUSTOMER_ID, we obtain a full relationship hierarchy. 
   We then isolate the anomalies by heavily filtering the output solely to instances where the MONTHLY_STATS ID remains NULL.
*/
SELECT 
    c.CUSTOMER_ID 
FROM 
    CUSTOMERS c
LEFT JOIN 
    MONTHLY_STATS s ON c.CUSTOMER_ID = s.CUSTOMER_ID
WHERE 
    s.STAT_ID IS NULL;

-- 4.2 Find the distribution of these missing customers across different cities.
/* 
   Approach: 
   We use the exact same LEFT OUTER JOIN technique as above to target solely the un-recorded users. 
   Once we have correctly filtered the null instances, we add a GROUP BY configuration using the c.CITY property. 
   This yields a regional anomaly report, returning proper volume metric sums representing the scope of the missing metadata categorized per city.
*/
SELECT 
    c.CITY, 
    COUNT(*) AS MISSING_RECORDS_COUNT
FROM 
    CUSTOMERS c
LEFT JOIN 
    MONTHLY_STATS s ON c.CUSTOMER_ID = s.CUSTOMER_ID
WHERE 
    s.STAT_ID IS NULL
GROUP BY 
    c.CITY
ORDER BY 
    MISSING_RECORDS_COUNT DESC;


-- ------------------------------------------------------------------------------
-- 5. Usage Analysis
-- ------------------------------------------------------------------------------

-- 5.1 Find the customers who have used at least 75% of their data limit.
/* 
   Approach: 
   We evaluate user exhaustion rates by comparing current usage parameters within MONTHLY_STATS against max parameters inside TARIFFS. 
   We join CUSTOMERS, MONTHLY_STATS, and TARIFFS utilizing respective primary/foreign key connections. 
   Finally, we introduce checking math on the filtering boundary: ensuring the data usage values natively exist beyond or identical to 75% (.75) of the allocated data limits.
*/
SELECT 
    c.CUSTOMER_ID, 
    c.NAME,
    s.DATA_USAGE,
    t.DATA_LIMIT,
    t.NAME AS TARIFF_PLAN
FROM 
    CUSTOMERS c
JOIN 
    MONTHLY_STATS s ON c.CUSTOMER_ID = s.CUSTOMER_ID
JOIN 
    TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE 
    s.DATA_USAGE >= (t.DATA_LIMIT * 0.75);

-- 5.2 Identify the customers who have completely exhausted all of their package limits.
/* 
   Approach: 
   This query is structured similarly to identifying heavy data consumers above, executing a comprehensive 3-way join hierarchy. 
   Instead of checking a mere 75% math threshold limit exclusively for data usages, we check all metric thresholds simultaneously utilizing the 'AND' operator in SQL natively. 
   Specifically, we ensure DATA_USAGE, MINUTE_USAGE, and SMS_USAGE independently cross or match strictly equal to their respective ceiling configurations designated across TARIFF.
*/
SELECT 
    c.CUSTOMER_ID, 
    c.NAME, 
    s.DATA_USAGE, 
    s.MINUTE_USAGE, 
    s.SMS_USAGE
FROM 
    CUSTOMERS c
JOIN 
    MONTHLY_STATS s ON c.CUSTOMER_ID = s.CUSTOMER_ID
JOIN 
    TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE 
    s.DATA_USAGE >= t.DATA_LIMIT 
    AND s.MINUTE_USAGE >= t.MINUTE_LIMIT 
    AND s.SMS_USAGE >= t.SMS_LIMIT;


-- ------------------------------------------------------------------------------
-- 6. Payment Analysis
-- ------------------------------------------------------------------------------

-- 6.1 Find the customers who have unpaid fees.
/* 
   Approach: 
   To identify unrecovered revenue, we investigate the PAYMENT_STATUS directly recorded within statistical statements. 
   We join the CUSTOMERS catalog together with the MONTHLY_STATS catalog efficiently utilizing their shared CUSTOMER_ID parameter space. 
   Then, we filter out everything leaving only strings matching 'UNPAID' explicitly because it strictly constitutes unresolved pending balances.
*/
SELECT 
    c.CUSTOMER_ID, 
    c.NAME, 
    s.PAYMENT_STATUS 
FROM 
    CUSTOMERS c
JOIN 
    MONTHLY_STATS s ON c.CUSTOMER_ID = s.CUSTOMER_ID
WHERE 
    s.PAYMENT_STATUS = 'UNPAID';

-- 6.2 Find the distribution of all payment statuses across the different tariffs.
/* 
   Approach: 
   To build this composite volume overview, we connect the entire functional triad of databases (TARIFFS, CUSTOMERS, and MONTHLY_STATS). 
   To show accurate distribution scopes natively across varied statuses, we execute a grouping mechanism referencing both dimensions independently (Tariff Name and explicit status markers). 
   We order the output alphabetically by the main plan terminology and subsequently rank numeric counts recursively natively showing highest volume status profiles.
*/
SELECT 
    t.NAME AS TARIFF_NAME, 
    s.PAYMENT_STATUS, 
    COUNT(s.STAT_ID) AS STATUS_COUNT
FROM 
    TARIFFS t
JOIN 
    CUSTOMERS c ON t.TARIFF_ID = c.TARIFF_ID
JOIN 
    MONTHLY_STATS s ON c.CUSTOMER_ID = s.CUSTOMER_ID
GROUP BY 
    t.NAME, 
    s.PAYMENT_STATUS
ORDER BY 
    TARIFF_NAME ASC, 
    STATUS_COUNT DESC;
