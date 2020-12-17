drop table if exists table_import;
create temp table table_import (doc jsonb);
\copy table_import from 'D:\BD\BD\lab5\task2\studios.json';

-- 1. Извлечь XML/jsonb фрагмент из XML/jsonb документа

drop table if exists table1;
create table table1 (studios jsonb);

insert into table1 (studios)
select doc
from table_import
where cast(doc::jsonb->>'studio_id' as int) = 1;

select * from table1;


-- 2. Извлечь значения конкретных узлов или атрибутов   XML/jsonb документа

drop table if exists table2;
create table table2
(
    studio_id int,
    studio_name varchar(40)
);

insert into table2 (studio_id, studio_name)
select  cast(doc::jsonb->>'studio_id' as int), doc::jsonb->>'studio_name' 
from table_import;

select * from table2;

-- 3. Выполнить проверку существования узла или атрибута

select doc::jsonb ? 'studio_name' as result
from table_import
where cast(doc::jsonb->>'studio_id' as int) = 65;

select doc::jsonb ? 'studio_nme' as result
from table_import
where cast(doc::jsonb->>'studio_id' as int) = 65;


-- 4. Изменить XML/jsonb документ

select doc->>'studio_name'
from table_import
where cast(doc->>'studio_id' as int) = 65;

update table_import
set doc = jsonb_set(doc, '{studio_name}', '"professional studio"')
where cast(doc->>'studio_id' as int) = 65;

update table_import
set doc = jsonb_set(doc, '{studio_name}', '"Super"')
where cast(doc->>'studio_id' as int) = 65;


-- 5. Разделить XML/JSON документ на несколько строк по узлам
-- сохраняем в файл 
\copy (select row_to_json(actors) from actors) to 'D:\BD\BD\lab5\task2\actors.json';
drop table if exists table_import;
create temp table table_import (doc jsonb);
\copy table_import from 'D:\BD\BD\lab5\task2\actors.json';


drop table if exists table4_1;
drop table if exists table4_2;

create table table4_1 (doc jsonb);
create table table4_2 (doc jsonb);

insert into table4_1(doc)
select doc  - 'actor_id' - 'film' - 'fee' - 'awards'
from table_import;

insert into table4_2(doc)
select doc - 'actor_id' - 'film' - 'sex' - 'nationality'
from table_import;

select * from table4_1;
select * from table4_2;