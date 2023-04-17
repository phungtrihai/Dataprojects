### **1. Digital Analysis**

**1 How many users are there?**

*Answer:*
```sql
SELECT 
	COUNT (DISTINCT (user_id))
FROM
	clique_bait.users;
```
*Result:*
| count |
| ----- |
| 500   |
***
**2 How many cookies does each user have on average?**

*Answer:*

```sql
WITH cookie AS (
  SELECT 
    user_id, 
    COUNT(cookie_id) AS cookie_id_count
  FROM clique_bait.users
  GROUP BY user_id)

SELECT 
  ROUND(AVG(cookie_id_count),0) AS avg_cookie_id
FROM cookie;
```

*Result:*


| avg_cookie_id |
| ------------- |
| 4             |
***
    
**3 What is the unique number of visits by all users per month?**

*Answer:*
```sql
SELECT
	date_trunc ('month' , event_time) months,
    count (distinct (visit_id)) num_visits
FROM
	clique_bait.events
GROUP BY 1;
```

*Result:*

| months                   | num_visits |
| ------------------------ | ---------- |
| 2020-01-01T00:00:00.000Z | 876        |
| 2020-02-01T00:00:00.000Z | 1488       |
| 2020-03-01T00:00:00.000Z | 916        |
| 2020-04-01T00:00:00.000Z | 248        |
| 2020-05-01T00:00:00.000Z | 36         |
***

**4 What is the number of events for each event type?**

*Answer:*
```sql
SELECT
	event_type,
    count (distinct (visit_id)) num_visits
FROM
	clique_bait.events
GROUP BY 1;
```

*Result:*

| event_type | num_visits |
| ---------- | ---------- |
| 1          | 3564       |
| 2          | 2510       |
| 3          | 1777       |
| 4          | 876        |
| 5          | 702        |
***
**5 What is the percentage of visits which have a purchase event?**

*Answer:*
```sql
SELECT
	count (distinct visit_id) purchase_event,
    100 * count (visit_id) / (SELECT count (distinct visit_id) FROM clique_bait.events) AS purchase_event_pct
FROM
	clique_bait.events
WHERE event_type = '3';
```

*Result:*

| purchase_event | purchase_event_pct |
| -------------- | ------------------ |
| 1777           | 49                 |
***
**6 What is the percentage of visits which view the checkout page but do not have a purchase event?**

*Answer:*
```sql
WITH 
CTE_6 AS (
    SELECT
	    visit_id,
        max(CASE WHEN page_id = '12' THEN 1 ELSE 0 END) as is_checkout,
        max(CASE WHEN event_type = '3' THEN 1 ELSE 0 END) as is_purchase
    FROM    
        clique_bait.events
    GROUP BY 1
    ORDER BY 1,2,3)

SELECT
	count (*) as numbers,
    100 * count (*) / ( SELECT count (*) FROM CTE_6) pct
FROM
	CTE_6
WHERE is_checkout = 1
AND is_purchase = 0;
```

*Result:*

| numbers | pct |
| ------- | --- |
| 326     | 9   |

*Approach:* Use `CASE WHEN` to  find visit that checkout page but do not have a purchase event
***
**7 What are the top 3 pages by number of views?**

*Answer:*
```sql
SELECT 
	ph.page_name,
    count (*) as views
FROM     
    clique_bait.events e
INNER JOIN
	clique_bait.page_hierarchy ph
ON e.page_id = ph.page_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;
```

*Result:*

| page_name    | views |
| ------------ | ----- |
| All Products | 4752  |
| Lobster      | 2515  |
| Crab         | 2513  |
***
**8 What is the number of views and cart adds for each product category?**

