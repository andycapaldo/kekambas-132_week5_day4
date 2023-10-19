-- Question 1

-- Testing it out outside of the procedure first by adding an absolutley GOATED film
SELECT *
FROM film;

INSERT INTO film (title, description, release_year, language_id, rental_duration, rental_rate, length, replacement_cost, rating)
VALUES (
	'There Will Be Blood', 
	'A story of family, religion, hatred, oil and madness, focusing on a turn-of-the-century prospector in the early days of the business.',
	2007,
	1,
	7,
	8.99,
	158,
	23.99,
	'R'
	);
	
SELECT *
FROM film
ORDER BY film_id DESC;


-- Creating the procedure 

CREATE OR REPLACE PROCEDURE insert_new_film (
	title VARCHAR(225), 
	description TEXT, 
	release_year YEAR,
	language_id INTEGER,
	rental_duration INTEGER, 
	rental_rate NUMERIC(4,2),
	length INTEGER,
	replacement_cost NUMERIC(5,2),
	rating MPAA_RATING
)
LANGUAGE plpgsql
AS $insert_new_film$
BEGIN 
	INSERT INTO film (title, description, release_year, language_id, rental_duration, rental_rate, length, replacement_cost, rating)
	VALUES (title, description, release_year, language_id, rental_duration, rental_rate, length, replacement_cost, rating);
END
$insert_new_film$


-- Testing to see if the procedure works by adding yet another GOATED film

CALL insert_new_film(
	'L.A. Confidential', 
	'As corruption grows in 1950s Los Angeles, three policemen - one straight-laced, one brutal, and one sleazy
	 - investigate a series of murders with their own brand of justice.',
	 1997,
	 1,
	 5,
	 7.99,
	 138,
	 22.99,
	 'R'
	 );
	
-- Calling the bottom of the list to see if the film was properly added after the procedure call
SELECT *
FROM film
ORDER BY film_id DESC;




-- Question 2

-- For starters, we'll need to create a SQL statement that returns the number of films in each category
SELECT category.category_id, category.name, COUNT(*) AS num_films
FROM film_category
JOIN category
ON film_category.category_id = category.category_id
GROUP BY category.category_id, category.name 
ORDER BY COUNT(*) DESC;


-- Now, we can change it so that it just returns a specific category based on a category_id input
SELECT COUNT(*) AS num_films
FROM film_category
JOIN category
ON film_category.category_id = category.category_id
GROUP BY category.category_id, category.name 
HAVING category.category_id = 15;


-- Now, we can create a function
CREATE OR REPLACE FUNCTION get_films_in_category(category_id_selection INTEGER) -- This STORED FUNCTION will RETURN ALL films ACCORDING TO a category_id
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
	DECLARE num_films INTEGER;
BEGIN
	SELECT COUNT(*) INTO num_films
	FROM film_category
	JOIN category
	ON film_category.category_id = category.category_id
	GROUP BY category.category_id, category.name 
	HAVING category.category_id = category_id_selection;
	RETURN num_films;
END;
$$;



SELECT get_films_in_category(15); -- 74
SELECT get_films_in_category(1); -- 64
SELECT get_films_in_category(6); -- 68
SELECT get_films_in_category(11); -- 56


-- So, the above function works! It takes in a category_id as an argument, and returns all of the films in that category.
-- To expand on this and have the function return the name of the category as well as the ID and count of films, we can make another function.
-- This function will have to return a table since we want to pull more columns from our selection.

CREATE OR REPLACE FUNCTION get_more_info_from_films_in_category(category_id_selection INTEGER)
RETURNS TABLE (
	category_id INTEGER,
	name VARCHAR(25),
	num_films INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN 
	RETURN QUERY -- We want TO RETURN a QUERY since we ARE querying FROM a TABLE 
	SELECT category.category_id, category.name, COUNT(*)::INTEGER AS num_films    -- Was getting errors BEFORE I casted the COUNT(*) RESULT TO an INTEGER TYPE!
	FROM film_category
	JOIN category
	ON film_category.category_id = category.category_id
	GROUP BY category.category_id, category.name 
	HAVING category.category_id = category_id_selection;
END;
$$;

SELECT *
FROM get_more_info_from_films_in_category(15);  -- After getting several errors due to COUNT(*) returning a BIGINT datatype, I finally got this to work and return these 3 cols. 

--|category_id|name  |num_films|
--|-----------|------|---------|
--|15         |Sports|74       |


SELECT *
FROM get_more_info_from_films_in_category(7); 

--|category_id|name |num_films|
--|-----------|-----|---------|
--|7          |Drama|62       |


SELECT *
FROM get_more_info_from_films_in_category(5); 

--|category_id|name  |num_films|
--|-----------|------|---------|
--|5          |Comedy|58       |


