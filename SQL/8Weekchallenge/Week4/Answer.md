### **A. Customer Nodes Exploration**
**1. How many unique nodes are there on the Data Bank system?**

*Answer:*
```sql
SELECT
	count (distinct node_id) unique_node
FROM 
	data_bank.customer_nodes;
```

*Result:*
| unique_node |
| ----------- |
| 5           |
***
**2. What is the number of nodes per region?**

*Answer:*
```sql
SELECT
	r.region_name,
    count (c.node_id)
FROM 
	data_bank.customer_nodes c
JOIN data_bank.regions r
ON c.region_id = r.region_id
GROUP BY r.region_name;
```

*Result:*
| region_name | count |
| ----------- | ----- |
| America     | 735   |
| Australia   | 770   |
| Africa      | 714   |
| Asia        | 665   |
| Europe      | 616   |
***
**3. How many customers are allocated to each region?**

*Answer:*
```sql
SELECT
	r.region_name,
    count (distinct c.customer_id)
FROM 
	data_bank.customer_nodes c
JOIN data_bank.regions r
ON c.region_id = r.region_id
GROUP BY r.region_name;
```

*Result:*

| region_name | count |
| ----------- | ----- |
| Africa      | 102   |
| America     | 105   |
| Asia        | 95    |
| Australia   | 110   |
| Europe      | 88    |
***
**4. How many days on average are customers reallocated to a different node?**

*Answer:*
```sql
SELECT
	avg(end_date - start_date) reallocate_days
FROM 
	data_bank.customer_nodes c
WHERE end_date <> '9999-12-31';
```
*Result:*
| reallocate_days     |
| ------------------- |
| 14.6340000000000000 |
***
**5What is the median, 80th and 95th percentile for this same reallocation days metric for each region?**

*Answer:*
```sql
WITH 
reallocation_days_cte AS
    (SELECT *,
        (end_date - start_date) AS reallocation_days
    FROM data_bank.customer_nodes
    INNER JOIN data_bank.regions USING (region_id)
    WHERE end_date!='9999-12-31'),

percentile_cte AS
    (SELECT *,
    percent_rank() over(PARTITION BY region_id
    ORDER BY reallocation_days)*100 AS p
    FROM reallocation_days_cte)

SELECT region_id,
       region_name,
       AVG(reallocation_days)::INT reallocation_days,
       AVG(p) percentile
FROM percentile_cte
WHERE round(p::int, -1) IN (50,80,95)
GROUP BY
    region_id,
    region_name,
    reallocation_days;
```
*Result:*
| region_id | region_name | reallocation_dáy | percentile         |
| --------- | ----------- | ---------------- | ------------------ |
| 1         | Australia   | 14               | 45.675265553869494 |
| 1         | Australia   | 15               | 49.468892261001535 |
| 1         | Australia   | 16               | 52.35204855842186  |
| 1         | Australia   | 23               | 76.93474962063736  |
| 1         | Australia   | 24               | 81.18361153262519  |
| 1         | Australia   | 25               | 83.61153262518972  |
| 2         | America     | 14               | 45.3100158982512   |
| 2         | America     | 15               | 48.012718600953896 |
| 2         | America     | 16               | 51.9872813990461   |
| 2         | America     | 22               | 75.0397456279809   |
| 2         | America     | 23               | 77.42448330683625  |
| 2         | America     | 24               | 81.08108108108107  |
| 2         | America     | 25               | 83.94276629570749  |
| 3         | Africa      | 14               | 45.008183306055656 |
| 3         | Africa      | 15               | 49.09983633387887  |
| 3         | Africa      | 16               | 53.35515548281504  |
| 3         | Africa      | 23               | 75.45008183306051  |
| 3         | Africa      | 24               | 79.54173486088378  |
| 3         | Africa      | 25               | 82.97872340425532  |
| 4         | Asia        | 14               | 47.451669595782064 |
| 4         | Asia        | 15               | 49.91212653778561  |
| 4         | Asia        | 16               | 53.25131810193321  |
| 4         | Asia        | 22               | 75.74692442882248  |
| 4         | Asia        | 23               | 79.08611599297008  |
| 4         | Asia        | 24               | 82.2495606326889   |
| 5         | Europe      | 14               | 45.54079696394686  |
| 5         | Europe      | 15               | 49.146110056925984 |
| 5         | Europe      | 16               | 51.80265654648955  |
| 5         | Europe      | 17               | 54.07969639468692  |
| 5         | Europe      | 23               | 74.76280834914611  |
| 5         | Europe      | 24               | 77.79886148007589  |
| 5         | Europe      | 25               | 81.21442125237193  |

### **B. Customer Transactions**
**1. What is the unique count and total amount for each transaction type?**

*Answer:*
```sql
SELECT 
    txn_type,
    count (txn_date) as unique_count,
    sum (txn_amount) as total_amount
FROM
	data_bank.customer_transactions
GROUP BY 1;
```    

*Result:*

| txn_type   | unique_count | total_amount |
| ---------- | ------------ | ------------ |
| purchase   | 1617         | 806537       |
| deposit    | 2671         | 1359168      |
| withdrawal | 1580         | 793003       |
***
**2. What is the average total historical deposit counts and amounts for all customers?**

*Answer:*

```sql
SELECT 
    customer_id,
    count (txn_date) as unique_count,
    sum (txn_amount) as total_amount
FROM
	data_bank.customer_transactions
GROUP BY
	1;
```

*Result (top 10):*
| customer_id | unique_count | total_amount |
| ----------- | ------------ | ------------ |
| 184         | 17           | 8920         |
| 87          | 14           | 6613         |
| 477         | 17           | 7988         |
| 273         | 10           | 6462         |
| 51          | 11           | 4788         |
| 394         | 16           | 9832         |
| 272         | 9            | 5649         |
| 70          | 14           | 6230         |
| 190         | 5            | 2076         |
| 350         | 18           | 7911         |

