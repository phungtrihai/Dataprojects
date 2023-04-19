### **A. Data Exploration and Cleansing**

**1. Update the `fresh_segments.interest_metrics` table by modifying the month_year column to be a date data type with the start of the month**

*Answer:*
```sql
ALTER TABLE 
    fresh_segments.interest_metrics
ALTER 
    column month_year type varchar(10);
UPDATE fresh_segments.interest_metrics
SET month_year = to_date(month_year, 'MM-YYYY');
ALTER TABLE fresh_segments.interest_metrics
ALTER column month_year type date USING month_year::date;

SELECT 	*
FROM fresh_segments.interest_metrics 
LIMIT 10;
```

*Result:*

| _month | _year | month_year               | interest_id | composition | index_value | ranking | percentile_ranking |
| ------ | ----- | ------------------------ | ----------- | ----------- | ----------- | ------- | ------------------ |
| 7      | 2018  | 2018-07-01T00:00:00.000Z | 32486       | 11.89       | 6.19        | 1       | 99.86              |
| 7      | 2018  | 2018-07-01T00:00:00.000Z | 6106        | 9.93        | 5.31        | 2       | 99.73              |
| 7      | 2018  | 2018-07-01T00:00:00.000Z | 18923       | 10.85       | 5.29        | 3       | 99.59              |
| 7      | 2018  | 2018-07-01T00:00:00.000Z | 6344        | 10.32       | 5.1         | 4       | 99.45              |
| 7      | 2018  | 2018-07-01T00:00:00.000Z | 100         | 10.77       | 5.04        | 5       | 99.31              |
| 7      | 2018  | 2018-07-01T00:00:00.000Z | 69          | 10.82       | 5.03        | 6       | 99.18              |
| 7      | 2018  | 2018-07-01T00:00:00.000Z | 79          | 11.21       | 4.97        | 7       | 99.04              |
| 7      | 2018  | 2018-07-01T00:00:00.000Z | 6111        | 10.71       | 4.83        | 8       | 98.9               |
| 7      | 2018  | 2018-07-01T00:00:00.000Z | 6214        | 9.71        | 4.83        | 8       | 98.9               |
| 7      | 2018  | 2018-07-01T00:00:00.000Z | 19422       | 10.11       | 4.81        | 10      | 98.63         

*Approach:* Use `ALTER TABLE` and `UPDATE` to update new data type of column
***
**2. What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?**

*Answer:*
```sql
SELECT
    month_year,
    count (*) as records
FROM
    fresh_segments.interest_metrics 
GROUP BY 1
ORDER BY 1 NULLS FIRST;
```

*Result:*
| month_year               | records |
| ------------------------ | ------- |
|                          | 1194    |
| 2018-07-01T00:00:00.000Z | 729     |
| 2018-08-01T00:00:00.000Z | 767     |
| 2018-09-01T00:00:00.000Z | 780     |
| 2018-10-01T00:00:00.000Z | 857     |
| 2018-11-01T00:00:00.000Z | 928     |
| 2018-12-01T00:00:00.000Z | 995     |
| 2019-01-01T00:00:00.000Z | 973     |
| 2019-02-01T00:00:00.000Z | 1121    |
***

**3. What do you think we should do with these null values in the fresh_segments.interest_metrics**

Some way to clean null value:
* Remove them 
* Replace with mean / median (numerical) and mode (text) 
* Backfill or Forwardfill - when data is order chronologically or when we have the logic of collecting data.

In this case, we can not use backfill/forward fill because the data is not order chronologically, we also dont have the interst_id for null value so we will consider remove null value.
```sql
DELETE FROM fresh_segments.interest_metrics
WHERE month_year IS NULL;
SELECT count(*) AS null_count
FROM fresh_segments.interest_metrics
WHERE month_year IS NULL;
```
| null_count |
| ---------- |
| 0          |

***
**4. How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?**

