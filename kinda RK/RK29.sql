Пусть есть связующая таблица DC, которая содержит соответствия DriversID к CarsID

В таблицу Fines нужно добавить FK MyDriverID, указывающий на id водителя,
 получившего штраф. Это все нужно для связи многие к одному.


1. Найти все пары вида <ФИО водителя, год его автомобиля>

--sql 
select FIO, Year
from Drivers join DC on (Drivers.DriverID = DC.DriversID)
join Cars on (Cars.CarID = DC.CarsID)

--реляционная алгебра
(Drivers join DC join Cars)[FIO, Year]

--исчиление кортежей
range of DX is Drivers
range of CX is Cars
range of DCX is DC
(DX.FIO, CX.Year) where exists DCX(DCX.DriversID = DX.DriverID and exists CX(CX.CarID = DCX.CarsID))


2. Найти все штрафы водителей, автомобили которых были зарегистрированы в 2020
(или можно через between --- and ---)
--sql
select FineID, FineType, Amount, FineDate
from Fines join Drivers on (Fines.MyDriverID = Drivers.DriverID)
join DC on (DC.DriversID = Drivers.DriverID)
join Cars on (Cars.CarID = DC.CarsID) 
where (Cars.RegistrationDate <= '2020-12-31' and Cars.RegistrationDate >= '2020-01-01')

--реляционная алгебра 
((Fines join Drivers join DC join Cars) where (Cars[RegistrationDate] <= '2020-12-31' and Cars[RegistrationDate] >= '2020-01-01'))[FineID, FineType, Amount, FineDate]

-- исчисление кортежей
range of DX is Drivers
range of CX is Cars where (Cars.RegistrationDate  <= '2020-12-31' and  Cars.RegistrationDate >= '2020-01-01')
range of FX is Fines
range of DCX is DC
(FX.FineID, FX.FineType, FX.Amount, FX.FineDate) 
where exists FX(FX.MyDriverID = DX.DriverID and exists DCX(DCX.DriversID = DX.DriverID 
and exists CX(CX.DriverID = DCX.DriversID)))

3. Вычислить сумму штрафов Иванова Ивана Ивановича

--sql
select sum(Fines.Amount)
from Fines join Drivers on (Fines.MyDriverID = Drivers.DriverID)
where Drivers.FIO = 'Иванов Иван Иванович'

--реляционная алгебра
(SUMMARIZE ((Fines join Drivers) WHERE Drivers[FIO] = 'Иванов Иван Иванович') PER Fines{Amount}
ADD sum(Amount) as sumA)[sumA]

-- исчисление кортежей
range of FX is Fines
range of DX is Drivers where Drivers.FIO = 'Иванов Иван Иванович'
(sum(FX.Amount where exists DX(DX.DriversID = FX.MyDriverID)))

---------------

1) G покрывает F?
F{A->BC, A->D, CD->E} 
 G{A->BE, A->B, C->ED},  R(A, B, C, D, E)?

 {A}+ = {A, B, C, D, E} (по F) =  {A, B, E} (по G)
 {C}+ = {C, E} (по F) = {C, E, D} (по G)

2) F покрывает G?
{A}+ = {A, B, E} (по G) = {A, B, C, D, E} (по F)
{CD}+ = {C, E, D} (по G) = {С, E, D} (по F)

 Не совпало => не покрывают G не покрывает F и G не покрывает F => они не эквивалентны