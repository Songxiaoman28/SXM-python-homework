-- Scientists
-- scientists.ssn=assignedto.scientist
-- assignedto.project=projects.code
-- 6.1 List all the scientists' names, their projects' names, 
    -- and the hours worked by that scientist on each project, 
    -- in alphabetical order of project name, then scientist name.
select p.name project,s.name scientist,p.hours from projects p 
left join assignedto a on a.project=p.code 
left join scientists s on s.ssn=a.scientist
order by p.name ,s.name;

-- 6.2 Select the project names which are not assigned yet
select p.name from projects p 
left join assignedto a on a.project=p.code 
left join scientists s on s.ssn=a.scientist
where s.name is null;
