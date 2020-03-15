-- *************第一部分 查询***************
/*1.查询customer表中的名字dd*/
SELECT column_name
FROM information_schema.columns
WHERE table_name='customer';/*查询customer字段名*/

SELECT first_name FROM customer;
   

/*2.查询city表中的城市名称（过滤重复值）*/
/*SELECT * FROM city LIMIT 5;*/
SELECT DISTINCT city FROM city;

/*3.查询customer表中的名字和姓氏，按照名字升序排列*/
SELECT first_name,last_name FROM customer ORDER BY first_name; /*默认升序*/

/*4.查询customer表中的名字和姓氏，按照名字升序排列,当名字相同时，姓氏降序排列*/
SELECT first_name,last_name 
FROM customer 
ORDER BY first_name ASC,last_name DESC; 

/*5.连接customer表中的名字和姓氏，以空格隔开，并重命名为"full_name"*/
SELECT CONCAT_WS(' ',first_name,last_name)  
AS full_name  
FROM customer;
/*CONCAT_WS函数指定分隔符连接字符串*/


-- *************第二部分 筛选***************

/*1.查询customer表中名字为Aaron的名字和姓氏*/
SELECT first_name,last_name 
FROM customer 
WHERE first_name='Aaron';

/*2.查询customer表中没有去1号店的顾客的邮箱*/
/*SELECT * FROM customer LIMIT 1;*/
SELECT email FROM customer WHERE store_id != 1;

/*3.查询payment表支付租金的金额小于1美元或大于8美元的顾客编号，金额以及付款日期*/
/*SELECT * FROM payment LIMIT 1;*/
SELECT customer_id,amount,payment_date 
FROM payment 
WHERE amount<1  OR amount>8;

/*4.查询电影的租赁时长不等于5并且电影时长少于100或者租赁时长等于5并且电影时长大于100的电影编号和名称*/
/*SELECT * FROM film LIMIT 1;*/
SELECT film_id,title 
FROM film
WHERE rental_duration !=5 AND length<100
OR rental_duration =5 AND length>100;/*AND优先级高于OR*/


/*5.查询customer表中名字为Alan或Alex的名字和姓氏和邮箱*/
SELECT last_name,email 
FROM customer 
WHERE first_name IN ('Alan','Alex');


/*6.查询payment表中付款日期在2007-02-20-2007-02-21之间的顾客编号*/
SELECT customer_id 
FROM payment 
WHERE payment_date BETWEEN '2007-02-20' AND '2007-02-21';


/*7.查询address表中以Man开头的街区名称*/
/*SELECT * FROM address LIMIT 4;*/
SELECT district FROM address WHERE  district LIKE 'Man%';


/*8.查询customer表中名字含有"er"的名字和姓氏*/
SELECT first_name,last_name 
FROM customer 
WHERE first_name LIKE '%er%';


/*9.查询customer表中名字以任一字符开头，中间为"her"的名字和姓氏*/
SELECT first_name,last_name 
FROM customer 
WHERE first_name LIKE '_her%';/*-替代一个字符,%替代一个或多个字符*/


/*10.查询customer表中名字不以"Jen"开头的名字和姓氏*/
SELECT first_name,last_name 
FROM customer 
WHERE first_name NOT LIKE 'Jen%';


/*11.查询customer表中名字以"BAR"或者"Bar"或者“BaR"开头的名字和姓氏（ILIKE运算符不区分大小写的值）*/
SELECT first_name,last_name 
FROM customer 
WHERE first_name ILIKE 'BAR%';


/*12.查询address表中电话号码不为空的街区名称*/
SELECT district FROM address WHERE phone IS NOT NULL;


/*13.查询film表中按标题排序的前五部电影*/
SELECT title  FROM film  ORDER BY title LIMIT 5;


/*14.查询film表中从第3行之后（即第4行）开始的4行数据*/
SELECT * FROM film LIMIT 4 OFFSET 3;
/*postgres 不支持limit双参数,offset跳过几行*/


