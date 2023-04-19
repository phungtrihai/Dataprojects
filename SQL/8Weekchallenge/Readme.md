
**<p align="center"> LEARNING SUMMARY </p>**

Through this 8 week challange, I learnt and applied these functions to process and wrangle data:

**1. Table relate functions:**
* `CREATE TABLE`, `ALTER` and `UPDATE` table to change data type, `DELETE` rows from table

**2. Functions to handle null value:**
* Use `COALESCE` / `NULLIF` to replace null value
* `IS NULL` / `IS NOT NULL` to filter null value

**3. Functions to handle Strings**
* Extract smaller part form string using `SUBSTRING`, `LEFT` and `RIGHT`
* Replace value with `REPLACE`
* `SPLIT_TO_TABLE` to split a string based on a specified delimiter and `STRING_AGG` to aggregate multiple strings.

**4. Functions to handle numerical values**
* Round number using `ROUND`, `FLOOR` and `CEIL` 
* change to appropriate type using `::`

**5. Functions to handle datetime**
* Use `DATE_PART` to get week, month or year from Date
* `DATE_TRUNC` to get first day of month, week or year.
* `TO_DATE` to change to datetime type

**6. Query from many table with JOIN, Append talbe with UNION**

**7. Perform more complex query** with `CTE` and `nest query`

**8. Calculate aggregate value** - sum(), min(), max(), count() with `GROUP BY`

**9. Window Function**
* Aggregate value with sum(), min(), max()
* Calculate rank or sequence of rows using `RANK` and `ROW_NUMBER`
* Get value from previous or following rows with `LAG` and `LEAD`
* Specify `window frame` to calculate **cumulative sum** and **rolling average**

**10. Other Functions**
* `CASE WHEN` to create new column 
* Combine `ORDER BY` and `LIMIT` to select top or bottom value
***