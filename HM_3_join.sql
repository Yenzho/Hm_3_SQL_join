--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.
select concat_ws(' ', first_name, last_name) as "Customer name", address, city, country
from customer c 
join address a on c.address_id = a.address_id 
join city c2 on a.city_id = c2.city_id 
join country c3 on c2.country_id = c3.country_id 




--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
select s.store_id, count(customer_id) 
from store s 
join customer c on c.store_id = s.store_id 
group by s.store_id 



--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.

select s.store_id, count(customer_id) 
from store s 
join customer c on c.store_id = s.store_id 
group by s.store_id
having count(customer_id) > 300 


-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.
select s.store_id, count(customer_id), concat_ws(' ', s2.first_name, s2.last_name) as "Имя сотрудника", c2.city  
from store s 
join customer c on c.store_id = s.store_id
join staff s2 on s2.store_id  = s.store_id
join address a on  s2.address_id = a.address_id 
join city c2 on c2.city_id = a.city_id  
group by s.store_id, staff_id, c2.city_id 
having count(customer_id) > 300 


--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов
select concat_ws(' ', c.first_name, c.last_name) as "Имя и фамилия покупателя", count(rental_id) as "Количество фильмов"
from customer c 
join rental r on r.customer_id = c.customer_id
group by c.customer_id 
order by count(rental_id) desc 
limit 5



--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма

select count(r.rental_id) as "Количество фильмов", round(sum(p.amount)) as "Общая стоимость платежей", 
	concat_ws(' ', c.first_name, c.last_name) as "Имя и фамилия покупателя", 
	max(p.amount) as "Максимальная стоимость платежа", min(p.amount) as "Минимальная стоимость платежа" 
from customer c  
join rental r on r.customer_id = c.customer_id
join payment p on r.rental_id  = p.rental_id 
group by c.customer_id


--ЗАДАНИЕ №5
--Используя данные из таблицы городов, составьте все возможные пары городов так, чтобы 
--в результате не было пар с одинаковыми названиями городов. Решение должно быть через Декартово произведение.

select c1.city as "Город1", c2.city as "Город2"
from city c1
cross join city c2
where c1.city_id < c2.city_id 
 

--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date) и 
--дате возврата (поле return_date), вычислите для каждого покупателя среднее количество 
--дней, за которые он возвращает фильмы. В результате должны быть дробные значения, а не интервал.
 
select customer_id as "ID покупателя", 
	round(avg(return_date::date - rental_date::date), 2) as "Среднее количество дней на возврат"
from rental r
group by customer_id 




--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.

select f.title as "Название фильма", f.rating as "Рейтинг",
	f.release_year as "Год выпуска", l."name" as "Язык", c."name" as "Жанр", 
	count(r.rental_id) as "Количество аренд", sum(p.amount) as "Общая стоимость аренды"  
from film f
join inventory i ON f.film_id = i.film_id
join rental r on i.inventory_id = r.inventory_id
join payment p on p.rental_id = r.rental_id 
join "language" l on l.language_id = f.language_id 
join film_category fc on f.film_id = fc.film_id 
join category c on fc.category_id = c.category_id 
group by f.film_id, l.language_id, c.category_id  



--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью него фильмы, которые отсутствуют на dvd дисках.

select f.title as "Название фильма", f.rating as "Рейтинг",
	f.release_year as "Год выпуска", l."name" as "Язык", c."name" as "Жанр", 
	count(r.rental_id) as "Количество аренд", sum(p.amount) as "Общая стоимость аренды"  
from film f
left join inventory i ON f.film_id = i.film_id
left join rental r on i.inventory_id = r.inventory_id
left join payment p on p.rental_id = r.rental_id 
left join "language" l on l.language_id = f.language_id 
left join film_category fc on f.film_id = fc.film_id 
left join category c on fc.category_id = c.category_id 
group by f.film_id, l.language_id, c.category_id
having count(i.film_id) = 0


--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".

select s.staff_id, concat_ws(' ', s.first_name, s.last_name) as "Имя и фамилия продавца", count(payment_id) as "Количество продаж",
	case
		when count(payment_id) > 7300 then 'Да'
		else 'Нет'
	end as "Премия"
from staff s
join payment p on s.staff_id = p.staff_id 
group by s.staff_id 