/*15.查询film表中从第3行之后按标题排序的前五部电影*/
SELECT title 
FROM film 
ORDER BY title 
OFFSET 3 ROWS FETCH FIRST 5 ROWS ONLY;


/*16.查询film表中从第3行之后（即第4行）开始的4行数据*/
SELECT * FROM film  OFFSET 3 ROWS FETCH FIRST 4 ROWS ONLY;


-- *************第三部分 连接***************

/*1.查询客户ID 2的客户租赁数据（customer,payment两表内连接）*/
SELECT c.customer_id,CONCAT_WS(' ',c.first_name,c.last_name) customer_name,
c.email,p.amount,p.payment_date
FROM customer c INNER JOIN payment p
ON c.customer_id = p.customer_id 
WHERE c.customer_id=2; /*INNER JOIN*/
 

/*2.查询客户ID 2的客户租赁数据（customer,payment,staff三表内连接）*/

SELECT c.customer_id ,CONCAT_WS(' ',c.first_name,c.last_name) customer_name,
c.email customer_email,p.amount,p.payment_date,
CONCAT_WS(' ',s.first_name,s.last_name) staff_name,s.email staff_email
FROM customer c 
INNER JOIN payment p ON c.customer_id=p.customer_id 
INNER JOIN  staff s ON p.staff_id=s.staff_id
WHERE c.customer_id=2; 


/*3.查找具有相同长度的所有电影对（自连接）
自联接对于比较同一表中的一列行中的值很有用。
要形成自连接，请使用不同的别名指定同一个表两次，设置比较，并消除值等于自身的情况。*/ 
SELECT first.title ,second.title,first.length
FROM film first INNER JOIN film second
ON first.length=second.length AND first.film_id != second.film_id;  


/*4.查询客户ID 2的客户租赁数据（完整外连接）*/
SELECT  c.customer_id ,CONCAT_WS(' ',c.first_name,c.last_name) customer_name,c.email,p.amount,p.payment_date
FROM customer c FULL JOIN payment p 
ON c.customer_id = p.customer_id 
WHERE c.customer_id=2; /*FULL JOIN*/


/*5.查询客户ID 2的客户租赁数据（完全外连接,,不包括customer,payment表的交集部分）*/
SELECT  c.customer_id ,CONCAT_WS(' ',c.first_name,c.last_name) customer_name,c.email,p.amount,p.payment_date
FROM customer c FULL JOIN payment p 
ON c.customer_id = p.customer_id 
WHERE c.customer_id=2;/*有问题*/ 



-- *************第四部分 分组***************

/*1.按顾客编号分组，计算总金额，并按总金额降序排列*/
SELECT customer_id,sum(amount) total_amount 
FROM payment 
GROUP BY customer_id 
ORDER BY total_amount DESC;


/*2.按顾客编号分组,查询总金额超过200的顾客编号*/
SELECT customer_id
FROM payment 
GROUP BY customer_id
HAVING sum(amount)>200;


-- *************第五部分 集合***************

/*1.取姓名为Aaron，Rene的并集（UNION ALL包括重复值）*/
SELECT first_name ,last_name 
FROM customer WHERE first_name = 'Aaron' 
UNION ALL 
SELECT first_name ,last_name 
FROM customer WHERE first_name = 'Rene';

/*2.取姓名为Aaron，Rene的交集*/
SELECT first_name ,last_name 
FROM customer WHERE first_name = 'Aaron' 
INTERSECT 
SELECT first_name ,last_name 
FROM customer WHERE first_name = 'Rene';

/*3.差集（查询不在库存inventory表中的影片）*/
SELECT film_id,title FROM film 
EXCEPT 
SELECT a.film_id,b.title FROM inventory a 
INNER JOIN film b  ON a.film_id = b.film_id;


-- *************第六部分 子查询*************

/*1.查找租金率高于平均租金率的前3部电影*/
SELECT title,rental_rate FROM film 
WHERE rental_rate >(SELECT avg(rental_rate) 
FROM film) 
ORDER BY rental_rate DESC LIMIT 3 ;


