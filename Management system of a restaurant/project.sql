SELECT * FROM CLIENTI_AOL;
SELECT * FROM COMENZI_AOL
ORDER BY data_emitere;
SELECT * FROM MENIURI_AOL;
SELECT * FROM PREPARATE_AOL;
SELECT * FROM OFERTE_AOL
ORDER BY id_furnizor;
SELECT * FROM FURNIZORI_AOL;

INSERT INTO FURNIZORI_AOL
VALUES(108, 'Obiceiuri gustoase', 'Pitesti');

INSERT INTO CLIENTI_AOL
VALUES(8, 'Constantin', 'Tudor', '18-SEP-1983');
INSERT INTO CLIENTI_AOL
VALUES(9, 'Ion', 'Andreea', '23-MAR-2000');
INSERT INTO CLIENTI_AOL
VALUES(10, 'Marin', 'Cristian', '20-JUN-2001');


INSERT INTO COMENZI_AOL
VALUES(30, NULL, SYSDATE+1, 8, 3);
INSERT INTO COMENZI_AOL
VALUES(31, NULL, SYSDATE+1, 9, 5);
INSERT INTO COMENZI_AOL
VALUES(43, 'dulceata de caise', SYSDATE + 2, 3, 6);
INSERT INTO COMENZI_AOL
VALUES(40, NULL, SYSDATE + 2, 5, 2);
INSERT INTO COMENZI_AOL
VALUES(52, NULL, SYSDATE + 3, 6, 4);
INSERT INTO COMENZI_AOL
VALUES(54, NULL, SYSDATE + 3, 9, 7);
INSERT INTO COMENZI_AOL
VALUES(45, 'fara legume', SYSDATE + 2, 8, 2);
INSERT INTO COMENZI_AOL
VALUES(32, NULL, SYSDATE+1, 10, 1);
INSERT INTO COMENZI_AOL
VALUES(42, NULL, SYSDATE+2, 10, 6);





--1 Sa se afiseze toti clientii care au comandat meniul 3 sau 7 si ale caror prenume incep cu litera A
SELECT id_client, nume, prenume
FROM clienti_aol
JOIN comenzi_aol USING(id_client)
WHERE (id_meniu = 3 OR id_meniu = 7) AND UPPER(prenume) LIKE 'A%';

--2 Sa se afiseze detaliile comenzilor, numele, prenumele si varsta clientilor cu varsta mai mare de 20 de ani, astfel daca nu exista precizari, se afiseaza 'fara detalii', altfel se afiseaza detaliile.
SELECT nume, prenume, id_comanda, NVL2(detalii,detalii,'fara detalii') AS detalii_comanda, TRUNC(months_between(sysdate,data_nastere)/12) AS varsta
FROM comenzi_aol
JOIN clienti_aol USING(id_client)
WHERE TRUNC(months_between(sysdate,data_nastere)/12) > 20;

--3 Sa se afiseze furnizorii, ofertele facute de acestia si preparatele din oferte care corespund meniurilor comandate pe 22 iunie de clientul al carui prenume se termina cu 'a'.
--Sa se ordoneze dupa id-ul furnizorilor
SELECT DISTINCT(f.id_furnizor), f.nume, f.locatie, o.id_oferta, o.pret, p.denumire
FROM furnizori_aol f
JOIN oferte_aol o ON(f.id_furnizor = o.id_furnizor)
JOIN preparate_aol p ON(p.id_preparat = o.id_preparat)
JOIN meniuri_aol m ON(m.id_meniu = p.id_meniu)
JOIN comenzi_aol c ON(c.id_meniu = m.id_meniu)
JOIN clienti_aol cl ON(cl.id_client = c.id_client)
WHERE TO_DATE(c.data_emitere, 'dd-mon-yy') = TO_DATE('22-JUN-2020', 'dd-mon-yy') and SUBSTR(LOWER(cl.prenume),-1)= 'a'
ORDER BY f.id_furnizor;

