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

