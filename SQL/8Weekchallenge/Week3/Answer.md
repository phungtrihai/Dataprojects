<details>
  <summary>Entity Relationship Diagram</summary>
  <img alt="Description" src="https://8weeksqlchallenge.com/images/case-study-3-erd.png">
</details>


## **B. Data Analysis Questions**

**1./ How many customers has Foodie-Fi ever had?**

*Answer:*
````sql
SELECT 
    count (distinct customer_id) as total_customers
FROM 
    foodie_fi.subscriptions;
````
*Result:*
| total_customers |
| --------------- |
| 1000            |


**2./ What is the monthly distribution of trial plan `start_date` values for our dataset - use the start of the month as the group by value**

*Answer:*

````sql
SELECT 
       date_trunc('month', start_date)  monthh,
       count (*) as trial_count
FROM 
    foodie_fi.subscriptions
WHERE 
    plan_id = 0
GROUP BY monthh
ORDER BY monthh
````
*Result:*
| monthh                   | trial_count |
| ------------------------ | ----------- |
| 2020-01-01T00:00:00.000Z | 88          |
| 2020-02-01T00:00:00.000Z | 68          |
| 2020-03-01T00:00:00.000Z | 94          |
| 2020-04-01T00:00:00.000Z | 81          |
| 2020-05-01T00:00:00.000Z | 88          |
| 2020-06-01T00:00:00.000Z | 79          |
| 2020-07-01T00:00:00.000Z | 89          |
| 2020-08-01T00:00:00.000Z | 88          |
| 2020-09-01T00:00:00.000Z | 87          |
| 2020-10-01T00:00:00.000Z | 79          |
| 2020-11-01T00:00:00.000Z | 75          |
| 2020-12-01T00:00:00.000Z | 84          |


**3./ What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name**

*Answer:*
````sql
SELECT 
    p.plan_id, 
    p.plan_name, 
    count(*) as number_plans
FROM 
    foodie_fi.subscriptions s
JOIN 
    foodie_fi.plans p ON s.plan_id = p.plan_id
WHERE 
    s.start_date > '2020-12-31'
GROUP BY 
    p. plan_id, p.plan_name
ORDER BY p.plan_id
````
*Result:*
| plan_id | plan_name     | number_plans |
| ------- | ------------- | ------------ |
| 1       | basic monthly | 8            |
| 2       | pro monthly   | 60           |
| 3       | pro annual    | 63           |
| 4       | churn         | 71           |


**4./ What is the customer count and percentage of customers who have churned rounded to 1 decimal place?**

*Answer:*
````sql
SELECT 
    SUM (CASE WHEN plan_id = 4 THEN 1 
         ELSE 0 END) churned_customer,
    count (distinct customer_id) as total_customer,
    100 * SUM (CASE WHEN plan_id = 4 THEN 1 ELSE 0 END)/count (distinct customer_id) percentage

FROM 
    foodie_fi.subscriptions

````
*Result:*
| churned_customer | total_customer | percentage |
| ---------------- | -------------- | ---------- |
| 307              | 1000           | 30         |

**5./How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?**

*Answer:*
````sql
with 
cte_5 as (
    SELECT 
        customer_id, 
        start_date
    FROM foodie_fi.subscriptions
    WHERE plan_id = 0)
,
cte_5b as (
    SELECT 
        cte_5.customer_id,
        cte_5.start_date,
        X.churned_date,
        X.churned_date - cte_5.start_date AS day_cancel
    FROM cte_5 
    JOIN
	    (SELECT 
		    customer_id,
   	 	    start_date churned_date
	    FROM foodie_fi.subscriptions
	    WHERE plan_id = 4) AS X
    
    ON X.customer_id = cte_5.customer_id
    WHERE X.churned_date - cte_5.start_date = 7)

SELECT 100* (SELECT COUNT (*) FROM cte_5b) / 
(SELECT COUNT( DISTINCT customer_id) FROM foodie_fi.subscriptions) AS PERCENTAGE
````
*Result:*
| percentage |
| ---------- |
| 9          |

Step: Create Common table expression that have customer id, start date when plan_id = 0 and the date they end.

**6./ What is the number and percentage of customer plans after their initial free trial?**

*Answer:*
````sql
with 
    cte_6a as (
		SELECT 
			*, 
    		RANK () OVER (PARTITION BY customer_id ORDER BY start_date ASC) as second_action
		FROM foodie_fi.subscriptions ),
        
    cte_6b as (
		SELECT 
			plan_id, 
    		count (*) as numbers
		FROM cte_6a
		WHERE second_action = 2
		GROUP BY plan_id) 
    
