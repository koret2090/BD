--Создать таблицу, в которой будет атрибут(-ы) с типом XML или JSON, или
--добавить атрибут с типом XML или JSON к уже существующей таблице.
--Заполнить атрибут правдоподобными данными с помощью команд INSERT
--или UPDATE.

drop table if exists table_with_json;
create table table_with_json
(
    id serial primary key,
    actor varchar(40),
    films json
);

insert into table_with_json (actor, films) values
('Steve Rodjers', '{"2018" : 2, "2019" : 1, "2020" : 0}'),
('Antony Stark', '{"2018" : 3, "2019" : 0, "2020" : 1}'),
('Peter Parker', '{"2018" : 1, "2019" : 1, "2020" : 0}');

select * from table_with_json;

