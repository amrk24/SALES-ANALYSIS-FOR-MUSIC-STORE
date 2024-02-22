

--q1: who is The senior most employees based on the job title
select (first_name + ' ' +last_name) as name ,title,levels
from music_database .. employee$
order by levels desc

--q2: which countries have the most invoices
select top 1 billing_country,count(*) as c
from music_database..invoice$
group by billing_country
order by count(*) desc 

--format date
alter table music_database..invoice$
add format_date date 

update music_database..invoice$
set format_date = convert(date , invoice_date) 

--q4: what is the top 3 values of total invoices 
select top 3 ROUND(total,2)
from music_database..invoice$
order by total desc

--q5: which city has the best customer .. select top 3
select top 3 billing_city,SUM(total) as invoice_total  
from music_database..invoice$
group by billing_city
order by sum(total) desc

--who is the best coustomers that spent the most money 
select first_name ,last_name,inv.customer_id,round(sum(total),2)
from music_database..invoice$ inv
join music_database..customer$ cu
on inv.customer_id = cu.customer_id
group by inv.customer_id, first_name ,last_name
order by sum(total) desc


-- retuen email,first name, last name and genere for all rock lesteners
select distinct first_name,last_name,email,g.name
from music_database..customer$ c
join music_database..invoice$ i
on c.customer_id = i.customer_id
join music_database..invoice_line$ il
on i.invoice_id = il.invoice_id
join music_database..track$ t
on il.track_id = t.track_id
join music_database..genre$ g
on t.genre_id = g.genre_id
where g.name like '%Rock%'
order by email

--top artists in rock 
select  distinct a.name,a.artist_id,g.name,count(a.name) over (partition by a.name) as total
from music_database..artist$ a
join music_database..album$ al
on a.artist_id = al.artist_id
join music_database..track$ t
on al.album_id= t.album_id
join music_database..genre$ g
on t.genre_id = g.genre_id
where g.genre_id =1
--group by a.name,a.artist_id,g.name
order by total desc

-- the songs that lenght of its name is longer than average name lenght
select name , len(name) , milliseconds
from music_database..track$
where len(name) > (select avg(len(name)) from music_database..track$)
order by len(name) desc

-- the songs that longer than the average in millesecond
select name , milliseconds
from music_database..track$
where milliseconds > (select avg(milliseconds) from music_database..track$)
order by milliseconds desc

--find how much spent customer on artists? and best customer and artist

with best_artist as 
(
select ar.name,ar.artist_id,SUM(i.quantity*i.unit_price) as total
from music_database..invoice_line$ i
join music_database..track$ t
on i.track_id = t.track_id
join music_database..album$ a 
on t.album_id = a.album_id
join music_database..artist$ ar
on a.artist_id = ar.artist_id
group by ar.name,ar.artist_id
) 
select c.first_name ,c.last_name,be.name,be.total
from music_database..customer$ c
join music_database..invoice$ i
on c.customer_id = i.customer_id
join music_database..invoice_line$ il
on i.invoice_id = il.invoice_id
join music_database..track$ t
on t.track_id = il.track_id
join music_database..album$ al
on t.album_id = al.album_id
join best_artist be
on al.artist_id = be.artist_id
group by c.first_name ,c.last_name,be.name,be.total
order by total desc

--gener populer in each country
select distinct c.country, g.name,count(il.quantity) count
from music_database..customer$ c 
join music_database..invoice$ i
on c.customer_id = i.customer_id
join music_database..invoice_line$ il
on i.invoice_id = il.invoice_id
join music_database..track$ t
on il.track_id = t.track_id
join music_database..genre$ g
on t.genre_id = g.genre_id
group by c.country,g.name
order by 1 ,count desc

--top customers in spent money in each country 
with custmer_spending as
(
select c.country,c.first_name,sum(il.quantity*il.unit_price) total
from music_database..customer$ c
join music_database..invoice$ i
on c.customer_id = i.customer_id
join music_database..invoice_line$ il
on i.invoice_id = il.invoice_id
group by c.first_name,c.country
)
select country,MAX(total),first_name 
from custmer_spending
group by country,first_name 
order by 2 desc,1