*Answer:*
```sql
SELECT
	ph.product_category,
    sum(CASE WHEN e.event_type = '1' THEN 1 ELSE 0 END) AS views,
    sum(CASE WHEN e.event_type = '2' THEN 1 ELSE 0 END) AS cart_adds
FROM
	clique_bait.events e
JOIN
	clique_bait.page_hierarchy ph    
ON e.page_id = ph.page_id
WHERE
	ph.product_category is not null
GROUP BY 1
ORDER BY 2 DESC;
```
*Result:*
| product_category | views | cart_adds |
| ---------------- | ----- | --------- |
| Shellfish        | 6204  | 3792      |
| Fish             | 4633  | 2789      |
| Luxury           | 3032  | 1870      |

**9. What are the top 3 products by purchases?**

*Answer:*
```sql
with buy_visit as 
    (SELECT visit_id
    FROM clique_bait.events 
    WHERE event_type = '3')
    
SELECT
    t3.product_category,
    SUM(CASE WHEN t1.event_type = '2' THEN 1 ELSE 0 END) AS add_to_carts
FROM
    lique_bait.events t1 
JOIN buy_visit t2
ON t1.visit_id = t2.visit_id
JOIN clique_bait.page_hierarchy t3
ON t1.page_id = t3.page_id
GROUP BY 1  
ORDER BY 1,2 DESC
LIMIT 3;
```

*Result:*
| product_category | add_to_carts |
| ---------------- | ------------ |
| Fish             | 2115         |
| Luxury           | 1404         |
| Shellfish        | 2898         |

*Approach:* Create table with only visit_id that buy product => Use `CASE WHEN` to mark the product they buy when they add to cart => then sum by product_category

### **2. Product Funnel Analysis**
**Create a new output table**

*Answer:*
```sql
DROP TABLE IF EXISTS product_summary;
CREATE TEMP TABLE product_summary as 
WITH 
view_cart_products AS(
    SELECT
      page_id,
      SUM(CASE WHEN event_type = 1 THEN 1 ELSE 0 END) AS product_view,
      SUM(CASE WHEN event_type = 2 THEN 1 ELSE 0 END) AS product_cart
    FROM
      clique_bait.events
    GROUP BY 1 ),
    
purchase_products AS (
    SELECT
      page_id,
      SUM(CASE WHEN event_type = 2 THEN 1 ELSE 0 END) AS product_purchase
    FROM
      clique_bait.events
    WHERE visit_id 
        IN (SELECT visit_id
            FROM clique_bait.events 
            WHERE event_type = '3')
    GROUP BY 1),

cart_xpurchase AS (
    SELECT
      page_id,
      SUM(CASE WHEN event_type = 2 THEN 1 ELSE 0 END) AS product_cart_not_purchase
    FROM
      clique_bait.events
    WHERE visit_id 
        NOT IN 
            (SELECT visit_id
            FROM clique_bait.events 
            WHERE event_type = '3')
    GROUP BY 1 )

SELECT
    t1.product_id,
    t1.page_name AS product_name,
    t1.product_category,
    t2.product_view AS page_views,
    t2.product_cart AS cart_adds,
    t3.product_purchase AS purchases,
    t4.product_cart_not_purchase AS abandoned
FROM
    clique_bait.page_hierarchy t1
INNER JOIN view_cart_products t2 
ON t1.page_id = t2.page_id
INNER JOIN purchase_products t3 
ON t2.page_id = t3.page_id
INNER JOIN cart_xpurchase t4 
ON t3.page_id = t4.page_id
WHERE t1.product_category is not null
ORDER BY 1;

DROP TABLE IF EXISTS product_category;
CREATE TEMP TABLE product_category AS
  SELECT
    product_category,
    SUM(page_views) AS page_views,
    SUM(cart_adds) AS cart_adds,
    SUM(purchases) AS purchases,
    SUM(abandoned) AS abandoned
  FROM
    product_summary
  GROUP BY 1
  ORDER BY 1;

SELECT * FROM product_summary;
SELECT * FROM product_category;
``` 
*Result:*

