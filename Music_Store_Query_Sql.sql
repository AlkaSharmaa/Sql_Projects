/* 1. Who is the senior most employee based on job title? */
select first_name,
last_name, title 
from employee
order by levels desc
limit 1

/*2. Which countries have the most Invoices?*/
select  billing_country, 
		count(*) as most_Invoice 
		from invoice 
group by billing_country
order by most_Invoice desc
limit 5

/*  3. What are top 3 values of total invoice? */
select total  from invoice
order by total desc
limit 3

 /* Q4: Which city has the best customers? 
We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select billing_city,sum(total) as invoice_total from invoice
group by billing_city
order by invoice_total desc
limit 2

/* Q5: Who is the best customer? 
The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/
select  c.first_name,
		c.last_name,c.customer_id,
        sum(total) as total_spending 
from customer c 
join invoice i on c.customer_id = i.customer_id
group by 
		c.first_name,
		c.last_name,c.customer_id
order by total_spending desc
limit 1
 /* Q6 Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A */ 

select  distinct c.first_name, 
		c.last_name, c.email
		from customer c
		join invoice i on i.customer_id   =  c.customer_id
		join invoice_line il on il.invoice_id = i.invoice_id
		join track t on t.track_id = il.track_id
		join genre g on g.genre_id = t.genre_id	
where  g.name = 'Rock'
order by email
limit 5

/* Q7 Let's invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands*/

select a.artist_id,a.name,count(a.artist_id) as no_of_song from artist a 
join album1 al on al.artist_id = a.artist_id
join track t on t.album_id = al.album_id
join genre g on g.genre_id = t.genre_id
where g.name = 'Rock'
group by a.artist_id,a.name
order by no_of_song desc
limit 10

/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. 
Order by the song length with the longest songs listed first. */

select track_id,milliseconds from track 
where milliseconds >(select avg(milliseconds) as avg_song_length from track)
order by milliseconds desc;
/*/* Q9: Find how much amount spent by each customer on artists?
 Write a query to return customer name, artist name and total spent */
 
 WITH best_selling_artist AS (
	SELECT art.artist_id AS art_id, art.name AS art_name, 
    SUM(il.unit_price*il.quantity) AS total_sales
	FROM invoice_line il 
	JOIN track ON track.track_id = il.track_id
	JOIN album1 ON album1.album_id = track.album_id
	JOIN artist art ON art.artist_id = album1.artist_id
	GROUP BY 1,2 )
SELECT c.customer_id, c.first_name, c.last_name,  bsa.art_name,
SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album1 alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.art_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC
limit 5;

/* Q10: We want to find out the most popular music Genre for each country.
 We determine the most popular genre as the genre 
with the highest amount of purchases.
 Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

with popular_genre as (
	select count(il.quantity) as purchases, c.country, g.name, g.genre_id,
    row_number() over(partition by c.country order by count(il.quantity) desc) 
    as row_no
    from invoice_line il 
		join invoice i on i.invoice_id = il.invoice_id
        join customer c on c.customer_id = i.customer_id
        join track t on t.track_id = il.track_id
        join genre g on g.genre_id = t.genre_id
        group by 2,3,4
        order by 2 asc,1 desc
        limit 5
)
select * from popular_genre where row_no>=1


/* Q-11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

With Customter_with_country AS (
		SELECT c.customer_id, first_name, last_name, billing_country,
        SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice i 
		JOIN customer c ON c.customer_id = i.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1
        







