

--ipg mediabrand assignment

--problem 1
--You have a table named "ProductSales" with columns: ProductID, SaleDate, UnitsSold.
--Write a SQL query to find the top 3 products that have shown the most significant sales growth month-over-month.

--sample data
mysql> select * from ProductSales;
+-----------+------------+-----------+
| ProductID | SaleDate   | UnitsSold |
+-----------+------------+-----------+
|         1 | 2025-01-15 |       120 |
|         1 | 2025-02-15 |       180 |
|         1 | 2025-03-15 |       250 |
|         1 | 2025-04-15 |       300 |
|         2 | 2025-01-20 |        90 |
|         2 | 2025-02-20 |        95 |
|         2 | 2025-03-20 |       150 |
|         2 | 2025-04-20 |       310 |
|         3 | 2025-01-10 |       200 |
|         3 | 2025-02-10 |       180 |
|         3 | 2025-03-10 |       220 |
|         3 | 2025-04-10 |       400 |
|         4 | 2025-01-05 |        50 |
|         4 | 2025-02-05 |        80 |
|         4 | 2025-03-05 |        60 |
|         4 | 2025-04-05 |        90 |
|         5 | 2025-01-25 |       300 |
|         5 | 2025-02-25 |       310 |
|         5 | 2025-03-25 |       350 |
|         5 | 2025-04-25 |       370 |
+-----------+------------+-----------+


--solution

with cte as (
select
	*,
	lag(unitssold,1,unitssold) over(partition by productid order by saledate) as previous_units_sold
from ProductSales )
,cte2 as (
select
	ProductID,
	SaleDate,
	round((UnitsSold-previous_units_sold)/previous_units_sold * 100,2) as mom_growth_percent
from cte )
,ranked as (
select
	ProductID,
	SaleDate,
	mom_growth_percent,
	row_number() over(order by month(saledate) desc,mom_growth_percent desc) as ranked
from cte2 )
select 
	ProductID,
	SaleDate,
	mom_growth_percent
from ranked where ranked <= 3;
	

--problem 2
--Consider a table named "OnlineCourses" with columns: CourseID, EnrollmentDate, StudentID, CompletionDate.
--Write a SQL query to determine the courses which have the highest drop rate (i.e., students enrolling but not completing).

--sample data
mysql> select * from OnlineCourses;
+----------+----------------+-----------+----------------+
| CourseID | EnrollmentDate | StudentID | CompletionDate |
+----------+----------------+-----------+----------------+
|      101 | 2025-01-10     |         1 | 2025-03-15     |
|      101 | 2025-01-12     |         2 | NULL           |
|      101 | 2025-01-15     |         3 | 2025-03-18     |
|      101 | 2025-01-20     |         4 | NULL           |
|      101 | 2025-01-22     |         5 | NULL           |
|      102 | 2025-02-05     |         6 | 2025-04-10     |
|      102 | 2025-02-06     |         7 | 2025-04-12     |
|      102 | 2025-02-08     |         8 | 2025-04-15     |
|      102 | 2025-02-10     |         9 | 2025-04-18     |
|      103 | 2025-03-01     |        10 | NULL           |
|      103 | 2025-03-02     |        11 | NULL           |
|      103 | 2025-03-03     |        12 | NULL           |
|      103 | 2025-03-04     |        13 | NULL           |
|      103 | 2025-03-05     |        14 | NULL           |
|      104 | 2025-03-10     |        15 | 2025-05-10     |
|      104 | 2025-03-12     |        16 | NULL           |
|      104 | 2025-03-14     |        17 | NULL           |
|      104 | 2025-03-16     |        18 | 2025-05-15     |
|      105 | 2025-03-20     |        19 | 2025-05-25     |
|      105 | 2025-03-21     |        20 | 2025-05-26     |
|      105 | 2025-03-22     |        21 | NULL           |
+----------+----------------+-----------+----------------+

--solution

with cte as (
select
	CourseID,
	count(*) as total_student_cnt,
	sum(case when CompletionDate is null then 1 end) as dropped_student_cnt
from OnlineCourses
group by CourseID )
select 
	CourseID,
	round((coalesce(dropped_student_cnt,0) / total_student_cnt * 100),2) as drop_percent
from cte
order by drop_percent desc;


