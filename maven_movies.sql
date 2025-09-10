-- DATA ANALYSIS PROJECT FOR RENTAL MOVIES BUSINESS
-- THE STEPS INVOLVED ARE EDA, UNDERSTANDING THR SCHEMA AND ANSWERING THE AD-HOC QUESTIONS
-- BUSINESS QUESTIONS LIKE EXPANDING MOVIES COLLECTION AND FETCHING EMAIL IDS FOR MARKETING ARE INCLUDED
-- HELPING COMPANY KEEP A TRACK OF INVENTORY AND HELP MANAGE IT.

use mavenmovies;

-- EXPLORATORY DATA ANALYSIS --

-- UNDERSTANDING THE SCHEMA --

SELECT * FROM RENTAL;

SELECT * FROM INVENTORY;

SELECT * FROM CUSTOMER;
SELECT * FROM FILM;
select * from category;

-- You need to provide customer firstname, lastname and email id to the marketing team --

select first_name, last_name,email from customer;

-- How many movies are with rental rate of $0.99? --

select count(*) as cheapest_rentals
from film
where rental_rate = 0.99;

-- We want to see rental rate and how many movies are in each rental category --
select rental_rate,count(*) AS NO_OF_MOVIES
from film 
group by 1;

-- Which rating has the most films? --
select rating,count(*) as rating_category
from film 
group by 1
order by rating_category desc;

-- Which rating is most prevalant in each store? --
select a.store_id,b.rating, count(*) 
from inventory a
left join film b
on a.film_id=b.film_id
group by 1,2
order by 1,2;

-- List of films by Film Name, Category, Language --
select f.title,c.name,l.name
from film f
left join film_category fc
on f.film_id=fc.film_id left join category c
on fc.category_id=c.category_id left join language l
on f.language_id=l.language_id;


-- How many times each movie has been rented out?
select f.title, count(b.film_id) NO_OF_RENTAL
from rental a
left join inventory b
on a.inventory_id=b.inventory_id left join film f
on b.film_id= f.film_id
group by 1;

-- REVENUE PER FILM (TOP 10 GROSSERS)

select f.title, count(b.film_id), sum(amount) total_revenue
from rental a
left join payment p
on a.rental_id=p.rental_id
left join inventory b
on a.inventory_id=b.inventory_id left join film f
on b.film_id= f.film_id
group by 1
order by 3 desc
limit 10;

-- Most Spending Customer so that we can send him/her rewards or debate points

select r.customer_id , sum(c.amount) as countc,r.first_name
from customer r
right join payment c
on r.customer_id=c.customer_id
group by 1
order by countc desc
limit 1;

-- Which Store has historically brought the most revenue?
SELECT S.STORE_ID,SUM(P.AMOUNT) AS STORE_REVENUE
FROM PAYMENT AS P LEFT JOIN STAFF AS S
	ON P.STAFF_ID=S.STAFF_ID
GROUP BY S.STORE_ID
ORDER BY STORE_REVENUE DESC;

-- How many rentals we have for each month
select extract(year from rental_date) as year,extract(month from rental_date) as month, count(r.rental_id) as nos
from rental r
group by 1,2;

-- Reward users who have rented at least 30 times (with details of customers)

select customer_id, first_name,last_name,email
from customer
where customer_id in (select c.customer_id from(
select r.customer_id, count(rental_id) as no_of_tansaction
from rental r
left join customer c 	
on r.customer_id=c.customer_id
group by 1
having no_of_tansaction>30) c) ;

-- Could you pull all payments from our first 100 customers (based on customer ID)
select *
from payment
order by customer_id
limit 100;

-- Now I’d love to see just payments over $5 for those same customers, since January 1, 2006

SELECT CUSTOMER_ID, RENTAL_ID,AMOUNT, PAYMENT_DATE
FROM PAYMENT
WHERE CUSTOMER_ID < 101 AND AMOUNT > 5 AND PAYMENT_DATE > '2006-01-01';

-- Now, could you please write a query to pull all payments from those specific customers, along --
-- with payments over $5, from any customer? --
SELECT CUSTOMER_ID, RENTAL_ID,AMOUNT, PAYMENT_DATE
FROM PAYMENT
WHERE AMOUNT > 5 AND CUSTOMER_ID IN (42,53,60,75);

-- We need to understand the special features in our films. Could you pull a list of films which
-- include a Behind the Scenes special feature?
SELECT TITLE,SPECIAL_FEATURES
FROM FILM
WHERE SPECIAL_FEATURES LIKE '%Behind the Scenes%';

-- unique movie ratings and number of movies

SELECT RATING,COUNT(FILM_ID) AS NO_OF_FILMS
FROM FILM
GROUP BY RATING;

-- Could you please pull a count of titles sliced by rental duration?

select rental_duration, count(title) as count_id
from film 
group by 1;

-- Could you please pull a count of titles sliced by rental duration? --

