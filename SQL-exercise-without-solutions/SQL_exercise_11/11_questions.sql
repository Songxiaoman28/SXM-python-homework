--学生表 Student(SId,Sname,Sage,Ssex) 
--SId 学生编号,Sname 学生姓名,Sage 出生年月,Ssex 学生性别 

--课程表 Course(CId,Cname,TId) 
--CId 课程编号,Cname 课程名称,TId 教师编号 
--教师表 Teacher(TId,Tname) 
--TId 教师编号,Tname 教师姓名 
--成绩表 SC(SId,CId,score) 
--SId 学生编号,CId 课程编号,score 分数
select * from Student;
select * from SC;
select * from course;
select * from teacher;
-- 1. 查询“01”课程比“02”课程成绩高的所有学生的学号；
/*筛选出学生中01分数比02分数高的学号*/
/*查询出每个学生01课程分数与02课程分数合并到一张表中进行比较大小*/

select distinct t1.sid from (select * from sc where cid='01') t1 
left join (select * from sc where cid='02') t2 
on t1.sid=t2.sid
where t1.score>t2.score;

-- 2. 查询平均成绩大于60分的同学的学号和平均成绩；
/*成绩表sc*/
select sid ,avg(score) 
from sc 
group by sid
having avg(score)>60;

-- 3. 查询所有同学的学号、姓名、选课数、总成绩
/*select 出现的聚合函数以及变量必须是group by 表里面的*/

select sc1.*,s.sname
from (select sc.sid,count(sc.cid),sum(sc.score) from sc group by sid) sc1 left join student s on sc1.sid=s.sid;/*错误，左表不能是sc，忽略了没选课的同学*/

select
    student.sid as sid
    ,sname
    ,count(distinct cid) course_cnt
    ,sum(score) as total_score
from student
left join sc
on student.sid=sc.sid
group by student.sid,student.sname;

-- 4. 查询姓“李”的老师的个数；

select count(tid) from teacher where tname like '李%' ;

-- 5. 查询没学过“张三”老师课的同学的学号、姓名；
/*没有学过“张三”老师课，把学过张三老师课的学号查询出来，student表中sid 不在子查询里*/
select sid,sname from student
where sid not in (
    SELECT sid from sc 
    left join course on sc.cid=course.cid 
    left join teacher on teacher.tid=course.tid 
    where teacher.tname='张三');

-- 6. 查询学过“01”并且也学过编号“02”课程的同学的学号、姓名；
/*从sc中筛选出分别选过01的和02的两张表，取交集连接起来查询出sid，然后连接student表查询出sname*/

select sc1.sid,student.sname from 
(select sid from sc where cid='01') sc1 inner join (select sid from sc where cid='02') sc2  on  sc1.sid=sc2.sid 
left join student on student.sid=sc1.sid;


-- 7. 查询学过“张三”老师所教的课的同学的学号、姓名；
/*查出张三老师所教课的cid作为子查询,然后通过student 和sc的连接表中cid=子查询*/

select student.sid,student.sname from student left join sc on student.sid=sc.sid where sc.cid=
(select  course.cid from course left join teacher on course.tid=teacher.tid where tname='张三');

-- 8. 查询课程编号“01”的成绩比课程编号“02”课程低的所有同学的学号、姓名；
/*01表和02表进行并列查询出01小于02的sid作为一个临时再去连接student表查询出姓名
选了课程02没选01的怎么处理：没选01就没有可比性*/
select temp.sid,student.sname from  
(select sc1.sid from (select * from sc where cid='01') sc1 left join (select * from sc where cid='02') sc2 on sc1.sid=sc2.sid
where sc1.score <sc2.score) temp 
left join student on student.sid=temp.sid;

-- 9. 查询所有课程成绩小于60分的同学的学号、姓名；
/*子查询，查询出所有课程小于60的sid
按照sid进行分组，sid的所有课程都小于60等价于最高分数小于60！！
所有xxx转换思维最大或最小xxx*/

