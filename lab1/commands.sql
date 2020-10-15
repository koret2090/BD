create table if not exists studios(
    studio_id int not null primary key,
    studio_name varchar(40) not null,
    date_of_creation date not null
);
copy studios from 'C:\Users\User\Desktop\BD\studios.csv' delimiter ',' csv; 