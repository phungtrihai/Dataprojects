### **B. Runner and Customer Experience**
**1./ How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)**

*Answer:*
````sql
SELECT   
    date_trunc( 'week' , registration_date ) ,
    count (*) as runners_sign
FROM 
    pizza_runner.runners
GROUP BY 
    date_trunc( 'week' , registration_date );
````
*Result:*
| date_trunc               | runners_sign |
| ------------------------ | ------------ |
| 2021-01-11T00:00:00.000Z | 1            |
| 2020-12-28T00:00:00.000Z | 2            |
| 2021-01-04T00:00:00.000Z | 1            |

***
**2./ What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?**

*Answer:*
````sql
SELECT 
    ro.runner_id,
    avg (extract (epoch from (cast (pickup_time as timestamp) - co.order_time))::integer/60) time_dif_minute 
FROM 
    pizza_runner.runner_orders ro
JOIN 
    pizza_runner.customer_orders co 
ON ro.order_id = co.order_id
WHERE 
    pickup_time <> 'null'
GROUP BY 
    ro.runner_id;
````

*Result:*
| runner_id | time_dif_minute     |
| --------- | ------------------- |
| 3         | 10.0000000000000000 |
| 2         | 23.4000000000000000 |
| 1         | 15.3333333333333333 |

*=> Approach: Use `extract` to get the time in minute*.
***
**3./ Is there any relationship between the number of pizzas and how long the order takes to prepare?**

*Answer:*
````sql
WITH CTE_3 AS (
    SELECT 
        co.order_id,
        count (*) as No_pizzas,
        avg (extract (epoch from (cast (pickup_time as timestamp) - co.order_time))::integer/60) time_dif_minute 
    FROM 
        pizza_runner.runner_orders ro
    JOIN 
        pizza_runner.customer_orders co 
    ON ro.order_id = co.order_id
    WHERE 
        pickup_time <> 'null'
    GROUP BY 
        co.order_id
    ORDER BY 2 DESC )

SELECT 
    no_pizzas,
    avg(time_dif_minute)
FROM 
    CTE_3
GROUP BY 
    no_pizzas
ORDER BY 1;

````
*Result:*

| no_pizzas | avg                 |
| --------- | ------------------- |
| 1         | 12.0000000000000000 |
| 2         | 18.0000000000000000 |
| 3         | 29.0000000000000000 |

***
**4./ What was the average distance travelled for each customer?**

*Answer:*

````sql
SELECT 
    co.customer_id,
    round (avg (replace (ro.distance, 'km', '')::numeric))
FROM 
    pizza_runner.runner_orders ro 
JOIN 
    pizza_runner.customer_orders co 
ON ro.order_id = co.order_id
WHERE 
    ro.distance <> 'null'
GROUP BY 
    co.customer_id;
````

*Result:*
| customer_id | round |
| ----------- | ----- |
| 101         | 20    |
| 103         | 23    |
| 104         | 10    |
| 105         | 25    |
| 102         | 17    |

*=> Approach: `Group by` *customer_id* and then avg the distanct*.
***
**5./ What was the difference between the longest and shortest delivery times for all orders?**

*Answer:*
````sql
SELECT 
    max(substring (duration, 0, 3)::numeric)- min(substring (duration, 0, 3)::numeric) max_min
FROM 
    pizza_runner.runner_orders
WHERE 
    duration <> 'null';
````

*Result:*
| max_min |
| ------- |
| 30      |

*=> Approach: Use `substring function` to extract number part of duration and then minus max value to min value*.
***
**6./ What was the average speed for each runner for each delivery and do you notice any trend for these values?**

*Answer:*
````sql
with cte_6 as (
    SELECT 
        runner_id,
        order_id,
        round  (replace (distance, 'km', '')::numeric) distance,
        substring (duration, 0, 3)::numeric as duration
FROM 
    pizza_runner.runner_orders
WHERE 
    duration <> 'null' )

SELECT 
    runner_id,
    order_id,
    round (distance /duration *60) speed
FROM 
    cte_6
ORDER BY 
    1, 2;
````

*Result:* 

| runner_id | order_id | speed |
| --------- | -------- | ----- |
| 1         | 1        | 38    |
| 1         | 2        | 44    |
| 1         | 3        | 39    |
| 1         | 10       | 60    |
| 2         | 4        | 35    |
| 2         | 7        | 60    |
| 2         | 8        | 92    |
| 3         | 5        | 40    |

*=> Approach: Similiar to question 6, add 1 more step which is divide distanct and time to get speed*.
***
**7./ What is the successful delivery percentage for each runner?**

*Answer:*
````sql
SELECT 
    runner_id,
    round (avg (CASE WHEN pickup_time = 'null' THEN 0 ELSE 1 END)*100) AS succesfull
FROM 
    pizza_runner.runner_orders
GROUP BY 
    runner_id
````

*Result:*

| runner_id | succesfull |
| --------- | ---------- |
| 3         | 50         |
| 2         | 75         |
| 1         | 100        |

*=> Approach: Use `CASE WHEN` to assign row that pick up successfully with 1 and calculate percentage*.