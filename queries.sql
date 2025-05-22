--Cчитаем общее количество покупателей
select
	COUNT(customer_id) as customers_count
from customers c;

/*Первый отчет о десятке лучших продавцов с максимальной выручкой за всё время.
Данные о продавце, суммарной выручке с проданных товаров и количестве проведенных сделок.
Отсортировка по убыванию выручки.*/ 
select
	CONCAT(e.first_name, ' ', e.last_name, null) as seller,
	COUNT(s.sales_id) as operations,
	FLOOR(SUM(s.quantity * p.price)) as income
from employees e join sales s on
	e.employee_id = s.sales_person_id
join products p on
	s.product_id = p.product_id
group by
	seller
order by income desc limit 10;

/*Второй отчет содержит информацию о продавцах, 
 чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам. 
 Сортировка по выручке по возрастанию.*/ 
select
	CONCAT(e.first_name, ' ', e.last_name, null) as seller,
	FLOOR(AVG(s.quantity * p.price)) as average_income
from
	employees e join sales s on
	e.employee_id = s.sales_person_id
join products p on
	s.product_id = p.product_id
group by seller
--С помощью having ограничим только те записи, которые меньше общего среднего
having	AVG(s.quantity * p.price) < (
	select
		AVG(s.quantity * p.price)
	from sales s
	join products p on
		s.product_id = p.product_id
)
order by average_income;

/*Третий отчет содержит информацию о продавцах, 
 чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам. 
 Сортировка по порядковому номеру дня недели и seller.*/ 
--Создадим таблицу для сортировки по порядковому номеру дня недели
with tab as (
select
	CONCAT(e.first_name, ' ', e.last_name, null) as seller,
	extract(ISODOW from s.sale_date) as num_day,
	TO_CHAR(sale_date, 'day') as day_of_week,
	FLOOR(SUM(s.quantity * p.price)) as income
from
	employees e join sales s on
	e.employee_id = s.sales_person_id
join products p on
	s.product_id = p.product_id
group by seller, num_day, day_of_week
order by seller, num_day)
--Выведем необходимые данные
select
	seller,
	day_of_week,
	income
from tab;