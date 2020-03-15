-- 10.1 Join table PEOPLE and ADDRESS, but keep only one address information for each person (we don't mind which record we take for each person). 
    -- i.e., the joined table should have the same number of rows as table PEOPLE
select p.id,p.name,a.address from people p 
left join (
    select id,max(address) address 
    from address group by id) a on p.id=a.id ;


-- 10.2 Join table PEOPLE and ADDRESS, but ONLY keep the LATEST address information for each person. 
    -- i.e., the joined table should have the same number of rows as table PEOPLE
select d.id,d.name,d.address,d.updatedate from(
    select p.id,p.name,a.address,a.updatedate,
     row_number() over(partition by a.id order by a.updatedate desc ) r 
     from people p left join address a on p.id=a.id ) d 
     where r=1;
