CREATE OR REPLACE VIEW zywnosc_xml_view (zywnosc_doc) AS
   SELECT XMLElement(NAME "Zywnosc",                      
                       XMLForest(z.id_zywnosci as "Id", z.nazwa as "Nazwa", z.opis as "Opis", skl.nazwa as "Skladnik", skl.opis as "Opis skladnika"))
       FROM zywnosc z join sklady s on (z.id_zywnosci = s.id_zywnosci) join skladniki skl on (s.id_skladnika = skl.id_skladnika);
       
select * from zywnosc_xml_view;

CREATE OR REPLACE VIEW magazyny_xml_view (magazyn_doc) AS
   SELECT XMLElement(NAME "Magazyny",                      
                       XMLForest(m.id_magazynu as "Id magazynu", m.nazwa as "Nazwa", m.polozenie as "Polozenie",
                       s.id_stanu as "Id stanu", s.jednostka as "Jednostka", s.ilosc as "Ilosc"))
       FROM magazyn m join lokalizacje l on (m.id_magazynu = l.id_magazynu) join stany_magazynowe s on (l.id_lokalizacji = s.id_lokalizacji);
       
select * from magazyny_xml_view;

CREATE OR REPLACE VIEW magazyn_view OF XMLType WITH OBJECT ID
  (extract(OBJECT_VALUE, '/Magazyn/@magazynno').getnumberval())
  AS SELECT XMLElement("Magazyn", 
                       XMLAttributes(id_magazynu),
                       XMLForest(m.id_magazynu as "id", m.nazwa as "nazwa"))
       AS "result"
       FROM magazyn m;   

select * from magazyn_view;

CREATE OR REPLACE VIEW alergie_skladniki_xml_view (Alergie_Skladniki) AS
    SELECT XMLElement("Alergie_Skladniki", 
                       XMLForest(skl.id_skladnika as "id", skl.nazwa, z.id_zaloganta))
       AS "result"
       FROM skladniki skl join alergie a on (skl.id_skladnika = a.id_skladnika) join zaloga z  on (a.id_zaloganta = z.id_zaloganta); 
       
select * from alergie_skladniki_xml_view;