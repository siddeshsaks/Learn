use role foundry_marketing;
use warehouse adhoc_reporting_wh;
use database foundry;
use schema marketing;
select top 10 * from marts.marketing.mi_sales;

create or replace table temp as (
select a.MKTG_IND_ID,a.tran_dt, b.FIRST_TRAN_DT, b.LAST_TRAN_DT, b.SECTOR_CD
from 
marts.marketing.mi_sales A join  
FIRST_LAST_TRAN_DT_MI B
ON a.mktg_ind_id = b.MKTG_IND_ID  and a.sector_cd =b.sector_cd
where 
a.TRAN_DT between $YR_START_DATE and $YR_END_DATE);


/* My own code for NEW vs EXISTING STARTS */
SET YR_START_DATE = '2023-01-29';
SET YR_END_DATE = '2024-02-03';

create or replace table FIRST_LAST_TRAN_DT_MI as (
select MKTG_IND_ID, min(tran_dt) as FIRST_TRAN_DT,max(tran_DT) as LAST_TRAN_DT, SECTOR_CD 
from marts.marketing.mi_sales group by 1,4);


select count (distinct a.MKTG_IND_ID),
CASE WHEN FIRST_TRAN_DT between $YR_START_DATE and $YR_END_DATE THEN 'NEW' else 'Existing' END AS CUST_TYPE
from 
marts.marketing.mi_sales A join  
FIRST_LAST_TRAN_DT_MI B
ON a.mktg_ind_id = b.MKTG_IND_ID  and a.sector_cd =b.sector_cd
where 
a.TRAN_DT between $YR_START_DATE and $YR_END_DATE 
and a.sector_cd = 'ECOM'
AND UNIT_SELL_PRC_AMT <> 0 AND
    A.MKTG_IND_ID IS NOT NULL and A.DEPT_CD NOT IN (877,878,950,999,995,864) 
    and a.transaction_identity_source <>'transaction_id'
group by 2;

/* My own code for NEW vs EXISTING ENDS */

/* USING MI_NAME_ADDRESS for NEW vs EXISTING STARTS */
SET YR_START_DATE = '2023-01-29';
SET YR_END_DATE = '2024-02-03';

select count (distinct a.MKTG_IND_ID),
CASE WHEN FIRST_ECOM_PURCHASE_DT between $YR_START_DATE and $YR_END_DATE THEN 'NEW' else 'Existing' END AS CUST_TYPE,
CASE
WHEN A.IS_PURCHASED_ONLINE = 'TRUE' THEN 'ECOM'
WHEN S.SECTOR_CD IS NOT NULL THEN S.SECTOR_CD
ELSE A.SECTOR_CD
END AS SECTOR
from 
marts.marketing.mi_sales A 
join  
MARTS.MARKETING.MI_NAME_ADDRESS B
ON a.mktg_ind_id = b.MKTG_IND_ID 
left join 
marts.marketing.store s on a.orig_store_num = s.store_num
where 
a.TRAN_DT between $YR_START_DATE and $YR_END_DATE 
and SECTOR = 'ECOM'
AND UNIT_SELL_PRC_AMT <> 0 AND
    A.MKTG_IND_ID IS NOT NULL and A.DEPT_CD NOT IN (877,878,950,999,995,864) 
    and a.transaction_identity_source <>'transaction_id' group by 2,3;





select top 10 * from MARTS.MARKETING.MI_NAME_ADDRESS;





select count( distinct MKTG_IND_ID),
CASE WHEN FIRST_TRAN_DT between $YR_START_DATE and $YR_END_DATE THEN 'NEW' else 'Existing' END AS CUST_TYPE from temp 
where sector_cd = 'ECOM'
group by 2;

select min(FISCAL_YR_BEGIN_DT) as FY23_ST, max(fiscal_yr_end_dt) as FY23_END from FOUNDRY.MARKETING.CDW_DATE_TIME
where FISCAL_YR = 2023;



select max(LAST_TRAN_DT) from FIRST_LAST_TRAN_DT_MI;


select count(distinct MKTG_IND_ID),sector_cd from temp group by 2;

select count(distinct MKTG_IND_ID), sector_cd from marts.marketing.mi_sales 
where TRAN_DT between $YR_START_DATE and $YR_END_DATE group by 2;


select top 10 * from marts.marketing.store;
select count MKTG_IND_ID, SKU from marts.marketing.MI_SALES;
select top 10 SALES_TRAN_ID, WEB_ORDER_NUMBER,SALES_LINE_ITEM_TYPE_CD from marts.marketing.mi_sales;

SET YR_START_DATE = '2023-01-29';
SET YR_END_DATE = '2024-02-03';

