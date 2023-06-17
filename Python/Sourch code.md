## **Prepare data**
1. Import from multiple csv file ( that have the same name %....)

```python
path = 'D:\Dataa\Python\Casestudy\casestudy1'

all_files = glob.glob(os.path.join(path, "sales2019_*.csv"))
df_from_each_file = (pd.read_csv(f, sep=',') for f in all_files)
df   = pd.concat(df_from_each_file, ignore_index=True)
df.to_csv( "merged.csv")
```

2. Overview data

`df.info()
df.describe()
df.head()
df.isnull()`

3. Filter data with loc and iloc

* Basic way: 

`df[df['Revenue'] == 2000]`

`df[(df['Quantity Ordered'] == 1) & ((df['Price Each'] == 700) | (df['Price Each'] == 2.99)) ]`

## **Clean**
1./ Drop/fill N/A values

`df.dropna (How = 'all')
df.fillna(inplace = True)`

2./ Change column type

`pd.to_numeric()
pd.to_datetime()`

3./ Duplicate values

`df.duplicated()
drop_duplicates()`

str.slice()

str.split()

values_count


## **Visualize**

`font = {'family': 'serif', 'color':  'black', 'weight': 'bold', 'fontname' : "monospace"}`

**Customize label**

`ax.set_title`

`ax.set_xlabel`

`ax.set_ylabel`

**Annotate (data label)**
```python
for rect in ax.patches:
    ax.annotate('{:.0f}'.format(rect.get_height()), (rect.get_x()+0.4, rect.get_height()),
                        ha='center', va='bottom',
                        color= 'black', weight = "bold", fontsize = 11)