--4 Se cer meniurile care contin sarmale sau cartofi prajiti sau care au fost comandate de clientul Ion Andreea
SELECT m.denumire, m.pret, m.durata_pregatire
FROM meniuri_aol m
JOIN preparate_aol p ON(m.id_meniu = p.id_meniu)
WHERE LOWER(p.denumire) LIKE 'sarmale' or LOWER(p.denumire) LIKE 'cartofi prajiti'
UNION
SELECT denumire, pret, durata_pregatire
FROM meniuri_aol
JOIN comenzi_aol USING(id_meniu)
JOIN clienti_aol USING(id_client)
WHERE LOWER(nume) LIKE 'ion' AND LOWER(prenume) LIKE 'andreea';

--5 Afisati clientii care au vizitat restaurantul in aceleasi zile precum clienta Vacaru Alexandra. Clienta Vacaru Alexandra va fi exclusa.
SELECT nume, prenume, data_emitere
FROM clienti_aol
JOIN comenzi_aol USING(id_client)
WHERE TO_DATE(data_emitere,'dd-mon-yy') IN (SELECT TO_DATE(data_emitere,'dd-mon-yy')
                                            FROM comenzi_aol
                                            JOIN clienti_aol USING(id_client)
                                            WHERE LOWER(nume) LIKE 'vacaru' and LOWER(prenume) LIKE 'alexandra' )
AND LOWER(nume)<> 'vacaru' and LOWER(prenume)<> 'alexandra';
                                            
--6 Afisati furnizorii ale caror oferte individuale au pretul mai mare decat media tuturor ofertelor furnizorilor din Bucuresti. Sortati descrescator dupa pretul ofertei.
SELECT nume, pret
FROM furnizori_aol
JOIN oferte_aol USING(id_furnizor)
WHERE pret > ALL (SELECT AVG(pret)
                    FROM oferte_aol
                    JOIN furnizori_aol USING(id_furnizor)
                    WHERE UPPER(locatie) LIKE '%BUCURESTI%')
ORDER BY 2 DESC;

--7 Afisati clientii care au mancat la restaurant in ziua in care au fost cele mai multe comenzi. Afisati si ziua din saptamana si denumiti coloana "Zi productiva".
SELECT nume, prenume, TO_CHAR(data_emitere, 'Day') "Zi productiva"
FROM clienti_aol
JOIN comenzi_aol USING(id_client)
WHERE TO_CHAR(data_emitere, 'DD-MON-YY') = (SELECT TO_CHAR(data_emitere,'DD-MON-YY')
                                            FROM comenzi_aol
                                            GROUP BY TO_CHAR(data_emitere, 'DD-MON-YY')
                                            HAVING COUNT(id_comanda) = (SELECT MAX(COUNT(id_comanda))
                                                                        FROM comenzi_aol
                                                                        GROUP BY TO_CHAR(data_emitere, 'DD-MON-YY')));
                                                                    
--8 Afisati furnizorii si ofertele lor. Se vor afisa si furnizorii care nu au propus oferte. Ordonati dupa numele furnizorilor.
SELECT nume, id_oferta, pret, id_preparat
FROM furnizori_aol
LEFT JOIN oferte_aol USING(id_furnizor)
ORDER BY 1;

--9 Afisati clientii care au comandat meniul cu cele mai multe preparate. Afisati denumirea meniului si numarul de preparate al acestuia.
SELECT nume, prenume, meniuri_aol.denumire, COUNT(id_preparat) "Nr_preparate"
FROM clienti_aol
JOIN comenzi_aol USING(id_client)
JOIN meniuri_aol USING(id_meniu)
JOIN preparate_aol USING(id_meniu)
GROUP BY meniuri_aol.denumire, nume, prenume
HAVING COUNT(id_preparat) = (SELECT MAX(COUNT(id_preparat))
                                FROM preparate_aol
                                GROUP BY id_meniu); 