--problem 3
--If table “reviewer” has two columns RevID, RevName and table “rating” has columns MovID, RevID, Rating, Count, 
--write a SQL query to find those reviewers who have not given a rating to certain films. Sort the result-set in descending order by Reviewer Name.

--solution

select
	reviewer.RevName
from reviewer left join rating 
on reviewer.RevID = rating.RevID
where rating.RevID is null
order by reviewer.RevName desc;


--problem 4
Imagine a table named "Movies" with columns: MovieID, Title, ReleaseDate, GenreID. 
There's another table "Genres" with columns: GenreID, GenreName. 
Write a SQL query to fetch the genres that don't have any movies associated with them.

--solution

select
	Genres.GenreName
from Genres left join Movies 
on Movies.GenreID = Genres.GenreID
where Movies.GenreID is null;


--problem 5
--Consider a table named "Elections" with columns: CandidateID, VoterID, VoteDate. 
--Write a SQL query to calculate the candidate who received the highest number of votes each month.

--incomplete problem statement


--problem 6
--You are given a table named "Attendance" with columns: StudentID, ClassDate, IsPresent (a boolean where 1 indicates presence and 0 indicates absence). 
--Write a SQL query to identify students who have missed more than 3 consecutive classes.


with bucketed as (
select
	StudentID,
	ClassDate,
	IsPresent,
	(ClassDate - row_number() over(partition by StudentID order by ClassDate)) as bucket
from Attendance
where IsPresent = 0 )
select
	StudentID
from bucketed
group by StudentID,bucket
having count(*) > 3;


--problem 7
--How can you copy data from one table in a schema to another table? Can you elaborat with the help of an example query?

create table attendc1 select * from Attendance where 1=2;

--problem 8
You are provided with a table named LibraryBooks that contains the following columns:
BookID — Unique identifier for each book
BorrowDate — The date the book was borrowed
ReturnDate — The date the book is expected to be returned
ActualReturnDate — The date the book was actually returned (nullable; NULL if not yet returned)

Write a SQL query to find all books that are currently borrowed and have passed their return date without being returned.

select
	*
from LibraryBooks
where ActualReturnDate is null and ReturnDate < current_date();


--problem 9
There are two tables: "BlogPosts" and "Comments". 
The "BlogPosts" table has columns: PostID, Title, PostDate, AuthorID. 
The "Comments" table has columns: CommentID, PostID, CommentDate, Text. 
Write a SQL query to fetch the blog posts that have not received any comments within a week of their posting.

select
	PostID,
	Title
from BlogPosts left join Comments 
on BlogPosts.PostID = Comments.PostID
and CommentDate <= date_add(PostDate,interval 7 day)
where Comments.CommentID is null ;


--problem 9
You have a table named "FlightBookings" with columns: BookingID, Flight Date, PassengerID, Destination. 
Write a SQL query to determine which destination has seen a steady month-on-month increase in bookings over the last year.

complex one to do later


--problem 10
mysql> select * from MasterEmployee;
+--------------+--------+
| EmployeeName | Gender |
+--------------+--------+
| John         | M      |
| Peter        | M      |
| Reeta        | F      |
| Rahul        | M      |
| Halen        | F      |
+--------------+--------+

select
	sum(case when Gender = 'M' then 1 else 0 end) as Male,
	sum(case when Gender = 'F' then 1 else 0 end) as Female
from MasterEmployee;


--problem 10
You are given a table named "Subscription" with columns: UserID, Subscription Date, Expiry Date. 
Write a SQL query to count the number of active subscriptions on the first day of each month in the past year.

--sample data
mysql> select * from Subscription;
+--------+------------------+------------+
| UserID | SubscriptionDate | ExpiryDate |
+--------+------------------+------------+
|      1 | 2024-12-15       | 2025-03-14 |
|      2 | 2025-01-05       | 2025-06-04 |
|      3 | 2025-02-10       | 2025-08-09 |
|      4 | 2024-11-20       | 2025-01-19 |
|      5 | 2025-03-01       | 2025-09-28 |
|      6 | 2025-05-15       | 2025-12-14 |
+--------+------------------+------------+

op =
|      1 | 2024-12-15       | 2025-03-14 |
|      4 | 2024-11-20       | 2025-01-19 |


select
	userid
from Subscription 
where (month(SubscriptionDate) = '01' and year(SubscriptionDate) = '2024') and ExpiryDate >= '2025-01-01';

incorrect had to correct