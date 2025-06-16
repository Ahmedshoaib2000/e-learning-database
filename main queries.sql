use E_Learning 
--1.1 show number of enrollments at each category
create or alter view popular_category 
as 
select c.category,COUNT(e.enrollment_id) as number_of_enrollments
from enrollment_schema.enrollment e join course_schema.course c
on e.course_id=c.course_id join users_schema.learners l
on e.learner_id=l.learner_id
group by c.category
select * from popular_category 
----1.2 show number of enrollments at each course
create or alter view course_enrollments
as
select c.c_name,COUNT(e.course_id) as number_of_enrollments
from enrollment_schema.enrollment e join course_schema.course c
on e.course_id=c.course_id join users_schema.learners l
on e.learner_id=l.learner_id
group by c.c_name
select * from course_enrollments
--3.1 Find the average course rating. 
create function course_rating(@coursename varchar(250))
returns int 
begin
declare @avg_rate int
select @avg_rate=AVG(f.rating )
from course_schema.course c join feedback_schema.feedback f
on c.course_id=f.course_id
where c.c_name=@coursename
return  @avg_rate
end 
select dbo.course_rating('Web Development with JavaScript') as avg_rate
select dbo.course_rating('Python for Data Science') as avg_rate

--4.1 the most popular courses at each category order by thier rating 
CREATE OR ALTER PROCEDURE pop_course(@category_name varchar(255))
as
begin
select avg(f.rating) as avg_rate,c.c_name
from course_schema.course c join feedback_schema.feedback f
on c.course_id=f.course_id
where c.category=@category_name
group by c.category,c.c_name
order by avg_rate desc 
end 
exec pop_course 'Programming'
exec pop_course 'Science'

--5.1 how much enrollment from country 
CREATE OR ALTER PROCEDURE pop_country
as
begin 
select l.country,COUNT(e.learner_id) as number_of_learner
from users_schema.learners l join enrollment_schema.enrollment e 
on l.learner_id=e.learner_id
group by l.country
order by  number_of_learner desc 
end
exec pop_country
--------------------------------------------------------------
--5.1 Show top-performing learners by quiz scores. 
create or alter proc top_learner 
as 
begin
select l.fname+''+l.lname as full_name ,sum(cast(ea.is_correct as int)) as score
from evaluation.answers ea join users_schema.learners l
on ea.learner_id=l.learner_id
group by l.fname,l.lname
order by score desc
end 
exec top_learner


-- 2.1 List learners who have completed spacific value of the course. 
create or alter proc Amount_of_progress(@percent decimal(4,2))
as 
begin
select  l.fname+''+l.lname as full_name ,COUNT(e.course_id) as number_of_course
from users_schema.learners l join enrollment_schema.enrollment e 
on l.learner_id=e.learner_id
where e.progress>=@percent
group by l.fname,l.lname 
order by number_of_course desc
end 
exec Amount_of_progress 50.00

--2.2 specific learner across all their courses.
create  or alter function learner_info (@id int)
returns table 
as
return
(
   select 
        l.fname + ' ' + l.lname as full_name, 
        e.progress, 
        c.c_name,  
        COUNT(cc.certification_id) as number_of_certifications
    from  users_schema.learners l join enrollment_schema.enrollment e on e.learner_id = l.learner_id
    join course_schema.course  c on e.course_id = c.course_id
    left join certification_schema.certification cc on cc.learner_id = l.learner_id and cc.course_id = c.course_id
    where l.learner_id = @id
    group by l.fname, l.lname, e.progress, c.c_name
)
SELECT *from learner_info(3)


-- 2.3 learners who started but didn’t get a certification.
create or alter view no_certification 
as
select l.learner_id,l.fname + ' ' + l.lname as full_name ,l.country
from users_schema.learners l 
where l.learner_id not in (
select l.learner_id
from users_schema.learners l join certification_schema.certification c
on l.learner_id = c.learner_id
)
 select * from no_certification

 --3.1 List courses with no enrollments.
 create or alter view no_enrollments_course 
 as
 select c.course_id,c.c_name,c.category
 from course_schema.course c 
 where c.course_id not in (
 select distinct(c.course_id)
 from enrollment_schema.enrollment e join course_schema.course c
 on e.course_id =c.course_id)
 select * from no_enrollments_course 

 -- 3.2 Find the average progress for each course.
 create or alter function avg_progress(@coursename varchar(250))
 returns table 
 as 
 return
 (
 select c.c_name,AVG(e.progress) as avg_progress
 from course_schema.course c join enrollment_schema.enrollment e 
 on c.course_id=e.course_id
 where c.c_name=@coursename
 group by c.c_name
 )
 select * from avg_progress('Mental Health and Wellbeing')

--3.4 Show the top-rated instructors based on feedback
create or alter proc top_instructors 
as 
begin 
select i.instructor_id,i.fname +''+i.lname as full_name ,i.qualification,AVG(f.rating) as avg_rate 
from users_schema.instructors i join course_schema.course c 
on i.instructor_id=c.instructor_id join feedback_schema.feedback f
on f.course_id=c.course_id
group by i.instructor_id,i.fname,i.lname,i.qualification
order by AVG(f.rating) desc
end 
exec top_instructors;

--  3.5 the most content popular 
create or alter view content_popular
as
select cc.content_type ,COUNT(cc.content_type) as number_of_content_type
from course_schema.course c join course_schema.course_content cc 
on c.course_id=cc.course_id
group by cc.content_type
select * from content_popular

