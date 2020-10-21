-- 1. Инструкция SELECT, использующая предикат сравнения.
select *
from actors
where age = 33

-- 2. Инструкция SELECT, использующая предикат between.
select *
from studios
where date_of_creation between '1990-01-01' and '2000-12-31'

-- 3. Инструкция SELECT, использующая предикат LIKE.
select *
from actors
where nationality like '%sh'

-- 4. Инструкция SELECT, использующая предикат IN с вложенным подзапросом.
select actor_name, awards, age
from actors
where actor_name in (
    select actor_name
    from actors
    where awards > 2
) and age < 20

-- 5. Инструкция SELECT, использующая предикат EXISTS с вложенным подзапросом.
select actor_name, age
from actors
where exists (
    select actor_name, age
    from actors join films on actors.film_id = films.film_id
    where films.budget > 200000000
)

-- 6. Инструкция SELECT, использующая предикат сравнения с квантором.
select *
from films
where films.budget > all (
    select films.budget
    from films
    where release_date between '1990-01-01' and '2000-12-31'
)
order by films.budget

-- 7. Инструкция SELECT, использующая агрегатные функции в выражениях столбцов.
select *
from (
    select nationality, sum(age) / count(actor_id) as avg_age
    from actors
    group by nationality
) as avg_nation_actor_age
order by avg_age

-- 8. Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов.
select
(
    select avg(budget)
    from films
    where film_name like '%a'
) as a_films_avg_budget,
(
    select avg(fees)
    from films
    where film_name like '%a'
) as a_films_fees
from films

-- 9. Инструкция SELECT, использующая простое выражение CASE.
select actor_id, actor_name,
case age
when 18 then 'young'
when 70 then 'very_old'
else 'mid_age'
end ages_groups
from actors
order by age


-- 10. Инструкция SELECT, использующая поисковое выражение CASE.
select actor_id, actor_name,
case 
when age < 30 then 'young'
when age < 55 then 'mid_ages'
else 'old'
end ages_groups
from actors
order by actor_name

-- 11. Создание новой временной локальной таблицы из
--      результирующего набора данных инструкции SELECT.
select actor_id, sex
into temp
from actors
--drop table temp

-- 12. Инструкция SELECT, использующая вложенные коррелированные
-----  подзапросы в качестве производных таблиц в предложении FROM.
select actor_name, studios.studio_name
from actors join
(
    films join studios
    on films.studio_id = studios.studio_id
) on actors.film_id = films.film_id

/*
select actor_name, info.studio_name
from actors join
( 
    films join studios
    on films.studio_id = studios.studio_id
) as info on actors.film_id = info.film_id
order by actor_name
*/

-- 13. Инструкция SELECT, использующая вложенные подзапросы с уровнем вложенности 3.
select actor_name
from actors
where actors.actor_id in (
    select actors.actor_id
    from actors join films 
    on actors.film_id = films.film_id
    where films.film_id in
    (
        select film_id
        from films join studios
        on films.studio_id = studios.studio_id
        where studios.studio_id in
        (
            select studios.studio_id
            from studios
            where studios.date_of_creation between '1960-01-01' and '1980-12-31'
        )
    )
)

-- 14. Инструкция SELECT, консолидирующая данные 
--      с помощью предложения GROUP BY, но без предложения HAVING.
select nationality, avg(age) as avg_age
from actors
group by nationality
order by avg_age

-- 15. Инструкция SELECT, консолидирующая данные 
--      с помощью предложения GROUP BY и предложения HAVING.
select nationality, avg(age) as Average_age
from actors
group by nationality
HAVING avg(age) >
(
    select avg(age)
    from actors
)

-- 16. Однострочная инструкция INSERT,
--      выполняющая вставку в таблицу одной строки значений.
insert into directors (director_id, director_name, age, sex, films_amount)
values (1001, 'Suslikov Daniil', '24', 'M', 1)

-- 17. Многострочная инструкция INSERT, выполняющая вставку в таблицу
--      результирующего набора данных вложенного подзапроса.
insert into actors (actor_id, film_id, actor_name, age, sex, nationality, fee, awards)
select max(actor_id) + 1, 
(
    select max(film_id)
    from actors
), 'Tom Riddle', 40, 'M', 'British', 1000000, 2
from actors

-- 18. Простая инструкция UPDATE.
update actors
set age = 25
where actor_id = 5001

-- 19. Инструкция UPDATE со скалярным подзапросом в предложении SET.
update actors
set fee = 
(
    select avg(fee)
    from actors
)
where actor_id = 5001

-- 20. Простая инструкция DELETE.
delete from actors
where actor_id = 5001 

-- 21. Инструкция DELETE с вложенным коррелированным подзапросом в предложении WHERE.
delete from directors
where director_id in 
(
    select director_id
    from directors
    where age < 40
) and director_id = 1001

-- 22. Инструкция SELECT, использующая простое обобщенное табличное выражение
with temp
as
(
    select actor_id, actor_name, age
    from actors
    where age < 30
)
select *
from temp
where actor_name like 'I%'

-- 23. Инструкция SELECT, использующая рекурсивное обобщенное табличное выражение.
with recursive add1(n) as
(
    select 1
    union all
    select n+1 from add1
    where n < 10
)
select n from add1

-- 24. Оконные функции. Использование конструкций MIN/MAX/AVG OVER()
select actor_name, age, film_id,
    min(age) over (partition by film_id),
    max(age) over (partition by film_id),
    avg(age) over (partition by film_id)
from actors

-- 25. Оконные фнкции для устранения дублей
select *
from
(
    select fa.age, row_number() over (partition by fa.age) as countt
    from films join 
    (
        select *
        from actors join films
        on actors.film = films.film_id
    ) as fa on films.film_id = fa.film_id
) as pc
where countt = 1
order by age