***
**3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?**

*Answer:*
```sql
with cte_3 as (
SELECT 
    date_trunc('month', txn_date) as months,
    customer_id,
    sum(CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END) AS deposit_count,
    sum(CASE WHEN txn_type = 'purchase' THEN 1 ELSE 0 END) AS purchase_count,
    sum(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS withdrawal_count
FROM
    data_bank.customer_transactions
GROUP BY
	1, 2
ORDER BY 
	1, 2)

SELECT 
    months,
    count (customer_id)
FROM 
    cte_3
WHERE
    deposit_count > 1
AND 
    (purchase_count >= 1 OR withdrawal_count >= 1)
GROUP BY 1
ORDER BY 1
```
*Result:*
| months                   | count |
| ------------------------ | ----- |
| 2020-01-01T00:00:00.000Z | 168   |
| 2020-02-01T00:00:00.000Z | 181   |
| 2020-03-01T00:00:00.000Z | 192   |
| 2020-04-01T00:00:00.000Z | 70    |

*Approach:*
Use `CASE WHEN` to add column that count numbers for each transaction types (deposit, withdrawal,..) and then filter customers make more than 1 deposit and either 1 purchase or 1 withdrawal and count by months.
***
**4. What is the closing balance for each customer at the end of the month?**

*Answer:*
```sql	
WITH 
months as (
    SELECT 
    distinct customer_id,
    ('2020-01-01'::DATE + GENERATE_SERIES(0,3) * INTERVAL '1 MONTH') AS months
    FROM data_bank.customer_transactions)
,
cte_4 as (
    SELECT
    m.customer_id,
    m.months,
    COALESCE(sum(CASE WHEN ct.txn_type = 'deposit' THEN ct.txn_amount ELSE ct.txn_amount*-1 END), 0) changes
    FROM 
        data_bank.customer_transactions ct
    RIGHT JOIN
        months m
    ON ct.customer_id = m.customer_id
    AND m.months = date_trunc ('month', ct.txn_date)
    GROUP BY 1, 2
    ORDER BY 1, 2
)

SELECT 
	*,
    sum(changes) OVER (PARTITION BY customer_id ORDER BY months 
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) balance
FROM cte_4
ORDER BY 1,2
```
*Result:*
| customer_id | months                   | changes | balance |
| ----------- | ------------------------ | ------- | ------- |
| 1           | 2020-01-01T00:00:00.000Z | 312     | 312     |
| 1           | 2020-02-01T00:00:00.000Z | 0       | 312     |
| 1           | 2020-03-01T00:00:00.000Z | -952    | -640    |
| 1           | 2020-04-01T00:00:00.000Z | 0       | -640    |
| 2           | 2020-01-01T00:00:00.000Z | 549     | 549     |
| 2           | 2020-02-01T00:00:00.000Z | 0       | 549     |
| 2           | 2020-03-01T00:00:00.000Z | 61      | 610     |
| 2           | 2020-04-01T00:00:00.000Z | 0       | 610     |
| 3           | 2020-01-01T00:00:00.000Z | 144     | 144     |
| 3           | 2020-02-01T00:00:00.000Z | -965    | -821    |
| 3           | 2020-03-01T00:00:00.000Z | -401    | -1222   |
| 3           | 2020-04-01T00:00:00.000Z | 493     | -729    |
| 4           | 2020-01-01T00:00:00.000Z | 848     | 848     |
| 4           | 2020-02-01T00:00:00.000Z | 0       | 848     |
| 4           | 2020-03-01T00:00:00.000Z | -193    | 655     |
| 4           | 2020-04-01T00:00:00.000Z | 0       | 655     |

*Approach:*
Adjust the amount base on transaction types (deposit => +; withdrawal => -) and then sum that amount with previous month. Note that we need to add month column to address full months.
***
**5. What is the percentage of customers who increase their closing balance by more than 5%?**

*Answer:*
```sql
With 
months as (
    SELECT 
    distinct customer_id,
    ('2020-01-01'::DATE + GENERATE_SERIES(0,3) * INTERVAL '1 MONTH') AS months
    FROM data_bank.customer_transactions)
,
cte_5a as (
    SELECT
    m.customer_id,
    m.months,
    COALESCE(sum(CASE WHEN ct.txn_type = 'deposit' THEN ct.txn_amount ELSE ct.txn_amount*-1 END), 0) changes
    FROM 
	    data_bank.customer_transactions ct
    RIGHT JOIN
	    months m
    ON ct.customer_id = m.customer_id
    AND m.months = date_trunc ('month', ct.txn_date)
    GROUP BY 1, 2
    ORDER BY 1, 2
)
,
cte_5b as (
    SELECT 
	*,
    sum(changes) OVER (PARTITION BY customer_id ORDER BY months 
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) balance
    FROM cte_5a
    ORDER BY 1,2)
,
cte_5c as (
    SELECT 
	customer_id,
    months,
    balance,
    lead (balance, 1) OVER (PARTITION BY customer_id ORDER BY months) next_month_balance,
    (100*lead (balance, 1) OVER (PARTITION BY customer_id ORDER BY months)/nullif(balance,0))::int as changes  
    FROM cte_5b )

SELECT 100*(
	SELECT count (distinct customer_id)  
	FROM cte_5c
	WHERE changes > 105) / 
(SELECT count (distinct customer_id)  
FROM cte_5c) AS percentage
```

*Result:*

| percentage |
| ---------- |
| 75         |

*Approach:*
Kind of similiar to question 4 but we need to use window function `Lead()` to add **next_month_balance** column and then calculate the percentage increase.

