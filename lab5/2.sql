-- Выполнить загрузку и сохранение XML или JSON файла в таблицу. 
-- Созданная таблица после всех манипуляций должна соответствовать таблице базы данных, 
-- созданной в первой лабораторной работе.

-- сохраняем в файл 
\copy (select row_to_json(studios) from studios) to 'D:\BD\BD\lab5\task2\studios.json';

-- создаем временную таблицу
create temp table studios_copy (doc json);

\copy studios_copy from 'D:\BD\BD\lab5\task2\studios.json';


-- json_populate_record(base anyelement, from_json json)
-- Разворачивает объект из from_json в табличную строку,
-- в которой столбцы соответствуют типу строки, заданному параметром base.

select studios_copy_norm.*
from studios_copy, json_populate_record(null::studios, doc) as studios_copy_norm;

select * from studios;