*Answer:*
```sql
SELECT
    count (interest_id) not_in_map
FROM    
    fresh_segments.interest_metrics
WHERE interest_id::int NOT IN (SELECT distinct id FROM fresh_segments.interest_map);

SELECT
    count (id) not_in_metric
FROM    
    fresh_segments.interest_map
WHERE id NOT IN (SELECT distinct interest_id::int FROM fresh_segments.interest_metrics);
```

*Result:*
| not_in_map |
| ---------- |
| 0          |

| not_in_metric |
| ------------- |
| 7             |
***
**5. Summarise the id values in the fresh_segments.interest_map by its total record count in this table**

*Answer:*
```sql
SELECT
    maps.id,
    count (metric.interest_id) as record
FROM 
    fresh_segments.interest_map maps
LEFT JOIN 
    fresh_segments.interest_metrics metric
ON maps.id = metric.interest_id::INT
GROUP BY 1
LIMIT 10;
```

*Result:*
| id  | record |
| --- | ------ |
| 1   | 12     |
| 2   | 11     |
| 3   | 10     |
| 4   | 14     |
| 5   | 14     |
| 6   | 14     |
| 7   | 11     |
| 8   | 13     |
| 12  | 14     |
| 13  | 13     |
***
**6. What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where interest_id = 21246 in your joined output and include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.**

Because all id from interest_metric are in interest_map so we can use inner or left join from interest_map.
***
### **B. Interest Analysis**
**1. Which interests have been present in all month_year dates in our dataset?**

*Answer:*
```sql
SELECT
    interest_id,
    count (distinct month_year) appearance
FROM fresh_segments.interest_metrics
GROUP BY 1
HAVING count (distinct month_year) = (SELECT count (distinct month_year) FROM fresh_segments.interest_metrics) 	
LIMIT 10;
```

*Result:*
| interest_id | appearance |
| ----------- | ---------- |
| 100         | 14         |
| 10008       | 14         |
| 10009       | 14         |
| 10010       | 14         |
| 101         | 14         |
| 102         | 14         |
| 10249       | 14         |
| 10250       | 14         |
| 10251       | 14         |
| 10284       | 14         |

*Approach:* calculate apprearance of interest_id in each month and select id that have appearance = distinct month_year.
***
**2. Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months - which total_months value passes the 90% cumulative percentage value?**

*Answer:*
```sql
WITH cte_2 as (
SELECT
    interest_id,
    count (distinct month_year) appearance
FROM fresh_segments.interest_metrics
GROUP BY 1)
,
cte_2b as (
SELECT 
    appearance,
    count (interest_id) id_count,
    (SELECT count (interest_id) FROM cte_2) total_id    
FROM cte_2
GROUP BY 1
ORDER BY 2 DESC)

SELECT
	*,
    round (100 * (sum(id_count) OVER (ORDER BY appearance DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW))::int / total_id ,2) as cum_pct
FROM cte_2b;
```
*Result:*
| appearance | id_count | total_id | cum_pct |
| ---------- | -------- | -------- | ------- |
| 14         | 480      | 1202     | 39.00   |
| 13         | 82       | 1202     | 46.00   |
| 12         | 65       | 1202     | 52.00   |
| 11         | 94       | 1202     | 59.00   |
| 10         | 86       | 1202     | 67.00   |
| 9          | 95       | 1202     | 75.00   |
| 8          | 67       | 1202     | 80.00   |
| 7          | 90       | 1202     | 88.00   |
| 6          | 33       | 1202     | 90.00   |
| 5          | 38       | 1202     | 94.00   |
| 4          | 32       | 1202     | 96.00   |
| 3          | 15       | 1202     | 97.00   |
| 2          | 12       | 1202     | 98.00   |
| 1          | 13       | 1202     | 100.00  |
***
**3. If we were to remove all interest_id values which are lower than the total_months value we found in the previous question - how many total data points would we be removing?**

*Answer:*
We will remove interest_id that appear in less than 6 month:
```sql
SELECT 
    sum (appearance) remove_records
FROM
	(SELECT
		interest_id,
    	count (distinct month_year) appearance
	FROM fresh_segments.interest_metrics
	GROUP BY 1
	HAVING count (distinct month_year) < 6) X
```
*Result:*
| remove_records |
| -------------- |
| 400            |

