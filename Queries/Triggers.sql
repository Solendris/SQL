-- Trigger changing letters in the food name to uppercase
create or replace trigger Wielkie_nazwy_zywnosc 
    before insert on zywnosc
    for each row
begin
    :NEW.nazwa := upper(:new.nazwa);
end Wielkie_nazwy_zywnosc;

-- Commands to enable/disable the trigger
alter trigger Wielkie_nazwy_zywnosc disable;
alter trigger Wielkie_nazwy_zywnosc enable;

-- Test data
INSERT INTO "SYSTEM"."ZYWNOSC" (ID_ZYWNOSCI, NAZWA, OPIS, WYMAGANIA, DATA_WAZNOSCI, KALORYCZNOSC, INDEKS_GLIKEMICZNY, TLUSZCZ, KWASY_TLUSZCZOWE_NASYCONE, WEGLOWODANY, CUKRY, BIALKO, SOL) VALUES ('5', 'salatka', 'niezbedne w diecie', 'ponizej 0 stopni', TO_DATE('2022-12-31 20:37:06', 'YYYY-MM-DD HH24:MI:SS'), '20', '0', '0', '40', '0', '0', '5', '0');
INSERT INTO "SYSTEM"."ZYWNOSC" (ID_ZYWNOSCI, NAZWA, OPIS, WYMAGANIA, DATA_WAZNOSCI, KALORYCZNOSC, INDEKS_GLIKEMICZNY, TLUSZCZ, KWASY_TLUSZCZOWE_NASYCONE, WEGLOWODANY, CUKRY, BIALKO, SOL) VALUES ('6', 'marchewka', 'niezbedne w diecie', '15 stopni', TO_DATE('2022-12-31 20:37:06', 'YYYY-MM-DD HH24:MI:SS'), '30', '15', '0', '0', '0', '40', '0', '0');
INSERT INTO "SYSTEM"."ZYWNOSC" (ID_ZYWNOSCI, NAZWA, OPIS, WYMAGANIA, DATA_WAZNOSCI, KALORYCZNOSC, INDEKS_GLIKEMICZNY, TLUSZCZ, KWASY_TLUSZCZOWE_NASYCONE, WEGLOWODANY, CUKRY, BIALKO, SOL) VALUES ('7', 'ZiEmNiAk', 'niezbedne w diecie', '15 stopni', TO_DATE('2022-12-31 20:37:06', 'YYYY-MM-DD HH24:MI:SS'), '40', '60', '0', '10', '0', '40', '0', '15');

select * from zywnosc;

-------------------------------------------------------------------------------------------------------------------------------------------------------

-- Table storing information about changes happening in the stany_magazynowe table
create table info_o_zmianach_stanu(
id_zmiany number (5) primary key,
opis varchar(100),
czas_zmiany timestamp,
typ_zmiany varchar2(10) check(typ_zmiany in ('update', 'insert', 'delete'))
);

-- Sequence enabling automatic increment of the id values
create sequence info_o_zmianach_stanu_seq; 

-- Trigger logging changes to the info_o_zmianach_stanu table
create or replace trigger Stany_magazynowe_zmiana 
    after update or insert or delete on stany_magazynowe
    for each row
begin
    if updating then
        insert into info_o_zmianach_stanu values (info_o_zmianach_stanu_seq.nextval,'modyfikacja stanu', current_timestamp, 'update');
    end if;
    if inserting then
        insert into info_o_zmianach_stanu values (info_o_zmianach_stanu_seq.nextval,'modyfikacja stanu', current_timestamp, 'insert');
    end if;
    if deleting then
        insert into info_o_zmianach_stanu values (info_o_zmianach_stanu_seq.nextval,'modyfikacja stanu', current_timestamp, 'delete');
    end if;
end Stany_magazynowe_zmiana;

-- Commands to enable/disable the trigger
alter trigger Stany_magazynowe_zmiana disable;
alter trigger Stany_magazynowe_zmiana enable;

-- Test data
INSERT INTO "SYSTEM"."STANY_MAGAZYNOWE" (ID_STANU, ID_ZYWNOSCI, ID_LOKALIZACJI, JEDNOSTKA, ILOSC) VALUES ('4', '4', '4', 'paczki', '14');
INSERT INTO "SYSTEM"."STANY_MAGAZYNOWE" (ID_STANU, ID_ZYWNOSCI, ID_LOKALIZACJI, JEDNOSTKA, ILOSC) VALUES ('5', '5', '2', 'paczki', '60');
UPDATE "SYSTEM"."STANY_MAGAZYNOWE" SET ID_LOKALIZACJI = 3, ILOSC = 41 WHERE ID_STANU=4;

