create extension plpython3u;


-- 1) Определяемую пользователем скалярную функцию CLR
drop function get_actor_by_id(id int) ;

create or replace function get_actor_by_id(id int) 
returns varchar
language plpython3u
as $$
    actor_arr = plpy.execute("select * from actors")
    for actors in actor_arr:
        if actors['actor_id'] == id:
            return actors['actor_name']
    return 'None'
$$;

select * from get_actor_by_id(1);

-- 2) Пользовательскую агрегатную функцию CLR

create or replace function avg_state(prev numeric[2], next numeric) returns numeric[2]
language plpython3u
as $$
	return prev if next == 0 or next == None else [0 if prev[0] == None else prev[0] + next, prev[1] + 1]
$$; 
create or replace function avg_final(num numeric[2]) returns numeric
language plpython3u
as $$
    return 0 if num[1] == 0 else num[0] / num[1]
$$;


create aggregate my_avg(numeric) (
    sfunc = avg_state,
    stype = numeric[],
    finalfunc = avg_final,
    initcond = '{0,0}'
);

select my_avg(actors.age::numeric)
from actors;


-- 3) Определяемую пользователем табличную функцию CLR
-- получить все актеров из страны

drop function if exists get_all_actors_by_nationality;
create or replace function get_all_actors_by_nationality(nationality varchar)
returns table(id int, actor_name varchar, age int, sex varchar, nationality varchar)
language plpython3u
as $$
    actors_arr = plpy.execute("select * from actors")
    result_table = list()
    for actors in actors_arr:
        if actors['nationality'] == nationality:
            result_table.append(actors)
    return result_table
$$;

select * from get_all_actors_by_nationality('Russian');

-- 4) Хранимую процедуру CLR
drop procedure if exists add_director;
create or replace procedure add_director(director_id int, director_name varchar, age int, sex varchar, films_amount int)
language plpython3u
as $$
    request = plpy.prepare("insert into directors (director_id, director_name, age, sex, films_amount) values($1, $2, $3, $4, $5);", ["int", "varchar", "int", "varchar", "int"])
    plpy.execute(request, [director_id, director_name, age, sex, films_amount])
$$;

call add_director(1001, 'Suslikov Daniil', 24, 'M', 1);

select * from directors 
where director_id = 1001;

-- 5) Триггер CLR

drop table if exists director_sex_changes;
create table if not exists director_sex_changes
(
    id serial not null,
    old_sex varchar(8),
    new_sex varchar(8)
);



drop trigger if exists change_director_sex on director_sex_changes;

create or replace function change_director_sex()
returns trigger
language plpython3u
as $$
    new_director = TD['new']
    old_director = TD['old']
    director_id = new_director["director_id"]
    old_sex = old_director["sex"]
    new_sex = new_director["sex"]
    if old_sex != new_sex:
        request = plpy.prepare("insert into director_sex_changes(old_sex, new_sex) values($1, $2);", ["varchar", "varchar"])
        change = plpy.execute(request, [old_sex, new_sex])
    return None
$$;

create trigger change_director_sex
after update on directors
for each row
execute procedure change_director_sex();

select * from directors 
where director_id = 322;

update directors
set sex = 'f'
where management.id = 322;

select * from directors;

-- 6) Определяемый пользователем тип данных CLR

drop function get_actor_brief_info(id int);
drop type brief_info;

create type brief_info as (
    actor_name varchar,
    sex varchar,
    age int
);

create or replace function get_actor_brief_info(id int)
returns brief_info
language plpython3u
as $$
	request = plpy.prepare("select actor_name, sex, age from actors where actor_id = $1", ["int"])
	information = plpy.execute(request, [id])
	return (information[0]['actor_name'], information[0]['sex'], information[0]['age'])
$$;

select * from get_actor_brief_info(322);
select actor_name, sex, age from actors where actor_id = 322;