--1. вывести количество фильмов в каждой категории, отсортировать по убыванию.
select t2.name, count(*)
from  film_category t1
join category t2 on t1.category_id = t2.category_id 
group by t1.category_id,t2.name
order by 2 desc
--2. вывести 10 актеров, чьи фильмы большего всего арендовали, отсортировать по убыванию.


select concat(a.first_name, ' ' ,a.last_name),count(*) from actor a 
join film_actor fa on a.actor_id = fa.actor_id 
join inventory i on fa.film_id = i.film_id 
join rental r on i.inventory_id = r.rental_id
group by a.actor_id 
order by 2 desc
limit 10

--3. вывести категорию фильмов, на которую потратили больше всего денег.
select c."name" from category c 
join film_category fc ON c.category_id = fc.category_id 
join inventory i on fc.film_id = i.film_id 
join rental r on i.inventory_id = r.inventory_id 
join payment p on r.rental_id = p.rental_id 
group by c."name" 
limit 1

--4. вывести названия фильмов, которых нет в inventory. Написать запрос без использования оператора IN.

select f.title from film f 
left join inventory i on f.film_id =i.film_id 
where i.inventory_id is null
group by f.film_id 

--5. вывести топ 3 актеров, которые больше всего появлялись в фильмах в категории “Children”. Если у нескольких актеров одинаковое кол-во фильмов, вывести всех.
select full_name
from(
	select concat(a.first_name,' ',a.last_name) as full_name, count(*) as cnt from actor a
	join film_actor fa on a.actor_id =fa.actor_id 
	join film_category fc on fa.film_id = fc.film_id 
	join category c on fc.category_id = c.category_id and c."name" ='Children'
	group by a.actor_id 
	order by cnt desc)tb
where tb.cnt>= 
	(select * 
	from(
		select count(*) from actor a
		join film_actor fa on a.actor_id =fa.actor_id 
		join film_category fc on fa.film_id = fc.film_id 
		join category c on fc.category_id = c.category_id and c."name" ='Children'
		group by a.actor_id 
		order by 1 desc
		limit 3)tb
	order by 1 asc
	limit 1)

--6. вывести города с количеством активных и неактивных клиентов (активный — customer.active = 1). Отсортировать по количеству неактивных клиентов по убыванию.
select c.city, COALESCE(sum(c2.active),0) as Active,coalesce(count(c2.active)-sum(c2.active),0) as Not_active from city c 
left join address a on c.city_id =a.city_id 
left join customer c2 on a.address_id =c2.address_id
group by c.city
order by 3 desc
--7. вывести категорию фильмов, у которой самое большое кол-во часов суммарной аренды в городах (customer.address_id в этом city),
-- и которые начинаются на букву “a”. То же самое сделать для городов в которых есть символ “-”. Написать все в одном запросе.

(select  c."name" ,
		sum(r.return_date-r.rental_date) as starts_from_a,
		NULL as contains_dash
from category c 
join film_category fc on c.category_id =fc.category_id 
join inventory i on fc.film_id = i.film_id 
join rental r on i.inventory_id = r.inventory_id 
join customer c3 on r.customer_id = c3.customer_id 
join address a on c3.address_id =a.address_id 
join city c2 on a.city_id = c2.city_id and c2.city ilike 'a%'
group by c."name"
order by starts_from_a desc
limit 1)
union
(select  c."name" ,	
		NULL as starts_from_a,
		sum(r.return_date-r.rental_date) as contains_dash   
from category c 
join film_category fc on c.category_id =fc.category_id 
join inventory i on fc.film_id = i.film_id 
join rental r on i.inventory_id = r.inventory_id 
join customer c3 on r.customer_id = c3.customer_id 
join address a on c3.address_id =a.address_id 
join city c2 on a.city_id = c2.city_id and c2.city like '%-%'
group by c."name"
order by contains_dash desc
limit 1)

