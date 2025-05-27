--4. Cчитаем общее количество покупателей
select COUNT(customer_id) as customers_count
from customers;

/*5.1. Первый отчет о десятке лучших продавцов с максимальной выручкой за всё время.
Данные о продавце, суммарной выручке с проданных товаров и количестве проведенных сделок.
Отсортировка по убыванию выручки.*/
select
    CONCAT(e.first_name, ' ', e.last_name, null) as seller,
    COUNT(s.sales_id) as operations,
    FLOOR(SUM(s.quantity * p.price)) as income
from employees as e inner join sales as s
    on
        e.employee_id = s.sales_person_id
inner join products as p
    on
        s.product_id = p.product_id
group by
    seller
order by income desc limit 10;

/*5.2. Второй отчет содержит информацию о продавцах,
 чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам.
 Сортировка по выручке по возрастанию.*/
select
    CONCAT(e.first_name, ' ', e.last_name, null) as seller,
    FLOOR(AVG(s.quantity * p.price)) as average_income
from
    employees as e inner join sales as s
    on
        e.employee_id = s.sales_person_id
inner join products as p
    on
        s.product_id = p.product_id
group by seller
--С помощью having ограничим только те записи, которые меньше общего среднего
having
    AVG(s.quantity * p.price) < (
        select AVG(s.quantity * p.price)
        from sales as s
        inner join products as p on
            s.product_id = p.product_id
    )
order by average_income;

/*5.3. Третий отчет содержит информацию о продавцах,
 чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам.
 Сортировка по порядковому номеру дня недели и seller.*/
--Создадим таблицу для сортировки по порядковому номеру дня недели
with tab as (
    select
        CONCAT(e.first_name, ' ', e.last_name, null) as seller,
        EXTRACT(isodow from s.sale_date) as num_day,
        TO_CHAR(sale_date, 'day') as day_of_week,
        FLOOR(SUM(s.quantity * p.price)) as income
    from
        employees as e inner join sales as s
        on
            e.employee_id = s.sales_person_id
    inner join products as p
        on
            s.product_id = p.product_id
    group by seller, num_day, day_of_week
    order by seller, num_day
)

--Выведем необходимые данные
select
    seller,
    day_of_week,
    income
from tab;

/*6.1 Первый отчет - количество покупателей в разных возрастных группах.
 Используем union all. Сортировка по возрастной категории.*/
select
    '16-25' as age_category,
    COUNT(c.customer_id) as age_count
from customers as c
where c.age between 16 and 25
group by age_category
union all
select
    '26-40' as age_category,
    COUNT(c.customer_id) as age_count
from customers as c
where c.age between 26 and 40
group by age_category
union all
select
    '40+' as age_category,
    COUNT(c.customer_id) as age_count
from customers as c
where c.age > 40
group by age_category
order by age_category;

/*6.2. Второй отчет - необходимо предоставить данные по количеству уникальных покупателей и выручке,
 которую они принесли. Сортировка по дате.*/
select
    TO_CHAR(s.sale_date, 'YYYY-MM') as selling_month,
    COUNT(distinct c.customer_id) as total_customers,
    FLOOR(SUM(s.quantity * p.price)) as income
from sales as s inner join customers as c
    on
        s.customer_id = c.customer_id
inner join products as p
    on
        s.product_id = p.product_id
group by selling_month
order by selling_month;


/*6.3. Третий отчет о покупателях, первая покупка которых была в ходе проведения акций (акционные товары со стоимостью равной 0).
 Сортировака по id покупателя.*/
select distinct on (s.customer_id)
    s.sale_date,
    CONCAT(c.first_name, ' ', c.last_name, null) as customer,
    CONCAT(e.first_name, ' ', e.last_name, null) as seller
from sales as s inner join customers as c
    on
        s.customer_id = c.customer_id
inner join products as p
    on
        s.product_id = p.product_id
inner join employees as e
    on
        s.sales_person_id = e.employee_id
where p.price = 0
order by s.customer_id, s.sale_date;