select count(*) from marts.marketing.mi_sales where TRAN_DT BETWEEN $YR_START_DATE AND $YR_END_DATE ;
--25689965

select distinct * from marts.marketing.mi_sales where TRAN_DT BETWEEN $YR_START_DATE AND $YR_END_DATE ;
--25689965

select  concat (mktg_ind_id,sku,SALES_LINE_ITEM_TYPE_CD,SALES_LINE_TYPE,SALES_TRAN_ID,WEB_ORDER_NUMBER ) as PRI, count(PRI) from marts.marketing.mi_sales where TRAN_DT BETWEEN $YR_START_DATE AND $YR_END_DATE group by 1 order by 2 desc;
--25689965

select * from marts.marketing.mi_sales where concat (mktg_ind_id,sku) = '14751761099999997' and ;



select top 10 * from marts.items.items_current;

-- distinct count of products which are live on site today IS_FOR_DOTCOM

select count (distinct(PRODUCT_ID)) from marts.items.items_current where IS_ONLINE_ELIGIBLE = 'TRUE';

--what are the columns that are repeating in both tables
--what are the repeating column names where table name is different

select distinct column_name, count(distinct table_name)
from MARTS.INFORMATION_SCHEMA.COLUMNS 
where table_name in ('MI_SALES', 'ITEMS_CURRENT') group by 1 having count( distinct table_name) > 1;


select distinct table_name, column_name
from MARTS.INFORMATION_SCHEMA.COLUMNS 
where table_name in ('MI_SALES', 'ITEMS_CURRENT') order by column_name;


select distinct a.column_name
from MARTS.INFORMATION_SCHEMA.COLUMNS a 
INNER JOIN MARTS.INFORMATION_SCHEMA.COLUMNS b
on a.column_name = b.column_name
and 
a.table_name <> b.table_name
and 
a.table_name in ('MI_SALES') 
and 
b.table_name in ('ITEMS_CURRENT');

select top 100 * from limitless_program_2024_h1;

-- total revenue in FY23 from 1 product code which has max SKU count
SET YR_START_DATE = '2023-01-29';
SET YR_END_DATE = '2024-02-03';

select sum(UNIT_SALE_PRC_AMT) as GSALES 
from marts.marketing.mi_sales a
where 
TRAN_DT BETWEEN $YR_START_DATE AND $YR_END_DATE 
and
SALES_LINE_ITEM_TYPE_CD = 'SL' 
and
SECTOR_CD = 'ECOM'
and upc in 
(
select PRODUCT_ID from marts.items.items_current 
where IS_ONLINE_ELIGIBLE = 'TRUE' and IS_FOR_DOTCOM = 'TRUE' and DISCONTINUED_DATE > $YR_START_DATE and 
IS_READY_FOR_PRODUCTION = 'TRUE' and PUBLISH_DATE > $YR_START_DATE
group by PRODUCT_ID 
order by count (distinct (ITEM_ID)) desc limit 1);

select PRODUCT_ID from marts.items.items_current 
where IS_ONLINE_ELIGIBLE = 'TRUE' and IS_FOR_DOTCOM = 'TRUE' and DISCONTINUED_DATE > $YR_START_DATE and 
IS_READY_FOR_PRODUCTION = 'TRUE' and PUBLISH_DATE > $YR_START_DATE
group by PRODUCT_ID 
order by count (distinct (ITEM_ID)) desc limit 1;

select count (distinct (ITEM_ID)), PRODUCT_ID from marts.items.items_current 
where IS_ONLINE_ELIGIBLE = 'TRUE' and IS_FOR_DOTCOM = 'TRUE' and DISCONTINUED_DATE < $YR_START_DATE and 
IS_READY_FOR_PRODUCTION = 'TRUE' and PUBLISH_DATE > $YR_START_DATE
group by PRODUCT_ID 
order by count (distinct (ITEM_ID)) desc limit 1;

select upc,item_id from marts.items.items_current where UPC = '487848457065';

select sum(UNIT_SALE_PRC_AMT) from marts.marketing.mi_sales where UPC ='3700559603116'
and TRAN_DT BETWEEN $YR_START_DATE AND $YR_END_DATE and SECTOR_CD = 'ECOM'
;

select sum(UNIT_SALE_PRC_AMT) over (partition by upc) from
marts.marketing.mi_sales a
left join
marts.items.items_current b 
on a.upc = b.upc
where a.TRAN_DT BETWEEN $YR_START_DATE AND $YR_END_DATE 
and SECTOR_CD = 'ECOM'
and a.upc = '3700559603116' ;
--487848457065

;









