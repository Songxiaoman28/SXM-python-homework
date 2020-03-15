-- Pieces_and_providers
-- pieces.code= provides.piece
-- provides.provider=providers.code
-- 5.1 Select the name of all the pieces. 
select name from pieces;

-- 5.2  Select all the providers' data. 
select * from providers;

-- 5.3 Obtain the average price of each piece (show only the piece code and the average price).
select piece, round(avg(price),2)  avg_price from provides group by piece;

-- 5.4  Obtain the names of all providers who supply piece 1.
select   b.name from provides a 
left join providers b on a.provider=b.code 
where a.piece=1;

-- 5.5 Select the name of pieces provided by provider with code "HAL".
select  b.name from provides a 
left join pieces b on b.code= a.piece
where a.provider='HAL';

-- 5.6
-- ---------------------------------------------
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- Interesting and important one.
-- For each piece, find the most expensive offering of that piece and include the piece name, provider name, and price 
-- (note that there could be two providers who supply the same piece at the most expensive price).
-- ---------------------------------------------
select d.piece,d.price,d.provider from (
    select b.name piece,
    a.price,c.name provider,
    row_number() over(PARTITION BY  a.piece order by a.price desc) ranks 
    from provides a 
    left join pieces b on b.code= a.piece 
    left join providers c on a.provider=c.code) d
where d.ranks=1 ;
/*通过排序找最大值,选取第一条记录*/

-- 5.7 Add an entry to the database to indicate that "Skellington Supplies" (code "TNBC") will provide sprockets (code "1") for 7 cents each.
insert into provides values (1,'TNBC',7);

-- 5.8 Increase all prices by one cent.
update provides set price=price+1;

-- 5.9 Update the database to reflect that "Susan Calvin Corp." (code "RBT") will not supply bolts (code 4).
delete from provides where provider='RBT' and piece=4;

-- 5.10 Update the database to reflect that "Susan Calvin Corp." (code "RBT") will not supply any pieces 
    -- (the provider should still remain in the database).
delete from provides where provider='RBT';
