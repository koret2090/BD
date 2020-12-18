import psycopg2
conn = psycopg2.connect(
    dbname='films_base',
    user='postgres',
    password='123',
    host='localhost'
)


# 1. Выполнить скалярный запрос

def scalar_request():
    cursor = conn.cursor()

    request = 'select actor_name, sex, age from actors where actor_id = 1'
    cursor.execute(request)
    result = cursor.fetchall()[0]
    print("Name:", result[0], "Sex:", result[1], "Age:", result[2])

    cursor.close()

# 2.Выполнить запрос с несколькими соединениями (JOIN)

def join_request():
    cursor = conn.cursor()

    request = 'select actor_name, sex, age , film_name\
        from actors join films on actors.film = films.film_id\
        where actor_id = 1'

    cursor.execute(request)
    result = cursor.fetchall()[0]
    print("Name:", result[0], "Sex:", result[1], "Age:", result[2], "Film:", result[3])

    cursor.close()
    

# 3. Выполнить запрос с ОТВ(CTE) и оконными функциями

def task3_request():
    cursor = conn.cursor()

    request = '''
    select arr.nationality, avg(arr.age) over (partition by nationality) as "age"
    from (
        select nationality, age
        from actors
        where nationality = 'British'
    ) as arr
    union
    select arr.nationality, avg(arr.age) over (partition by nationality) as "age"
    from (
        select nationality, age
        from actors
        where nationality = 'Russian'
    ) as arr;   
    '''
    cursor.execute(request)
    for string in cursor:
        print('Nationality:', string[0], "Average age:", string[1])
        
    cursor.close()


# 4. Выполнить запрос к метаданным

def meta_data_request():
    cursor = conn.cursor()

    request = '''
    select relname,
    pg_size_pretty(pg_relation_size(indexrelname::text))
    from pg_stat_all_indexes 
    where relname = 'actors';
    '''
    cursor.execute(request)
    result = cursor.fetchall()[0]

    print("Table name:", result[0], "\nSize:", result[1])

    cursor.close()


# 5. Вызвать скалярную функцию
'''
-- Скалярная функция
create or replace function skalar_func() returns int
language sql
as $$ 
    select age
    from actors
    order by actor_id;
$$;
'''

def scalar_function():
    cursor = conn.cursor()

    request = 'select * from skalar_func()'
    cursor.execute(request)
    result = cursor.fetchall()[0][0]
    print(result)

    cursor.close()

##########################################

# 6. Вызвать многооператорную или табличную функцию
# select * from get_players(219);

def table_func():
    cursor = conn.cursor()

    request = 'select * from get_with_this_age(20)'
    cursor.execute(request)
    for string in cursor:
        print("Name:", string[0], "Sex:", string[1], "Age:", string[2])

    cursor.close()


# 7. Вызвать хранимую процедуру
#Вызвать хранимую процедуру (написанную в третьей лабораторной работе)

def stored_proc_func():
    cursor = conn.cursor()

    request = 'call make_older()'
    cursor.execute(request)
    print("Procedure Called")

    cursor.close()


# 8. Вызвать системную функцию или процедуру

def system_func():
    cursor = conn.cursor()

    request = 'select version()'
    cursor.execute(request)
    result = cursor.fetchall()[0][0]
    print(result)

    cursor.close()


# 9. Создать таблицу в базе данных, соответствующую тематике БД

def create_table():
    cursor = conn.cursor()

    request = '''
    drop table if exists example;
    create table example (
        studio_id serial not null,
        cost int
    );
    '''
    cursor.execute(request)
    conn.commit()

    cursor.close()

# 10. Выполнить вставку данных в созданную таблицу с использованием
#     инструкции INSERT или COPY.

def insert_table(studio_id, cost):
    cursor = conn.cursor()

    request = f'''
    insert into example(studio_id, cost)
    values({studio_id}, {cost})
    '''
    cursor.execute(request)
    conn.commit()

    cursor.close()


#scalar_request()
#join_request()
#task3_request()
#meta_data_request()
#scalar_function()
#table_func()
#stored_proc_func()
#system_func()
#create_table()
#insert_table(3, 30000000)

conn.close()