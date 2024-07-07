-- Requirement:
--   Pivot the Occupation column in OCCUPATIONS so that each Name is sorted
--   alphabetically and displayed underneath its corresponding Occupation.
--   The output column headers should be Doctor, Professor, Singer, and Actor,
--   respectively.

-- Note: Print NULL when there are no more names corresponding to an occupation.

create table occupations
(
    name       varchar(255),
    occupation varchar(255)
);

-- check mysql import file path
SHOW VARIABLES LIKE 'secure_file_priv';

truncate occupations;

load data infile '/data/occupations.csv' into table occupations
    FIELDS TERMINATED BY ' '
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES;

-- solution 1:
SET @row_number := 0;
set @prev_category := null;
select MAX(IF(OCCUPATION = 'Doctor', name, NULL))    AS 'Doctor',
       MAX(IF(OCCUPATION = 'Professor', name, NULL)) AS 'Professor',
       MAX(IF(OCCUPATION = 'Singer', name, NULL))    AS 'Singer',
       MAX(IF(OCCUPATION = 'Actor', name, NULL))     AS 'Actor'
from (select name,
             OCCUPATION,
             (@row_number := IF(@prev_category = OCCUPATION, @row_number + 1, 1)) AS row_num,
             @prev_category := OCCUPATION
      FROM occupations,
           (SELECT @row_number := 0, @prev_category := NULL) AS vars
      ORDER BY OCCUPATION, name) AS subquery
group by row_num;

-- solution 2:
SELECT MAX(CASE WHEN Occupation = 'Doctor' THEN Name END)    AS Doctor,
       MAX(CASE WHEN Occupation = 'Professor' THEN Name END) AS Professor,
       MAX(CASE WHEN Occupation = 'Singer' THEN Name END)    AS Singer,
       MAX(CASE WHEN Occupation = 'Actor' THEN Name END)     AS Actor
FROM (SELECT Name,
             Occupation,
             ROW_NUMBER() OVER (PARTITION BY Occupation ORDER BY Name) AS row_num
      FROM occupations) AS sub
GROUP BY row_num;

SELECT Name,
       Occupation,
       row_number() over (PARTITION BY occupation order by name) AS row_num
FROM occupations

