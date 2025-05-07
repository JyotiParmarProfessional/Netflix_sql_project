-- Business Problems and Solutions

-- 1. Count the Number of Movies vs TV Shows
select
 type, count(*)
from netflix
group by type;

-- 2. Find the Most Common Rating for Movies and TV Shows
select type,
 rating from
  (select type,
   rating, count(*),
   rank()over (partition by type order by count(*) desc)as ranking
 from netflix
 group by 1, 2 
 order by 3 desc)as t1
where ranking =1;

-- 3. List All Movies Released in a Specific Year (e.g., 2020)
select
 title
from netflix 
where type = 'Movie'
 and release_year = 2020;

-- 4. Find the Top 5 Countries with the Most Content on Netflix
WITH RECURSIVE numbers AS (
  SELECT 1 AS n
UNION ALL
  SELECT n + 1 FROM numbers
  WHERE n < 50   # assuming not more then 50 contry are together
),
split_country AS (
  SELECT
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', n), ',', -1)) AS country
  FROM netflix
  JOIN numbers ON n <= CHAR_LENGTH(country) - CHAR_LENGTH(REPLACE(country, ',', '')) + 1
)
SELECT
 country,
 COUNT(*) AS total_content
FROM split_country
WHERE country IS NOT NULL AND country != ''
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;

-- 5. Identify the Longest Movie
SELECT
 title,
 duration
FROM netflix
WHERE type = 'Movie'
ORDER BY 
  CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC
LIMIT 1;

-- 6. Find Content Added in the Last 5 Years
select *
from netflix
where str_to_date( date_added, '%M %d, %Y') >= curdate() - interval 5 year;

-- 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
select *
from netflix
where lower(director) like '%rajiv chilaka%';

-- 8. List All TV Shows with More Than 5 Seasons
select *
from netflix 
where type = 'TV show'
 and duration > '5 seasons' ;

select *,
 SUBSTRING_INDEX(duration, ' ', 1) as season
from netflix
where type = 'TV show'
 and  SUBSTRING_INDEX(duration, ' ', 1)>5;

-- 9. Count the Number of Content Items in Each Genre
WITH RECURSIVE numbers AS (
  SELECT 1 AS n
UNION ALL
  SELECT n + 1
 FROM numbers
 WHERE n < 50   # assuming not more then 50 contry are together
),
split_genre AS (
  SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', n), ',', -1)) AS genre
  FROM netflix
  JOIN numbers ON n <= CHAR_LENGTH(listed_in) - CHAR_LENGTH(REPLACE(listed_in, ',', '')) + 1
)
SELECT
 genre,
 COUNT(*) AS total_content
FROM split_genre
WHERE genre IS NOT NULL AND genre != ''
group by genre;

-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!
select
 extract(year from str_to_date( date_added, '%M %d, %Y'))as year ,
 count(*),
 count(*) /(select count(*) from netflix where country = 'India')*100 as avg
from netflix 
where country = 'India'
group by year;

-- 11. List All Movies that are Documentaries
select *
from netflix 
where type = 'Movie'
 and listed_in like '%Documentaries%';

-- 12. Find All Content Without a Director
SELECT * 
FROM netflix
WHERE director IS NULL;

-- 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Year
select *
from netflix
where cast like '%Salman Khan%'
 and release_year > extract(year from curdate() ) -10;

-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
with recursive numbers as (
  select 1 as n 
union all 
  select n+1 from numbers where n < 50),
split_cast as (
 select
  trim(substring_index(substring_index(cast, ',', n), ",", -1)) as actor
from netflix n
join numbers on n <= char_length(cast) - char_length(replace(cast,",", '')) +1 
 where lower(n.country) like '%india%'
  and n.type = 'Movie'
  and n.cast is not null)
select
 actor,
 count(*)as total_movie
from split_cast 
where actor is not null and actor != '' 
group by actor
order by total_movie desc
limit 10;

-- 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
with category as(
 select *,
  case when
           lower(descriptions) like '%kill%' or
           lower(descriptions) like '%violence%' then 'Bad Content'
           else 'Good Content'
       end category
from netflix)
select
 category ,
 count(*)
from category
group by category;

    
    