**Product_summary:**
| product_id | product_name   | product_category | page_views | cart_adds | purchases | abandoned |
| ---------- | -------------- | ---------------- | ---------- | --------- | --------- | --------- |
| 1          | Salmon         | Fish             | 1559       | 938       | 711       | 227       |
| 2          | Kingfish       | Fish             | 1559       | 920       | 707       | 213       |
| 3          | Tuna           | Fish             | 1515       | 931       | 697       | 234       |
| 4          | Russian Caviar | Luxury           | 1563       | 946       | 697       | 249       |
| 5          | Black Truffle  | Luxury           | 1469       | 924       | 707       | 217       |
| 6          | Abalone        | Shellfish        | 1525       | 932       | 699       | 233       |
| 7          | Lobster        | Shellfish        | 1547       | 968       | 754       | 214       |
| 8          | Crab           | Shellfish        | 1564       | 949       | 719       | 230       |
| 9          | Oyster         | Shellfish        | 1568       | 943       | 726       | 217       |
***
**Product_category**
| product_category | page_views | cart_adds | purchases | abandoned |
| ---------------- | ---------- | --------- | --------- | --------- |
| Fish             | 4633       | 2789      | 2115      | 674       |
| Luxury           | 3032       | 1870      | 1404      | 466       |
| Shellfish        | 6204       | 3792      | 2898      | 894       |

*Approach:* Create temp table with product_view, add_to_cart; table with purchase column; table with abandone column and then join them together.
***
**1. Which product had the most views, cart adds and purchases?**

*Answer:*
```sql
(SELECT 
	product_name,
    page_views as values,
    'Most view' as types
FROM product_summary
ORDER BY 2 DESC
limit 1)
UNION
(SELECT 
	product_name,
    cart_adds as values,
    'Most cart add' as types
FROM product_summary
ORDER BY 2 DESC
limit 1)
UNION
(SELECT 
	product_name,
    purchases as values,
    'Most purchase' as types
FROM product_summary
ORDER BY 2 DESC
limit 1);
```

*Result:*
| product_name | values | types         |
| ------------ | ------ | ------------- |
| Oyster       | 1568   | Most view     |
| Lobster      | 754    | Most purchase |
| Lobster      | 968    | Most cart add |

*Approach:* Create temp table with most view, most purchase and most add cart and then union to have 1 table.
***
**2. Which product was most likely to be abandoned?**

*Answer:*
```sql
SELECT
	product_name,
	round (100 * abandoned::numeric / page_views::numeric, 2) AS abandone_rate
FROM product_summary
ORDER BY 2 DESC
LIMIT 1;
```

*Result:*
| product_name   | abandone_rate |
| -------------- | ------------- |
| Russian Caviar | 15.93         |

*Approach:* Calculate the product with highest abandone rate.

**3. Which product had the highest view to purchase percentage?**

*Answer:*
```sql
SELECT
	product_name,
	round (100 * purchases::numeric / page_views::numeric, 2) AS purchase_rate
FROM product_summary
ORDER BY 2 DESC
LIMIT 1;
```

*Result:*

| product_name | purchase_rate |
| ------------ | ------------- |
| Lobster      | 48.74         |
***
**4. What is the average conversion rate from view to cart add?**

*Answer:*
```sql
SELECT
	round (avg(100 * cart_adds::numeric / page_views::numeric),2) AS add_cart_rate
FROM product_summary;
```

*Result:*
| add_cart_rate |
| ------------- |
| 60.95         |
***
**5. What is the average conversion rate from cart add to purchase?**

*Answer:*
```sql
SELECT
	round (avg(100 * purchases::numeric / cart_adds::numeric),2) AS purchase_cart_rate
FROM product_summary
```
***
### **3. Campaigns Analysis**
**Generate a table that has 1 single row for every unique `visit_id`**

