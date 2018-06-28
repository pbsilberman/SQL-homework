# Philip Silberman SQL Homework
# HW Assignment 8

USE sakila;

# 1a. Display the first and last names of all actors from the table actor.
SELECT first_name
	, last_name
FROM actor;


#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT(first_name,' ',last_name) AS 'Actor Name'
FROM actor;


#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id
	, first_name
    , last_name
FROM actor
WHERE first_name = 'Joe';


#2b. Find all actors whose last name contain the letters GEN:
SELECT *
FROM actor
WHERE last_name LIKE '%GEN%';


#2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT *
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;


#2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id
	, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');


#3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
ALTER TABLE actor ADD middle_name VARCHAR(45) AFTER first_name;


#3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
ALTER TABLE actor MODIFY middle_name BLOB;


#3c. Now delete the middle_name column.
ALTER TABLE actor DROP COLUMN middle_name;


#4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name
	, count(actor_id) AS 'Number of actors'
FROM actor
GROUP BY last_name;


#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name
	, count(actor_id) AS 'Number of actors'
FROM actor
GROUP BY last_name
HAVING count(actor_id) >= 2;


#4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO'
AND last_name = 'WILLIAMS';


#4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all!
#In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error.
#BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)
SELECT actor_id
FROM actor
WHERE first_name = 'HARPO'
AND last_name = 'WILLIAMS';

# actor_id = 172

UPDATE actor
SET first_name = CASE WHEN first_name = 'HARPO' THEN 'GROUCHO' ELSE 'MUCHO GROUCHO' END
WHERE actor_id = 172;


#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

# Find the query from this:
SHOW CREATE TABLE address;

# This actually creates the table:
CREATE TABLE `address` (
   `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
   `address` varchar(50) NOT NULL,
   `address2` varchar(50) DEFAULT NULL,
   `district` varchar(20) NOT NULL,
   `city_id` smallint(5) unsigned NOT NULL,
   `postal_code` varchar(10) DEFAULT NULL,
   `phone` varchar(20) NOT NULL,
   `location` geometry NOT NULL,
   `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
   PRIMARY KEY (`address_id`),
   KEY `idx_fk_city_id` (`city_id`),
   SPATIAL KEY `idx_location` (`location`),
   CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
 ) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;
 

#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT staff.first_name
	, staff.last_name
    , address.address
    , address.address2
    , address.district
    , address.postal_code
FROM staff
	INNER JOIN address
		ON address.address_id = staff.address_id;


#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT s.first_name
	, s.last_name
    , SUM(amount) AS 'Total amount rung up (dollars)'
FROM staff s
	INNER JOIN payment p
		ON p.staff_id = s.staff_id
WHERE p.payment_date BETWEEN '2005-08-01 00:00:00' AND '2005-08-31 23:59:59'
GROUP BY s.first_name, s.last_name;


#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT f.title
	, COUNT(fa.actor_id) AS 'Number of actors'
FROM film_actor fa
	INNER JOIN film f
		ON f.film_id = fa.film_id
GROUP BY f.title;


#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(inventory_id) AS 'Copies of Hunchback Impossible in the inventory'
FROM inventory
WHERE film_id = (
	SELECT film_id FROM film
	WHERE title = 'Hunchback Impossible'
);


#6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.first_name
	, c.last_name
    , SUM(p.amount) AS 'Total paid (dollars)'
FROM payment p
	JOIN customer c
		ON c.customer_id = p.customer_id
GROUP BY c.first_name, c.last_name
ORDER BY c.last_name;


#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity.
#Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title
FROM film
WHERE language_id IN (
	SELECT language_id
    FROM language
    WHERE name = 'English'
    )
AND (title LIKE 'K%' OR title LIKE 'Q%')
;


#7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name
	, last_name
FROM actor
WHERE actor_id IN (
	SELECT actor_id
    FROM film_actor
	WHERE film_id IN (
		SELECT film_id
        FROM film
        WHERE title = 'Alone Trip'
        )
	);


#7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT first_name
	, last_name
    , email
FROM customer c
	JOIN address a
		ON a.address_id = c.address_id
	JOIN city ci
		ON ci.city_id = a.city_id
	JOIN country co
		ON co.country_id = ci.country_id
WHERE co.country = 'Canada'
;


#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
SELECT f.title AS 'Family films'
FROM film f
	JOIN film_category fc
		ON fc.film_id = f.film_id
	JOIN category c
		ON c.category_id = fc.category_id
WHERE c.name = 'Family'
;


#7e. Display the most frequently rented movies in descending order.
SELECT f.title
	, COUNT(r.rental_id) AS 'Number of Rentals'
FROM rental r
	JOIN inventory i
		ON i.inventory_id = r.inventory_id
	JOIN film f
		ON f.film_id = i.inventory_id
GROUP BY f.title
ORDER BY COUNT(r.rental_id) DESC
;


#7f. Write a query to display how much business, in dollars, each store brought in.
SELECT st.store_id
	, ad.address	AS 'Store address'
	, SUM(p.amount) AS 'Total business (dollars)'
FROM payment p
	JOIN staff s
		ON s.staff_id = p.staff_id
	JOIN store st
		ON st.store_id = s.store_id
	JOIN address ad
		ON ad.address_id = st.address_id
GROUP BY st.store_id, ad.address
;


#7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id
	, c.city
    , co.country
FROM store s
	JOIN address a
		ON a.address_id = s.address_id
	JOIN city c
		ON c.city_id = a.city_id
	JOIN country co
		ON co.country_id = c.country_id
;


#7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name AS 'Genre'
	, SUM(p.amount) AS 'Gross Revenue'
FROM category c
	JOIN film_category fc
		ON fc.category_id = c.category_id
	JOIN inventory i
		ON i.film_id = fc.film_id
	JOIN rental r
		ON r.inventory_id = i.inventory_id
	JOIN payment p
		ON p.rental_id = r.rental_id
GROUP BY c.name
ORDER BY SUM(p.amount) DESC
LIMIT 5
;


#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue.
#Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE view `top_five_genres_by_revenue` AS (
	SELECT c.name AS 'Genre'
		, SUM(p.amount) AS 'Gross Revenue'
	FROM category c
		JOIN film_category fc
			ON fc.category_id = c.category_id
		JOIN inventory i
			ON i.film_id = fc.film_id
		JOIN rental r
			ON r.inventory_id = i.inventory_id
		JOIN payment p
			ON p.rental_id = r.rental_id
	GROUP BY c.name
	ORDER BY SUM(p.amount) DESC
	LIMIT 5
);


#8b. How would you display the view that you created in 8a?
SELECT *
FROM top_five_genres_by_revenue;


#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres_by_revenue;
