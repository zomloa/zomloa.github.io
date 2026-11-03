-- =====================================================================
-- Accidents de la route dans la Capitale-Nationale (2011-2022)
-- Analyses SQL (SQLite) - base : donnees/accidents.db, table : accidents
-- Source des données : Rapports d'accident, SAAQ (Données Québec)
-- =====================================================================


-- ---------------------------------------------------------------------
-- 0. Contrôles (réconciliation avec Python)
-- ---------------------------------------------------------------------

-- Aperçu des 10 premières lignes
SELECT * FROM accidents LIMIT 10;

-- Nombre total d'accidents (attendu : 1 717 407)
SELECT COUNT(*) FROM accidents;

-- Nombre d'accidents dans la Capitale-Nationale (attendu : 163 578)
SELECT COUNT(*) FROM accidents
WHERE TERRITOIRE = 'Capitale-Nationale';


-- ---------------------------------------------------------------------
-- Q1. Évolution du nombre d'accidents dans le temps
-- ---------------------------------------------------------------------

-- Nombre d'accidents par année, tout le Québec
SELECT AN, COUNT(*) AS nb_accidents
FROM accidents
GROUP BY AN
ORDER BY AN;

-- Nombre d'accidents par année, Capitale-Nationale
SELECT AN, COUNT(*) AS nb_accidents
FROM accidents
WHERE TERRITOIRE = 'Capitale-Nationale'
GROUP BY AN
ORDER BY AN;


-- ---------------------------------------------------------------------
-- Q2. Gravité : Capitale-Nationale vs reste du Québec
-- ---------------------------------------------------------------------

-- Part des accidents graves par année, Capitale-Nationale
SELECT AN,
       COUNT(*) AS nb_accidents,
       SUM(GRAVE) AS nb_graves,
       ROUND(AVG(GRAVE) * 100, 2) AS pct_graves
FROM accidents
WHERE TERRITOIRE = 'Capitale-Nationale'
GROUP BY AN
ORDER BY AN;

-- Part des accidents graves par territoire, 2011-2022
-- Résultat : Capitale-Nationale 0,95 %, reste du Québec 1,14 %
SELECT TERRITOIRE,
       COUNT(*) AS nb_accidents,
       SUM(GRAVE) AS nb_graves,
       ROUND(AVG(GRAVE) * 100, 2) AS pct_graves
FROM accidents
GROUP BY TERRITOIRE;

-- Part des accidents graves par année et par territoire
-- (règle : toute colonne non calculée du SELECT doit être dans le GROUP BY)
SELECT AN, TERRITOIRE,
       COUNT(*) AS nb_accidents,
       SUM(GRAVE) AS nb_graves,
       ROUND(AVG(GRAVE) * 100, 2) AS pct_graves
FROM accidents
GROUP BY AN, TERRITOIRE
ORDER BY AN, TERRITOIRE;


-- ---------------------------------------------------------------------
-- Q3. Hiver : part des accidents graves selon l'état de la chaussée
-- ---------------------------------------------------------------------

-- Capitale-Nationale. HAVING écarte les catégories de moins de 1 000 accidents
SELECT ETAT_SURFACE,
       COUNT(*) AS nb_accidents,
       ROUND(AVG(GRAVE) * 100, 2) AS pct_graves
FROM accidents
WHERE TERRITOIRE = 'Capitale-Nationale'
GROUP BY ETAT_SURFACE
HAVING COUNT(*) >= 1000
ORDER BY pct_graves DESC;


-- ---------------------------------------------------------------------
-- Q5. Usagers vulnérables : les piétons
-- ---------------------------------------------------------------------

-- À écrire : dans la Capitale-Nationale, les accidents impliquant un piéton
-- (IND_PIETON = 'O') sont-ils plus souvent graves que les autres ?

SELECT IND_PIETON,
       COUNT(*) AS nb_accidents,
       SUM(GRAVE) AS nb_graves,
       ROUND(AVG(GRAVE) * 100, 2) AS pct_graves
FROM accidents
WHERE TERRITOIRE = 'Capitale-Nationale'
GROUP BY IND_PIETON;

-- Résultat : accident avec piéton grave dans 15,94 % des cas, contre 0,75 % (environ 21 fois plus).
-- Les accidents avec piéton = 1,3 % du total, mais 22 % des accidents graves de la région (346 sur 1 562).


-- ---------------------------------------------------------------------
-- Q4. Moments à risque : part des accidents graves selon la tranche horaire
-- ---------------------------------------------------------------------

-- À écrire : dans la Capitale-Nationale, quelle tranche horaire (HR_ACCDN)
-- a la plus forte part d'accidents graves ? (la plus grave en premier)

SELECT HR_ACCDN,
       COUNT(*) AS nb_accidents,
       ROUND(AVG(GRAVE) * 100, 2) AS pct_graves
FROM accidents
WHERE TERRITOIRE = 'Capitale-Nationale'
GROUP BY HR_ACCDN
ORDER BY pct_graves DESC;

-- Résultat : la nuit (00 h-04 h) compte le moins d'accidents (8 225) mais la plus forte part de graves (1,40 %),
-- presque deux fois plus que le matin 08 h-12 h (0,77 %). Heure non précisée : 4 262 accidents, écartés de la conclusion.
