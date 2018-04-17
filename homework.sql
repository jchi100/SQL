-- 1a. Display the first and last names of all actors from the table actor.--

use sakila;

SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. --
-- Name the column Actor Name. --

select concat(upper(first_name),' ' ,upper(last_name))  as 'Actor Name'
from actor;

-- 2a. Find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." --

select actor_id, first_name, last_name
from actor
where first_name = 'Joe';

-- 2c. Find all actors whose last names contain the letters LI --

select *
from actor
where last_name like '%L%' or last_name like '%I%';

-- 2d. Using IN, display the country_id and country columns of --
-- the following countries: Afghanistan, Bangladesh, and China:  --

select country_id, country
from country
where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. --

ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(45) AFTER first_name;

-- 3b. Change the data type of the middle_namecolumn to blobs. --

alter table actor modify column middle_name BLOB;

-- 3c. Delete the middle_name column. --

ALTER TABLE actor DROP COLUMN middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name.--

select last_name, count(last_name)
from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, --
-- but only for names that are shared by at least two actors --

select last_name, count(last_name) as number_of_actors
from actor
group by last_name
having count(last_name)>=2;

-- 4c.The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, --
-- the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record. --

update actor
set first_name = 'HARPO',
    last_name = 'WILLIAMS'
where first_name='GROUCHO' and last_name ='WILLIAMS' ;

-- It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. --
-- Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO--

select * 
from actor
where first_name = 'HARPO' or first_name = 'GROUCHO';

update actor
set first_name = if(first_name = 'HARPO', 'GROUCHO',  'MUCHO GROUCHO')
where first_name in('GROUCHO','HARPO') ;

select * 
from actor
where first_name = 'HARPO';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

show create table address;

-- 6a. Display the first and last names, as well as the address, of each staff member. Use the tables staff and address --

select s.first_name, s.last_name, a.address
from staff as s
join address as a
on s.address_id = a.address_id;

-- 6b. Display the total amount rung up by each staff member in August of 2005. Use tables staff and payment. --

SELECT s.first_name, s.last_name, sum(p. amount) as 'total amount'
FROM payment as p
join staff as s
on p.staff_id = s.staff_id
where year(p.payment_date) = 2005 and month(p.payment_date)=8
group by p.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film--

SELECT f.title, count(a.actor_id) as 'actors'
FROM film_actor as a
inner join film as f
on a.film_id = f.film_id
group by a.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system? --
SELECT f.title, count(inventory_id) as 'number_of_copies'
FROM film as f
join inventory as i
on f.film_id = i.film_id
where f.title = 'Hunchback Impossible';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. --
-- List the customers alphabetically by last name --

SELECT c.first_name, c.last_name, sum(p.amount) as 'total amount'
FROM customer as c
join payment as p
on c.customer_id = p.customer_id
group by c.customer_id
order by c.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, --
-- films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English. --

select title
from film
where (title like 'K%' or title like 'Q%' ) and language_id =
(  select language_id
   from language 
   where name = 'English'
);

-- 7b. Display all actors who appear in the film Alone Trip

select first_name, last_name
from actor
where actor_id in
( select actor_id
  from film_actor
  where film_id =
  ( select film_id
	from film
    where title = 'Alone Trip'
    )
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and --
--  email addresses of all Canadian customers. Use joins to retrieve this information --

select customer.first_name, customer.last_name, customer.email
from customer
	INNER JOIN address as a ON customer.address_id = a.address_id
    INNER JOIN city ON a.city_id  = city.city_id
    inner join country on city.country_id = country.country_id
     where country.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films. --

select film.title
from film
	join film_category as f on film.film_id = f.film_id
	join category as c on f.category_id = c.category_id
	where c.name = 'Family' ;
    
-- 7e. Display the most frequently rented movies in descending order--
select title, rental_duration
from film
order by rental_duration desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in. --

SELECT s.store_id, sum(p.amount) as 'total amount $'
from payment as p
join store as s
on s.manager_staff_id = p.staff_id
group by s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country--

select store.store_id, city.city, country.country
from store
 join address as a on store.address_id = a.address_id
 join city  on a.city_id = city.city_id
 join country  on city.country_id = country.country_id;
 
-- 7h. List the top five genres in gross revenue in descending order. --
-- following tables: category, film_category, inventory, payment, and rental --

select category.name as 'Genre',sum(p.amount) as 'Gross Revenue'
from payment as p
	left join rental on rental.rental_id = p.rental_id
    left join inventory on rental.inventory_id = inventory.inventory_id
    left join film_category on inventory.film_id = film_category.film_id
    left join category on film_category.category_id = category.category_id
group by category.name
order by sum(p.amount) desc limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. --
-- Use the solution from the problem above to create a view. --

create view top_5_genres as

select category.name as 'Genre',sum(p.amount) as 'Gross Revenue'
from payment as p
	left join rental on rental.rental_id = p.rental_id
    left join inventory on rental.inventory_id = inventory.inventory_id
    left join film_category on inventory.film_id = film_category.film_id
    left join category on film_category.category_id = category.category_id
group by category.name
order by sum(p.amount) desc limit 5;



-- 8b. How would you display the view that you created in 8a? --

select * 
from top_5_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it --

drop view top_5_genres;






