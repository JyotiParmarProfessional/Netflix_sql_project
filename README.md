# Netflix Movies and TV Shows Data Analysis using SQL
![Netflix logo](https://github.com/JyotiParmarProfessional/Netflix_sql_project/blob/main/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
CREATE DATABASE Netflix_db
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```
Can upload file directaly without creating table.

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
select
 type, count(*)
from netflix
group by type;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
select type,
 rating from
  (select type,
   rating, count(*),
   rank()over (partition by type order by count(*) desc)as ranking
 from netflix
 group by 1, 2 
 order by 3 desc)as t1
where ranking =1;
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
select
 title
from netflix 
where type = 'Movie'
 and release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
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
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT
 title,
 duration
FROM netflix
WHERE type = 'Movie'
ORDER BY 
  CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC
LIMIT 1;
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
select *
from netflix
where str_to_date( date_added, '%M %d, %Y') >= curdate() - interval 5 year;
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
select *
from netflix
where lower(director) like '%rajiv chilaka%';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
select *
from netflix 
where type = 'TV show'
 and duration > '5 seasons' ;

select *,
 SUBSTRING_INDEX(duration, ' ', 1) as season
from netflix
where type = 'TV show'
 and  SUBSTRING_INDEX(duration, ' ', 1)>5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
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
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
select
 extract(year from str_to_date( date_added, '%M %d, %Y'))as year ,
 count(*),
 count(*) /(select count(*) from netflix where country = 'India')*100 as avg
from netflix 
where country = 'India'
group by year;
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
select *
from netflix 
where type = 'Movie'
 and listed_in like '%Documentaries%';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT * 
FROM netflix
WHERE director IS NULL;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
select *
from netflix
where cast like '%Salman Khan%'
 and release_year > extract(year from curdate() ) -10;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
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
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.
