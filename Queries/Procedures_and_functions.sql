SET SERVEROUTPUT ON;
CREATE OR REPLACE PACKAGE procedury AS
PROCEDURE warehouse_content(p_id_magazynu IN lokalizacje.id_magazynu%TYPE,
p_id_zywnosci OUT stany_magazynowe.id_zywnosci%TYPE,
p_jednostka OUT stany_magazynowe.jednostka%TYPE,
p_ilosc OUT stany_magazynowe.ilosc%TYPE);
PROCEDURE allergies
(p_id_zaloganta IN alergie.id_zaloganta%TYPE,
p_id_skladnika OUT alergie.id_skladnika%TYPE,
p_nazwa OUT skladniki.nazwa%TYPE,
p_opis OUT skladniki.opis%TYPE);
PROCEDURE food_type
(p_nazwa_z IN zywnosc.nazwa%TYPE);
PROCEDURE crew_allergies
(p_id_zaloganta OUT alergie.id_zaloganta%TYPE,
p_nazwa IN skladniki.nazwa%TYPE);
FUNCTION package_count  
(nazwa IN magazyn.nazwa%TYPE)
RETURN NUMBER;
FUNCTION expiration_date  
(f_data_waznosci IN zywnosc.data_waznosci%TYPE)
RETURN DATE;
END procedury;

CREATE OR REPLACE PACKAGE BODY procedury AS

--procedura wypisujaca zawartosc magazynu 
--A procedure listing the contents of the warehouse.
PROCEDURE warehouse_content
(p_id_magazynu IN lokalizacje.id_magazynu%TYPE,
p_id_zywnosci OUT stany_magazynowe.id_zywnosci%TYPE,
p_jednostka OUT stany_magazynowe.jednostka%TYPE,
p_ilosc OUT stany_magazynowe.ilosc%TYPE) IS
BEGIN
select id_zywnosci, jednostka, ilosc into  p_id_zywnosci, p_jednostka, p_ilosc
from stany_magazynowe s join lokalizacje l on (s.id_lokalizacji = l.id_lokalizacji)
WHERE id_magazynu = p_id_magazynu;
END warehouse_content;

--procedura zwracajaca skladnik, na ktory dany zalogant ma alergie
--A procedure returning the ingredient to which a given user is allergic
PROCEDURE allergies
(p_id_zaloganta IN alergie.id_zaloganta%TYPE,
p_id_skladnika OUT alergie.id_skladnika%TYPE,
p_nazwa OUT skladniki.nazwa%TYPE,
p_opis OUT skladniki.opis%TYPE) IS
BEGIN
select id_skladnika, nazwa, opis into  p_id_skladnika, p_nazwa, p_opis
from alergie  join skladniki USING (id_skladnika)
WHERE id_zaloganta = p_id_zaloganta;
END allergies;

--procedura znajdujaca RYZ w magazynie
--A procedure finding RICE in the warehouse
PROCEDURE food_type 
(p_nazwa_z IN zywnosc.nazwa%TYPE) IS
BEGIN
declare
cursor food_type_cursor is
SELECT M.nazwa, M.polozenie, L.nr_regalu, L.pozycja, S.jednostka, S.ilosc, Z.nazwa 
FROM MAGAZYN M JOIN LOKALIZACJE  L ON  (M.ID_MAGAZYNU = L.ID_MAGAZYNU) JOIN 
stany_magazynowe S ON (S.ID_LOKALIZACJI = L.ID_LOKALIZACJI) JOIN zywnosc Z ON (S.ID_ZYWNOSCI = Z.ID_ZYWNOSCI)
WHERE Z.nazwa = 'RYZ';
M_NAZWA MAGAZYN.NAZWA%TYPE;
M_POLOZENIE MAGAZYN.POLOZENIE%TYPE;
REGAL LOKALIZACJE.NR_REGALU%TYPE;
POZYCJA LOKALIZACJE.POZYCJA%TYPE;
JEDNOSTKA stany_magazynowe.JEDNOSTKA%TYPE;
ILOSC stany_magazynowe.ILOSC%TYPE;
Z_NAZWA zywnosc.NAZWA%TYPE;
BEGIN
open food_type_cursor;
fetch food_type_cursor into M_NAZWA, M_POLOZENIE, REGAL, POZYCJA, JEDNOSTKA, ILOSC, Z_NAZWA;
close food_type_cursor;
dbms_output.put_line('M_NAZWA: '||M_NAZWA||' M_POLOZENIE: '||M_POLOZENIE||' REGAL: '||REGAL ||' POZYCJA: '||POZYCJA ||' JEDNOSTKA: '||JEDNOSTKA||' ILOSC: '||ILOSC ||' Z_NAZWA: '||Z_NAZWA);
end;
END food_type;

--procedura wyszukujaca zalogantow z alergia na dany skladnik
--A procedure searching for users with an allergy to a specific ingredient
PROCEDURE crew_allergies
(p_id_zaloganta OUT alergie.id_zaloganta%TYPE,
p_nazwa IN skladniki.nazwa%TYPE) IS
BEGIN
select  id_zaloganta into p_id_zaloganta
from skladniki s join alergie a on (s.id_skladnika = a.id_skladnika)
WHERE nazwa = p_nazwa;
END crew_allergies;

--funkcja sprawdzajaca czy ilosc paczek zywnosci jest wieksza niz 45
--A function checking if the quantity of food packages is greater than 45
FUNCTION package_count  
(nazwa IN magazyn.nazwa%TYPE) 
RETURN NUMBER
AS ILOSC NUMBER;
BEGIN
select S.ILOSC INTO ILOSC
from magazyn M join lokalizacje L ON (M.id_magazynu = L.id_magazynu) join stany_magazynowe S ON
(L.id_lokalizacji = S.id_lokalizacji)
WHERE S.ILOSC>45;
RETURN ILOSC;
END package_count;


--funkcja pokazujaca zywnosc, dla ktorej data waznosci jest krotsza niz miesiac
--A function displaying food items with an expiration date less than a month
FUNCTION expiration_date  
(f_data_waznosci IN zywnosc.data_waznosci%TYPE) 
RETURN DATE
AS DATA_UPLYWA DATE;
BEGIN
SELECT DATA_WAZNOSCI INTO DATA_UPLYWA
FROM ZYWNOSC WHERE DATA_WAZNOSCI < Add_months(current_date,1);
RETURN DATA_UPLYWA;
END expiration_date;

--funkcja sprawdzajaca czy ilosc kalorii w posilku jest odpowiednia
--A function checking if the calorie count in a meal is appropriate
CREATE OR REPLACE FUNCTION Calories_check  
(id_posilku IN posilki.id_posilku%TYPE) 
RETURN NUMBER
AS KALORIE NUMBER;
BEGIN
select kalorycznosc INTO KALORIE
from posilki
WHERE  kalorycznosc>=2500;
RETURN KALORIE;
END Calories_check;

END procedury;