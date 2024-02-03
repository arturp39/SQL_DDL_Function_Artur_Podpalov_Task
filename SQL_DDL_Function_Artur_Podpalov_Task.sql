--1

CREATE OR REPLACE VIEW sales_revenue_by_category_qtr AS
SELECT
    c.name AS category,
    SUM(p.amount) AS total_sales_revenue
FROM
    payment p
JOIN
    rental r ON p.rental_id = r.rental_id
JOIN
    inventory i ON r.inventory_id = i.inventory_id
JOIN
    film f ON i.film_id = f.film_id
JOIN
    film_category fc ON f.film_id = fc.film_id
JOIN
    category c ON fc.category_id = c.category_id
WHERE
    p.payment_date >= date_trunc('quarter', current_date)
GROUP BY
    c.name;
	
--2

CREATE OR REPLACE FUNCTION get_sales_revenue_by_category_qtr(p_current_quarter date)
RETURNS TABLE (category text, total_sales_revenue numeric)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.name AS category,
        SUM(p.amount) AS total_sales_revenue
    FROM
        payment p
    JOIN
        rental r ON p.rental_id = r.rental_id
    JOIN
        inventory i ON r.inventory_id = i.inventory_id
    JOIN
        film f ON i.film_id = f.film_id
    JOIN
        film_category fc ON f.film_id = fc.film_id
    JOIN
        category c ON fc.category_id = c.category_id
    WHERE
        p.payment_date >= date_trunc('quarter', p_current_quarter)
    GROUP BY
        c.name;

    RETURN;
END;
$$ LANGUAGE plpgsql;


--3
CREATE OR REPLACE PROCEDURE new_movie(movie_title VARCHAR)
LANGUAGE plpgsql
AS $$
DECLARE
    new_film_id INT;
    s_language_id INT;
BEGIN
    SELECT COALESCE(MAX(film_id), 0) + 1 INTO new_film_id FROM film;

    SELECT language_id INTO s_language_id
    FROM language
    WHERE name = 'Klingon';

    IF s_language_id IS NULL THEN
        RAISE EXCEPTION 'Language "Klingon" does not exist in the language table.';
    END IF;

    INSERT INTO film (film_id, title, rental_rate, rental_duration, replacement_cost, release_year, language_id)
    VALUES (new_film_id, movie_title, 4.99, 3, 19.99, EXTRACT(YEAR FROM CURRENT_DATE), s_language_id);
END;
$$;

CALL new_movie('The Lord of the Rings');