SELECT RATING,RENTAL_DURATION,COUNT(FILM_ID) AS COUNT_ID
FROM FILM
GROUP BY RATING,RENTAL_DURATION;

-- RATING, COUNT_MOVIES,LENGTH OF MOVIES AND COMPARE WITH RENTAL DURATION --
SELECT RATING,
     COUNT(FILM_ID) AS COUNT_OF_FILMS,
	 MIN(LENGTH) AS SHORTEST_FILM,
	 MAX(LENGTH) AS LONGEST_FILM,
     AVG(LENGTH) AS AVERAGE_FILM_LENGTH,
     AVG(RENTAL_DURATION) AS AVERAGE_RENTAL_DURATION
FROM FILM
GROUP BY RATING
ORDER BY AVERAGE_FILM_LENGTH;

-- I’m wondering if we charge more for a rental when the replacement cost is higher. --
-- Can you help me pull a count of films, along with the average, min, and max rental rate, --
-- grouped by replacement cost? --

SELECT REPLACEMENT_COST,
     COUNT(FILM_ID) AS COUNT_OF_FILMS,
	 MIN(RENTAL_RATE) AS CHEAPEST_RENTAL,
	 MAX(RENTAL_RATE) AS EXPENSIVE_RENTAL,
     AVG(RENTAL_RATE) AS AVERAGE_RENTAL
FROM FILM
GROUP BY REPLACEMENT_COST
ORDER BY REPLACEMENT_COST;
 
-- “I’d like to talk to customers that have not rented much from us to understand if there is something
-- we could be doing better. Could you pull a list of customer_ids with less than 15 rentals all-time?”
SELECT CUSTOMER_ID,COUNT(*) AS TOTAL_RENTALS
FROM RENTAL
GROUP BY CUSTOMER_ID
HAVING TOTAL_RENTALS < 15;

-- “I’d like to see if our longest films also tend to be our most expensive rentals.
-- Could you pull me a list of all film titles along with their lengths and rental rates, and sort them
-- from longest to shortest?”

SELECT TITLE,LENGTH,RENTAL_RATE
FROM FILM
ORDER BY LENGTH DESC
LIMIT 20;

SELECT DISTINCT LENGTH,
   CASE
       WHEN LENGTH < 60 THEN 'UNDER 1 HR'
       WHEN LENGTH BETWEEN 60 AND 90 THEN '1 TO 1.5 HRS'
       WHEN LENGTH > 90 THEN 'OVER 1.5 HRS'
       ELSE 'ERROR'
   END AS LENGTH_BUCKET
FROM FILM;   

-- CATEGORIZING MOVIES TO RECOMMEND VARIOUS AGE GROUPS AND DEMOGRAPHIC --
SELECT DISTINCT TITLE,
   CASE
       WHEN RENTAL_DURATION <= 4 THEN 'RENTAL TOO SHORT'
       WHEN RENTAL_RATE >= 3.99 THEN 'TOO EXPENSIVE'
       WHEN RATING IN ('NC-17','R') THEN 'TOO ADULT'
	   WHEN LENGTH NOT BETWEEN 60 AND 90 THEN 'TOO SHORT OR TOO LONG'
       WHEN DESCRIPTION LIKE '%SHARK%' THEN 'N0_NO_HAS_SHARK'
       ELSE 'GREAT_RECOMMENDATION_FOR_CHILDREN'
   END AS FIT_FOR_RECOMMENDATION
FROM FILM; 

-- “I’d like to know which store each customer goes to, and whether or
-- not they are active. Could you pull a list of first and last names of all customers, and
-- label them as either ‘store 1 active’, ‘store 1 inactive’, ‘store 2 active’, or ‘store 2 inactive’?”
SELECT FIRST_NAME,LAST_NAME,
    CASE
		WHEN STORE_ID = 1 AND ACTIVE = 1 THEN 'STORE 1 ACTIVE'
        WHEN STORE_ID = 1 AND ACTIVE = 0 THEN 'STORE 1 INACTIVE'
        WHEN STORE_ID = 2 AND ACTIVE = 1 THEN 'STORE 2 ACTIVE'
        WHEN STORE_ID = 2 AND ACTIVE = 0 THEN 'STORE 2 INACTIVE'
        ELSE 'ERROR'
    END AS STORE_AND_STATUS   
FROM CUSTOMER;

SELECT STORE_ID,COUNT(ACTIVITY.STORE_AND_STATUS)
FROM(SELECT FIRST_NAME,LAST_NAME,STORE_ID,
    CASE
		WHEN STORE_ID = 1 AND ACTIVE = 1 THEN 'STORE 1 ACTIVE'
        WHEN STORE_ID = 1 AND ACTIVE = 0 THEN 'STORE 1 INACTIVE'
        WHEN STORE_ID = 2 AND ACTIVE = 1 THEN 'STORE 2 ACTIVE'
        WHEN STORE_ID = 2 AND ACTIVE = 0 THEN 'STORE 2 INACTIVE'
        ELSE 'ERROR'
    END AS STORE_AND_STATUS   
FROM CUSTOMER) AS ACTIVITY
GROUP BY ACTIVITY.STORE_ID,ACTIVITY.STORE_AND_STATUS;

