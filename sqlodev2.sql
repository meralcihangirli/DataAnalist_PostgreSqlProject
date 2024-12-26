--Case 1 : Sipariş Analizi
--Question 1 : 
--Aylık olarak order dağılımını inceleyiniz. Tarih verisi için order_approved_at kullanılmalıdır.
select to_char(order_approved_at,'YYYY-MM') as order_monthly,
count(order_id) as order_count 
from orders where order_approved_at is not null group by order_monthly 

--Question 2 : 
--Aylık olarak order status kırılımında order sayılarını inceleyiniz. Sorgu sonucunda çıkan outputu excel ile görselleştiriniz. 
--Dramatik bir düşüşün ya da yükselişin olduğu aylar var mı? Veriyi inceleyerek yorumlayınız.
select to_char(order_approved_at,'YYYY-MM') as order_monthly,
order_status,
count(order_id) as order_count 
from orders  where order_approved_at is not null group by order_monthly, order_status

--Question 3 : 
--Ürün kategorisi kırılımında sipariş sayılarını inceleyiniz. 
--Özel günlerde öne çıkan kategoriler nelerdir? Örneğin yılbaşı, sevgililer günü…
select to_char(order_approved_at,'YYYY-MM') as order_monthly,
p.product_category_name,
count(o.order_id) as order_count
from orders o left join order_items oi on oi.order_id=o.order_id left join products p on p.product_id=oi.product_id
group by order_monthly, product_category_name order by order_count desc;

--Question 4 : 
--Haftanın günleri(pazartesi, perşembe, ….) ve ay günleri (ayın 1’i,2’si gibi) bazında order sayılarını inceleyiniz.
--Yazdığınız sorgunun outputu ile excel’de bir görsel oluşturup yorumlayınız.
select to_char(order_approved_at,'DAY') as order_daily,
count(order_id) as order_count
from orders 
group by order_daily;

select extract(day from order_approved_at) as order_daily,
count(order_id) as order_count
from orders 
group by order_daily order by order_daily;


--Case 2 : Müşteri Analizi 
--Question 1 : 
--Hangi şehirlerdeki müşteriler daha çok alışveriş yapıyor? 
--Müşterinin şehrini en çok sipariş verdiği şehir olarak belirleyip analizi ona göre yapınız. 
select c.customer_city,
count(o.order_id) as order_count
from customers c inner join orders o on o.customer_id=c.customer_id group by customer_city order by order_count desc limit 1

--Case 3: Satıcı Analizi
--Question 1 : 
--Siparişleri en hızlı şekilde müşterilere ulaştıran satıcılar kimlerdir? Top 5 getiriniz.
WITH seller_order_delivery AS (
SELECT oi.seller_id,
extract(DAY FROM order_delivered_customer_date - order_purchase_timestamp) AS day_difference
FROM orders AS o
LEFT JOIN order_items AS oi
ON o.order_id=oi.order_id
)
SELECT seller_id,
ROUND(avg(day_difference)::numeric) as avg_delivery
FROM seller_order_delivery
GROUP BY seller_id
ORDER BY avg_delivery LIMIT 5


--Bu satıcıların order sayıları ile ürünlerindeki yorumlar ve puanlamaları inceleyiniz ve yorumlayınız.
WITH top_5 AS (
WITH seller_order_delivery AS (
SELECT oi.seller_id,
extract(DAY FROM order_delivered_customer_date - order_purchase_timestamp) AS day_difference
FROM orders AS o
LEFT JOIN order_items AS oi
ON o.order_id=oi.order_id)
SELECT seller_id,
ROUND(avg(day_difference)::numeric) as avg_delivery
FROM seller_order_delivery
GROUP BY seller_id
ORDER BY avg_delivery LIMIT 5)
SELECT t.seller_id,
count(DISTINCT oi.order_id) AS order_count,
ROUND(avg(r.review_score)::numeric) AS review_score_avg,
count(DISTINCT review_comment_message) AS review_message
FROM top_5 AS t
LEFT JOIN order_items AS oi
ON oi.seller_id = t.seller_id
LEFT JOIN reviews AS r
ON r.order_id = oi.order_id
GROUP BY t.seller_id


--kullanılmayacak
select
seller_id,
count(order_id) as order_count
from order_items 
group by seller_id order by order_count desc


--Question 2 : 
--Hangi satıcılar daha fazla kategoriye ait ürün satışı yapmaktadır? 
--Fazla kategoriye sahip satıcıların order sayıları da fazla mı? 
SELECT oi.seller_id,
count(DISTINCT p.product_category_name) AS category_count,
count(DISTINCT oi.order_id) AS order_count
FROM order_items AS oi
LEFT JOIN products AS p
ON oi.product_id = p.product_id
GROUP BY oi.seller_id
ORDER BY category_count DESC


--Case 4 : Payment Analizi
--Question 1 : 
--Ödeme yaparken taksit sayısı fazla olan kullanıcılar en çok hangi bölgede yaşamaktadır? Bu çıktıyı yorumlayınız.
SELECT c.customer_city,
count(DISTINCT o.customer_id) AS customer_count,
payment_installments
FROM payments AS p
LEFT JOIN orders AS o
ON p.order_id = o.order_id
LEFT JOIN customers AS c
ON c.customer_id = o.customer_id
GROUP BY payment_installments, c.customer_city
ORDER BY customer_count,payment_installments DESC

--Question 2 : 
--Ödeme tipine göre başarılı order sayısı ve toplam başarılı ödeme tutarını hesaplayınız. En çok kullanılan ödeme tipinden en az olana göre sıralayınız.
SELECT payment_type,
SUM(payment_value) AS sum_payment_value,
count(DISTINCT o.order_id) AS order_count
FROM payments AS p
LEFT JOIN orders AS o
ON p.order_id = o.order_id
GROUP BY payment_type

--Question 3 : 
--Tek çekimde ve taksitle ödenen siparişlerin kategori bazlı analizini yapınız. En çok hangi kategorilerde taksitle ödeme kullanılmaktadır?
SELECT product_category_name,payment_installments,
count(DISTINCT o.order_id) AS order_count
FROM orders AS o
LEFT JOIN payments AS p
ON p.order_id = o.order_id
LEFT JOIN order_items AS oi
ON oi.order_id = o.order_id
LEFT JOIN products as pr ON pr.product_id=oi.product_id
WHERE payment_installments=1
group by payment_installments,product_category_name
order by order_count DESC, payment_installments DESC

SELECT product_category_name,payment_installments,
count(DISTINCT o.order_id) AS order_count
FROM orders AS o
LEFT JOIN payments AS p
ON p.order_id = o.order_id
LEFT JOIN order_items AS oi
ON oi.order_id = o.order_id
LEFT JOIN products as pr ON pr.product_id=oi.product_id
WHERE payment_installments>1
group by payment_installments,product_category_name
order by payment_installments DESC, order_count DESC


