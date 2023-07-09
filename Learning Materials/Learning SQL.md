# Chapter 1: A Little Background

## Introduction to Database
One final note: SQL is not an acronym for anything (although many people will insist
it stands for “Structured Query Language”). When referring to the language, it is equally acceptable to say the letters individually (i.e., S. Q. L.) or to use the word sequel.

## SQL: A Nonprocedural Language
> SQL statements define the necessary inputs and outputs, but the manner in which a statement is executed is left to a component of your database engine known as the optimizer. The optimizer’s job is to look at your SQL statements and, taking into account how your tables are configured and what indexes are available, **decide the most efficient execution path** (well, not always the most efficient). 
***
# Chapter 2: Creating and Populating a Database

## MySQL Datatype

### Character Data

- Char(N) - Fix length  
- Varchar(N) - variable length  
- Text

### Numeric Data

Integer type

    - Int
    - Bigint
    - Mediumint

Float type

    - float(p, s)  
        - precision (the total number of allowable digits both to the left and to the right of the decimal point)
        - scale (the number of allowable digits to the right of the decimal point)
    
    - double(p, s)

### Temoral Data

- Date  *`Default format: YYYY/MM/DD`*
- Datetime
- Timestamp

## Table Creation

Step 1: Design  
Step 2: Refinement  
Step 3: Building SQL schema statements

Ex:
```sql
mysql> CREATE TABLE person
-> (person_id SMALLINT UNSIGNED,
-> fname VARCHAR(20),
-> lname VARCHAR(20),
-> gender ENUM('M','F'), --Add constraint
-> birth_date DATE,
-> street VARCHAR(30),
-> city VARCHAR(20),
-> state VARCHAR(20),
-> country VARCHAR(20),
-> postal_code VARCHAR(20),
-> CONSTRAINT pk_person PRIMARY KEY (person_id) --Add constraint 
-> );
```
**What is NULL**

Null is used for various cases where a value cannot be supplied, such as:

• Not applicable  
• Unknown  
• Empty set  

When designing a table, you may specify which columns are allowed to be null (the
default), and which columns are not allowed to be null (designated by adding the keywords not null after the type definition).

## Populating and Modifying Tables

### Inserting Data

```sql
mysql> INSERT INTO person
-> (person_id, fname, lname, gender, birth_date,
-> street, city, state, country, postal_code)
-> VALUES (null, 'Susan','Smith', 'F', '1975-11-02',
-> '23 Maple St.', 'Arlington', 'VA', 'USA', '20220');
Query OK, 1 row affected (0.01 sec)
```

**Note:**

- The column names and the values provided must correspond in number and type.
- If values were not provided for columns => It will return NULL ( In case the column is not allow null -> Errors)

### Updating Data

```sql
mysql> UPDATE person
-> SET street = '1225 Tremont St.',
-> city = 'Boston',
-> state = 'MA',
-> country = 'USA',
-> postal_code = '02138'
-> WHERE person_id = 1;
Query OK, 1 row affected (0.04 sec)
Rows matched: 1 Changed: 1 Warnings: 0
```

### Deleting Data

```sql
mysql> DELETE FROM person
-> WHERE person_id = 2;
Query OK, 1 row affected (0.01 sec)
```

## When Good Statements Go Bad (Error)

### Nonunique Primary Key

```sql
mysql> INSERT INTO person
-> (person_id, fname, lname, gender, birth_date)
-> VALUES (1, 'Charles','Fulton', 'M', '1968-01-15');
ERROR 1062 (23000): Duplicate entry '1' for key 'PRIMARY'
```

=> Primary key must be unique

### Nonexistent Foreign Key

```sql
mysql> INSERT INTO favorite_food (person_id, food)
-> VALUES (999, 'lasagna');
ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint
fails ('bank'.'favorite_food', CONSTRAINT 'fk_fav_food_person_id' FOREIGN KEY
('person_id') REFERENCES 'person' ('person_id'))
```
=> Values Add to a foreign key must appeared in primary key of another table

### Column Value Violations

