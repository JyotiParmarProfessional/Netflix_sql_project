create database netflix_db;
select * from netflix;
select count(*) from netflix;
# 1. Count the number of Movies vs TV Shows
select type, count(*) from netflix group by type;
# 2. Find the most common rating for movies and TV shows
select type, rating from
(select type, rating, count(*), rank()over (partition by type order by count(*) desc)as ranking
from netflix
group by 1, 2 
order by 3 desc)as t1 where ranking =1;
-- 3. List all movies released in a specific year (e.g., 2020)
select title from netflix 
where type = 'Movie' and release_year = 2020;
-- 4. Find the top 5 countries with the most content on Netflix
WITH RECURSIVE numbers AS (
  SELECT 1 AS n
  UNION ALL
  SELECT n + 1 FROM numbers WHERE n < 50   # assuming not more then 50 contry are together
),
split_country AS (
  SELECT
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', n), ',', -1)) AS country
  FROM netflix
  JOIN numbers ON n <= CHAR_LENGTH(country) - CHAR_LENGTH(REPLACE(country, ',', '')) + 1
)
SELECT country, COUNT(*) AS total_content
FROM split_country
WHERE country IS NOT NULL AND country != ''
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;
-- 5. Identify the longest movie
SELECT title, duration
FROM netflix
WHERE type = 'Movie'
ORDER BY 
  CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC
LIMIT 1;
-- 6. Find content added in the last 5 years
select * from netflix
where str_to_date( date_added, '%M %d, %Y') >= curdate() - interval 5 year;
-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select * from netflix where lower(director) like '%rajiv chilaka%';
-- 8. List all TV shows with more than 5 seasons
select * from netflix 
where type = 'TV show' and duration > '5 seasons' ;
select *, SUBSTRING_INDEX(duration, ' ', 1) as season from netflix
where type = 'TV show' and  SUBSTRING_INDEX(duration, ' ', 1)>5;
-- 9. Count the number of content items in each genre
WITH RECURSIVE numbers AS (
  SELECT 1 AS n
  UNION ALL
  SELECT n + 1 FROM numbers WHERE n < 50   # assuming not more then 50 contry are together
),
split_genre AS (
  SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', n), ',', -1)) AS genre
  FROM netflix
  JOIN numbers ON n <= CHAR_LENGTH(listed_in) - CHAR_LENGTH(REPLACE(listed_in, ',', '')) + 1
)
SELECT genre, COUNT(*) AS total_content
FROM split_genre
WHERE genre IS NOT NULL AND genre != ''
group by genre;
-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !
select extract(year from str_to_date( date_added, '%M %d, %Y'))as year , count(*),
count(*) /(select count(*) from netflix where country = 'India')*100 as avg from netflix 
where country = 'India' group by year;
-- 11. List all movies that are documentaries
select * from netflix 
where type = 'Movie' and listed_in like '%Documentaries%';
-- 12. Find all content without a director
select * from netflix 
where  director is null;
-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
select * from netflix
where cast like '%Salman Khan%' and release_year > extract(year from curdate() );
-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
with recursive numbers as ( select 1 as n 
  union all 
  select n+1 from numbers where n < 50),
split_cast as (select trim(substring_index(substring_index(cast, ',', n), ",", -1)) as actor from netflix n
 join numbers on n <= char_length(cast) - char_length(replace(cast,",", '')) +1 
 where lower(n.country) like '%india%' and n.type = 'Movie' and n.cast is not null)
select actor, count(*)as total_movie from split_cast 
where actor is not null and actor != '' 
group by actor order by total_movie  desc limit 10;
 /*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/
with category as(select *, case 
      when lower(descriptions) like '%kill%' or
     lower(descriptions) like '%violence%' then 'Bad Content'
     else 'Good Content' end category from netflix)
select category , count(*) from category  group by category;
	
    
    













