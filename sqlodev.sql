----CASE1-------
--Question 1 : 
--Aylık olarak order dağılımını inceleyiniz. Tarih verisi için order_approved_at kullanılmalıdır.
select to_char(date_trunc('month',order_approved_at),'YYYY-MM') as order_monthly, 
count(order_id) as order_count from orders
where order_approved_at IS NOT NULL group by order_monthly

----CASE2-------
--Question 2 : 
--Aylık olarak order status kırılımında order sayılarını inceleyiniz. Sorgu sonucunda çıkan outputu excel ile görselleştiriniz. 
--Dramatik bir düşüşün ya da yükselişin olduğu aylar var mı? Veriyi inceleyerek yorumlayınız.
select to_char(date_trunc('month',order_approved_at),'YYYY-MM') as order_monthly, 
count(distinct order_id) as order_count,
order_status
from orders
where order_approved_at IS NOT NULL group by order_status,order_monthly order by order_monthly

select to_char(date_trunc('month',order_approved_at),'YYYY-MM') as order_date, 
order_status,
count(order_id) as order_count FROM orders WHERE order_approved_at IS NOT NULL group by 1,2 order by 1

----CASE3-------
--Question 3 : 
--Ürün kategorisi kırılımında sipariş sayılarını inceleyiniz. Özel günlerde öne çıkan kategoriler nelerdir? Örneğin yılbaşı, sevgililer günü…
select to_char(date_trunc('month',order_approved_at),'YYYY-MM') as order_monthly, 
count(o.order_id) as order_count,
product_category_name as category_name,
order_status
from orders o inner join order_items oi on oi.order_id=o.order_id inner join products p on p.product_id=oi.product_id
where order_approved_at IS NOT NULL group by order_monthly,category_name,order_status order by order_monthly;


WITH order_count AS (
SELECT to_char(order_approved_at, 'YYYY-MM') as order_date,
product_category_name,
COALESCE(product_category_name, 'UNCATEGORIZED') as category_name,
COUNT(DISTINCT o.order_id) orderCount
FROM order_items o JOIN products p ON p.product_id=o.product_id
JOIN orders ON orders.order_id = o.order_id
WHERE order_approved_at IS NOT NULL
GROUP BY 1,2
)
SELECT order_date,orderCount,category_name_english from order_count inner join translation t on t.category_name=order_count.category_name order by 1,2 desc;






 select p.product_category_name,count(oi.order_id) as order_count, o.order_approved_at from order_items oi inner join products p on p.product_id=oi.product_id 
 inner join orders o on o.order_id=oi.order_id where product_category_name IS NOT NULL and p.product_category_name='beleza_saude' 
 group by product_category_name,order_approved_at order by order_approved_at asc
 
  select * from translation
  select * from products
  select *  from orders order by order_approved_at IS NOT NULL ASC
