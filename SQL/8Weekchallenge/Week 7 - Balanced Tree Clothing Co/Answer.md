### **1. High Level Sales Analysis**

**1. What was the total quantity sold for all products?**

**2. What is the total generated revenue for all products before discounts?**

**3. What was the total discount amount for all products?**

*Answer:*
```sql
SELECT
	sum(qty) as total_quantity,
    sum(qty*price) as rvn_before_discount,
    ROUND (sum(discount)) as total_discount
FROM
	balanced_tree.sales; 
```

*Result:*
| total_quantity | rvn_before_discount |total_discount|	
| ------------------- | -------------- | -------------- |
| 45216            | 1289453        |182700    |
***

### **2. Transaction Analysis**
**1. How many unique transactions were there?**

*Answer:*
```sql
SELECT
	count (distinct (txn_id)) unique_txn
FROM
	balanced_tree.sales;
```
*Result:*
| unique_txn |
| ---------- |
| 2500       |
***
**2. What is the average unique products purchased in each transaction?**

*Answer:*
```sql
SELECT
	txn_id,
    count (distinct prod_id) unique_products
FROM
	balanced_tree.sales
GROUP BY 1
LIMIT 10;
```

*Result:*
| txn_id | unique_products |
| ------ | --------------- |
| 000027 | 7               |
| 000106 | 6               |
| 000dd8 | 6               |
| 003920 | 6               |
| 003c6d | 7               |
| 003ea6 | 4               |
| 0053d3 | 5               |
| 00a68b | 7               |
| 00c8dc | 7               |
| 00d139 | 6               |
***
**3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?**

*Answer:*
```sql
WITH CTE AS (
SELECT
	txn_id,
    sum (qty*price) revenue
FROM
	balanced_tree.sales
GROUP BY 1)

SELECT
	percentile_cont(0.25) within group (order by revenue asc) as percentile_25,
    percentile_cont(0.50) within group (order by revenue asc) as percentile_50,
    percentile_cont(0.75) within group (order by revenue asc) as percentile_75
FROM CTE;
```

*Result:*
| percentile_25 | percentile_50 | percentile_75 |
| ------------- | ------------- | ------------- |
| 375.75        | 509.5         | 647           |

*Approach:* Use `percentile_cont` and `within group` to calculate percentile
***
**4. What is the average discount value per transaction?**

*Answer:*
```sql
SELECT
    sum (discount) / count (distinct txn_id) avg_discount
FROM
	balanced_tree.sales;
```

*Result:*
| avg_discount |
| ------------ |
| 73           |
***
**5. What is the percentage split of all transactions for members vs non-members?**

*Answer:*
```sql
SELECT
	member,
    count (distinct txn_id) as transactions,
    round (100 * count(distinct txn_id)::numeric / (SELECT count (distinct txn_id) FROM balanced_tree.sales),2) percentage
FROM
	balanced_tree.sales
GROUP BY 1;
```

*Result:*
| member | transactions | percentage |
| ------ | ------------ | ---------- |
| false  | 995          | 39.80      |
| true   | 1505         | 60.20      |
***
**6. What is the average revenue for member transactions and non-member transactions?**

*Answer:*
```sql
SELECT
	member,
    sum(qty*price) revenue,
    round (100 * sum(qty*price)::numeric / (SELECT sum(qty*price) FROM balanced_tree.sales),2) percentage
FROM
	balanced_tree.sales
GROUP BY 1
```

*Result:*
| member | revenue | percentage |
| ------ | ------- | ---------- |
| false  | 512469  | 39.74      |
| true   | 776984  | 60.26      |
***
### **3. Product Analysis**
**1. What are the top 3 products by total revenue before discount?**

*Answer:*
```sql
SELECT
	pd.product_name,
    sum (s.qty*s.price) revenue
FROM
	balanced_tree.product_details pd
JOIN
	balanced_tree.sales s     
ON s.prod_id = pd.product_id    
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;
```

*Result:*
| product_name                 | revenue |
| ---------------------------- | ------- |
| Blue Polo Shirt - Mens       | 217683  |
| Grey Fashion Jacket - Womens | 209304  |
| White Tee Shirt - Mens       | 152000  |
***
**2. What is the total quantity, revenue and discount for each segment?**

*Answer:*
```sql
SELECT
	pd.segment_name,
    sum(s.qty) as total_quantity,
    sum(s.qty*s.price) as revenue,
    sum(s.discount) as total_discount
FROM
	balanced_tree.sales s
JOIN
	balanced_tree.product_details pd
ON s.prod_id = pd.product_id
GROUP BY 1
ORDER BY 3 DESC;
```

