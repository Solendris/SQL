--obiekt przechowujący dane o alergiach
--object storing allergy data
create type alergie_obiekt as object (
nazwa_alergii varchar2(25),
rodzaj_alergii varchar2(25),
zalecenia varchar2(60)
);

create type lista_alergii as varray(15) of alergie_obiekt;

create table zaloga_alergie(
    Id_zaloganta number(30), 
    Imie varchar(25),
    nazwisko varchar(25),
    alergia lista_alergii
);

INSERT INTO zaloga_alergie VALUES (1, 'John', 'Doe', lista_alergii(alergie_obiekt('chemiczna','pokarmowa', 'Zakaz produktow zawierajacych gluten')));
INSERT INTO zaloga_alergie VALUES (2, 'Katarzyna', 'Kowalska', lista_alergii(alergie_obiekt('chemiczna','kontaktowa', 'Zakaz kontaktu z metalami: chrom, nikiel, kobalt.')));
INSERT INTO zaloga_alergie VALUES (3, 'Jan', 'Nowak', lista_alergii(alergie_obiekt('wziewna','roslinne', 'Unikac roslin wiatropylnych')));

SELECT * FROM zaloga_alergie CROSS JOIN TABLE(zaloga_alergie.alergia);

--obiekt przechowujący dane o stanowisku
--object storing position data
create type rola as object (
stanowisko varchar2(25),
staz_lata number(3)
);

create type rola_lista as varray(2) of rola;

create table zaloganci (
    ID_ZALOGANTA NUMBER, 
    IMIE VARCHAR2(25),
    NAZWISKO VARCHAR2(25),
    role rola_lista
);

INSERT INTO zaloganci VALUES ('1', 'Jan', 'Kowalski', rola_lista(rola('dyrektor','3')));

SELECT * FROM zaloganci CROSS JOIN TABLE(zaloganci.role);

--obiekt przechowujacy informacje o diecie zaloganta
--object storing information about the user's diet
create type zalecenia_obiekt as object (
Osoba_wystawiajaca varchar2(60),
cel_diety varchar2(50),
Rodzaj_diety varchar2(50),
Uzasadnienie varchar2(150)
);

create type lista_zalecen as varray(17) of zalecenia_obiekt;

create table Zalecenia_dla_zalogi (
    id_zaloganta number, 
    Imie_pacjenta  varchar2(25),
    Nazwisko_pacjenta varchar2(25),
    zalecenie lista_zalecen
);

INSERT INTO Zalecenia_dla_zalogi VALUES (1, 'Jan', 'Kowalski', lista_zalecen(zalecenia_obiekt('dr. Janusz Stachurski', 'Zwiekszenie masy','Anaboliczna', 'Dieta oparta na redukcji tkanki tluszczowej przy jednoczesnym dostarczaniu bialka pozwoli na zbudowanie masy miesniowej')));
INSERT INTO Zalecenia_dla_zalogi VALUES (2, 'Kalina', 'Nowak', lista_zalecen(zalecenia_obiekt('dr. Janusz Stachurski', 'Wyrownanie cholesterolu','Ketogenna', 'Dieta oparta na zdrowych tluszczach pozwoli pacjentowi na obnizenie cholesterolu')));
INSERT INTO Zalecenia_dla_zalogi VALUES (3, 'John', 'Doe', lista_zalecen(zalecenia_obiekt('dr. Janusz Stachurski', 'Obnizenie cisnienia krwi','Wegetarianska', 'Przez zbyt duza ilosc miesa w posilkach pacjent doprowadzil do zwiekszenia cisnienia krwi. dieta wegetarianska je obnizy.')));

SELECT * FROM Zalecenia_dla_zalogi CROSS JOIN TABLE(Zalecenia_dla_zalogi.zalecenie);