**4. Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 months present to a removed interest example for your arguments - think about what it means to have less months present from a segment perspective.**

*Answer:* I think we can not remove these data points because 1 interest_id may appear in a few month but in each month they appear multiple time so we much take them for consideration. In the other hand, we also can have interest_id that appear in all month but just 1 times each month.


**5. After removing these interests - how many unique interests are there for each month?**

*Answer:*
```sql
WITH CTE AS
    (SELECT
    	interest_id,
        count (distinct month_year)
    FROM fresh_segments.interest_metrics
    GROUP BY 1
    HAVING count (distinct month_year) >= 6)
    
SELECT
  month_year,
  count (distinct interest_id) unique_interests
FROM
  fresh_segments.interest_metrics
WHERE interest_id 
IN (SELECT interest_id FROM CTE)	
GROUP BY 1
ORDER BY 1;
```

*Result:*
| month_year               | unique_interests |
| ------------------------ | ---------------- |
| 2018-07-01T00:00:00.000Z | 709              |
| 2018-08-01T00:00:00.000Z | 752              |
| 2018-09-01T00:00:00.000Z | 774              |
| 2018-10-01T00:00:00.000Z | 853              |
| 2018-11-01T00:00:00.000Z | 925              |
| 2018-12-01T00:00:00.000Z | 986              |
| 2019-01-01T00:00:00.000Z | 966              |
| 2019-02-01T00:00:00.000Z | 1072             |
| 2019-03-01T00:00:00.000Z | 1078             |
| 2019-04-01T00:00:00.000Z | 1035             |
| 2019-05-01T00:00:00.000Z | 827              |
| 2019-06-01T00:00:00.000Z | 804              |
| 2019-07-01T00:00:00.000Z | 836              |
| 2019-08-01T00:00:00.000Z | 1062             |
***
*Approach:* Use `IN` to filter interest_id that appear in more than 6 month.
***

### **C. Segment Analysis**
**1. Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any month_year? Only use the maximum composition value for each interest but you must keep the corresponding month_year**

*Answer:*
```sql
ALTER TABLE 
    fresh_segments.interest_metrics
ALTER 
    column month_year type varchar(10);
UPDATE fresh_segments.interest_metrics
SET month_year = to_date(month_year, 'MM-YYYY');
ALTER TABLE fresh_segments.interest_metrics
ALTER column month_year type date USING month_year::date;

DROP TABLE IF EXISTS filtered_data;
CREATE TEMP TABLE filtered_data AS (
	WITH cte_total_months AS (
		SELECT 
            interest_id,
			count(DISTINCT month_year) AS total_months
		FROM fresh_segments.interest_metrics
		GROUP BY interest_id
		HAVING count(DISTINCT month_year) >= 6
	)
SELECT *
FROM fresh_segments.interest_metrics
WHERE interest_id IN (
	SELECT interest_id
	FROM cte_total_months)

);
SELECT 
    month_year,
	interest_id,
	ip.interest_name,
	composition,
	rank() OVER ( ORDER BY composition desc) AS rnk
FROM 
    filtered_data
JOIN fresh_segments.interest_map AS ip 
ON interest_id::int = ip.id
ORDER BY 4 DESC
LIMIT 10;
```

*Result:*
| month_year               | interest_id | interest_name                     | composition | rnk |
| ------------------------ | ----------- | --------------------------------- | ----------- | --- |
| 2018-12-01T00:00:00.000Z | 21057       | Work Comes First Travelers        | 21.2        | 1   |
| 2018-10-01T00:00:00.000Z | 21057       | Work Comes First Travelers        | 20.28       | 2   |
| 2018-11-01T00:00:00.000Z | 21057       | Work Comes First Travelers        | 19.45       | 3   |
| 2019-01-01T00:00:00.000Z | 21057       | Work Comes First Travelers        | 18.99       | 4   |
| 2018-07-01T00:00:00.000Z | 6284        | Gym Equipment Owners              | 18.82       | 5   |
| 2019-02-01T00:00:00.000Z | 21057       | Work Comes First Travelers        | 18.39       | 6   |
| 2018-09-01T00:00:00.000Z | 21057       | Work Comes First Travelers        | 18.18       | 7   |
| 2018-07-01T00:00:00.000Z | 39          | Furniture Shoppers                | 17.44       | 8   |
| 2018-07-01T00:00:00.000Z | 77          | Luxury Retail Shoppers            | 17.19       | 9   |
| 2018-10-01T00:00:00.000Z | 12133       | Luxury Boutique Hotel Researchers | 15.15       | 10  |
***
**2. Which 5 interests had the lowest average ranking value?**

