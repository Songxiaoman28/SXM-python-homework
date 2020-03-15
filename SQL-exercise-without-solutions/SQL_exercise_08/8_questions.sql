--physician; 医生信息
--procedures; 手术名称成本
--Trained_In;医生执行的手术代码及时间
--Undergoes; 病人手术信息
--patient;病人信息

-- 8.1 Obtain the names of all physicians that have performed a medical procedure they have never been certified to perform.
/*查询做过手术却没有记录的医生*/
select name from physician where employeeid in (select u.physician from undergoes u where not EXISTS (select * from trained_in t where t.physician=u.physician and t.treatment =u.procedures));

-- 8.2 Same as the previous query, but include the following information in the results: Physician name, name of procedure, date when the procedure was carried out, name of the patient the procedure was carried out on.
select p.name physician_name,pr.name  procedure_name,u.dateundergoes,pa.name from physician p  
join undergoes u on u.physician = p.employeeid 
join procedures pr on u.procedures = pr.code
join patient pa on u.patient = pa.ssn
where not EXISTS (select * from trained_in t where t.physician=u.physician and t.treatment =u.procedures);

-- 8.3 Obtain the names of all physicians that have performed a medical procedure that they are certified to perform, but such that the procedure was done at a date (Undergoes.Date) after the physician's certification expired (Trained_In.CertificationExpires).
/*查询做过手术并有手术记录，但手术日期超过认证最后期限*/
select p.name from trained_in t 
left join physician p on p.employeeid=t.physician
left join undergoes u on u.physician = t.physician
where u.dateundergoes>t.certificationexpires;

-- 8.4 Same as the previous query, but include the following information in the results: Physician name, name of procedure, date when the procedure was carried out, name of the patient the procedure was carried out on, and date when the certification expired.
select p.name physician_name,pr.name  procedure_name,u.dateundergoes,pa.name,t.certificationexpires  from trained_in t 
left join physician p on p.employeeid=t.physician
left join undergoes u on u.physician = t.physician
left join procedures pr on u.procedures = pr.code
left join patient pa on pa.ssn=u.patient
where u.dateundergoes>t.certificationexpires;


-- 8.5 Obtain the information for appointments where a patient met with a physician other than his/her primary care physician. Show the following information: Patient name, physician name, nurse name (if any), start and end time of appointment, examination room, and the name of the patient's primary care physician.
/*查询病人与除与primary care physician见面的其他医生的信息*/

select pa.name patient,p.name physician,n.name nurse, a.start starttime,a."End"  endtime,a.examinationroom,phy.name primary_care_physician 
from appointment a 
join physician p on a.physician=p.employeeid
join patient pa on a.patient=pa.ssn
left join nurse n on a.prepnurse=n.employeeid
left join physician phy on pa.pcp=phy.employeeid
where pa.pcp!=a.physician;


-- 8.6 The Patient field in Undergoes is redundant, since we can obtain it from the Stay table. There are no constraints in force to prevent inconsistencies between these two tables. More specifically, the Undergoes table may include a row where the patient ID does not match the one we would obtain from the Stay table through the Undergoes.Stay foreign key. Select all rows from Undergoes that exhibit this inconsistency.
/*在undergoes表中选出patient表中与stay表中不一致的记录*/
select u.* from undergoes u
where u.patient != ( select patient from stay s
where u.stay = s.stayid);

-- 8.7 Obtain the names of all the nurses who have ever been on call for room 123.
select distinct n.name from nurse n
left join on_call o on n.employeeid=o.nurse
left join block b on b.blockfloor=o.blockfloor and b.blockcode=o.blockcode
left join room r on r.blockcode=b.blockfloor and b.blockcode=r.blockcode and r.roomnumber=123;

-- 8.8 The hospital has several examination rooms where appointments take place. Obtain the number of appointments that have taken place in each examination room.
select examinationroom, count(appointmentid)
from appointment
group by examinationroom;

-- 8.9 Obtain the names of all patients (also include, for each patient, the name of the patient's primary care physician), such that \emph{all} the following are true:
    -- The patient has been prescribed some medication by his/her primary care physician.
    -- The patient has undergone a procedure with a cost larger that $5,000
    -- The patient has had at least two appointment where the nurse who prepped the appointment was a registered nurse.
    -- The patient's primary care physician is not the head of any department.
/*获取所有患者姓名，primary care physician  pcp:pcp 开过药；手术成本>5000;至少2次
appointment，且是registered nurse；pcp不是department 的head*/  
select pa.name patient,phy.name primary_care_physician 
from patient pa left join physician phy on  pa.pcp=phy.employeeid
where exists (
    select * from prescribes pr where pr.patient=pa.ssn and pr.physician=pa.pcp)
and exists (
    select * from undergoes u left join procedures pro on 
    u.procedures = pro.code and u.patient=pa.ssn and cost>5000)
and 2<= (
    select count(a.appointmentid) from appointment a left join nurse n 
    on a.prepnurse=n.employeeid and n.registered='1')
and pa.pcp not in (select head from department);