select a.sid,student.sname from (select sid from sc group by sid having max(score) <60) a left join student on a.sid=student.sid;

-- 10. 查询没有学全所有课的同学的学号、姓名；
/*计算所有课程的课程数，按sid进行分组，查询计算课程数小于所有课程总数,*/
select a.sid,student.sname from (select sid from sc group by sid having count(cid)<(select count(cid) from course)) a/*子查询*/left join student on a.sid=student.sid ;

-- 11. 查询至少有一门课与学号为“01”的同学所学相同的同学的信息；
/*查询出sid=01的同学所学的cid，其他学生的cid 要in */


select * from student where sid in (select sid from sc where cid in (select distinct cid from sc where sid='01') and sid!='01' /*查询出满足条件的sid*/) ;


-- 12. 查询和"01"号的同学学习的课程完全相同的其他同学的学号和姓名
/*string_agg将分组连接起来，与group by 联合使用，类似sql中的group_concat*/
/*课程完全相同，将其汇总为一个新变量*/
/*查询出01所选的全部课程，用string_agg连接起来
将其他学生所选的课程都用string_agg汇总起来
*/

select a.sid,student.sname 
from (select sid,string_agg(cid,',') cagg from sc where sid !='01' group by sid ) a /*其他学生全部课程汇总*/ 
left join student on student.sid=a.sid 
where cagg=
(select string_agg(cid,',') from sc where sid='01' group by sid)/*01学生的课程*/ ; 

-- 13. 把“SC”表中“张三”老师教的课的成绩都更改为此课程的平均成绩；
/*求出“张三”老师教课程的平均成绩，在进行更改*/

update  sc set score=(select avg(score) from sc where cid =(select cid from course left join teacher on course.tid=teacher.tid where tname='张三') 
group by cid/*张三老师课程平均分*/) 
where cid = (select cid from course left join teacher on course.tid=teacher.tid where tname='张三');

-- 14. 查询没学过"张三"老师讲授的任一门课程的学生姓名
/*先把选了张三的课的学生sid查询出来，然后not in */
select sid,sname from student 
where sid not in 
(select sid from sc 
left join course on sc.cid=course.cid
left join teacher on course.tid=teacher.tid  
where teacher.tname='张三');

-- 15. 查询两门及其以上不及格课程的同学的学号，姓名及其平均成绩
/*先筛选出score<60 的学生然后再  count(cid)>=2*/

select student.sid,student.sname,avg(sc.score) 
from student 
left join sc on student.sid=sc.sid 
where sc.score<60 
group by student.sid,student.sname
having count(sc.cid)>=2;

-- 16. 检索"01"课程分数小于60，按分数降序排列的学生信息

select student.* from student 
left join sc on student.sid=sc.sid
where sc.cid='01' and sc.score <60 
order by sc.score desc;

-- 17. 按平均成绩从高到低显示所有学生的平均成绩
select sid,avg(score) avg from sc 
group by sid 
order by avg desc;


-- 18. 查询各科成绩最高分、最低分和平均分：以如下形式显示：课程ID，课程name，最高分，最低分，平均分，及格率
/*难点 在于如何对分组后计算及格率，用case when 大于60 记为1求和*/
select sc.cid, 
course.cname,
max(sc.score),
min(sc.score),
avg(sc.score),
(select count(score) from sc where score>60)::numeric/(select count(score) from sc)::numeric passrate /*没有考虑课程分组*/
from sc left join course on sc.cid=course.cid
group by sc.cid,course.cname;

select sc.cid 课程号, 
course.cname 课程名,
max(sc.score) 最高分,
min(sc.score) 最低分,
avg(sc.score) 平均分,
concat((sum(case when score>60 then 1 else 0 end )*100/count(score)),'%') 及格率
from sc left join course on sc.cid=course.cid
group by sc.cid,course.cname;

-- 19. 按各科平均成绩从低到高和及格率的百分数从高到低顺序
select sc.cid 课程号, 
course.cname 课程名,
max(sc.score) 最高分,
min(sc.score) 最低分,
avg(sc.score) 平均分,
concat((sum(case when score>60 then 1 else 0 end )*100/count(score)),'%') 及格率
from sc left join course on sc.cid=course.cid
group by sc.cid,course.cname
order by avg(sc.score) asc , 及格率 desc;

