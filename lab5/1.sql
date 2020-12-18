-- Из таблиц базы данных, созданной в первой лабораторной работе, 
-- извлечь данные в XML (MSSQL) или JSON(Oracle, Postgres). Для выгрузки 
-- в XML проверить все режимы конструкции FOR XML

select to_json(films) from films; 
select to_json(actors) from actors;
select to_json(directors) from directors;
select to_json(studios) from studios; 


select arr.nationality, avg(arr.age) over (partition by nationality)
from (
    select nationality, age
    from actors
    where nationality = 'British'
) as this