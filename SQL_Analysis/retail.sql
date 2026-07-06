CREATE TABLE online_retail_data (
    InvoiceNo VARCHAR(20),
    StockCode VARCHAR(20),
    Description TEXT,
    Quantity INTEGER,
    InvoiceDate TIMESTAMP,
    UnitPrice NUMERIC(10,2),
    CustomerID TEXT,
    Country VARCHAR(100),
    Revenue NUMERIC(12,2)
);

select * from online_retail_data Limit 10;

-- total records
select count(*) as total_rows from online_retail_data;

-- total customers
select count(distinct CustomerID) as total_customers from online_retail_data;

-- total revenue
select round(sum(revenue),2) as total_revenue from online_retail_data;

-- total products
select count(distinct Description) as total_products from online_retail_data;

-- countries served
select count(distinct Country) as countries from online_retail_data;

-- top products by revenue
select Description, round(sum(Revenue),2) as revenue from online_retail_data group by Description Order by Revenue desc limit 10;

-- top prodcuts by quantity
select Description , sum(Quantity) as units_sold from online_retail_data group by Description Order by units_sold desc limit 10;

-- revenue by country
select country , round(sum(Revenue),2) as revenue from online_retail_data group by Country Order by Revenue desc;

-- top customers
select CustomerID, round(sum(revenue),2) as revenue from online_retail_data group by CustomerID order by Revenue desc limit 10;

-- monthly revenue
select TO_CHAR(InvoiceDate, 'YYYY-MM') as month, round(sum(Revenue),2) as revenue from online_retail_data group by Month order by Month;

-- monthly orders
select TO_CHAR(InvoiceDate, 'YYYY-MM') as month, count(distinct InvoiceNo) as orders from online_retail_data group by Month Order by Month;

-- average order value
select round(avg(OrderRevenue),2) as avergae_order_value from (select InvoiceNo, SUM(revenue) as OrderRevenue from online_retail_data group by InvoiceNo) as orders;

-- rank countries
select country, round(SUM(Revenue),2) as revenue, rank() over (order by sum(Revenue) desc) as country_rank from Online_retail_data group by country;

-- running revenue
select TO_char(InvoiceDate, 'YYYY-MM') as month, sum(Revenue) as revenue, sum(sum(revenue)) over(order by TO_CHAR(InvoiceDate, 'YYYY-MM') ) as running_revenue from online_retail_data group by Month;

-- top customer in each country
with CustomerRevenue as (select Country, CustomerID, sum(Revenue) as revenue, rank() over(partition by country order by sum(Revenue) desc) as rnk from online_retail_data group by Country, CustomerID) select * from CustomerRevenue where rnk = 1;

create view top_customers as select CustomerID, Sum(Revenue) as Revenue from online_retail_data group by CustomerID;

-- highest revenue product in each country
with ProductRevenue as(select Country, Description, sum(Revenue) as total_revenue, rank() over(Partition by Country order by sum(revenue) desc)as rnk from online_retail_data group by Country, Description) select*from ProductRevenue where rnk=1;

-- monthly revenue growth
select to_char(InvoiceDate, 'YYYY-MM') as month,
round(sum(Revenue),2) as revenue
from online_retail_data 
group by month
order by month;

-- top 5 customers in each country
with CustomerSales as(
select Country, CustomerID, sum(Revenue) as revenue,
DENSE_RANK() OVER( PARTITION BY COUNTRY ORDER BY SUM(REVENUE) DESC) AS RANK_NO From online_retail_data group by Country, CustomerID)
select* from CustomerSales where rank_no <= 5;

-- revenue category
select InvoiceNo, Revenue, CASE when Revenue >= 100 then 'high'
when Revenue >= 50 then 'medium'
else 'low'
end as Revenue_Category from online_retail_data;

-- view
create view Country_Revenue as select Country, sum(revenue) as total_revenue from online_retail_data group by Country;
select * from Country_Revenue;

-- Performance
create INDEX idx_country on online_retail_data(Country);
create INDEX idx_customer on online_retail_data(CustomerID);