-- 3.6 Compare feedback ratings across different categories. 
create or alter proc category_feedback 
as
begin 
select c.category,AVG(f.rating) as category_feedback_rateing 
from course_schema.course c join feedback_schema.feedback f
on c.course_id=f.course_id
group by c.category
order by category_feedback_rateing  desc
end
exec category_feedback
------------------------------------------------------------------
-- 4.1 Pivot Table learners by country 
SELECT * 
FROM (
    SELECT l.country
    FROM users_schema.learners l
) AS country_data
PIVOT (
    COUNT(country) FOR country IN (
        [Australia],[Canada],[France],
        [Germany],[Italy],[UK],[USA]
    )
) AS p_table;
--4.2  Number of Courses  in Category
select * from (
select c.category,c.c_name
from course_schema.course c
)as  c_data
PIVOT
(
count(c_name) for category in ([Arts & Humanities],
[Business],[Education],[Health & Wellness],
[Mathematics],[Programming],[Science],[Technology])
) as p1_table 
---------------------------------------------------
--5.1  Auto-Update Course Last Modified Date
create or alter trigger auto_update_course
on course_schema.course 
after update 
as
begin 
update course_schema.course 
set created_at=GETDATE()
where course_id in (select course_id from inserted);
end 

--5.2 Automatically log every learner who enrolls in a course.
create table Enrollment_Log
(
learner_id int ,
course_id int , 
enrollment_date date 
)
CREATE TRIGGER trg_Log_Course_Enrollments
ON enrollment_schema.enrollment
AFTER INSERT
AS
BEGIN
    INSERT INTO Enrollment_Log (learner_id, course_id, enrollment_date)
    SELECT learner_id, course_id, enrollment_date
    FROM inserted;
END
select * from Enrollment_Log

--5.3 create  clustered index 
create clustered index Enrollment_Log_id
on Enrollment_Log(learner_id)
--5.4  Iterating Over Learners and Updating Their Status cursor
alter table users_schema.learners
add status varchar(50)

declare @learner_id int;
declare @progress int;
declare @status varchar(50);

declare learner_cursor cursor for
select l.learner_id, progress
from users_schema.learners l
join enrollment_schema.enrollment e 
on l.learner_id = e.learner_id
where progress < 100;

open learner_cursor;

fetch next from learner_cursor into @learner_id, @progress;

while @@fetch_status = 0
begin
    if @progress = 0
    begin
        set @status = 'not started';
    end
    else if @progress < 50
    begin
        set @status = 'in progress';
    end
    else
    begin
        set @status = 'almost complete';
    end
    
    update users_schema.learners 
    set status = @status
    where learner_id = @learner_id;

    fetch next from learner_cursor into @learner_id, @progress;
end

close learner_cursor;
deallocate learner_cursor;
select * from users_schema.learners
--update learners status using merge
merge into users_schema.learners as target
using (
    select l.learner_id, max(e.progress) as progress 
    from users_schema.learners l
    join enrollment_schema.enrollment e 
    on l.learner_id = e.learner_id
    where e.progress < 100
    group by l.learner_id
) as source
on target.learner_id = source.learner_id
when matched then
    update set target.status = 
        case 
            when source.progress = 0 then 'not started'
            when source.progress < 50 then 'in progress'
            else 'almost complete'
        end;
------------------------------
--Show number of support tickets resolved by each admin.
select a.admin_id ,a.fname +' '+a.lname as full_name ,COUNT(s.support_id) as tickets_resolved
from users_schema.admins a join support_schema.support s 
on a.admin_id=s.admin_id
where s.status='Resolved'
group by a.admin_id,a.fname ,a.lname
order by tickets_resolved desc
--List learners with unresolved support issues.
select l.learner_id, l.fname + ' ' + l.lname as full_name
from users_schema.admins a join support_schema.support s 
on a.admin_id=s.admin_id join users_schema.learners l 
on l.learner_id=s.user_id
where s.status='Open'
---------------------------
-- Rank Learners by Total Quiz Score ranking func 
select 
    l.learner_id,
    l.fname + ' ' + l.lname as full_name,
    sum(cast(a.is_correct as int)) as total_score,
    rank() over (order by sum(cast(a.is_correct as int)) desc) as rank
from 
    evaluation.answers a
join 
    users_schema.learners l on a.learner_id = l.learner_id
group by 
    l.learner_id, l.fname, l.lname;
-- history of progress ber learners 
select 
    e.learner_id,
    l.fname + ' ' + l.lname as full_name,
    e.course_id,
    e.enrollment_date,
    e.progress,
    lag(e.progress, 1) over (
        partition by e.learner_id, e.course_id 
        order by e.enrollment_date
    ) as previous_progress,
    
    lead(e.progress, 1) over (
        partition by e.learner_id, e.course_id 
        order by e.enrollment_date
    ) as next_progress
from 
    enrollment_schema.enrollment e
join 
    users_schema.learners l on e.learner_id = l.learner_id;
	-----------------------
	--nonclustered index 
create nonclustered index enrollment_progress
on enrollment_schema.enrollment(progress);
----------------------------------------
--Backups
--full backup 
BACKUP DATABASE [E_Learning]
TO DISK = 'D:\backups e learning.bak'
WITH FORMAT,
     NAME = 'Full Backup of E_Learning';
	 -----------------------------------
--Differential Backup
BACKUP DATABASE [E_Learning]
TO DISK = 'D:\backups e learning.bak'
WITH DIFFERENTIAL,
     NAME = 'Differential Backup of E_Learning';

--------------------
--Transaction Log Backup
BACKUP LOG [E_Learning]
TO DISK = 'D:\backups e learning\E_Learning_LOG.trn'
WITH NOFORMAT,
     NAME = 'Transaction Log Backup of E_Learning';


