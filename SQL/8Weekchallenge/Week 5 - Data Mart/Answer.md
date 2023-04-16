### **1. Data Cleansing Steps**

*Answer:*
```sql
DROP TABLE IF EXISTS clean_weekly_sales;
CREATE TEMP TABLE clean_weekly_sales AS 
(SELECT
  TO_DATE(week_date, 'DD/MM/YY') AS week_date,
  DATE_PART('week', TO_DATE(week_date, 'DD/MM/YY')) AS week_number,
  DATE_PART('month', TO_DATE(week_date, 'DD/MM/YY')) AS month_number,
  DATE_PART('year', TO_DATE(week_date, 'DD/MM/YY')) AS calendar,
  region,
  platform,
  REPLACE (segment, 'null' , 'Unknown') segment,
  CASE WHEN SUBSTRING (segment, 2,1) ='1' THEN 'Young Adults' 
       WHEN SUBSTRING (segment, 2,1) ='2' THEN 'Middle Aged'
       WHEN SUBSTRING (segment, 2,1) IN ('3', '4') THEN 'Retired'
       ELSE 'Unknown' 
  END AS age_band,
  CASE WHEN SUBSTRING (segment, 1,1) ='C' THEN 'Couples' 
       WHEN SUBSTRING (segment, 1,1) ='F' THEN 'Families' 
       ELSE 'Unknown' 
  END AS demographic,
  customer_type,
  transactions,
  sales,
  round (sales/nullif(transactions,0) , 2) avg_transaction
FROM data_mart.weekly_sales);
```

*Result:*
| week_date                | week_number | month_number | calendar | region        | platform | segment | age_band     | demographic | customer_type | transactions | sales    | avg_transaction |
| ------------------------ | ----------- | ------------ | -------- | ------------- | -------- | ------- | ------------ | ----------- | ------------- | ------------ | -------- | --------------- |
| 2020-08-31T00:00:00.000Z | 36          | 8            | 2020     | ASIA          | Retail   | C3      | Retired      | Couples     | New           | 120631       | 3656163  | 30.00           |
| 2020-08-31T00:00:00.000Z | 36          | 8            | 2020     | ASIA          | Retail   | F1      | Young Adults | Families    | New           | 31574        | 996575   | 31.00           |
| 2020-08-31T00:00:00.000Z | 36          | 8            | 2020     | USA           | Retail   | Unknown | Unknown      | Unknown     | Guest         | 529151       | 16509610 | 31.00           |
| 2020-08-31T00:00:00.000Z | 36          | 8            | 2020     | EUROPE        | Retail   | C1      | Young Adults | Couples     | New           | 4517         | 141942   | 31.00           |
| 2020-08-31T00:00:00.000Z | 36          | 8            | 2020     | AFRICA        | Retail   | C2      | Middle Aged  | Couples     | New           | 58046        | 1758388  | 30.00           |
| 2020-08-31T00:00:00.000Z | 36          | 8            | 2020     | CANADA        | Shopify  | F2      | Middle Aged  | Families    | Existing      | 1336         | 243878   | 182.00          |
| 2020-08-31T00:00:00.000Z | 36          | 8            | 2020     | AFRICA        | Shopify  | F3      | Retired      | Families    | Existing      | 2514         | 519502   | 206.00          |
| 2020-08-31T00:00:00.000Z | 36          | 8            | 2020     | ASIA          | Shopify  | F1      | Young Adults | Families    | Existing      | 2158         | 371417   | 172.00          |
| 2020-08-31T00:00:00.000Z | 36          | 8            | 2020     | AFRICA        | Shopify  | F2      | Middle Aged  | Families    | New           | 318          | 49557    | 155.00          |
| 2020-08-31T00:00:00.000Z | 36          | 8            | 2020     | AFRICA        | Retail   | C3      | Retired      | Couples     | New           | 111032       | 3888162  | 35.00           |
| 2020-08-31T00:00:00.000Z | 36          | 8            | 2020     | USA           | Shopify  | F1      | Young Adults | Families    | Existing      | 1398         | 260773   | 186.00          |
| 2020-08-31T00:00:00.000Z | 36          | 8            | 2020     | OCEANIA       | Shopify  | C2      | Middle Aged  | Couples     | Existing      | 4661         | 882690   | 189.00          |

*Approach:*
* Use `To_date` to convert data type
* Use `Date_part` to get the **week**, **month** and **year** form date
* Use `CASE WHEN` and `Substring` to add column **age_band** and **demographic** 
* Use `Replace` to replace **'null'** text with **'unknown'**
***
**1. What day of the week is used for each week_date value?**

*Answer:*
```sql
SELECT 
    distinct (to_char (week_date, 'Day'))
FROM
    clean_weekly_sales;
```

*Result:*
| to_char   |
| --------- |
| Monday    |

*Approach:*
Use `To_char` to get day of week element from date.

**2. What range of week numbers are missing from the dataset?**

*Answer:*
```sql
WITH week_table as (
    SELECT 
        GENERATE_SERIES(1,52) AS week_number)

SELECT 
    week_number
FROM 
    week_table
WHERE 
    week_number NOT IN (SELECT distinct (week_number) FROM clean_weekly_sales);
```

*Result:*

| week_number |
| ----------- |
| 1           |
| 2           |
| 3           |
| 4           |
| 5           |
| 6           |
| 7           |
| 8           |
| 9           |
| 10          |
| 11          |
| 12          |
| 37          |
| 38          |
| 39          |
| 40          |
| 41          |
| 42          |
| 43          |
| 44          |
| 45          |
| 46          |
| 47          |
| 48          |
| 49          |
| 50          |
| 51          |
| 52          |
***

**3. How many total transactions were there for each year in the dataset?**