*Result:*
| segment_name | total_quantity | revenue | total_discount |
| ------------ | -------------- | ------- | -------------- |
| Shirt        | 11265          | 406143  | 46043          |
| Jacket       | 11385          | 366983  | 45452          |
| Socks        | 11217          | 307977  | 45465          |
| Jeans        | 11349          | 208350  | 45740          |
***
**3. What is the top selling product for each segment?**

*Answer:*
```sql
WITH CTE_3 AS (
SELECT
	pd.segment_name,
    pd.product_name,
    sum(s.qty) as total_quantity,
    rank () OVER (PARTITION BY pd.segment_name ORDER BY sum(s.qty) DESC) ranks
FROM
	balanced_tree.sales s
JOIN
	balanced_tree.product_details pd
ON s.prod_id = pd.product_id
GROUP BY 1, 2
ORDER BY 1, 2 DESC)

SELECT *
FROM CTE_3
WHERE ranks = 1;
```

*Result:*
| segment_name | product_name                  | total_quantity | ranks |
| ------------ | ----------------------------- | -------------- | ----- |
| Jacket       | Grey Fashion Jacket - Womens  | 3876           | 1     |
| Jeans        | Navy Oversized Jeans - Womens | 3856           | 1     |
| Shirt        | Blue Polo Shirt - Mens        | 3819           | 1     |
| Socks        | Navy Solid Socks - Mens       | 3792           | 1     |

*Approach:* Use rank() window function to ranking product base on their quantity.
***

**4. What is the total quantity, revenue and discount for each category?**

*Answer:*
```sql
SELECT
	pd.category_name,
    sum(s.qty) as total_quantity,
    sum(s.qty*s.price) as revenue,
    sum(s.discount) as total_discount
FROM
	balanced_tree.sales s
JOIN
	balanced_tree.product_details pd
ON s.prod_id = pd.product_id
GROUP BY 1
ORDER BY 3 DESC;
```

*Result:*
| category_name | total_quantity | revenue | total_discount |
| ------------- | -------------- | ------- | -------------- |
| Mens          | 22482          | 714120  | 91508          |
| Womens        | 22734          | 575333  | 91192          |
***
**5. What is the top selling product for each category?**
*Answer:*
```sql
WITH CTE_5 AS (
SELECT
	pd.category_name,
    pd.product_name,
    sum(s.qty) as total_quantity,
    rank () OVER (PARTITION BY pd.category_name ORDER BY sum(s.qty) DESC) ranks
FROM
	balanced_tree.sales s
JOIN
	balanced_tree.product_details pd
ON s.prod_id = pd.product_id
GROUP BY 1, 2
ORDER BY 1, 2 DESC)

SELECT *
FROM CTE_5
WHERE ranks = 1;
```

*Result:*
| category_name | product_name                 | total_quantity | ranks |
| ------------- | ---------------------------- | -------------- | ----- |
| Mens          | Blue Polo Shirt - Mens       | 3819           | 1     |
| Womens        | Grey Fashion Jacket - Womens | 3876           | 1     |

*Approach:* Similiar to question 3 but we use partition by `category_name` instead.
***
**6. What is the percentage split of revenue by product for each segment?**

*Answer:*
```sql
with cte_6 as (

SELECT
	pd.segment_name,
    pd.product_name,
    sum(s.qty*s.price) as revenue
FROM
	balanced_tree.sales s
JOIN
	balanced_tree.product_details pd
ON s.prod_id = pd.product_id
GROUP BY 1, 2)

SELECT
	*,
    sum(revenue) OVER (PARTITION BY segment_name) segment_revenue,
    ROUND (100 * revenue::numeric / sum (revenue) OVER (PARTITION BY segment_name),2) as pct
FROM
	cte_6
ORDER BY 1, 5 DESC;    
```

*Result:*
| segment_name | product_name                     | revenue | segment_revenue | pct   |
| ------------ | -------------------------------- | ------- | --------------- | ----- |
| Jacket       | Grey Fashion Jacket - Womens     | 209304  | 366983          | 57.03 |
| Jacket       | Khaki Suit Jacket - Womens       | 86296   | 366983          | 23.51 |
| Jacket       | Indigo Rain Jacket - Womens      | 71383   | 366983          | 19.45 |
| Jeans        | Black Straight Jeans - Womens    | 121152  | 208350          | 58.15 |
| Jeans        | Navy Oversized Jeans - Womens    | 50128   | 208350          | 24.06 |
| Jeans        | Cream Relaxed Jeans - Womens     | 37070   | 208350          | 17.79 |
| Shirt        | Blue Polo Shirt - Mens           | 217683  | 406143          | 53.60 |
| Shirt        | White Tee Shirt - Mens           | 152000  | 406143          | 37.43 |
| Shirt        | Teal Button Up Shirt - Mens      | 36460   | 406143          | 8.98  |
| Socks        | Navy Solid Socks - Mens          | 136512  | 307977          | 44.33 |
| Socks        | Pink Fluro Polkadot Socks - Mens | 109330  | 307977          | 35.50 |
| Socks        | White Striped Socks - Mens       | 62135   | 307977          | 20.18 |
***
**7. What is the percentage split of revenue by segment for each category?**