*Answer:*
```sql
-- Step 1: Create cte to aggregate all product by single visit_id rows (strings add & order by)
with
cte_1 as (
SELECT
  e.visit_id,
  STRING_AGG (ph.page_name , ', ' ORDER BY e.sequence_number) cart_products
FROM
  clique_bait.events e
JOIN
  clique_bait.page_hierarchy ph
ON e.page_id = ph.page_id  
WHERE e.event_type = '2'  
GROUP BY 1),

-- Step 2: Create cte with unique visit_id, visit_start_time, numbers of cart adds, impression, click, page view.
cte_2 as (
SELECT
	u.user_id,
    e.visit_id,
    min (e.event_time) visit_start_time,
    count (e.page_id) page_views,
    sum (CASE WHEN e.event_type = '2' THEN 1 ELSE 0 END) as cart_adds,
    max (CASE WHEN e.event_type = '3' THEN 1 ELSE 0 END) as is_purchase,
    sum (CASE WHEN e.event_type = '4' THEN 1 ELSE 0 END) as impression,
    sum (CASE WHEN e.event_type = '5' THEN 1 ELSE 0 END) as click
FROM
	clique_bait.events e
JOIN
	clique_bait.users u
ON e.cookie_id = u.cookie_id
JOIN
	clique_bait.page_hierarchy ph
ON ph.page_id = e.page_id    
GROUP BY
	u.user_id,
    e.visit_id)

-- Step 3: Join with campaign_identifier table to get campaign name
SELECT
	cte_2.user_id,
    cte_2.visit_id,
    cte_2.visit_start_time,
    cte_2.page_views,
    cte_2.cart_adds,
    cte_2.is_purchase,
    ci.campaign_name,
    cte_2.impression,
    cte_2.click,
    cte_1.cart_products    
FROM
	cte_2
LEFT JOIN
	clique_bait.campaign_identifier ci
ON cte_2.visit_start_time BETWEEN ci.start_date AND ci.end_date
LEFT JOIN
	cte_1
ON cte_1.visit_id = cte_2.visit_id;
```
*Result:*
| user_id | visit_id | visit_start_time         | page_views | cart_adds | is_purchase | campaign_name                     | impression | click | cart_products                                                                         |
| ------- | -------- | ------------------------ | ---------- | --------- | ----------- | --------------------------------- | ---------- | ----- | ------------------------------------------------------------------------------------- |
| 423     | 2b7137   | 2020-02-29T05:52:32.923Z | 18         | 6         | 1           | Half Off - Treat Your Shellf(ish) | 1          | 1     | Salmon, Kingfish, Russian Caviar, Lobster, Crab, Oyster                               |
| 392     | e17256   | 2020-02-15T20:09:41.477Z | 8          | 2         | 0           | Half Off - Treat Your Shellf(ish) | 0          | 0     | Salmon, Russian Caviar                                                                |
| 159     | fdd5b7   | 2020-01-31T05:32:44.783Z | 1          | 0         | 0           |                                   | 0          | 0     |                                                                                       |
| 38      | a47e94   | 2020-01-28T03:38:07.514Z | 19         | 7         | 1           |                                   | 1          | 1     | Salmon, Kingfish, Tuna, Black Truffle, Lobster, Crab, Oyster                          |
| 387     | 58573e   | 2020-02-10T14:19:57.455Z | 15         | 4         | 1           | Half Off - Treat Your Shellf(ish) | 0          | 0     | Kingfish, Russian Caviar, Abalone, Lobster                                            |
| 472     | f23cfe   | 2020-02-07T16:10:22.888Z | 11         | 3         | 1           | Half Off - Treat Your Shellf(ish) | 0          | 0     | Salmon, Kingfish, Crab                                                                |
| 258     | 2ae01a   | 2020-02-23T22:01:32.574Z | 20         | 7         | 1           | Half Off - Treat Your Shellf(ish) | 1          | 1     | Tuna, Russian Caviar, Black Truffle, Abalone, Lobster, Crab, Oyster                   |
| 289     | e7757e   | 2020-01-20T17:38:02.368Z | 8          | 2         | 1           | 25% Off - Living The Lux Life     | 1          | 0     | Black Truffle, Lobster                                                                |
| 396     | 0c1bd4   | 2020-03-01T10:53:21.740Z | 10         | 2         | 0           | Half Off - Treat Your Shellf(ish) | 0          | 0     | Black Truffle, Oyster                                                                 |



