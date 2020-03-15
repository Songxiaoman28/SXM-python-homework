-- Planet_Express 
/*package表创建时部分数据未插入：insert or update on table "package" violates foreign key constraint "package_recipient_fkey"*/
-- employee.employeeid=has_clearance.employee
-- package.recipient=client.accountnumber
-- package.shipment=shipment.shipmentid
-- planet.planetid=shipment.planet
-- planet.planetid=has_clearance.planet;
-- employee.employeeid=shipment.manager
-- package.sender=client.accountnumber
-- employee e
-- has_clearance h
-- package pa 
-- planet pl
-- client c
-- shipment s

-- 7.1 Who receieved a 1.5kg package?
    -- The result is "Al Gore's Head".
select c.name from package pa 
left join client c on  pa.recipient=c.accountnumber
where pa.weight=1.5;

-- 7.2 What is the total weight of all the packages that he sent?
select sum(weight) from package pa left join client c on  pa.recipient=c.accountnumber where c.name='Al Gore''s Head';



