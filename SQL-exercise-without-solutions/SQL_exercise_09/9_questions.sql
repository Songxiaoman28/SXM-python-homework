-- 9.1 give the total number of recordings in this table
select count(*) from cran_logs;

-- 9.2 the number of packages listed in this table?
select count(distinct package) from cran_logs;

-- 9.3 How many times the package "Rcpp" was downloaded?
select count(*) from cran_logs where package='Rcpp';

-- 9.4 How many recordings are from China ("CN")?
select count(*) from cran_logs where country='CN';

-- 9.5 Give the package name and how many times they're downloaded. Order by the 2nd column descently.
select package,count(*) from cran_logs 
group by package  
order by 2 desc;

-- 9.6 Give the package ranking (based on how many times it was downloaded) during 9AM to 11AM
select a.package, count(*) from (select * from cran_logs where  substr(time, 1, 5)<'11:00' and substr(time, 1, 5)>'09:00') a
group by a.package ;

-- 9.7 How many recordings are from China ("CN") or Japan("JP") or Singapore
-- ("SG")?
select count(*) from cran_logs 
where country in ('CN','JP','SG');

-- 9.8 Print the countries whose downloaded are more than the downloads from China ("CN")
select country from cran_logs 
group by country
having count(package)>(
    select count(package) from cran_logs where country='CN'
);

-- 9.9 Print the average length of the package name of all the UNIQUE packages
select avg(length(p.package)) from (select distinct package from cran_logs) p ;

-- 9.10 Get the package whose downloading count ranks 2nd (print package name and it's download count).
select distinct package, count(package) download_numbers
from cran_logs 
group by package 
order by count(package) desc 
limit 1 offset 1;

-- 9.11 Print the name of the package whose download count is bigger than 1000.
select package from cran_logs 
group by package 
having count(package)>1000;

-- 9.12 The field "r_os" is the operating system of the users.
    -- 	Here we would like to know what main system we have (ignore version number), the relevant counts, and the proportion (in percentage).
select substr(r_os,1,5), count(r_os) system_number, concat(round(count(r_os)/(select count(*) from cran_logs)*100,2),'%') propotion  from cran_logs
group by substr(r_os,1,5)
order by system_number desc;