*Answer:*
```sql
SELECT 
    calendar,
    sum (transactions) as transactions
FROM
    clean_weekly_sales
GROUP BY 1 
ORDER BY 1;
```

*Result:*
| calendar | transactions |
| -------- | ------------ |
| 2018     | 346406460    |
| 2019     | 365639285    |
| 2020     | 375813651    |
***
**4. What is the total sales for each region for each month?**

*Answer:*
```sql
SELECT 
    region,
    month_number,
    sum (sales) as total_sales
FROM
    clean_weekly_sales
GROUP BY 1,2 
ORDER BY 1,2;
```

*Result:*

| region        | month_number | total_sales |
| ------------- | ------------ | ----------- |
| AFRICA        | 3            | 567767480   |
| AFRICA        | 4            | 1911783504  |
| AFRICA        | 5            | 1647244738  |
| AFRICA        | 6            | 1767559760  |
| AFRICA        | 7            | 1960219710  |
| AFRICA        | 8            | 1809596890  |
| AFRICA        | 9            | 276320987   |
| ASIA          | 3            | 529770793   |
| ASIA          | 4            | 1804628707  |
| ASIA          | 5            | 1526285399  |
| ASIA          | 6            | 1619482889  |
| ASIA          | 7            | 1768844756  |
| ASIA          | 8            | 1663320609  |
| ASIA          | 9            | 252836807   |
***
**5. What is the total count of transactions for each platform**

*Answer:*
```sql
SELECT 
    platform,
    sum (transactions) as transactions_count
FROM
    clean_weekly_sales
GROUP BY 1 
ORDER BY 1,2;
```

*Result:*

| platform | transactions_count |
| -------- | ------------------ |
| Retail   | 1081934227         |
| Shopify  | 5925169            |
***
**6. What is the percentage of sales for Retail vs Shopify for each month?**

*Answer:*
```sql
with cte_6 as(
SELECT 
    month_number,
    sum(CASE WHEN platform = 'Retail' THEN sales ELSE 0 END) AS Retail_sales ,
    sum(CASE WHEN platform = 'Shopify' THEN sales ELSE 0 END) AS Shopify_sales,
    sum (sales) sales
FROM
    clean_weekly_sales
GROUP BY 1 
ORDER BY 1,2)

SELECT 
    month_number,
    round(100*retail_sales/sales,2) as retails_sales_pct,
    round(100*shopify_sales/sales,2) as shopify_sales_pct
FROM cte_6
ORDER BY 1;
```

*Result:*
| month_number | retails_sales_pct | shopify_sales_pct |
| ------------ | ----------------- | ----------------- |
| 3            | 97.00             | 2.00              |
| 4            | 97.00             | 2.00              |
| 5            | 97.00             | 2.00              |
| 6            | 97.00             | 2.00              |
| 7            | 97.00             | 2.00              |
| 8            | 97.00             | 2.00              |
| 9            | 97.00             | 2.00              |

*Approach:*
Use `CASE WHEN` to create column for retail and shopify sales and then calculate percentage
***

**7. What is the percentage of sales by demographic for each year in the dataset?**

*Answer:*
```sql
with cte_7 as(
SELECT 
    calendar,
    sum(CASE WHEN demographic = 'Couples' THEN sales ELSE 0 END) AS Couples_sales ,
    sum(CASE WHEN demographic = 'Families' THEN sales ELSE 0 END) AS Families_sales,
    sum (sales) sales
FROM
    clean_weekly_sales
GROUP BY 1 
ORDER BY 1,2)

SELECT 
    calendar,
    round(100*Couples_sales/sales,2) as Couples_sales_pct,
    round(100*Families_sales/sales,2) as Families_sales_pct
FROM cte_7
ORDER BY 1;
```

*Result:*
| calendar | couples_sales_pct | families_sales_pct |
| -------- | ----------------- | ------------------ |
| 2018     | 26.00             | 31.00              |
| 2019     | 27.00             | 32.00              |
| 2020     | 28.00             | 32.00              |

*Approach:* Similiar to question 7, replace month by year, platform by demographic

**8.  Which age_band and demographic values contribute the most to Retail sales?**

*Answer:*
```sql
SELECT 
    age_band,
    demographic,
    sum(sales) sales,
    100 * sum(sales) / (SELECT sum(sales) FROM clean_weekly_sales WHERE platform = 'Retail') as contribution
FROM
    clean_weekly_sales
WHERE platform = 'Retail'     
GROUP BY 1, 2
ORDER BY 4 DESC;    
```

*Result:*
| age_band     | demographic | sales       | contribution |
| ------------ | ----------- | ----------- | ------------ |
| Unknown      | Unknown     | 16067285533 | 40           |
| Retired      | Couples     | 6370580014  | 16           |
| Retired      | Families    | 6634686916  | 16           |
| Middle Aged  | Families    | 4354091554  | 10           |
| Young Adults | Couples     | 2602922797  | 6            |
| Middle Aged  | Couples     | 1854160330  | 4            |
| Young Adults | Families    | 1770889293  | 4            |
***

**9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?**

*Answer:*
We can not use the avg_transaction because this column is the average transaction for each rows.
```sql
SELECT 
  calendar, 
  platform, 
  SUM(sales) / sum(transactions) AS avg_transaction
FROM clean_weekly_sales
GROUP BY 1, 2
ORDER BY 1, 2;
```

*Result:*

| calendar | platform | avg_transaction |
| -------- | -------- | --------------- |
| 2018     | Retail   | 36              |
| 2018     | Shopify  | 192             |
| 2019     | Retail   | 36              |
| 2019     | Shopify  | 183             |
| 2020     | Retail   | 36              |
| 2020     | Shopify  | 179             |
