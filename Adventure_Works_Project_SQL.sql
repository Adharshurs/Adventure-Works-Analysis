create database Adventure_Works;

select * from factinternetsales;
Select * from dimcustomer;
Select * from dimdate;
Select * from dimproduct;
Select * from dimproductcategory;
Select * from dimproductsubcategory;
Select * from factinternetsales;
Select * from dimsalesterritory;
select * from combined_sales_data;

/*							 Q.1 Union of Fact Internet sales and Fact internet sales new */

create table Combined_Sales_Data as
select * from (select * from fact_internet_sales_new union all select * from factinternetsales) as merged_data;

/* Concatinating title, firstname, middlename, lastname, suffix for CustomerFullName and adding new column as customerfullname into dimcustomer table*/

alter table dimcustomer
add column Customerfullname varchar (50) generated always as (trim(replace(concat_ws(' ',title,Firstname,middlename,lastname,suffix),'  ',' ')));

/* adding customerfullname and productname into combined_sales_data table*/

alter table combined_sales_data
add column Customerfullname varchar(100);

alter table combined_sales_data
add column productname varchar(100);

                      /* Q.2 Lookup the productname from the Product sheet to Sales sheet */

 set sql_safe_updates = 0;
update combined_sales_data csd
join dimproduct dp on csd.productkey = dp.productkey
set csd.productname = dp.englishproductname;
 
                  /* Q.3 Lookup the customerfullname from the Product sheet to Sales sheet */
 
 set sql_safe_updates = 0;
 update combined_sales_data csd
 join dimcustomer dc on csd.customerkey= dc.customerkey
 set csd.Customerfullname = dc.customerfullname;
 
              /* Q.4 calcuate the following fields from the Orderdatekey field ( First Create a Date Field from Orderdatekey)
   A.Year
   B.Monthno
   C.Monthfullname
   D.Quarter(Q1,Q2,Q3,Q4)
   E. YearMonth ( YYYY-MMM)
   F. Weekdayno
   G.Weekdayname
   H.FinancialMOnth
   I. Financial Quarter 
*/
 
alter table combined_sales_data
add column year int generated always as (year(orderdatekey)),
add column MonthNo int generated always as (month(orderdatekey)),
add column Monthfullname varchar(20) generated always as (monthname(orderdatekey)),
add column Quarter varchar(5) generated always as (concat("Q", (quarter(orderdatekey)))),
add column YearMonth varchar(10) generated always as (Date_Format(orderdatekey,'%Y-%b')),
add column Weekdayno int generated always as (dayofweek(orderdatekey)),
add column Weekdayname varchar(10) generated always as (dayname(orderdatekey)),
add column FinancialMonth int generated always as (
CASE 
		WHEN MONTH(orderdatekey) >= 4 THEN MONTH(Orderdatekey) - 3
		ELSE MONTH(OrderDatekey) + 9
        END
    ),
 add column FinancialQuarter char(2) generated always as (
  CASE 
        WHEN  MonthNo BETWEEN 4 AND 6 THEN 'Q1'
        WHEN MonthNo BETWEEN 7 AND 9 THEN 'Q2'
        WHEN MonthNo BETWEEN 10 AND 12 THEN 'Q3'
        ELSE 'Q4'
    END
);
 
 /*                 Q5.Calculate the Sales amount uning the columns(unit price,order quantity,unit discount) */
 
 select ceil(sum(unitprice * orderquantity - discountamount)) as total_sales from combined_sales_data;
 
/*                   Q6.Calculate the Productioncost uning the columns(unit cost ,order quantity) */

select ceil(sum(totalproductcost * orderquantity)) as total_cost from combined_sales_data;

/*                                   Q7.Calculate the profit.*/

select ceil(total_sales - total_cost) as profit from
(select sum(unitprice * orderquantity - discountamount) as total_sales, sum(totalproductcost * orderquantity) as total_cost
from combined_sales_data) as sales_cost;

alter table combined_sales_data
add column FinancialQuarter char(2) generated always as (
 CASE 
        WHEN MonthNo BETWEEN 4 AND 6 THEN 'Q1'
        WHEN MonthNo BETWEEN 7 AND 9 THEN 'Q2'
        WHEN MonthNo BETWEEN 10 AND 12 THEN 'Q3'
        ELSE 'Q4'
    END
);







 





 







