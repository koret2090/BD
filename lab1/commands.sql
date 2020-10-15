create table if not exists studios(
    studio_id int primary key,
    studio_name varchar(40),
    date_of_creation date
);
copy studios from 'D:\BD\studios.csv' delimiter ',' csv; 

create table if not exists directors(
    director_id int primary key,
    director_name varchar(40),
    age int check(age > 23 and age < 71),
    sex varchar (6),
    films_amount int check(films_amount > 0 and films_amount < 10)
);
copy directors from 'D:\BD\directors.csv' delimiter ',' csv; 

create table if not exists films(
    film_id int primary key,
    studio_id int references studios(studio_id),
    director_id int references directors(director_id),
    film_name varchar(40),
    release_date date,
    budget int check(budget >= 20000 and budget <= 250000000),
    fees int check(fees >= 20000 and fees <= 1000000000)
);
copy films from 'D:\BD\films.csv' delimiter ',' csv;

create table if not exists actors(
    actor_id int primary key,
    film_id int references films(film_id),
    actor_name varchar(40),
    age int check(age > 17 and age < 71),
    sex varchar(6),
    nationality varchar(40),
    fee int check(fee >= 1000 and fee <= 1000000),
    awards int check(awards >= 0 and awards < 6)
);
copy actors from 'D:\BD\actors.csv' delimiter ',' csv;