--10 Sa se afiseze numarul total de oferte si numarul ofertelor pentru preparatele cu denumirile mamaliga, legume sote, piure de cartofi, muraturi, papanasi. Denumiti coloanele sugestiv.
SELECT COUNT(id_oferta) AS "Nr oferte", 
    SUM(DECODE(denumire, 'mamaliga', 1, 0)) AS "mamaliga",
    SUM(DECODE(denumire, 'legume sote', 1, 0)) AS "legume sote",
    SUM(DECODE(denumire, 'piure de cartofi', 1, 0)) AS "piure de cartofi",
    SUM(DECODE(denumire, 'muraturi', 1, 0)) AS "muraturi",
    SUM(DECODE(denumire, 'papanasi', 1, 0)) AS "papanasi"   
FROM oferte_aol
JOIN preparate_aol USING(id_preparat);

--11 Sa se afiseze numarul de oferte pentru fiecare preparat, inclusiv preparatele care nu au fost introduse intr-o oferta.
SELECT denumire, COUNT(id_oferta) "Numar oferte"
FROM oferte_aol
RIGHT JOIN preparate_aol USING(id_preparat)
GROUP BY id_preparat, denumire;
       
--12 Afisati primele 2 oferte cele mai avantajoase pentru preparatul sarmale.
SELECT *
FROM (SELECT id_oferta, pret 
      FROM oferte_aol
      JOIN preparate_aol USING(id_preparat)
      WHERE denumire = 'sarmale'
      ORDER BY pret)
WHERE ROWNUM <= 2;

--13 Afisati clientii care au comandat aceleasi meniuri ca si clientul cu id-ul 3. Afisati si meniurile.
SELECT c.nume, c.prenume, c.id_client, co.id_meniu
FROM clienti_aol c
JOIN comenzi_aol co ON(c.id_client = co.id_client)
WHERE NOT EXISTS(SELECT id_meniu
                FROM comenzi_aol 
                WHERE id_client = 3
                MINUS 
                (SELECT id_meniu
                FROM comenzi_aol 
                WHERE id_client = c.id_client)) AND
                NOT EXISTS(SELECT id_meniu
                            FROM comenzi_aol 
                            WHERE id_client = c.id_client 
                            MINUS 
                            SELECT id_meniu 
                            FROM comenzi_aol
                            WHERE id_client = 3)
AND c.id_client != 3;
                            
--14 Afisati clientii care au mancat la restaurant intre 2 date introduse de catre utilizator. Concatenati numele si prenumele clientilor.
ACCEPT p_data1 PROMPT 'Data de inceput:'
ACCEPT p_data2 PROMPT 'Data de sfarsit:'
SELECT DISTINCT nume || ' ' || prenume
FROM clienti_aol
JOIN comenzi_aol USING(id_client)
WHERE data_emitere BETWEEN TO_DATE('&p_data1','DD-MON-YY') AND TO_DATE('&p_data2','DD-MON-YY');


--15 Afisati timpul de pregatire total al meniurilor din data introdusa de utilizator.
ACCEPT p_data PROMPT 'Data:'
SELECT SUM(durata_pregatire) "Timp total de pregatire(min)"
FROM meniuri_aol
JOIN comenzi_aol USING(id_meniu)
JOIN clienti_aol USING(id_client)
WHERE TO_DATE(data_emitere,'DD-MON-YY') = TO_DATE('&p','DD-MON-YY');

--16 Sa se afiseze suma totala ceruta pentru toate preparatele de catre furnizorii al caror nume are lungime mai mare decat 10.
SELECT id_furnizor, nume, locatie, SUM(pret)
FROM furnizori_aol
JOIN oferte_aol USING(id_furnizor)
JOIN preparate_aol USING(id_preparat)
WHERE LENGTH(nume)>10
GROUP BY locatie, nume, id_furnizor;




