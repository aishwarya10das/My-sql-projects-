# who is the senior most employee based on job title?

select * from employee
order by levels desc
limit 1;

# which countries have the most invoices?

select  count(*) as c, billing_country from invoice
group by billing_country
order by c desc;

# what are the top 3 values of total invoices?

select total from invoice
order by total desc
limit 3;

/* which city has the best customers? we would like to throw a promo music event
in the city we made the most money.write a query that returns highest sum of 
invoice totals. Return both city name and invoice totals. */

select sum(total) as invoice_total , billing_city from invoice
group by billing_city 
order by invoice_total desc;


/* who is the best customer? the customer who has spent the 
most money will be the best customer. Write a query to find the best customer? */

select customer. customer_id , customer.first_name , customer.last_name , sum(invoice. total) as t  from customer
join invoice on customer. customer_id = invoice. customer_id
group by customer . customer_id
order by t desc
limit 1 ;

/* write a query to  return the first name, last name , enmail, and all the genre of  rock music listeners.return the
name aphabetically ordered by email starting with A. */

select distinct email, first_name, last_name from customer
join invoice on customer. customer_id = invoice.customer_id
join invoice_line on invoice. invoice_id = invoice_line.invoice_id
where track_id in(
select track_id from track
join genre on track.genre_id=genre. genre_id
where genre.name like 'Rock'
)
order by email;

/* lets invite the artists who have written the most rock music in our data set.
write a query that returns the artists name and total trcak count of the top 10 rock bands*/

select artist.artist_id , artist.name, count(artist.artist_id) as number_of_songs from track
join album2 on album2.album_id = track.album_id
join artist on artist.artist_id = album2.artist_id 
join genre on genre.genre_id = track. genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_of_songs desc
limit 10;




/* return all the track names that have a song lenghth longer than the average song lenghth
return the name and milliseconds for each track. order by song lenghth with the longest songs listed first.*/


select name, milliseconds from track
where milliseconds > ( 
select avg (milliseconds) as avg_track_length
from track )
order by milliseconds desc
;

/* Find how much amount spent by each customer on artists?
write a query to return customer name , artist name and total spent */

with best_selling_artist as(
select artist.artist_id as artist_id, artist.name as artist_name,
sum(invoice_line.unit_price*invoice_line.quantity) as total_sales from invoice_line
join track on track.track_id =invoice_line.track_id
join album2 on album2.album_id = track.album_id
join artist on artist.artist_id=album2.artist_id
group by 1 
order by 3 desc
limit 1 
)
select c.customer_id, c.first_name, c.last_name , bsa.artist_name, sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id = i .customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album2 alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;

/* we want to find out the most popular music dgenre for each country.
we determine the most popular genre as the genre with the highest amount of purchases.
 write a query that returns each country along with the top genre .
 for countries where the maximum number of purchases is shared return all geres.
 */
 
WITH popular_genre as 
 (
 select count(invoice_line.quantity) as purchases, customer.country, genre.name, genre.genre_id,
 row_number() over(partition by customer.country order by count(invoice_line.quantity)desc)as RowNo
 from invoice_line
 join invoice on invoice.invoice_id=invoice_line.invoice_id
 join customer on customer.customer_id=invoice.customer_id
 join track on track.track_id=invoice_line.track_id
 join genre on genre.genre_id=track.genre_id
 group by 2,3,4
 order by 2 asc , 1 desc
 )

 select * from popular_genre where RowNo <=1;
 
 /*write a query that detremines the customer that has spent the most money on music
 for each country. Write a query that returns the country along with the top customet and how much they spent .
 For countries where the top amount spend alteris shared, provide all customers who spent thsi amount
 */
 
 with recursive 
  customer_with_country as(
  select customer.customer_id,first_name,last_name,billing_country, 
  sum(total) as total_spending from invoice
  join customer on customer.customer_id =invoice.customer_id
 group by 1,2,3,4
 order by 2,3 desc 
 ),
  country_max_spending as(
  select billing_country, max(total_spending) as max_spending
  from customer_with_country
  group by billing_country)
  
  select cc.billing_country,cc.total_spending, cc. first_name, cc. last_name,cc.customer_id
  from customer_with_country cc
  join country_max_spending ms 
  on cc.billing_country=ms.billing_country
  where cc.total_spending=ms.max_spending
  order by 1;