*Answer:*
```sql 
 SELECT
    im.interest_name,
    avg (t1.ranking) as ranking
 FROM filtered_data t1
 JOIN fresh_segments.interest_map im
 ON im.id = t1.interest_id::int
 GROUP BY 1
 ORDER BY 2 desc
 LIMIT 10;
 ```

*Result:*
| interest_name                                      | ranking               |
| -------------------------------------------------- | --------------------- |
| League of Legends Video Game Fans                  | 1037.2857142857142857 |
| Computer Processor and Data Center Decision Makers | 974.1250000000000000  |
| Astrology Enthusiasts                              | 968.5000000000000000  |
| Medieval History Enthusiasts                       | 961.7142857142857143  |
| Budget Mobile Phone Researchers                    | 961.0000000000000000  |
| Comedy Movie and TV Enthusiasts                    | 956.6363636363636364  |
| Haunted House Researchers                          | 953.1250000000000000  |
| Off the Grid Living Enthusiasts                    | 952.7500000000000000  |
| Video Gamers                                       | 952.3636363636363636  |
| Readers of El Salvadoran Content                   | 952.3636363636363636  |
***
**3. Which 5 interests had the largest standard deviation in their percentile_ranking value?**

*Answer:*
```sql
SELECT
    im.interest_name,
    stddev_samp (t1.percentile_ranking) as std_ranking
FROM filtered_data t1
JOIN fresh_segments.interest_map im
ON im.id = t1.interest_id::int
GROUP BY 1
ORDER BY 2 desc
LIMIT 5;
```

*Result:*

| interest_name                          | std_ranking        |
| -------------------------------------- | ------------------ |
| Techies                                | 30.175047086403477 |
| Entertainment Industry Decision Makers | 28.97491995962486  |
| Oregon Trip Planners                   | 28.318455623301364 |
| Personalized Gift Shoppers             | 26.24268591980848  |
| Tampa and St Petersburg Trip Planners  | 25.612267373272516 |

*Approach:* Use `stddev_samp` to calculate standardiviation.
***
**4. For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values for each interest and its corresponding year_month value? Can you describe what is happening for these 5 interests?**

*Answer:*
```sql
with 
cte_4 as (
    SELECT
        interest_id,
        stddev_samp (percentile_ranking) as std_percentile
    FROM filtered_data
    GROUP BY 1
    ORDER BY 2 desc
    LIMIT 5)
,
cte_4b as (
    SELECT
        interest_id,
        max (percentile_ranking) OVER (PARTITION BY interest_id) as max_percentile,
        min (percentile_ranking) OVER (PARTITION BY interest_id) as min_percentile
    FROM filtered_data
    WHERE interest_id IN (SELECT interest_id FROM cte_4))

SELECT
    t1.interest_id,
    t2.max_percentile,
    t2.min_percentile,
    t1.std_percentile
FROM
    cte_4 t1
JOIN cte_4b t2
ON t1.interest_id = t2.interest_id
GROUP BY 1,2,3,4;
```

*Result:*
| interest_id | max_percentile | min_percentile | std_percentile     |
| ----------- | -------------- | -------------- | ------------------ |
| 10839       | 75.03          | 4.84           | 25.612267373272523 |
| 20764       | 86.15          | 11.23          | 28.97491995962485  |
| 23          | 86.69          | 7.92           | 30.175047086403474 |
| 38992       | 82.44          | 2.2            | 28.318455623301364 |
| 43546       | 73.15          | 5.7            | 26.242685919808476 |