/*2.查询film_category表按电影类别分组的所有电影的最大长度
(最小值为178)*/
SELECT category_id,max(length) max_length 
FROM film 
INNER JOIN film_category  
ON film.film_id=film_category.film_id 
GROUP BY category_id ;


/*3.对于每个电影类别，子查询找到最大长度。外部查询查看所有这些值并确定哪个胶片的长度大于或等于任何胶片类别的最大长度。
ANY表示有任何一个满足就返回TRUE，此时大于178即可
'SOME'相当于'ANY'
'= ANY'相当于'IN','<> ANY'不同于'NOT IN'
USING用法：ON table1.column_name = table2.column_name 等价于
USING(column_name)*/
SELECT title,length FROM film 
WHERE length >= ANY(
    SELECT max(length) FROM film 
    INNER JOIN film_category 
    USING (film_id) 
    GROUP BY category_id);


/*4.查询按电影评级分组的所有电影的平均长度
最大值为120.44*/
SELECT rating,avg(length) avg_length FROM film GROUP BY rating;

/*5.查询按电影评级分组的所有电影的平均长度
最大值为120.44*/
SELECT rating,avg(length) FROM film 
GROUP BY rating;


/*6.查询返回所有长度大于子查询返回的平均长度列表中最大值的影片
ALL表示全部都满足才返回TRUE,即大于平均长度的最大值120.44才可*/
SELECT title,length FROM  film
WHERE length > ALL(
    SELECT avg(length) FROM film  
    GROUP BY rating);


/*7.查找至少有一笔金额大于11的付款的客户
EXISTS运算符来测试子查询中是否存在行*/
SELECT first_name,last_name 
FROM customer c 
WHERE EXISTS (
    SELECT * FROM payment p WHERE amount>11 AND c.customer_id=p.customer_id   
);

-- *************第七部分 修改数据*************

/*1.一次向表中添加多行*/
INSERT INTO table_name (var1,var2,...)
VALUES 
(value11,value12,...),
(value21,value22,...),
...;

/*INSERT
INTO  film (Sno,Sname,Ssex,Sdept,Sage)
VALUES ('200215128','陈冬','男','IS',18);*/


/*2.插入来自另一个表的数据*/
INSERT INTO table_name(var1,var2,...)
SELECT var1,var2,...
FROM another_table ;


/*3.更改表中列的值*/
UPDATE table_name 
set var1=value1,var2=value2,...
WHERE condition;


/*4.根据另一个表中的值更新表的数据*/
update A 
SET A.A1 = b.B1,A.A2=B.A2 
FROM A ,B 
WHERE  A.ID1 = B.ID1 and A.ID2 = B.ID2;



/*5.从表中删除数据*/
DELETE
FROM tableA
WHERE condition;


/*6.检查引用另一个表中的一个或多个列的条件来删除数据*/

/*DELETE
FROM SC
WHERE  'CS'=
(SELETE Sdept
FROM Student
WHERE Student.Sno=SC.Sno);删除计算机科学系所有学生的选课记录。*/


-- *************第八部分 管理表*************

/*1.创建表*/

/*建立“学生”表Student,学号是主码,姓名取值唯一。*/
CREATE TABLE Student          
(Sno CHAR(9) PRIMARY KEY, /* 列级完整性约束条件*/                  
Sname  CHAR(20) UNIQUE,/* Sname取唯一值*/
Ssex CHAR(2),
Sage SMALLINT,
Sdept  CHAR(20));

/*在film的基础上创建一个名为的新表film_t，其中包含评级为R租期为5的所有电影*/
SELECT *
INTO TABLE film_t
FROM film
WHERE rating='R' AND rental_duration=5;


/*2.验证表*/
SELECT * from film_t;

/*3.向表中添加新列*/
ALTER TABLE table_name 
ADD column_name datatype/*列属性*/;


/*4.删除现有列*/
ALTER TABLE table_name                
DROP COLUMN column_name;


/*5.重命名现有列*/
ALTER TABLE table_name 
RENAME COLUMN column_name
TO new_column_name;