SELECT 
    p.plan_id,
    p.plan_name,
    cte_6b.numbers,
    round(100*cte_6b.numbers/sum (cte_6b.numbers) OVER ()) as percentage	
FROM cte_6b
JOIN foodie_fi.plans p ON p.plan_id = cte_6b.plan_id
ORDER BY p.plan_id;
````
*Result:*
| plan_id | plan_name     | numbers | percentage |
| ------- | ------------- | ------- | ---------- |
| 1       | basic monthly | 546     | 55         |
| 2       | pro monthly   | 325     | 33         |
| 3       | pro annual    | 37      | 4          |
| 4       | churn         | 92      | 9          |


**7./ What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?**

*Answer:*
````sql
with cte_7 as (
    SELECT 
	    *,
        max (start_date) 
            OVER ( PARTITION BY customer_id 
                   ORDER BY start_date ASC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) last_date
    FROM foodie_fi.subscriptions
    WHERE start_date <= '2020-12-31')
,
    cte_7b as (
	SELECT *
	FROM cte_7
	WHERE start_date = last_date)
    
SELECT 
    plan_id,
    count (*) as numbers,
    100*count (*)/ (SELECT COUNT(*) FROM cte_7b) as percentage
FROM cte_7b
GROUP BY plan_id
````

*Result:*
| plan_id | numbers | percentage |
| ------- | ------- | ---------- |
| 0       | 19      | 1          |
| 1       | 224     | 22         |
| 3       | 195     | 19         |
| 2       | 326     | 32         |
| 4       | 236     | 23         |


**8./ How many customers have upgraded to an annual plan in 2020?**

*Answer:*
````sql
SELECT 
    COUNT (DISTINCT customer_id) 
FROM 
    foodie_fi.subscriptions
WHERE 
    start_date <= '2020-12-31' AND plan_id = 3;
````    
*Result:*
| count |
| ----- |
| 195   |


**9./ How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?**

*Answer:*
````sql
with cte_9 as (
    SELECT 
        customer_id, 
        start_date
    FROM foodie_fi.subscriptions
    WHERE plan_id = 0)

SELECT 
    avg (X.anual_sub_date - cte_9.start_date) AS interval
FROM cte_9 
JOIN
	(SELECT 
        customer_id,
        start_date anual_sub_date
	FROM foodie_fi.subscriptions
	WHERE plan_id = 3) AS X
    
ON X.customer_id = cte_9.customer_id;
````

*Result:*
| interval             |
| -------------------- |
| 104.6201550387596899 |


**10./ Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)**

*Answer:*
````sql
with cte_10 as (
    SELECT 
        customer_id, 
        start_date
    FROM foodie_fi.subscriptions
    WHERE plan_id = 0)
,
cte_10b as (
SELECT 
    cte_10.customer_id,
    X.anual_sub_date - cte_10.start_date AS interval,
    CASE WHEN X.anual_sub_date - cte_10.start_date <= 30 THEN '0-30 DAYS'
    	 WHEN X.anual_sub_date - cte_10.start_date <= 60 THEN '31-60 DAYS'
         ELSE '> 60 DAYS' END AS interval_types
FROM cte_10 
JOIN
	(SELECT 
		customer_id,
   	 	start_date anual_sub_date
	FROM foodie_fi.subscriptions
	WHERE plan_id = 3) AS X
    
ON X.customer_id = cte_10.customer_id)

SELECT 
    interval_types,
    count (*) as numbers,
    round (100*count(*)/(SELECT COUNT(*) FROM cte_10b)) as percentage
FROM cte_10b
GROUP BY interval_types
````
*Result:*
| interval_types | numbers | percentage |
| -------------- | ------- | ---------- |
| 31-60 DAYS     | 24      | 9          |
| > 60 DAYS      | 185     | 71         |
| 0-30 DAYS      | 49      | 18         |

**11./ How many customers downgraded from a pro monthly to a basic monthly plan in 2020?**

*Answer:*

````sql
WITH basic as (
	SELECT *
	FROM foodie_fi.subscriptions
	WHERE plan_id = 1)
,
	pro as (
	SELECT *
	FROM foodie_fi.subscriptions
	WHERE plan_id = 2)
    
SELECT 
	basic.customer_id,
    basic.start_date as basic_start_date,
	pro.start_date as pro_start_date
FROM basic 
JOIN pro ON basic.customer_id = pro.customer_id
WHERE basic.start_date > pro.start_date;
````

## **C. Challenge Payment Question**
The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes **amounts paid by each customer** in the `subscriptions table` with the following requirements:

* monthly payments always occur on the same day of month as the original start_date of any monthly paid plan

* upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
* upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
* once a customer churns they will no longer make payments