*Approach:* Use window function `max()` and `min()` to get min and max percentile of each interest_id.
***
**5. How would you describe our customers in this segment based off their composition and ranking values? What sort of products or services should we show to these customers and what should we avoid?**

We can see that top interest of all time include Work Comes First Travelers, Gym Equipment Owners and Shoppers. It's seem that our customer prefer outside activity/sport and shopping related events so we should consider develop these activities. In the other hand, avoid activities that involved video game or research cause these are the lowest ranking activities.
***

### **D. Index Analysis**
* The `index_value` is a measure which can be used to reverse calculate the average composition for Fresh Segments’ clients.

* `Average composition` can be calculated by dividing the composition column by the index_value column rounded to 2 decimal places.

**1. What is the top 10 interests by the average composition for each month?**

*Answer:*
```sql
DROP TABLE IF EXISTS top10_by_month;
CREATE TEMP TABLE top10_by_month AS 
WITH cte_1 as (
    SELECT
        month_year,
        interest_id,
        round (avg(composition / index_value)::numeric ,2) as avg_composition,
        rank () OVER (PARTITION BY month_year ORDER BY avg(composition / index_value) DESC) AS ranks
    FROM
        fresh_segments.interest_metrics
    GROUP BY 1, 2
    ORDER BY 1 ASC, 3 DESC)

SELECT * 
FROM cte_1
WHERE ranks <= 10;
 
SELECT *
FROM top10_by_month;
```

*Result:*
| month_year               | interest_id | avg_composition | ranks |
| ------------------------ | ----------- | --------------- | ----- |
| 2018-07-01T00:00:00.000Z | 6324        | 7.36            | 1     |
| 2018-07-01T00:00:00.000Z | 6284        | 6.94            | 2     |
| 2018-07-01T00:00:00.000Z | 4898        | 6.78            | 3     |
| 2018-07-01T00:00:00.000Z | 77          | 6.61            | 4     |
| 2018-07-01T00:00:00.000Z | 39          | 6.51            | 5     |
| 2018-07-01T00:00:00.000Z | 18619       | 6.10            | 6     |
| 2018-07-01T00:00:00.000Z | 6208        | 5.72            | 7     |
| 2018-07-01T00:00:00.000Z | 21060       | 4.85            | 8     |
| 2018-07-01T00:00:00.000Z | 21057       | 4.80            | 9     |
| 2018-07-01T00:00:00.000Z | 82          | 4.71            | 10    |
| 2018-08-01T00:00:00.000Z | 6324        | 7.21            | 1     |
| 2018-08-01T00:00:00.000Z | 6284        | 6.62            | 2     |
| 2018-08-01T00:00:00.000Z | 77          | 6.53            | 3     |
| 2018-08-01T00:00:00.000Z | 39          | 6.30            | 4     |
| 2018-08-01T00:00:00.000Z | 4898        | 6.28            | 5     |
| 2018-08-01T00:00:00.000Z | 21057       | 5.70            | 6     |
| 2018-08-01T00:00:00.000Z | 18619       | 5.68            | 7     |
| 2018-08-01T00:00:00.000Z | 6208        | 5.58            | 8     |
| 2018-08-01T00:00:00.000Z | 7541        | 4.83            | 9     |
| 2018-08-01T00:00:00.000Z | 5969        | 4.72            | 10    |

*Approach:* Calculate avg_composition and then use `rank() window function` to calculate rank base on avg_composition and select **rank <=10**.
***
**2. For all of these top 10 interests - which interest appears the most often?**

*Answer:*
```sql
SELECT
    interest_id,
    count (*) times
FROM top10_by_month    
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```

*Result:*
| interest_id | times |
| ----------- | ----- |
| 7541        | 10    |
| 6065        | 10    |
| 5969        | 10    |
| 21245       | 9     |
| 18783       | 9     |
***
**3. What is the average of the average composition for the top 10 interests for each month?**

*Answer:*
```sql
SELECT
    month_year,
    ROUND (avg (avg_composition), 2) avg_composition
FROM
    top10_by_month
GROUP BY 1
ORDER BY 1;
```

