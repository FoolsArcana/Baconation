use sakila;

#1 a
select first_name, last_name from actor;

#1 b
select Upper(concat(first_name,' ',last_name)) as 'Actor Name' from actor;

#2 a
select * from actor where first_name like 'Joe';

#2 b
select * from actor where last_name like '%GEN%';

#2 c
select * from actor where last_name like '%LI%' order by last_name desc, first_name desc;

#2 d
select * from country where country in ('Afghanistan','Bangladesh', 'China');

#3a
alter table actor 
	add column
		middle_name varchar(50)
        after first_name;
        
#3b
alter table actor
	modify 
		middle_name blob;
#3c
alter table actor
	drop middle_name;

#4a
select last_name, count(last_name) from actor group by last_name;

#4b
select * from (select last_name, count(last_name) as counter from actor group by last_name) a where a.counter >1;

#4c
#select * from actor where first_name = 'GROUCHO' and last_name = 'WILLIAMS'
update actor
	set first_name = 'GROUCHO'
    where first_name = 'GROUCHO' and last_name = 'WILLIAMS';

#4d
update actor
	set first_name = case 
		when first_name = 'GROUCHO' then 'MUCHO GROUCHO'
		when first_name = 'HARPO' then 'GROUCHO'
	end
    where first_name in ('GROUCHO','HARPO') and last_name = 'WILLIAMS';
    
#5a
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

#6a
select staff.first_name, staff.last_name, address.address from staff left join address on staff.address_id = address.address_id;

#6b
select staff.first_name, staff.last_name, sum(payment.amount) from staff left join payment on staff.staff_id = payment.staff_id where payment.payment_date like '%2005-05%' group by staff.staff_id;

#6c
select film.title, count(film_actor.actor_id) from film inner join film_actor on film.film_id = film_actor.film_id group by film.film_id;

#6d
select count(film.film_id) from film inner join inventory on film.film_id = inventory.film_id where film.title = 'Hunchback Impossible';

#6e
select customer.first_name, customer.last_name, sum(payment.amount) from customer inner join payment on customer.customer_id = payment.customer_id group by customer.customer_id order by customer.last_name asc;

#7a
select film.title from film where film.title like 'K%' or film.title like 'Q%' and film.language_id in (select language_id from language where name ='English');

#7b
select actor.first_name, actor.last_name from actor where actor.actor_id in
	(select actor_id from film_actor where film_id in
		(select film_id from film where title = 'Alone Trip'
        )
	);

#7c
select customer.email, customer.first_name, customer.last_name from customer inner join
	(select address_id from address where city_id in
		(select city_id from city where country_id in
			(select country_id from country where country = 'Canada'
            )
		)
	) addr on customer.address_id = addr.address_id;
    
#7d
select film.title from film inner join
	(select film_id from film_category where category_id in
		(select category_id from category where name = 'Family'
        )
	) cats on film.film_id = cats.film_id;
    
#7e
select film.title from film inner join
	(select film_id from inventory where inventory_id in 
		(select inventory_id from rental)
	) rents on film.film_id = rents.film_id group by film.title order by count(film.title) desc;
    
#7f
select sum(payment.amount) from payment 
	inner join rental on payment.rental_id = rental.rental_id
    inner join inventory on rental.inventory_id = inventory.inventory_id
    group by inventory.store_id;
    
#7g
select store.store_id, city.city, country.country from store
	inner join address on store.address_id = address.address_id
    inner join city on address.city_id = city.city_id
    inner join country on city.country_id = country.country_id;
    
#7h
select category.name from category
	inner join film_category on category.category_id = film_category.category_id
    inner join inventory on film_category.film_id = inventory.film_id
    inner join rental on inventory.inventory_id = rental.inventory_id
    inner join payment on rental.rental_id = payment.rental_id
    group by inventory.film_id order by sum(payment.amount) desc limit 5;
    
#8a
create view catRev as
select category.name from category
	inner join film_category on category.category_id = film_category.category_id
    inner join inventory on film_category.film_id = inventory.film_id
    inner join rental on inventory.inventory_id = rental.inventory_id
    inner join payment on rental.rental_id = payment.rental_id
    group by inventory.film_id order by sum(payment.amount) desc limit 5;
    
#8b
select * from catRev;

#8c
drop view catRev;