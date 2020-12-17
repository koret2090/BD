-- Четыре функции
select * from <имя функции>

-- Скалярная функция
create or replace function skalar_func() returns int
language sql
as $$ 
    select age
    from actors
    order by actor_id;
$$;

-- Подставляемая табличная
drop function get_younger(int);
create function get_younger(int) 
returns setof actors 
language sql
as $$
    select *
    from actors
    where age < $1;
$$;

select * from get_younger(20);

-- Многооператорная табличная

drop table if exists age_actors;
create table age_actors (
    name varchar(40),
    sex varchar(6),
    age int
);

create or replace function get_with_this_age(int)
returns table
(
    actor_name varchar(40),
    sex varchar(6),
    age int
)
language sql
as $$
    insert into age_actors
    select actor_name, sex, age
    from actors
    where age = $1;

    update age_actors
    set age = age * 2;

    select * from age_actors;
$$;

select * from get_with_this_age(20);

-- Рекурсивную функцию или функцию с рекурсивным ОТВ
create or replace function pow(x int, grade int)
returns int
language plpgsql
as $$
begin 
	if grade = 0 then
		return 1;
	else 
		return x * pow(x, grade - 1);
	end if;
end $$; 
 

create function or replace get_actors_in_interval(cur_id int, end_id int)
returns table
(
    id_of_actor int,
    name_of_actor varchar(40)
)
language plpgsql
as $$
begin
	return query select actor_id, actor_name
	from actors
	where actor_id = cur_id;
	
	if cur_id < end_id then
	return query select *
	from get_actors_in_interval(cur_id + 1, end_id);
	end if;	
end;
$$;

select * from get_actors_in_interval(10, 20);

-- Четыре хранимые процедуры

-- Хранимая процедура без параметров или с параметрами
drop procedure make_older();
drop table actors_copy;

select * into temp actors_copy from actors;

create procedure make_older()
language plpgsql
as $$
begin
    update actors_copy
    set age = age + 1;
end; 
$$;

call make_older();

-- Рекурсивную хранимую процедуру или хранимую процедуру с рекурсивным ОТВ
drop procedure new_fee(increasement int, end_id int, cur_id int);

create procedure new_fee(increasement int, end_id int, cur_id int)
language plpgsql
as $$
begin
    if cur_id < end_id then
        update actors_copy
        set fee = increasement
        where actor_id = cur_id;
        call new_fee(increasement, end_id, cur_id + 1);
    end if;
end; 
$$;

call new_fee(100000, 10, 1);

-- Хранимую процедуру с курсором

drop procedure update_awards(plus int);

create procedure update_awards(plus int)
language plpgsql
as $$
declare my_cursor cursor
	for select actor_name, age, actor_id  
	from actors;
    name_temp varchar(40);
    age_temp int;
    id int;
begin
	open my_cursor;
	loop
		fetch my_cursor into name_temp, age_temp, id;
		exit when not found;
		update actors_copy
		set awards = awards + plus
		where actor_id = id;
	end loop;
	close my_cursor;		
end
$$;

call update_awards(1);

select * from actors_copy;


-- Xранимую процедуру доступа к метаданным
raise notice 'INFO: % %', 
drop procedure table_info();

create or replace procedure table_info(table_name varchar(40))
language plpgsql
as $$
declare
    line record;
begin
    select relname,
    pg_size_pretty(pg_relation_size(indexrelname::text)) as size into line
    from pg_stat_all_indexes 
    where relname = table_name;
    raise notice 'INFO: % %', line.relname, line.size;
end; 
$$;

call table_info('actors');


--Два DML триггера

--Триггер AFTER

drop table kids;

create table kids
(
    kid_id int not null,
    kid_name varchar(40)
);

insert into kids(kid_id, kid_name)
values (id, name_of_kid);


drop function kid_is_added() cascade;

create function kid_is_added()
returns trigger
language plpgsql
as $$
begin
    raise notice 'New kid is added';
    return new;
end;
$$;


create trigger after_add_kid
after insert on kids
    for each row
    execute procedure kid_is_added();


--Триггер INSTEAD OF

create view kids_view as
select *
from kids;

drop function kid_isnt_deleted() cascade;

create function kid_isnt_deleted()
returns trigger
language plpgsql
as $$
begin
    raise notice 'CANNOT DELETE KID. KID WANTS TO LIVE';
    return new;
end;
$$;

create trigger after_add_kid
instead of delete on kids_view
    for each row
    execute procedure kid_isnt_deleted();

delete from kids_view
where kid_id = 1;