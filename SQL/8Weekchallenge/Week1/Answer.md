**1./ What is the total amount each customer spent at the restaurant?**

*Answer:*
````sql
SELECT 
    sales.customer_id, 
    sum(menu.price) AS amount_spend
FROM 
    dannys_diner.sales sales 
JOIN 
    dannys_diner.menu menu
ON sales.product_id = menu.product_id
GROUP BY 
    sales.customer_id
ORDER BY 
    amount_spend DESC
````
*Result:*

| customer_id | amount_spend |
| ----------- | ------------ |
| A           | 76           |
| B           | 74           |
| C           | 36           |

*=> Approach: `Group by` **customer_id** and then `sum` **price** to get the amount_pend*
***
**2./ How many days has each customer visited the restaurant?**

*Answer:*

````sql
SELECT 
    sales.customer_id, 
    count (distinct(sales.order_date) No_days
FROM 
    dannys_diner.sales sales 
GROUP BY 
    sales.customer_id
ORDER BY 
    No_days DESC
````
*Result:*

| customer_id | no_days |
| ----------- | ------- |
| B           | 6       |
| A           | 4       |
| C           | 2       |

*=> Approach: `count distinct` by customer to get the date each customer visit the restaurant*
***
**3./ What was the first item from the menu purchased by each customer?**

*Answer:*

````sql
WITH ab as(
    SELECT 
        sales.customer_id, 
        min(order_date) first_date
    FROM 
        dannys_diner.sales sales
    GROUP BY 
        sales.customer_id )

SELECT 
    sales.customer_id, 
    menu.product_name
FROM 
    dannys_diner.sales sales 
JOIN 
    dannys_diner.menu menu
ON sales.product_id = menu.product_id
JOIN ab ON sales.order_date = ab.first_date
GROUP BY 
    sales.customer_id, 
    menu.product_name
ORDER BY sales.customer_id;
````
*Result:*
| customer_id | product_name |
| ----------- | ------------ |
| A           | curry        |
| A           | sushi        |
| B           | curry        |
| C           | ramen        |

*=> Approach: find the `first date` each customer buy product and join with sales table to get that product*

*=> Others Approach: use `window function` and `rank()` to get the `first date` and then filter rows that have order_date = first_date*
***
**4./  What is the most purchased item on the menu and how many times was it purchased by all customers?**

*Answer:*
````sql
SELECT 
	menu.product_id,
    menu.product_name,
    count(*) as times

FROM 
    dannys_diner.sales sales
JOIN 
    dannys_diner.menu menu
ON sales.product_id = menu.product_id
GROUP BY 1,2
ORDER BY times DESC
LIMIT 1;
````

*Result:*

| product_id | product_name | times |
| ---------- | ------------ | ----- |
| 3          | ramen        | 8     |

*=> Approach: `Group by` product_id and then count times*
***
**5./ Which item was the most popular for each customer?**

*Answer:*
````sql
WITH c as (
    SELECT 
        sales.customer_id, 
        menu.product_name ,
        count(menu.product_id) AS No_items
    FROM 
        dannys_diner.sales sales 
    JOIN 
        dannys_diner.menu menu
    ON sales.product_id = menu.product_id
    GROUP BY 
        sales.customer_id, 
        menu.product_name ),

    CTE as (
    SELECT 
        customer_id, 
        product_name, 
        rank() over( PARTITION BY customer_id 
        ORDER BY No_items DESC ) as ranking
    FROM c)

SELECT * 
FROM CTE
WHERE ranking = 1;
````

*Result:*
| customer_id | product_name | ranking |
| ----------- | ------------ | ------- |
| A           | ramen        | 1       |
| B           | ramen        | 1       |
| B           | curry        | 1       |
| B           | sushi        | 1       |
| C           | ramen        | 1       |

*=> Approach: Use `window function` and `rank()` to calculate the most buy product**
***
**6./ Which item was purchased first by the customer after they became a member?**

*Answer:*
````sql
WITH CTE_6 AS (
    SELECT 
        sales.customer_id,
        sales.product_id,
        members.join_date,
        sales.order_date,
        sales.order_date - members.join_date as date_after_join
    FROM 
        dannys_diner.sales sales
    JOIN 
        dannys_diner.members members 
    ON sales.customer_id = members.customer_id
    WHERE 
        (sales.order_date - members.join_date) > 0 )

SELECT 
    CTE_6.*
FROM 
    (
    SELECT 
        customer_id, 
        min(date_after_join) as date
    FROM CTE_6
    GROUP BY customer_id ) AS X
JOIN CTE_6 
ON X.date = CTE_6.date_after_join;
````

*Result:*
| customer_id | product_id | join_date                | order_date               | date_after_join |
| ----------- | ---------- | ------------------------ | ------------------------ | --------------- |
| A           | 3          | 2021-01-07T00:00:00.000Z | 2021-01-10T00:00:00.000Z | 3               |
| B           | 1          | 2021-01-09T00:00:00.000Z | 2021-01-11T00:00:00.000Z | 2               |

*=> Approach: Merge with members table to get the `join_date` and then find the first `order_date` after they join*
***
**7./ Which item was purchased just before the customer became a member?**

*Answer:*
````sql
WITH CTE_7 AS (
    SELECT 
        sales.customer_id,
        sales.product_id,
        members.join_date,
        sales.order_date,
        sales.order_date - members.join_date as date_after_join
    FROM 
        dannys_diner.sales sales
    JOIN 
        dannys_diner.members members 
    ON sales.customer_id = members.customer_id
    WHERE (sales.order_date - members.join_date) < 0 )

SELECT 
    CTE_7.*
FROM (
    SELECT 
        customer_id, 
        max(date_after_join) as date
    FROM CTE_7
    GROUP BY customer_id ) AS X
JOIN CTE_7 
ON X.date = CTE_7.date_after_join;
````
*Result:*
| customer_id | product_id | join_date                | order_date               | date_after_join |
| ----------- | ---------- | ------------------------ | ------------------------ | --------------- |
| A           | 1          | 2021-01-07T00:00:00.000Z | 2021-01-01T00:00:00.000Z | -6              |
| A           | 2          | 2021-01-07T00:00:00.000Z | 2021-01-01T00:00:00.000Z | -6              |
| B           | 1          | 2021-01-09T00:00:00.000Z | 2021-01-04T00:00:00.000Z | -5              |

*=> Approach: kind of the same with previous question, just need to find the first `order_date` that before `join_date`*
***
**8./ What is the total items and amount spent for each member before they became a member?**

*Answer:*
````sql
With CTE_8 as (
    SELECT 
        sales.customer_id,
        sales.product_id,
        menu.price,
        sales.order_date - members.join_date as date_after_join
    FROM 
        dannys_diner.sales sales
    JOIN 
        dannys_diner.members members 
    ON 
        sales.customer_id = members.customer_id
    JOIN dannys_diner.menu menu
    ON menu.product_id = sales.product_id
    WHERE (sales.order_date - members.join_date) < 0 )

SELECT 
    customer_id,
    count (product_id) total_items,
    sum ( price) amount_spends
FROM 
    CTE_8 
GROUP BY 
    customer_id;
````
*Result:*
| customer_id | total_items | amount_spends |
| ----------- | ----------- | ------------- |
| B           | 3           | 40            |
| A           | 2           | 25            |

*Approach: filter `order_date` before `join_date` and count product_id as total items and sum price as amount spend*
***
**9./  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**

*Answer:*
````sql
with cte_9 as (
    SELECT 
        sales.customer_id,
        sales.product_id,
        menu.price
    FROM 
        dannys_diner.sales sales
    JOIN 
        dannys_diner.menu menu 
    ON 
        sales.product_id = menu.product_id )

SELECT 
    customer_id, 
    sum (pointt) pointtt
FROM (
    SELECT 
        customer_id,
        product_id,
        price,
        CASE WHEN product_id = 1 THEN price*20
             ELSE price*10
             END AS pointt
        FROM cte_9) X
GROUP BY customer_id;
````
*Result:*
| customer_id | pointtt |
| ----------- | ------- |
| B           | 940     |
| C           | 360     |
| A           | 860     |

*=> Approach: Use `CASE WHEN` to assign point to each product and then sum it*
***
**10./ In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?**

*Answer:*
````sql
WITH CTE_10 AS (
    SELECT 
        sales.customer_id,
        sales.product_id,
        menu.price,
        sales.order_date - members.join_date as date_after_join
    FROM 
        dannys_diner.sales sales
    JOIN 
        dannys_diner.members members 
    ON sales.customer_id = members.customer_id
    JOIN 
        dannys_diner.menu menu
    ON menu.product_id = sales.product_id )

SELECT 
    customer_id,
    sum (point) point
     
FROM (
    SELECT 
        *,
        CASE 
            WHEN date_after_join BETWEEN 0 AND 7 THEN price*20
            WHEN product_id = 1 THEN price*20
            ELSE price*10
        END AS point
    FROM CTE_10 ) X

GROUP BY customer_id;
````
*Result:*
| customer_id | point |
| ----------- | ----- |
| A           | 1370  |
| B           | 1060  |

*=> Approach: Just like question number 9 but add 1 more condition that in the first week after join they have 2x point*