The gender column in the person table is restricted to the values 'M' and 'F'
```sql mysql> UPDATE person
-> SET gender = 'Z'
-> WHERE person_id = 1;
ERROR 1265 (01000): Data truncated for column 'gender' at row 1 
```

### Invalid Date Conversions

Here’s an example that
uses a date format that does not match the default date format of “YYYY-MM-DD”:
```sql
mysql> UPDATE person
-> SET birth_date = 'DEC-21-1980'
-> WHERE person_id = 1;
ERROR 1292 (22007): Incorrect date value: 'DEC-21-1980' for column 'birth_date' at row 1
```

=> In general, it is always a good idea to explicitly specify the format string rather than relying on the default format. 
```sql
mysql> UPDATE person
-> SET birth_date = str_to_date('DEC-21-1980' , '%b-%d-%Y')
-> WHERE person_id = 1;
Query OK, 1 row affected (0.12 sec)
```
Here are a few more formatters that you might need when converting strings to datetimes in MySQL:

%a The short weekday name, such as Sun, Mon, ...  
%b The short month name, such as Jan, Feb, ...  
%c The numeric month (0..12)  
%d The numeric day of the month (00..31)  
%f The number of microseconds (000000..999999)  
%H The hour of the day, in 24-hour format (00..23)  
%h The hour of the day, in 12-hour format (01..12)  
%i The minutes within the hour (00..59)  
%j The day of year (001..366)  
%M The full month name (January..December)  
%m The numeric month  
%p AM or PM  
%s The number of seconds (00..59)  
%W The full weekday name (Sunday..Saturday)  
%w The numeric day of the week (0=Sunday..6=Saturday)  
%Y The four-digit y  
***
# Chapter 3: Query Primer
## Query Clauses

Several components or clauses make up the select statement. While only one of them
is mandatory when using MySQL (the select clause)

Query Clauses (6 Major clauses)

- **Select:** Determines which columns to include in the query’s result set
- **From:** Identifies the tables from which to draw data and how the tables should be joined
- **Where:** Filters out unwanted data
- **Group by:** Used to group rows together by common column values
- **Having** Filters out unwanted groups
- **Order by** Sorts the rows of the final result set by one or more columns

## The Select Clause
Even though the select clause is the first clause of a select statement, it is one of the
last clauses that the database server evaluates. The reason for this is that before you can
determine what to include in the final result set, you need to know all of the possible
columns that could be included in the final result set.

### Column Aliases
```sql
mysql> SELECT emp_id,
-> 'ACTIVE' AS status,
-> emp_id * 3.14159 AS empid_x_pi,
-> UPPER(lname) AS last_name_upper
-> FROM employee;
```

### Removing Duplicates
```sql
mysql> SELECT DISTINCT cust_id
-> FROM account;
```

>Keep in mind that generating a distinct set of results requires the data to be **sorted**, which can be **time-consuming** for large result sets. Take the time to understand the data you are working with so that you will know whether duplicates are possible.

## The From Clause

```
The from clause defines the tables used by a query, along with the means of linking the
tables together
```
### Tables

Three different types of tables meet this
relaxed definition:  
- **Permanent tables** (i.e., created using the create table statement)
- **Temporary tables** (i.e., rows returned by a subquery)
- **Virtual tables** (i.e., created using the create view statement)

### Subquery-generated tables
> A subquery is a query contained within another query. 

Subqueries can be found in various parts of a select statement; within the from
clause, however, a subquery serves the role of **generating a temporary table** that is visible
from all other query clauses and can **interact** with other tables named in the from clause.

```sql
mysql> SELECT e.emp_id, e.fname, e.lname
-> FROM (SELECT emp_id, fname, lname, start_date, title
-> FROM employee) e;
```

### Views

> A view is a **query** that is stored in the data dictionary. It looks and acts like a table, but
there is no data associated with a view (this is why I call it a **virtual table**). 

```sql
mysql> CREATE VIEW employee_vw AS
-> SELECT emp_id, fname, lname,
-> YEAR(start_date) start_year
-> FROM employee;
Query OK, 0 rows affected (0.10 sec)
```

