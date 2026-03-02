--Netflix Project

drop table if exists netflix;
create table netflix
(
show_id	varchar(6),
type varchar(10),
title varchar(150),
director varchar(208),
casts varchar(1000),
country	varchar(150),
date_added varchar(50),
release_year Int,
rating	varchar(10),
duration varchar(15),
listed_in varchar(100),
description varchar(250)
);

select * from netflix;

select count(*) as total_content
from netflix;

select distinct type 
from netflix;

-- 15 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows
select type,count(*) as total_content
from netflix
group by type;

-- 2. Find the most common rating for movies and TV shows
with cte as(
  select type,rating,count(rating)as cnt 
  from netflix
  group by type,rating
)

select type,rating
from 
(
   select type,rating,
   row_number() over(partition by type order by cnt desc) as rnk
   from cte   
)
where rnk=1



-- 3. List all movies released in a specific year (e.g., 2020)
select *
from netflix
where type='Movie'
and release_year=2020

-- 4. Find the top 5 countries with the most content on Netflix
select
 unnest(string_to_array(country,',')) as new_country,
 count(*) as total_content
from netflix
group by new_country
order by total_content desc
limit 5;

-- 5. Identify the longest movie
with cte AS (
    SELECT 
        MAX(CAST(split_part(duration, ' ', 1) AS INT)) AS max_len
    FROM netflix
)
SELECT 
    title,max_len
FROM netflix
JOIN cte
ON CAST(split_part(duration, ' ', 1) AS INT) = cte.max_len;


-- 6. Find content added in the last 5 years

select *
from netflix
where to_date(date_added,'Month DD,YYYY')>=current_date-Interval '5 years'


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

with cte as(
select  *,unnest(string_to_array(director,',')) as direct
from netflix
)
select *
from cte 
where direct='Rajiv Chilaka'
--------------
select * 
from netflix
where director Ilike '%Rajiv Chilaka%'

-- 8. List all TV shows with more than 5 seasons
select *
from netflix
-- where substring(duration,1)>'5 Seasons' and duration not like '% min'
where type='TV Show' and substring(duration,1)>'5 Seasons';
-- where type='TV Show' and substring(duration,1,1)>'5';

SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND CAST(SPLIT_PART(duration, ' ', 1) AS INT) >5;
  
-- 9. Count the number of content items in each genre
select trim(unnest(string_to_array(listed_in,','))) as genre,count(*) as cnt
from netflix
group by 1



-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!

SELECT 
	country,
	release_year,
	COUNT(show_id) as total_release,
	ROUND(
		COUNT(show_id)::numeric/
								(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100 
		,2
		)
		as avg_release
FROM netflix
WHERE country = 'India' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5



-- 11. List all movies that are documentaries
select *
from netflix
where listed_in Ilike '%Documentaries%'

-- 12. Find all content without a director
select * 
from netflix
where director is null

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
-- select extract(year from (to_date(date_added,'Month DD,YYYY'))) as yr
-- from netflix
-- where type='Movie' and casts like '%Salman Khan%'

SELECT * FROM netflix
WHERE 
	casts LIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
select unnest(string_to_array(casts,',')) as actors,count(*) as cnt
from netflix
where country like '%India%' and type='Movie'
group by unnest(string_to_array(casts,','))
order by count(*) desc
limit 10

-- with cte as (
--     select 
--         unnest(string_to_array(casts, ',')) as actor
--     from netflix
--     where country like '%India%' and type='Movie'
-- )
-- select 
--     trim(actor) as actor,
--     count(*) as cnt
-- from cte
-- group by actor
-- order by cnt desc
-- limit 10;


-- 15.
-- Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2