/*6.将assets表中name列的数据类型更改为VARCHAR*/
ALTER TABLE assets 
ALTER COLUMN name varchar


/*7.重命名表*/
ALTER TABLE table_name RENAME TO new_table_name;

ALTER TABLE film RENAME TO myfilm;
ALTER TABLE myfilm RENAME TO film;

/*8.删除表*/
DROP TABLE table_name;


/*9.创建临时表*/
CREATE TEMPORARY TABLE IF NOT EXISTS  MyTable(
    ID VARCHAR(100) PRIMARY KEY,
    NAME VARCHAR(100)
);


/*10.删除表中所有数据*/
TRUNCATE film_r;

-- *************第九部分 约束*************

/*1.主键约束方式一：创建表时定义主键*/
CREATE TABLE table_name
(var1 data_type PRIMARY KEY,/*主键*/
var2 data_type,
var3 data_type,
...
);

CREATE TABLE Student
(Sno   CHAR(9) PRIMARY KEY, /* 列级完整性约束条件*/
Sname  CHAR(20),
Ssex    CHAR(2),
Sage   SMALLINT,
Sdept  CHAR(20));


/*2.主键约束方式二：如果主键由两列或更多列组成*/
CREATE TABLE table_name
(var1 data_type,
var2 data_type,
var3 data_type,
...
PRIMARY KEY(var1,var2));

/*3.主键约束方式三：更改现有表结构时定义主键*/
ALTER TABLE products ADD PRIMARY KEY (product_group_id) REFERENCES product_groups;



/*4.删除主键*/
ALTER TABLE table_name DROP CONSTRAINT primary_key_name;

/*5.UNIQUE约束方式一：添加UNIQUE约束，确保存储在列或列组中的值在整个表中是唯一*/
CREATE TABLE table_name
(var1 data_type PRIMARY KEY,/*主键*/
var2 data_type UNIQUE, /*取唯一值*/
var3 data_type,
...
);

CREATE TABLE Student
(Sno   CHAR(9) PRIMARY KEY, /* 列级完整性约束条件*/
Sname  CHAR(20) UNIQUE,     /* Sname取唯一值*/
Ssex    CHAR(2),
Sage   SMALLINT,
Sdept  CHAR(20));


/*6.UNIQUE约束方式二：列c2和c3中的值组合在整个表中是唯一的。列c2或c3的值不必是唯一的*/
CREATE TABLE table_name
(var1 data_type PRIMARY KEY, 
 var2 data_type,
 var3 data_type,
 CONSTRAINT var12_unique UNIQUE(var1,var2)
);


/*7.NOT NULL约束方式一：在创建新表时，将PostgreSQL非空约束添加到列*/
CREATE TABLE table_name
(var1 data_type PRIMARY KEY NOT NULL, 
 var2 data_type NOT NULL,
 var3 data_type,
 ...
);


/*8.NOT NULL约束方式二：将PostgreSQL非空约束添加到现有表的列*/
ALTER TABLE table_name ALTER COLUMN var SET NOT NULL;


/*9.CHECK约束，该约束根据布尔表达式约束表中列的值
一个CHECK约束是一种约束，使您可以指定是否在列中的值必须满足特定的要求。的CHECK约
束使用布尔表达式插入或更新到列之前评估值。如果值通过检查，PostgreSQL将在列中插入
或更新这些值。 CHECK 约束保证列中的所有值满足某一条件，即对输入一条记录要进行检查。如果条件值为 false，则记录违反了约束，且不能输入到表。
首先，birth_date员工的出生日期（）必须大于01/01/1900。如果您之前尝试插入出生日期01/01/1900，您将收到一条错误消息。
其次，联合日期（joined_date）必须大于出生日期（birth_date）。此检查将阻止根据其语义含义更新无效日期。
第三，薪水必须大于零*/

CREATE TABLE employee(
   staff_id INT PRIMARY KEY     NOT NULL,
   staff_name     TEXT    NOT NULL,
   birth_date     CHAR(20) CHECK(birth_date>'1900/01/01'),
   joined_date    CHAR(20) CHECK(joined_date>birth_date ),
   salary         REAL    CHECK(SALARY > 0)
);