-- “Can you pull for me a list of each film we have in inventory?
-- I would like to see the film’s title, description, and the store_id value
-- associated with each item, and its inventory_id. Thanks!”
SELECT DISTINCT INVENTORY.INVENTORY_ID,
				INVENTORY.STORE_ID,
                FILM.TITLE,
                FILM.DESCRIPTION
FROM FILM INNER JOIN INVENTORY ON FILM.FILM_ID = INVENTORY.FILM_ID;

-- FIRST_NAME ,LAST_NAME AND NO_OF_MOVIES
SELECT
	ACTOR.ACTOR_ID,
    ACTOR.FIRST_NAME,
    ACTOR.LAST_NAME,
    COUNT(FILM_ACTOR.FILM_ID) AS NUMBER_OF_FILMS
FROM ACTOR 
	LEFT JOIN FILM_ACTOR 
		ON ACTOR.ACTOR_ID =FILM_ACTOR.ACTOR_ID
GROUP BY ACTOR.ACTOR_ID;

-- “One of our investors is interested in the films we carry and how many actors are listed for each
-- film title. Can you pull a list of all titles, and figure out how many actors are
-- associated with each title?” --
SELECT*
FROM FILM; 
SELECT*
FROM ACTOR; 

SELECT FILM.TITLE,
	   COUNT(FILM_ACTOR.ACTOR_ID) AS NUMBER_OF_ACTOR
FROM FILM 
	LEFT JOIN FILM_ACTOR 
		ON FILM.FILM_ID = FILM_ACTOR.FILM_ID
GROUP BY FILM.TITLE;

-- “Customers often ask which films their favorite actors appear in. It would be great to have a list of --
-- all actors, with each title that they appear in. Could you please pull that for me?” --
SELECT ACTOR.FIRST_NAME,
	   ACTOR.LAST_NAME,
       FILM.TITLE
FROM ACTOR
	INNER JOIN FILM_ACTOR
		ON ACTOR.ACTOR_ID = FILM_ACTOR.ACTOR_ID
				INNER JOIN FILM
		ON FILM_ACTOR.FILM_ID = FILM.FILM_ID
ORDER BY ACTOR.LAST_NAME,
		 ACTOR.FIRST_NAME;
    
-- “The Manager from Store 2 is working on expanding our film collection there.
-- Could you pull a list of distinct titles and their descriptions, currently available in inventory at store 2?”
SELECT DISTINCT FILM.TITLE,
                FILM.DESCRIPTION
FROM FILM
	INNER JOIN INVENTORY
		ON FILM.FILM_ID = INVENTORY.FILM_ID
WHERE STORE_ID = 2;
         
SELECT DISTINCT FILM.TITLE,
                FILM.DESCRIPTION
FROM FILM
	INNER JOIN INVENTORY
		ON FILM.FILM_ID = INVENTORY.FILM_ID
        AND INVENTORY.STORE_ID = 2;  


-- “Can you pull for me a list of each film we have in inventory?
-- I would like to see the film’s title, description, and the store_id value
-- associated with each item, and its inventory_id. Thanks!”

SELECT F.TITLE,F.DESCRIPTION,I.STORE_ID,I.INVENTORY_ID,F.FILM_ID
FROM FILM F
JOIN INVENTORY AS I
ON F.FILM_ID=I.FILM_ID;


-- Actor first_name, last_name and number of movies
SELECT A.ACTOR_ID,A.FIRST_NAME,A.LAST_NAME,COUNT(FA.FILM_ID) as NO_OF_MOVIES
FROM ACTOR AS A
LEFT JOIN FILM_ACTOR AS FA
ON A.ACTOR_ID=FA.ACTOR_ID
group by 1
order by COUNT(FA.FILM_ID) DESC;

-- “One of our investors is interested in the films we carry and how many actors are listed for each
-- film title. Can you pull a list of all titles, and figure out how many actors are
-- associated with each title?”

SELECT F.TITLE, COUNT(FA.ACTOR_ID) AS NO_OF_ACTOR
FROM FILM F
LEFT JOIN FILM_ACTOR FA
ON FA.FILM_ID=F.FILM_ID 
group by 1
order by COUNT(FA.ACTOR_ID) DESC;


-- “We will be hosting a meeting with all of our staff and advisors soon. Could you pull one list of all staff
-- and advisor names, and include a column noting whether they are a staff member or advisor? Thanks!”

SELECT FIRST_NAME, LAST_NAME,"STAFF" AS DESIGNATION
FROM STAFF
UNION
SELECT FIRST_NAME, LAST_NAME,"ADVISOR" AS DESIGNATION
FROM ADVISOR;