*Result:*
| month_year               | avg_composition |
| ------------------------ | --------------- |
| 2018-07-01T00:00:00.000Z | 6.04            |
| 2018-08-01T00:00:00.000Z | 5.95            |
| 2018-09-01T00:00:00.000Z | 6.90            |
| 2018-10-01T00:00:00.000Z | 7.07            |
| 2018-11-01T00:00:00.000Z | 6.62            |
| 2018-12-01T00:00:00.000Z | 6.65            |
| 2019-01-01T00:00:00.000Z | 6.40            |
| 2019-02-01T00:00:00.000Z | 6.58            |
| 2019-03-01T00:00:00.000Z | 6.17            |
| 2019-04-01T00:00:00.000Z | 5.75            |
| 2019-05-01T00:00:00.000Z | 3.54            |
| 2019-06-01T00:00:00.000Z | 2.43            |
| 2019-07-01T00:00:00.000Z | 2.77            |
| 2019-08-01T00:00:00.000Z | 2.63            |
***
**4. What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 nd include the previous top ranking interests in the same output shown below.**

*Answer:*
```sql
SELECT
  t1.month_year,
  t2.interest_name,
  t1.avg_composition,
  round (avg (t1.avg_composition) OVER (ORDER BY t1.month_year ASC rows between current row and 2 following), 2) AS rolling_avg_3,
  lag (t2.interest_name, 1) OVER (ORDER BY t1.month_year ASC) AS previous_rank1
FROM top10_by_month t1
JOIN fresh_segments.interest_map t2
ON t1.interest_id::int = t2.id
WHERE t1.ranks = 1
AND t1.month_year BETWEEN '2018-08-01' AND '2019-08-01';
```
*Result:*

| month_year               | interest_name                 | avg_composition | rolling_avg_3 | previous_rank1              |
| ------------------------ | ----------------------------- | --------------- | ------------- | --------------------------- |
| 2018-08-01T00:00:00.000Z | Las Vegas Trip Planners       | 7.21            | 8.20          |                             |
| 2018-09-01T00:00:00.000Z | Work Comes First Travelers    | 8.26            | 8.56          | Las Vegas Trip Planners     |
| 2018-10-01T00:00:00.000Z | Work Comes First Travelers    | 9.14            | 8.58          | Work Comes First Travelers  |
| 2018-11-01T00:00:00.000Z | Work Comes First Travelers    | 8.28            | 8.08          | Work Comes First Travelers  |
| 2018-12-01T00:00:00.000Z | Work Comes First Travelers    | 8.31            | 7.88          | Work Comes First Travelers  |
| 2019-01-01T00:00:00.000Z | Work Comes First Travelers    | 7.66            | 7.29          | Work Comes First Travelers  |
| 2019-02-01T00:00:00.000Z | Work Comes First Travelers    | 7.66            | 6.83          | Work Comes First Travelers  |
| 2019-03-01T00:00:00.000Z | Alabama Trip Planners         | 6.54            | 5.74          | Work Comes First Travelers  |
| 2019-04-01T00:00:00.000Z | Solar Energy Researchers      | 6.28            | 4.49          | Alabama Trip Planners       |
| 2019-05-01T00:00:00.000Z | Readers of Honduran Content   | 4.41            | 3.33          | Solar Energy Researchers    |
| 2019-06-01T00:00:00.000Z | Las Vegas Trip Planners       | 2.77            | 2.77          | Readers of Honduran Content |
| 2019-07-01T00:00:00.000Z | Las Vegas Trip Planners       | 2.82            | 2.78          | Las Vegas Trip Planners     |
| 2019-08-01T00:00:00.000Z | Cosmetics and Beauty Shoppers | 2.73            | 2.73          | Las Vegas Trip Planners     |

*Approach:* Specify `window frame` to calculate rolling avg and Use `Lag` to find the privious top 1 interest_name.
***
**5. Provide a possible reason why the max average composition might change from month to month? Could it signal something is not quite right with the overall business model for Fresh Segments?**

`<Updating>`