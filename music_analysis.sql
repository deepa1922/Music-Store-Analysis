USE music;
-- Q1: Who is the senior most employee based on job title?
SELECT * FROM employee
ORDER BY levels DESC LIMIT 1;

-- Q2: Which country have the more Invoices?
SELECT COUNT(*),billing_country FROM invoice
GROUP BY billing_country
ORDER BY COUNT(*) DESC LIMIT 1;


-- Q3: What are the top 3 values to total invoice?
SELECT total FROM invoice
ORDER BY total DESC LIMIT 3;


-- Q4: Which city has the best customer? we would like to throw a promotional Music Festival in the city
-- we made the most money. write a query that returns one city that has the highest sum of invoice totals. 
--  Return both the city name & sum of all invoice totals.
SELECT SUM(total) ,billing_city FROM invoice
GROUP BY billing_city
ORDER BY SUM(total) DESC LIMIT 1;


-- Q5: Who is the best customer? The customer who has spend the most money will be declared the best customer. 
-- Write a query that return the person who had spend the most money.
SELECT  t1.first_name,t1.last_name,t1.customer_id,SUM(t2.total) AS total FROM customer t1
JOIN invoice t2
ON t1.customer_id = t2.customer_id
GROUP BY t1.customer_id,t1.first_name,t1.last_name
ORDER BY total DESC LIMIT 1	;

-- Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A. 
/*Method 1 */
SELECT DISTINCT t5.email,t5.first_name,t5.last_name FROM genre t1
JOIN track t2 ON t1.genre_id = t2.genre_id
JOIN invoice_line t3 ON t2.track_id = t3.track_id
JOIN invoice t4 ON t3.invoice_id = t4.invoice_id
JOIN customer t5 ON t4.customer_id = t5.customer_id
WHERE t1.name = 'Rock'
ORDER BY email;

/* method 2 - optimized and efficient due to its direct filtering*/
SELECT DISTINCT t1.email,t1.first_name ,t1.last_name FROM customer t1
JOIN invoice t2 ON t2.customer_id = t1.customer_id
JOIN invoice_line t3 ON t2.invoice_id = t3.invoice_id 
WHERE track_id IN ( 
                SELECT track_id FROM track 
                JOIN genre  ON track.genre_id= genre.genre_id
                WHERE genre.name ='Rock' );

-- Q7: Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands.
SELECT t1.artist_id,t1.name,COUNT(t1.artist_id) AS total_track FROM artist t1
JOIN album t2 ON t1.artist_id = t2.artist_id
JOIN track t3 ON t2.album_id = t3.album_id 
JOIN genre t4 ON t3.genre_id = t4.genre_id
WHERE t4.name='Rock'
GROUP BY t1.artist_id,t1.name
ORDER BY total_track DESC LIMIT 10;


-- Q8: Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.
SELECT name,milliseconds FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;

/* Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

WITH best_selling_artist AS (
    SELECT t1.artist_id,t1.name,SUM(t4.unit_price*t4.quantity) AS total_sales FROM artist t1
    JOIN album t2 ON t1.artist_id = t2.artist_id
    JOIN track t3 ON t2.album_id = t3.album_id
    JOIN invoice_line t4 ON t3.track_id = t4.track_id
    GROUP BY t1.artist_id,t1.name
    ORDER BY total_sales DESC LIMIT 1)

SELECT t5.customer_id,t5.first_name,t5.last_name,bsa.name,SUM(t7.unit_price*t7.quantity) FROM customer t5
JOIN invoice t6 ON t5.customer_id = t6.customer_id
JOIN invoice_line t7 ON t6.invoice_id = t7.invoice_id
JOIN track t8 ON t7.track_id = t7.track_id
JOIN album t9 ON t9.album_id = t8.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = t9.artist_id
GROUP BY t5.customer_id,t5.first_name,t5.last_name,bsa.name
ORDER BY SUM(t7.unit_price*t7.quantity) DESC;


/* Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

WITH popular_genre AS(
SELECT t5.name,t3.country,COUNT(t1.quantity) AS purchase ,
ROW_NUMBER() OVER(PARTITION BY t3.country ORDER BY COUNT(t1.quantity) DESC) AS row_no
FROM invoice_line t1
JOIN invoice t2 ON t2.invoice_id = t1.invoice_id
JOIN customer t3 ON t2.customer_id = t3.customer_id
JOIN track t4 ON t4.track_id = t1.track_id 
JOIN genre t5 ON t5.genre_id = t4.genre_id
GROUP BY t5.name,t3.country,t5.genre_id
ORDER BY t3.country ASC,COUNT(t1.quantity) DESC
)
SELECT * FROM popular_genre WHERE row_no <=1 ;

/*  Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH customer_with_country AS (SELECT t2.customer_id,t2.first_name,t2.last_name,t1.billing_country, SUM(total) AS total_spending ,
ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC ) AS row_num
FROM invoice t1
JOIN customer t2 ON t1.customer_id=t2.customer_id
GROUP BY t2.customer_id,t2.first_name,t2.last_name,t1.billing_country
ORDER BY t1.billing_country ASC, total_spending DESC)
SELECT * FROM customer_with_country WHERE row_num <=1;

-- Q12. Who are the top 5 most popular artists?
SELECT t4.name,COUNT(t1.quantity) AS purchase FROM invoice_line t1
JOIN track t2 ON t2.track_id = t1.track_id
JOIN album t3 ON t3.album_id = t2.album_id
JOIN artist t4 ON t4.artist_id = t3.artist_id
GROUP BY t4.artist_id,t4.name
ORDER BY purchase DESC LIMIT 5;

-- Q13. Which is the most popular song(track name)?
SELECT COUNT(quantity) AS purchase , t2.name AS song_name FROM invoice_line t1
JOIN track t2 ON t1.track_id = t2.track_id
GROUP BY t2.track_id,t2.name
ORDER BY purchase DESC ;

-- Q15. What are the most popular countries for music purchases?
SELECT COUNT(t1.quantity) AS purchase,t3.country FROM invoice_line t1
JOIN invoice t2 ON t1.invoice_id = t2.invoice_id
JOIN customer t3 ON t3.customer_id = t2.customer_id
GROUP BY country
ORDER BY purchase DESC;