select * from info_o_zmianach_stanu;

-------------------------------------------------------------------------------------------------------------------------------------------------------

-- Auxiliary view to display key data from the inventory_states, locations, and warehouse tables
create or replace view zawartosc_magazynu as
select id_magazynu, id_lokalizacji, Id_zywnosci, jednostka, ilosc from stany_magazynowe  join lokalizacje  using (id_lokalizacji) join magazyn  using (id_magazynu); 

select * from zawartosc_magazynu;

-- Sequence enabling automatic increment of the id values
create  sequence zawartosc_magazynu_seq 
START WITH 5
INCREMENT BY 1; 

-- Trigger modifying data in the inventory_content perspective
create or replace trigger Zmiana_zawartosci 
    instead of insert on zawartosc_magazynu
    for each row
begin
    insert into lokalizacje values (:NEW.id_lokalizacji, :NEW.id_magazynu, 0, 0 );
    insert into stany_magazynowe values(zawartosc_magazynu_seq.nextval,:NEW.id_zywnosci, :NEW.id_lokalizacji, :new.jednostka, :NEW.ilosc);  
end Zmiana_zawartosci;

-- Commands to enable/disable the trigger
alter trigger Zmiana_zawartosci disable;
alter trigger Zmiana_zawartosci enable;

-- Test data
insert into zawartosc_magazynu (id_magazynu, id_lokalizacji, Id_zywnosci, jednostka, ilosc) values (1,6, 5, 'skrzynie',4);
insert into zawartosc_magazynu (id_magazynu, id_lokalizacji, Id_zywnosci, jednostka, ilosc) values (1,7, 5, 'skrzynie',4);


-------------------------------------------------------------------------------------------------------------------------------------------------------


-- Table storing entries
create table logger(
id_zmiany number (5) primary key,
nazwa_tablicy varchar(25),
opis varchar(100),
czas_zmiany timestamp,
typ_zmiany varchar2(10) check(typ_zmiany in ('update', 'insert', 'delete'))
);

-- Sequence enabling automatic increment of the id values
create sequence logger_count; 

-- Trigger logging changes on the stany_magazynowe table to the info_o_zmianach_stanu table
create or replace trigger Stany_magazynowe_zmiana 
    after update or insert or delete on stany_magazynowe
    for each row
begin
    if updating then
        insert into logger values (logger_count.nextval,'Stany magazynowe','modyfikacja stanu', current_timestamp, 'update');
    end if;
    if inserting then
        insert into logger values (logger_count.nextval,'Stany magazynowe','modyfikacja stanu', current_timestamp, 'insert');
    end if;
    if deleting then
        insert into logger values (logger_count.nextval,'Stany magazynowe','modyfikacja stanu', current_timestamp, 'delete');
    end if;
end Stany_magazynowe_zmiana;

-- Trigger logging changes made on the locations table to the info_o_zmianach_stanu table
create or replace trigger Lokalizacje_zmiana 
    after update or insert or delete on lokalizacje
    for each row
begin
    if updating then
        insert into logger values (logger_count.nextval,'Lokalizacje','modyfikacja stanu', current_timestamp, 'update');
    end if;
    if inserting then
        insert into logger values (logger_count.nextval,'Lokalizacje','modyfikacja stanu', current_timestamp, 'insert');
    end if;
    if deleting then
        insert into logger values (logger_count.nextval,'Lokalizacje','modyfikacja stanu', current_timestamp, 'delete');
    end if;
end Lokalizacje_zmiana;

INSERT INTO "SYSTEM"."STANY_MAGAZYNOWE" (ID_STANU, ID_ZYWNOSCI, ID_LOKALIZACJI, JEDNOSTKA, ILOSC) VALUES ('10', '4', '4', 'paczki', '14');
INSERT INTO "SYSTEM"."STANY_MAGAZYNOWE" (ID_STANU, ID_ZYWNOSCI, ID_LOKALIZACJI, JEDNOSTKA, ILOSC) VALUES ('11', '5', '2', 'paczki', '60');
UPDATE "SYSTEM"."STANY_MAGAZYNOWE" SET ID_LOKALIZACJI = 6, ILOSC = 41 WHERE ID_STANU=6;

INSERT INTO "SYSTEM"."LOKALIZACJE" (ID_LOKALIZACJI, ID_MAGAZYNU, NR_REGALU, POZYCJA) VALUES ('10', '4', '14','19');
UPDATE "SYSTEM"."LOKALIZACJE" SET ID_MAGAZYNU = 2, NR_REGALU = 10, POZYCJA=15 WHERE ID_LOKALIZACJI=6;

select * from logger;