When the view is created, *no additional data is generated or stored*: the server simply
tucks away the select statement for future use.

Views are created for various reasons, including to **hide columns** from users and to **simplify complex** database designs.


### Table Links
The second deviation from the simple from clause definition is the mandate that if more than one table appears in the from clause, the **conditions used to link** the tables must be included. 

```sql
mysql> SELECT employee.emp_id, employee.fname,
-> employee.lname, department.name dept_name
-> FROM employee INNER JOIN department
-> ON employee.dept_id = department.dept_id;
```

### Defining Table Aliases

When multiple tables are joined in a single query, you need a way to identify which table you are referring to when you reference columns.

- Use the entire table name, such as employee.emp_id.
- Assign each table an alias and use the alias throughout the query.

```sql
SELECT e.emp_id, e.fname, e.lname,
d.name dept_name
FROM employee e INNER JOIN department d
ON e.dept_id = d.dept_id;
```

> Using aliases makes for a more compact statement without causing confusion.

## The where Clause

```
The where clause is the mechanism for filtering out unwanted rows from your result set.
```

```sql
sql> SELECT emp_id, fname, lname, start_date, title
-> FROM employee
-> WHERE title = 'Head Teller';
```

You can include as many conditions as required;
individual conditions are separated using operators such as **and, or, and not**

```sql
mysql> SELECT emp_id, fname, lname, start_date, title
-> FROM employee
-> WHERE title = 'Head Teller'
-> AND start_date > '2006-01-01';
```

You should always use **parentheses** to separate groups of conditions when mixing different operators so that you, the database server, and anyone who comes along later to modify your code will be on the same page.

```sql
mysql> SELECT emp_id, fname, lname, start_date, title
-> FROM employee
-> WHERE (title = 'Head Teller' AND start_date > '2006-01-01')
-> OR (title = 'Teller' AND start_date > '2007-01-01');
```
## The group by and having Clauses
- Group by clause, which is used to group data by column values
- Having allows you to filter group data in the same way the where clause lets you filter raw data
```sql
mysql> SELECT d.name, count(e.emp_id) num_employees
-> FROM department d INNER JOIN employee e
-> ON d.dept_id = e.dept_id
-> GROUP BY d.name
-> HAVING count(e.emp_id) > 2;
```

## The order by Clause

```
The order by clause is the mechanism for sorting your result set using either raw column
data or expressions based on column data.
```
```sql 
mysql> SELECT open_emp_id, product_cd
-> FROM account
-> ORDER BY open_emp_id;
```
### Ascending Versus Descending Sort Order
```
When sorting, you have the option of specifying ascending or descending order via the
asc and desc keywords
``` 

### Sorting via Expressions
```sql
mysql> SELECT cust_id, cust_type_cd, city, state, fed_id
-> FROM customer
-> ORDER BY RIGHT(fed_id, 3);
```

### Sorting via Numeric Placeholders

Personally, I may reference columns positionally when writing ad hoc queries, but I
always reference columns by name when writing code.
# Chapter 4: Filtering

## Condition Evaluation

| Operator  | Description       |
| ------------- | -------------       |
| AND  | TRUE if all values meet condition        |
| OR  | TRUE if any values meet condition |
| NOT  | Show result when condition is False        |
| BETWEEN  | TRUE if within the range  |
| LIKE  | TRUE if match a pattern        |
| IN  | TRUE if equal to one of a list specify |
| ALL  | TRUE if all subquery meet condition|
| ANY  | TRUE if any subquery meet condition |
| EXISTS  | TRUE if subquery return one or more row|


## Type of Conditions

Equally: =  
Non-equally: <>  
Range: Between .. and    
Matching: LIKE  
***
# Chapter 5: Querying Multiple Tables

## Inner join

```sql
mysql> SELECT e.fname, e.lname, d.name
-> FROM employee e INNER JOIN department d
-> ON e.dept_id = d.dept_id;
```

## Joining Three or More Tables
```sql
mysql> SELECT a.account_id, c.fed_id, e.fname, e.lname
-> FROM customer c INNER JOIN account a
-> ON a.cust_id = c.cust_id
-> INNER JOIN employee e
-> ON a.open_emp_id = e.emp_id
-> WHERE c.cust_type_cd = 'B';
```