*Answer:*
```sql
with cte_7 as (

SELECT
	pd.category_name,
    pd.segment_name,
    sum(s.qty*s.price) as revenue
FROM
	balanced_tree.sales s
JOIN
	balanced_tree.product_details pd
ON s.prod_id = pd.product_id
GROUP BY 1, 2)

SELECT
	*,
    sum(revenue) OVER (PARTITION BY category_name) category_revenue,
    ROUND (100 * revenue::numeric / sum (revenue) OVER (PARTITION BY category_name),2) as pct
FROM
	cte_7
ORDER BY 1, 5 DESC;
```

*Result:*
| category_name | segment_name | revenue | category_revenue | pct   |
| ------------- | ------------ | ------- | ---------------- | ----- |
| Mens          | Shirt        | 406143  | 714120           | 56.87 |
| Mens          | Socks        | 307977  | 714120           | 43.13 |
| Womens        | Jacket       | 366983  | 575333           | 63.79 |
| Womens        | Jeans        | 208350  | 575333           | 36.21 |
***
**8. What is the percentage split of total revenue by category?**

*Answer:*
```sql
SELECT
	pd.category_name,
    sum(s.qty*s.price) as revenue,
    round (100 * sum(s.qty*s.price)::numeric / (SELECT sum(qty*price) FROM balanced_tree.sales), 2) pct
FROM
	balanced_tree.sales s
JOIN
	balanced_tree.product_details pd
ON s.prod_id = pd.product_id
GROUP BY 1;
```

*Result:*

| category_name | revenue | pct   |
| ------------- | ------- | ----- |
| Mens          | 714120  | 55.38 |
| Womens        | 575333  | 44.62 |
***
**9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)**

*Answer:*
```sql
SELECT
	prod_id,
    round (100 * count (*)::numeric / (SELECT count (distinct txn_id) FROM balanced_tree.sales),2) as penetration
FROM
	balanced_tree.sales
GROUP BY 1
ORDER BY 2 DESC;
```

*Result:*
| prod_id | penetration |
| ------- | ----------- |
| f084eb  | 51.24       |
| 9ec847  | 51.00       |
| c4a632  | 50.96       |
| 5d267b  | 50.72       |
| 2a2353  | 50.72       |
| 2feb6b  | 50.32       |
| 72f5d4  | 50.00       |
| d5e9a6  | 49.88       |
| e83aa3  | 49.84       |
| e31d39  | 49.72       |
| b9a74d  | 49.72       |
| c8d436  | 49.68       |
***
**10.What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?**

*Answer:*
```sql
with 
products AS(
    SELECT
    	txn_id,
        product_name
  	FROM
        balanced_tree.sales AS s
    JOIN
        balanced_tree.product_details AS pd 
    ON s.prod_id = pd.product_id
    )
-- Use self-joins to create every combination of products.  Each column is derived from its own table.
SELECT
    p.product_name AS product_1,
    p1.product_name AS product_2,
    p2.product_name AS product_3,
    COUNT(*) AS times_bought_together,
    ROW_NUMBER() OVER(ORDER BY COUNT(*) DESC) AS rank 
-- Use a window function to apply a unique row number to each permutation.
FROM
    products AS p
JOIN 
    products AS p1 
ON p.txn_id = p1.txn_id -- Self-join table 1 to table 2
AND p.product_name != p1.product_name 
-- Ensure that we DO NOT duplicate items.
AND p.product_name < p1.product_name 
-- Self-join table 1 to table 3
JOIN products AS p2 
ON p.txn_id = p2.txn_id
AND p.product_name != p2.product_name 
-- Ensure that we DO NOT duplicate items in the first table.
AND p1.product_name != p2.product_name 
-- Ensure that we DO NOT duplicate items in the second table.
AND p.product_name < p2.product_name
AND p1.product_name < p2.product_name
GROUP BY 1, 2, 3
LIMIT 3
```

*Result:*

| product_1                     | product_2                    | product_3                        | times_bought_together | rank |
| ----------------------------- | ---------------------------- | -------------------------------- | --------------------- | ---- |
| Grey Fashion Jacket - Womens  | Teal Button Up Shirt - Mens  | White Tee Shirt - Mens           | 352                   | 1    |
| Black Straight Jeans - Womens | Indigo Rain Jacket - Womens  | Navy Solid Socks - Mens          | 349                   | 2    |
| Black Straight Jeans - Womens | Grey Fashion Jacket - Womens | Pink Fluro Polkadot Socks - Mens | 347                   | 3    |