INSERT INTO employee(
 staff_id,
 staff_name,
 birth_date,
 joined_date,
 salary
)
VALUES
(
 1,
 'A',
 '1972-01-01',
 '2015-07-01', 
 -100000
);  /*报错*/



-- *************第十部分 条件表达式和运算符*************

/*1.为电影分配价格段：如果租金率为0.99，则为普通；如果租金率是1.99，则为经济；如果出租率是4.99，则为豪华*/
SELECT * FROM film LIMIT 2;
SELECT film_id,title,
(CASE
WHEN rental_rate=0.99 THEN '普通'
WHEN rental_rate=1.99 THEN '经济'
ELSE '豪华' END) rental_level 
FROM film;


/*2.从左到右计算参数，直到找到第一个非null参数*/
SELECT COALESCE (NULL,2,3,4,1,NULL,4);
/*条件函数：coalesce 返回从左到右返回第一个不为NULL的值*/


/*3.将字符串常量转换为整数*/
SELECT CAST( '222'AS INT );

-- *************第十一部分 习题*************
/*1.将姓中含有“oo”的演员参演的电影的租赁期增加三天
Al Garland参演的电影的租赁期增加一天，
其他姓“Garland”的演员参演的电影的租赁期减两天，
展示所有演员的名字，过去的租赁期和当前最新的租赁期*/

SELECT c.first_name,c.last_name,a.title, a.rental_duration old_rental_duration,
(CASE
WHEN c.first_name LIKE '%oo%' THEN a.rental_duration+3
WHEN c.first_name='Al' AND last_name='Garland' THEN a.rental_duration+1
WHEN c.last_name='Garland'THEN a.rental_duration-2
ELSE a.rental_duration END) new_rental_duration
FROM film a 
INNER JOIN film_actor b USING (film_id) 
INNER JOIN  actor c USING (actor_id);


/*2.展示播放时长为115分钟到125分钟的电影名称及时长,
并按播放时长排序,相同时长的电影按名字排序，但A开头
和名字中含有c（另一个字母）r的电影必须最后排列，即
该条件为第一满足的条件，即第一排序*/
SELECT title,length FROM film 
WHERE length BETWEEN 115 AND 125
ORDER BY 
title IN (SELECT title FROM film 
WHERE title LIKE 'A%' OR title LIKE '%c_r%'),
length,title;
/*title IN语句会进行判断，如果title满足条件，返回1，不满足，返回0
所以，满足条件的title，因为返回值是1，进行ASC排序的时候，就被放置在了最后。*/


/*3.展示不同语言种类的电影数量，并按从小到大的顺序排列*/
SELECT count(film_id) ,language_id FROM film
GROUP BY language_id
ORDER BY  count(film_id);


/*4.展示英语类电影的电影类型及相应数目*/
SELECT language_id ,count(film_id) FROM film
WHERE language_id='1'
GROUP BY language_id;


/*5.展示有支付行为的每个城市的支付笔数*/
/*payment p
staff s
country c 
address a
city  city */

/*city.city_id=a.city_id
city.country_id=c.country_id
s.address_id = a.address_id
s.staff_id = p.staff_id*/

SELECT c.country,city.city,
sum(CASE WHEN p.amount >0 THEN 1 ELSE 0 END ) pay_volume 
FROM payment p 
INNER JOIN staff s USING (staff_id)
INNER JOIN address a USING (address_id)
INNER JOIN city city USING (city_id)
INNER JOIN country c USING (country_id)
GROUP BY c.country,city.city;


/*6.找出每个国家按字母排序是排末位的城市中最高的支付金额*/

/*每个国家字母排序的城市最高支付金额*/
SELECT c.country,city.city,max(p.amount) max_amount
FROM payment p 
INNER JOIN staff s USING (staff_id)
INNER JOIN address a USING (address_id)
INNER JOIN city city USING (city_id)
INNER JOIN country c USING (country_id)
GROUP BY c.country,city.city
ORDER BY c.country;