## Self Join

## Equi-Joins Versus Non-Equi-Joins

## Join Conditions Versus Filter Conditions
***

# Chapter 6: Working with Sets

## Set Theory in Practice

When performing set operations on two data sets, the following guidelines must apply:
- Both data sets must have the same number of columns.
- The data types of each column across the two data sets must be the same (or the server must be able to convert one to the other).

## Set Operators

### The union Operator
```
The union and union all operators allow you to combine multiple data sets. 
```

=> Union sorts the combined set and removes duplicates, whereas union all does not. 

```sql
mysql> SELECT 'IND' type_cd, cust_id, lname name
-> FROM individual
-> UNION ALL
-> SELECT 'BUS' type_cd, cust_id, name
-> FROM business;
```

### The intersect Operator
```
 INTERSECT returns distinct rows that are output by both the left and right input queries operator.
 ```
```sql
SELECT emp_id, fname, lname
FROM employee
INTERSECT
SELECT cust_id, fname, lname
FROM individual;
```

### The except Operator

```
The except operator returns the first table minus any overlap with the second table.
```

```sql
SELECT emp_id
FROM employee
WHERE assigned_branch_id = 2
AND (title = 'Teller' OR title = 'Head Teller')
EXCEPT
SELECT DISTINCT open_emp_id
FROM account
WHERE open_branch_id = 2;
```

## Set Operation Rules

### Sorting Compound Query Results

Add an order by clause **after the last query**. When specifying column names in the order by clause, you will need to choose from the **column names in the first query** of the compound query.

```sql
mysql> SELECT emp_id, assigned_branch_id
-> FROM employee
-> WHERE title = 'Teller'
-> UNION
-> SELECT open_emp_id, open_branch_id
-> FROM account
-> WHERE product_cd = 'SAV'
-> ORDER BY emp_id;
```

### Set Operation Precedence

In general, compound queries containing three or more queries are evaluated in order from top to bottom, but with the following caveats:

- The ANSI SQL specification calls for the intersect operator to have precedence
over the other set operators.
- You may dictate the order in which queries are combined by enclosing multiple queries in parentheses.
***
# Chapter 7: Data Generation, Conversion, and Manipulation

# Chapter 8: Grouping & Aggregates

## Grouping Concepts

## Aggregate functions
`Max()` Returns the maximum value within a set  
`Min()` Returns the minimum value within a set  
`Avg()` Returns the average value across a set  
`Sum()` the sum of the values across a set  
`Count()` Returns the number of values in a set  

## Implicit Versus Explicit Groups

## Counting Distinct Values
```sql
mysql> SELECT COUNT(DISTINCT open_emp_id)
-> FROM account;
```

## Using Expressions
```sql
mysql> SELECT MAX(pending_balance - avail_balance) max_uncleared
-> FROM account;
```

## How Nulls Are Handled
The `sum()`, `max()`, and `avg()` ignore any null values encountered.  

Count(*) counts the number of rows, whereas count(val) counts the number of values contained in the val column and ignores any null values encountered

## Generating Groups
## Generating Rollups
```SQL
mysql> SELECT product_cd, open_branch_id,
-> SUM(avail_balance) tot_balance
-> FROM account
-> GROUP BY product_cd, open_branch_id WITH ROLLUP;
```

=> The ROLLUP is an extension of the GROUP BY clause. The ROLLUP option allows you to include extra rows that represent the subtotals,

## Group Filter Conditions

When grouping data, you also can apply filter
conditions to the data after the groups have been generated with `Having` clause
```sql
mysql> SELECT product_cd, SUM(avail_balance) prod_balance
-> FROM account
-> WHERE status = 'ACTIVE'
-> GROUP BY product_cd
-> HAVING SUM(avail_balance) >= 10000;  
```

# Chapter 9: Subqueries

## What Is a Subquery?
```
A subquery is a query contained within another SQL statement (which I refer to as the containing statement for the rest of this discussion)

```