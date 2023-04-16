### **C. Ingredient Optimisation**
**1./ What are the standard ingredients for each pizza?**

*Answer:*

````sql
WITH cte_1 AS (

    SELECT 
        pizza_id,
        regexp_split_to_table (toppings, ', ' )::int topping_id
    FROM 
        pizza_runner.pizza_recipes)

SELECT 
    pizza_id,
    topping_name
FROM 
    cte_1 
JOIN 
    pizza_runner.pizza_toppings pt on pt.topping_id = cte_1.topping_id
ORDER BY 1;
````
*Result:*
| pizza_id | topping_name |
| -------- | ------------ |
| 1        | BBQ Sauce    |
| 1        | Pepperoni    |
| 1        | Cheese       |
| 1        | Salami       |
| 1        | Chicken      |
| 1        | Bacon        |
| 1        | Mushrooms    |
| 1        | Beef         |
| 2        | Tomato Sauce |
| 2        | Cheese       |
| 2        | Mushrooms    |
| 2        | Onions       |
| 2        | Peppers      |
| 2        | Tomatoes     |


*=> Approach: Use `split_to_table` to extract substring and get ingredients of each pizza*
***
**2./ What was the most commonly added extra?**

*Answer:*
```sql
with cte_2 as (
    SELECT 
        pizza_id,
        extras
    FROM 
        pizza_runner.customer_orders
    WHERE 
        extras <> 'null' and extras <> '' )

SELECT 
    pt.topping_name, 
    times  
FROM 
    pizza_runner.pizza_toppings as pt
JOIN 
		(SELECT
		regexp_split_to_table (extras, ', ' )::int extra,
		count (*) times
        FROM cte_2
		GROUP BY extra) as X
ON pt.topping_id = X.extra
ORDER BY 2;
```

*Result:*

| topping_name | times |
| ------------ | ----- |
| Cheese       | 1     |
| Chicken      | 1     |
| Bacon        | 4     |

*=> Approach: `split_to_table` extra column and then count **topping_name***
***
**3./ What was the most common exclusion?**

*Answer:*
```sql
with cte_3 as (
    SELECT 
        pizza_id,
        exclusions
    FROM 
        pizza_runner.customer_orders
    WHERE 
        exclusions <> 'null' and exclusions <> '' )

SELECT 
    pt.topping_name, 
    times  
FROM 
    pizza_runner.pizza_toppings as pt
JOIN 
		(SELECT
		regexp_split_to_table (exclusions, ', ' )::int exclusions,
		count (*) times
        FROM cte_3
		GROUP BY exclusions) as X
ON pt.topping_id = X.exclusions
ORDER BY 2;
```

*Result:*
| topping_name | times |
| ------------ | ----- |
| BBQ Sauce    | 1     |
| Mushrooms    | 1     |
| Cheese       | 4     |

*=> Approach: Approach: `split_to_table` exclusions column and then count **topping_name***