select count (*) from 
(select distinct * from marts.marketing.mi_sales);
--137008743


select count(mktg_ind_id) from marts.marketing.mi_sales;
--136955741

select count(*) from marts.marketing.MI_SALES where mktg_ind_id is null;
--53002

select top 10 concat (mktg_ind_id,sku) as PRI from marts.marketing.mi_sales;
--136955741


select concat(mktg_ind_id,sku) as PRI, count(PRI) from marts.marketing.mi_sales group by 1;



where SALES_TRAN_ID in ('344852362');

select max()* from marts.marketing.mi_sales
where SALES_LINE_ITEM_TYPE_CD = '' 
and DEPT_CD in ('995', '950');

select * from marts.marketing.mi_sales
where transaction_identity_source ='transaction_id';

select distinct transaction_identity_source from marts.marketing.mi_sales;

select top 50 
MKTG_IND_ID,
SALES_TRAN_ID,
TRAN_DT,
DEMAND_DATE,
SALES_LINE_ITEM_TYPE_CD,SECTOR_CD,
STORE_NUM, UNIT_SALE_PRC_AMT, UPC, SKU from marts.marketing.mi_sales 
where transaction_identity_source ='transaction_id' order by unit_sell_prc_amt desc;

select top 50
* from reporting.salesaudit.salesaudit_detail;

select top 10 * from marts.items.item_cost_history where item_id = 'MARTS.ITEMS.PRODUCT_FOLDER_ASSORTMENT_ATTRIBUTES_MASTER';

select top 5 * from marts.items.items_current; where PRODUCT_ID = '0400154469966';
select top 5 * from marts.items.PRODUCT_FOLDER_ASSORTMENT_ATTRIBUTES_MASTER;


select * from marts.marketing.MI_NAME_ADDRESS where EMAIL_ADDR_TXT like '%@hbc.com%';




/*
99999997
397935535
450815877
368688039
362970947
345250422
349490448
323175511
324348168
344306205
/*



SELECT
MKTG_IND_ID,
SALES_TRAN_ID,
TRAN_DT,
DEMAND_DATE,
SALES_LINE_ITEM_TYPE_CD,
A.STORE_NUM,
CASE WHEN S.SECTOR_CD IS NOT NULL THEN S.SECTOR_CD 
    ELSE A.SECTOR_CD END AS SECTOR,
COUNT(DISTINCT (CASE WHEN SALES_LINE_ITEM_TYPE_CD = 'SL' AND WEB_ORDER_NUMBER <> 0 THEN WEB_ORDER_NUMBER END)) AS WEB_ORDERS,	
COUNT(DISTINCT (CASE WHEN SALES_LINE_ITEM_TYPE_CD = 'SL' AND WEB_ORDER_NUMBER = 0 THEN SALES_TRAN_ID END)) AS POS_ORDERS,
count(distinct (CASE WHEN sales_line_item_type_cd = 'SL' then sales_tran_id end)) as GROSS_SFA_ORDERS,
SUM(CASE WHEN SALES_LINE_ITEM_TYPE_CD = 'SL' THEN A.ITEM_QTY ELSE 0 END) AS GROSS_ITEMS,
SUM(CASE WHEN SALES_LINE_ITEM_TYPE_CD = 'RTN' THEN A.ITEM_QTY ELSE 0 END) AS RTN_ITEMS,
SUM(CASE WHEN SALES_LINE_ITEM_TYPE_CD = 'SL' THEN UNIT_SELL_PRC_AMT ELSE 0 END) AS GROSS_SALES,
SUM(UNIT_SELL_PRC_AMT) AS NET_SALES,
SUM(CASE WHEN SALES_LINE_ITEM_TYPE_CD = 'RTN' THEN -UNIT_SELL_PRC_AMT ELSE 0 END) AS RETURNS_AMT
FROM 
    marts.marketing.mi_sales A
INNER JOIN 
    foundry.marketing.cdw_date_time CAL
    ON A.TRAN_DT = CAL.DT_IDENTIFIER
LEFT JOIN 
    marts.marketing.store S 
    ON A.ORIG_STORE_NUM=S.STORE_NUM AND S.SECTOR_CD IN ('SFA','ECOM')
WHERE 
    SECTOR IN ('SFA','ECOM')
    AND(TRAN_DT BETWEEN $YR_START_DATE AND $YR_END_DATE)
    AND UNIT_SELL_PRC_AMT <> 0 AND
    A.MKTG_IND_ID IS NOT NULL and A.DEPT_CD NOT IN (877,878,950,999,995,864) 
    and a.transaction_identity_source <>'transaction_id'
GROUP BY 
1,2,3,4,5,6,7;
