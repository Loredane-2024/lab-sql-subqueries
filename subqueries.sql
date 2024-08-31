-- Challenge
-- Write SQL queries to perform the following tasks using the Sakila database:
-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
SELECT COUNT(film_id) AS film_count
FROM inventory 
WHERE film_id = (
	SELECT film_id
    FROM film AS f
    WHERE f.title = 'Hunchback Impossible'
);

-- 2. List all films whose length is longer than the average length of all the films in the Sakila database.
SELECT DISTINCT title, length
FROM film
WHERE length > (SELECT ROUND(AVG(length),2) from film);

-- 3. Use a subquery to display all actors who appear in the film "Alone Trip".
SELECT 
    CONCAT(a.first_name, ' ', a.last_name) AS full_name
FROM actor AS a
WHERE a.actor_id IN (
	SELECT fa.actor_id
	FROM film_actor AS fa
	WHERE fa.film_id = (
		SELECT f.film_id
		FROM film AS f
        WHERE f.title = 'Alone Trip'
		)	
);
-- Bonus:
-- 4. Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.
SELECT title
FROM film AS f
WHERE f.film_id IN (
	SELECT fc.film_id
	FROM film_category AS fc
	WHERE fc.category_id = (
		SELECT c.category_id
		FROM category AS c
        WHERE c.name = 'family'
		)	
);

-- 5. Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys.
SELECT CONCAT(cu.first_name, ' ', cu.last_name) AS full_name, cu.email
FROM customer AS cu
JOIN address AS a ON cu.address_id = a.address_id
JOIN city AS ci ON a.city_id = ci.city_id
WHERE ci.country_id = (
	SELECT co.country_id
	FROM country AS co
    WHERE co.country = 'Canada'
);

-- 6. Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films. First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.
SELECT CONCAT(a.first_name, ' ', a.last_name) AS full_name_actor, f.title
FROM actor AS a
JOIN film_actor AS fa ON a.actor_id = fa.actor_id
JOIN film AS f ON fa.film_id = f.film_id
WHERE a.actor_id = (
	SELECT actor_id
	FROM film_actor 
    GROUP BY actor_id
    ORDER BY COUNT(film_id) DESC
    LIMIT 1
 );

-- 7. Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.
SELECT f.film_id, f.title
FROM rental AS r
JOIN inventory  AS i ON r.inventory_id = i.inventory_id
JOIN film AS f ON i.film_id = f.film_id
WHERE r.customer_id = (
    SELECT customer_id
    FROM payment
    GROUP BY customer_id
    ORDER BY SUM(amount) DESC
    LIMIT 1
);

-- 8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. You can use subqueries to accomplish this.
SELECT customer_id, total_amount_spent
FROM (
    SELECT customer_id, SUM(amount) AS total_amount_spent
    FROM payment
    GROUP BY customer_id
) AS customer_totals
WHERE total_amount_spent > (
    SELECT AVG(total_amount_spent)
    FROM (
        SELECT customer_id, SUM(amount) AS total_amount_spent
        FROM payment
        GROUP BY customer_id
    ) AS sub_totals
);