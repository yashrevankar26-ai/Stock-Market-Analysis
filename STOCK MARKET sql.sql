use stock_market;
show tables;

-- KPIs 
Select concat(round(sum(Market_Capitalization)/1000000,0), "M") as Total_Market_Capatilization from stocks; 

Select round(avg(avg_vol),0) as Avg_Daily_Trading_Volume from fact_Daily_Prices;

Select concat(round(stddev(return_pct)*100,0) , "%") as Volatility from fact_Dtrades; 

Select based_on_return as Top_Performing_Sector from stocks limit 1;

Select concat(round(((sum(current_value) - sum(initial_value)) / sum(initial_value))*100, 0), "%") as Portfolio_Return from stocks;

Select concat(round(sum(quantity_sold)/1000, 0), "K") as Total_Quantity_Sold from fact_dtrades;

Select concat(round(sum(Share_price * quantity)/1000,0), "K") as Portfolio_Value from stocks;

Select concat(round(count(Trader_id) / count(order_id) * 100,0), "%") as Order_Execution_Rate from Fact_orders;

select concat(round(sum(win_flag) / count(win_loss) *100,0), "%") as Trade_Win_Rate from fact_dtrades;

select concat(round((sum(gross_sell_amount) - sum(gross_buy_amount)) / 1000000, 0) , "M" ) as Trader_Performance from fact_dtrades;


-- View Program of Company Data
Create View Company_Data as 
Select a.Company_name as Company_Name, a.Ticker as Ticker , b.Sector_name Sector_Name, c.Exchange_name  Exchange_Name, C.Country Country, 
round(Avg(d.open),0) Average_Opening, round(Sum(d.open),0) Total_Opening, 
round(max(d.High),0)  Max_High, round(Min(d.high),0) as Min_High, 
round(max(d.low),0) Max_Low, round(min(d.low),0) Min_Low,
round(Avg(d.close),0) Avg_Closeing, round(Sum(d.close),0) Total_Closeing, 
round(Avg(d.volume),0) Avg_Volumme, round(Sum(d.volume),0) Total_Volume,
round(Sum(d.adjusted_close),0) Total_Adjusted_Close, round(Avg(d.adjusted_close),0) Avg_Adjusted_Close,
Max(e.split_ratio) as Max_Split_Ratio,
round(sum(f.quantity),0) Total_Quantity, round(Avg(f.quantity),0) Avg_Quantity, 
round(Avg(f.price),0) Avg_Price, round(Sum(f.price),0) Total_Price, 
round(Sum(f.fees),0) Total_Fees 
from dim_company as a 
left join fact_trades as f 
on a.company_id = f.company_id
left join fact_splits as e
on a.company_id = e.company_id
left join fact_daily_prices as d
on a.company_id = d.company_id
left join dim_exchange as c
on a.exchange_id = c.exchange_id
left join dim_sector as b
on b.sector_id = a.sector_id
group by a.Company_name, a.ticker, b.sector_name, c.exchange_name, c.country
order by a.company_name;

##Drop view Company_Data; 

-- COMPANY DATA 
Select * from Company_Data;


-- MONTHS BY QUANTITY SOLD
Select a.month_name as Month_Name, 
sum(b.Quantity_sold) as Quantity_sold 
from Dim_calendar as a 
join fact_Dtrades as b
on a.calendar_id = b.calendar_id
group by month_name, a.month
order by a.month;


-- COMPANIES BY MARKET CAPATILIZATION
Select a.company_name as Company_Name, 
concat(round(sum(b.Market_Capitalization)/1000000,0), "M") as Total_Market_Capatilization
from Dim_company as a
join stocks as b
on a.company_name = b.company_name
group by company_name
order by sum(b.Market_Capitalization) desc;


-- WIN V/S Loose
SELECT
win_loss AS Result,
concat(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_dtrades), 1), "%") AS Percentage
FROM fact_dtrades
GROUP BY win_loss
order By Percentage desc;


-- BUY V/S Sell
Select side as Result,
concat(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_trades), 1), "%") AS Percentage 
from fact_trades
group by Result
order by Percentage desc;


-- COMPANIES BY VOLUME
select a.Company_name as Company_Name,
concat(round(sum(b.volume)/1000, 0), "K") as Volume 
from Fact_Daily_Prices as b 
join Dim_Company as a
on a.company_id = b.company_id
group by company_name
order by volume desc; 


-- COMPANIES BY TRADER PERFORMANCE
Select a.Company_name as Company_Name,
concat(round((sum(b.gross_sell_amount) - sum(b.gross_buy_amount)) / 1000000, 0) , "M" ) as Trader_Performance
from fact_dtrades as b
join Dim_company as a 
on a.Company_id = b.Company_id
group by Company_name
order by sum(b.gross_sell_amount) - sum(b.gross_buy_amount) desc;


-- SECTOR BY TOTAL COST BASIS
Select c.Sector_Name as Sector_Name,
concat(round(sum(b.Total_Cost_Basis)/1000000,0), "M") as Total_Cost_Basis 
from fact_dtrades as b
join dim_Company as a
on a.company_id = b.Company_id
join Dim_sector as c
on c.sector_id = a.sector_id
group by Sector_name
order by sum(b.total_cost_basis) desc;


-- EXCHANGE NAME BY TOTAL FEES ALLOCATED
Select c.Exchange_Name as Exchange_Name,
concat(round(sum(b.total_fees_allocated)/1000, 0), "K") as Total_Fees_Allocated
from fact_dtrades as b 
join Dim_company as a
on a.company_id = b.company_id
join Dim_Exchange as c
on c.exchange_id = a.exchange_id
group by exchange_name
order by sum(b.total_fees_allocated) desc;


-- SECTOR BY TRADER PERFORMANCE
Select c.Sector_name as Sector_Name,
concat(round((sum(b.gross_sell_amount) - sum(b.gross_buy_amount)) / 1000000, 0) , "M" ) as Trader_Performance
from Fact_Dtrades as b
join Dim_company as a
on a.company_id = b.company_id
join Dim_Sector as c
on c.Sector_id = a.Sector_id
group by Sector_name
order by sum(b.gross_sell_amount) - sum(b.gross_buy_amount) desc;


-- PORTFOLIO WISE DATA
call stock_market.PORTFOLIO_WISE_DATA('pf000004');
