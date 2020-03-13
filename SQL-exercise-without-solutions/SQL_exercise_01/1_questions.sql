-- LINK: The_computer_store
-- 1.1 Select the names of all the products in the store.
SELECT name from products;

-- 1.2 Select the names and the prices of all the products in the store.
SELECT name,price from products;

-- 1.3 Select the name of the products with a price less than or equal to $200.
SELECT name from products WHERE price <=200;

-- 1.4 Select all the products with a price between $60 and $120.
SELECT * from products WHERE price BETWEEN 60 AND 120;

-- 1.5 Select the name and price in cents (i.e., the price must be multiplied by
-- 100).
SELECT name,price*100 price from products;

-- 1.6 Compute the average price of all the products.
SELECT round(avg(price),2) avgprice from products;

-- 1.7 Compute the average price of all products with manufacturer code equal to 2.
SELECT round(avg(price),2) avgprice from products WHERE manufacturer=2;

-- 1.8 Compute the number of products with a price larger than or equal to $180.
SELECT count(code) from products WHERE price<=180;

-- 1.9 Select the name and price of all products with a price larger than or equal to $180, and sort first by price (in descending order), and then by name (in ascending order).
select name from products where price<=180 order by price DESC,name ASC;

-- 1.10 Select all the data from the products, including all the data for each product's manufacturer.
select p.*,m.name manufacturer_name from products p left JOIN manufacturers m ON p.manufacturer=m.code order by code;

-- 1.11 Select the product name, price, and manufacturer name of all the products.
select p.name,p.price,m.name manufacturer_name from products p left join manufacturers m on p.manufacturer=m.code;

-- 1.12 Select the average price of each manufacturer's products, showing only the manufacturer's code.
select manufacturer ,round(avg(price),2) avg_price from products group by manufacturer order by manufacturer;

-- 1.13 Select the average price of each manufacturer's products, showing the manufacturer's name.
select m.name manufacturer_name ,round(avg(p.price),2) avg_price 
from products p left join manufacturers m on p.manufacturer=m.code 
group by m.name;

-- 1.14 Select the names of manufacturer whose products have an average price larger than or equal to $150.
select m.name manufacturer_name ,round(avg(p.price),2) avg_price 
from products p left join manufacturers m on p.manufacturer=m.code 
group by m.name 
having avg(p.price) >= 150;

-- 1.15 Select the name and price of the cheapest product.
select name,price from products order by price limit 1;
/*或*/
select name,price from products where price=(select min(price)from products);

-- 1.16 Select the name of each manufacturer along with the name and price of its most expensive product.
select m.name manufacturer_name,p.name product_name,p.price from products p 
left join manufacturers m on p.manufacturer=m.code 
order by p.price DESC LIMIT 1 ;
/*或*/
select m.name manufacturer_name,p.name product_name,p.price from products p 
left join manufacturers m on p.manufacturer=m.code 
where price=(select max(price)from products);

-- 1.17 Add a new product: Loudspeakers, $70, manufacturer 2.
insert into products values('11','Loudspeakers',70,'2');

-- 1.18 Update the name of product 8 to "Laser Printer".
update products set name='Laser Printer' where code = 8;

-- 1.19 Apply a 10% discount to all products.
select *,0.9*price discount_price from products;

-- 1.20 Apply a 10% discount to all products with a price larger than or equal to $120.
select *,0.9*price discount_price from products where price >=120;