-- 19.1 查询各科成绩最高分、最低分和平均分，以如下形式显示：课程 ID，课程 name，最高分，最低分，平均分，及格率，中等率，优良率，优秀率(及格为>=60，中等为：70-80，优良为：80-90，优秀为：>=90）
select sc.cid 课程号, 
course.cname 课程名,
max(sc.score) 最高分,
min(sc.score) 最低分,
avg(sc.score) 平均分,
concat((sum(case when score>60 then 1 else 0 end )*100/count(score)),'%') 及格率,
concat((sum(case when score >=70 and score<80 then 1 else 0 end)*100/count(score)),'%') 中等率,
concat((sum(case when score >=80 and score<90 then 1 else 0 end)*100/count(score)),'%') 优良率,
concat((sum(case when score >=90 then 1 else 0 end)*100/count(score)),'%') 优秀率
from sc left join course on sc.cid=course.cid
group by sc.cid,course.cname;

-- 20. 查询学生的总成绩并进行排名
/*考虑到没有选课的学生的总成绩
将null 转为0
排名用窗口函数，窗口函数中order by 用原表变量或者创建的变量的函数，不能用新变量
名替代，这里就是指order by 不能用sumscore*/
select student.sid,student.sname ,
(sum(case when sc.score is null then 0 else sc.score end))  sumscore,
rank() over(order by (sum(case when sc.score is null then 0 else sc.score end)) desc) rank 
from student left join sc on student.sid=sc.sid 
group by student.sid,student.sname ;


-- 21. 查询不同老师所教不同课程平均分从高到低显示

select teacher.tid,teacher.tname,avg(sc.score) from teacher,course,sc 
where course.tid=teacher.tid
and course.cid=sc.cid 
group by teacher.tid,teacher.tname
order by avg(sc.score) desc;

-- 22. 查询所有课程的成绩第2名到第3名的学生信息及该课程成绩
/*窗口函数，将成绩按照cid分组score 降序 得到一个排名
dense_rank()如果有并列名次的行，不占用下一名次的位置
rank()占用下个名次，
row_number()不考虑并列名次的情况*/

select student.*,temp.cid,temp.score,temp.rank from (select *, dense_rank()over(partition by cid order by score desc) rank 
from sc ) temp /*含排名*/ 
left join student on student.sid=temp.sid
where rank in (2,3);

-- 23. 统计各科成绩各分数段人数：课程编号,课程名称,[100-85],[85-70],[70-60],[0-60]及所占百分比

/*运用case when 以及sum结合*/
select sc.cid,course.cname,
sum(case when score<=60 then 1 else 0 end) "[0-60]人数",
sum(case when score<=60 then 1 else 0 end)*100 /count(score) as "[0-60](%)",
sum(case when score>60 and score<=70 then 1 else 0 end) as "[60-70]人数",
sum(case when score>60 and score<=70 then 1 else 0 end)*100 /count(score) as "[60-70](%)",
sum(case when score>70 and score<=85 then 1 else 0 end)*100 /count(score) as "[70-85](%)",
sum(case when score>85 and score<100 then 1 else 0 end)*100 /count(score) as "[85-100](%)"
from sc,course
where sc.cid=course.cid 
group by sc.cid,course.cname;



-- 24. 查询学生平均成绩及其名次

select sid,avg(score),rank()over(order by sum(score) desc) from sc group by sid;

-- 25. 查询各科成绩前三名的记录
/*将分数按照课程分组降序排列得到排名
将含有排名的表作为临时表
从这个表里进行查询*/
select * from 
(select sc.*,rank()over (partition by cid order by score desc) as ranking  from sc ) temp 
where temp.ranking<=3;

-- 26. 查询每门课程被选修的学生数
/*按课程分组对sid进行计数*/
select cid,count(sid) from sc 
group by cid;

-- 27. 查询出只选修了一门课程的全部学生的学号

select sid from sc group by sid having count(cid)=1; 

-- 28. 查询男生、女生人数
select ssex,count(ssex) from student group by ssex;
-- 29. 查询名字中含有"风"字的学生信息
select * from student where sname like '%风%';

-- 30. 查询同名同性学生名单，并统计同名人数
select sname,ssex,count(sid) from student 
group by sname,ssex
having count(*)>1;

-- 31. 查询1990年出生的学生名单(注：Student表中Sage列的类型是datetime)
/*pgsql没有year函数*/
select * from student where year(sage)=1990;


-- 32. 查询每门课程的平均成绩，结果按平均成绩升序排列，平均成绩相同时，按课程号降序排列
select cid,avg(score) from sc
group by cid
order by avg(score),cid desc;

-- 33. 查询不及格的课程，并按课程号从大到小排列
select distinct cid from sc where score<60  order by cid desc;

-- 34. 查询课程编号为"01"且课程成绩在60分以上的学生的学号和姓名；
select sc.sid,student.sname from sc,student where sc.sid=student.sid and cid='01' and score>60;

-- 35. 查询选修“张三”老师所授课程的学生中，成绩最高的学生姓名及其成绩
/*成绩最高可以降序后用limit*/
select student.sname,sc.score from sc,student,course,teacher 
where sc.sid=student.sid 
and sc.cid=course.cid
and course.tid=teacher.tid
and teacher.tname='张三'
order by sc.score desc
limit 1 ;

-- 36. 查询每门功课成绩最好的前两名
/*用两个sc表进行根据cid左连接，这样左sc表的每一个cid如01的每一个score都会与右表的所有01的score进行连接，是一对多，01有6个分数，连接后，就会有6*6个01表
这样通过a.score<b.score可以把每个分数比大小的样本筛选出来
select * from sc as a 
left join sc as b 
on a.cid = b.cid and a.score<b.score*/
/*取每门课程的前多少名就通过a.score<b.score删选后用count(b.cid)<前多少名，但这样是没有考虑并列*/
select a.cid, a.sid from sc as a 
left join sc as b 
on a.cid = b.cid and a.score<b.score
group by a.cid, a.sid
having count(b.cid)<2
order by a.cid;

select
    cid,sid,rank1
from 
    (select
            cid
            ,sid
            ,rank() over(partition by cid order by score desc) as rank1
        from sc 
    )t
where rank1 <=2;/*这个也是没有考虑并列情况*/

-- 37. 统计每门课程的学生选修人数（超过5人的课程才统计）。要求输出课程号和选修人数，查询结果按人数降序排列，若人数相同，按课程号升序排列
select cid,count(sid) from sc
group by cid 
having count(sid)>5
order by count(sid) desc,cid;


-- 38. 检索至少选修两门课程的学生学号
select sid from sc 
group by sid
having count(cid)>=2;

-- 39. 查询选修了全部课程的学生信息
select * from student where sid in (select distinct sid from sc
group by sc.sid 
having count(*) =(select distinct count(cid) from course));
-- 40. 查询各学生的年龄
select
    sid,sname,year(curdate())-year(sage) as sage
from student; /*mysql*/

select sid,sname,age(CURRENT_DATE,sage) age from student;

-- 41 查询本周过生日的学生
select *
from student 
where WEEKOFYEAR(student.Sage)=WEEKOFYEAR(CURDATE()); /*mysql*/



-- 42. 查询下周过生日的学生
select 
    sid,sname,sage
from student
where weekofyear(sage) = weekofyear(date_add(curdate(),interval 1 week));/*mysql*/
-- 43.查询本月过生日的学生
select
    sid,sname,sage
from student
where month(sage) = month(curdate());/*mysql*/
-- 44. 查询下月过生日的学生
select
    sid,sname,sage
from student
where month(date_sub(sage,interval 1 month)) = month(curdate());

select *
from student 
where MONTH(student.Sage)=MONTH(CURDATE())+1;

