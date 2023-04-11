### **A. Pizza Metric** 
**1./ How many pizzas were ordered?**

*Answer:*
````sql
SELECT 
    count (pizza_id) as No_pizza
FROM 
    pizza_runner.customer_orders;
````
*Result:*
| no_pizza |
| -------- |
| 14       |
***
**2./ How many unique customer orders were made?**

*Answer:*
````sql
SELECT 
    count (distinct order_id) as No_ordered
FROM 
    pizza_runner.customer_orders;
````

*Result:*
| no_ordered |
| ---------- |
| 10         |
***
**3./ How many successful orders were delivered by each runner?**

*Answer:*
````sql
SELECT  
    run_orders.runner_id,
    count (distinct cus_orders.order_id) successful_orders
FROM 
    pizza_runner.customer_orders cus_orders
JOIN 
    pizza_runner.runner_orders   run_orders
ON cus_orders.order_id = run_orders.order_id
WHERE 
    pickup_time <> 'null'
GROUP BY 
    run_orders.runner_id;
````
*Result:*
| runner_id | successful_orders |
| --------- | ----------------- |
| 1         | 4                 |
| 2         | 3                 |
| 3         | 1                 |

*=> Approach: Map with **runner_orders** table to filter orders that delivered and `group by` runner_id*
***
**4./How many of each type of pizza was delivered?**

*Answer:*
````sql
SELECT  
    cus_orders.pizza_id,
    count (run_orders.pickup_time) times_delivered
FROM 
    pizza_runner.customer_orders cus_orders
JOIN 
    pizza_runner.runner_orders   run_orders
ON cus_orders.order_id = run_orders.order_id
WHERE 
    pickup_time <> 'null'
GROUP BY 
    cus_orders.pizza_id;
````
*Result:*
| pizza_id | times_delivered |
| -------- | --------------- |
| 2        | 3               |
| 1        | 9               |

*=> Approach: `Group by` pizza_id and then count times delivered succesful*
***
**5./How many Vegetarian and Meatlovers were ordered by each customer?**

*Answer:*
````sql
SELECT  
    pz_name.pizza_name,
    count (run_orders.pickup_time times_delivered
FROM 
    pizza_runner.customer_orders cus_orders
JOIN 
    pizza_runner.runner_orders   run_orders
ON cus_orders.order_id = run_orders.order_id
JOIN 
    pizza_runner.pizza_names   pz_name
ON pz_name.pizza_id = cus_orders.pizza_id
GROUP BY 
    pz_name.pizza_name;
````
*Result:*
| pizza_name | times_delivered |
| ---------- | --------------- |
| Meatlovers | 10              |
| Vegetarian | 4               |

*=> Approach Join with **pizza table** and then `Group by` pizza_name to count times*
***
**6./ What was the maximum number of pizzas delivered in a single order?**

*Answer:*
````sql
SELECT  
    cus_orders.order_id,
    count (run_orders.pickup_time) times_delivered
FROM 
    pizza_runner.customer_orders cus_orders
JOIN 
    pizza_runner.runner_orders   run_orders
ON cus_orders.order_id = run_orders.order_id
WHERE 
    pickup_time <> 'null'
GROUP BY 
    cus_orders.order_id
ORDER BY 
    times_delivered DESC
LIMIT 1;
````
*Result:*
| order_id | times_delivered |
| -------- | --------------- |
| 4        | 3               |

*=> Count numbers of order time and then use `Limt 1` to get the maximum number*
***
**7./ For each customer, how many delivered pizzas had at least 1 change and how many had no changes?**

*Answer:*
````sql
WITH CTE_7 AS (
    SELECT 
        customer_id,
        exclusions,
        extras,
        (exclusions <> 'null' and exclusions <> '' ) OR (extras <> 'null' and extras <> '' and extras IS NOT NULL) changes
    FROM 
        pizza_runner.customer_orders ) 

SELECT 
    customer_id,
    SUM(CASE WHEN changes = true  THEN 1 ELSE 0 END) AS atleast1,
    SUM(CASE WHEN changes = false THEN 1 ELSE 0 END) AS nochange
FROM 
    CTE_7
GROUP BY 
    customer_id
;
````
*Result:*
| customer_id | atleast1 | nochange |
| ----------- | -------- | -------- |
| 101         | 0        | 3        |
| 103         | 4        | 0        |
| 104         | 2        | 1        |
| 105         | 1        | 0        |
| 102         | 0        | 3        |

*=> Approach: Create **changes column** true/false base on extra and exclusion column and then count value to get pizza that have extra/exclusion*
***
**8./ How many pizzas were delivered that had both exclusions and extras?**

*Answer:*
````sql
with cte_8 as (
    SELECT 
    customers.customer_id,
    customers.exclusions,
    customers.extras,
    runner.pickup_time,
    (customers.exclusions <> 'null' and customers.exclusions <> '' ) AND (customers.extras <> 'null' and customers.extras <> '' and customers.extras IS NOT NULL) changes
    FROM 
        pizza_runner.customer_orders customers
    JOIN 
        pizza_runner.runner_orders  runner
    ON customers.order_id = runner.order_id
    WHERE runner.pickup_time <> 'null' )

SELECT *
FROM cte_8
WHERE changes = true;
````
*Result:*
| customer_id | exclusions | extras | pickup_time         | changes |
| ----------- | ---------- | ------ | ------------------- | ------- |
| 104         | 2, 6       | 1, 4   | 2020-01-11 18:50:20 | true    |


*=> Approach: Similiar to previous question, just need to chage logic of changes column*
***
**9./ What was the total volume of pizzas ordered for each hour of the day?**

*Answer:*
````sql
SELECT 
    extract (hour from order_time) as intervals,
    count (*) as pizza_ordered
FROM 
    pizza_runner.customer_orders
GROUP BY 
    intervals
ORDER BY 
    intervals; 
````
*Result:*
| intervals | pizza_ordered |
| --------- | ------------- |
| 11        | 1             |
| 13        | 3             |
| 18        | 3             |
| 19        | 1             |
| 21        | 3             |
| 23        | 3             |

*=> Approach: `Extract` the **hour** part from order_time and then count numbers of pizza*
***
**10./ What was the volume of orders for each day of the week?**

*Answer:*
````sql
SELECT 
    extract (dow from order_time ) as no_day,
    to_char (order_time , 'dy') as day_of_week,
    count (*) as volume_order
FROM 
    pizza_runner.customer_orders
GROUP BY 
    no_day, day_of_week
ORDER BY 
    no_day;
````
*Result:* 

| no_day | day_of_week | volume_order |
| ------ | ----------- | ------------ |
| 3      | wed         | 5            |
| 4      | thu         | 3            |
| 5      | fri         | 1            |
| 6      | sat         | 5            |

*=> Approach: Approach: `Extract` the **day of week** part from order_time and then count numbers of pizza*