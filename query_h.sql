-- Actor–Director h-Index (distinct films) with total‐films counter and row number

.headers on
.mode column

WITH
  -- 1) Only “solid” feature films
  FilteredMovies AS (
    SELECT t.title_id
    FROM titles t
    JOIN ratings r USING (title_id)
    WHERE t.type = 'movie'
      AND t.is_adult = 0
      AND t.runtime_minutes >= 60
--      AND r.votes >= 1000
--      AND r.rating >= 6.0
      AND LOWER(t.genres) NOT LIKE '%animation%'
      AND LOWER(t.genres) NOT LIKE '%anime%'
      AND LOWER(t.genres) NOT LIKE '%cartoon%'
  ),

  -- 2) Every film per director (distinct)
  DirectorFilms AS (
    SELECT DISTINCT
      dir.person_id  AS director_id,
      dir.title_id
    FROM crew dir
    JOIN FilteredMovies fm
      ON dir.title_id = fm.title_id
    WHERE dir.category = 'director'
  ),

  -- 3) Count DISTINCT films per director–actor duo
  CollabCounts AS (
    SELECT
      df.director_id,
      act.person_id  AS actor_id,
      COUNT(DISTINCT df.title_id) AS collab_count
    FROM DirectorFilms df
    JOIN crew act
      ON df.title_id = act.title_id
     AND act.category = 'actor'
    GROUP BY df.director_id, act.person_id
  ),

  -- 4) Rank each actor for each director by collab_count
  RankedActorCollabs AS (
    SELECT
      director_id,
      actor_id,
      collab_count,
      ROW_NUMBER() OVER (
        PARTITION BY director_id
        ORDER BY collab_count DESC
      ) AS actor_rank
    FROM CollabCounts
  ),

  -- 5) Compute h-index per director
  DirectorHIndex AS (
    SELECT
      director_id,
      MAX(
        CASE
          WHEN collab_count >= actor_rank THEN actor_rank
          ELSE 0
        END
      ) AS h_index
    FROM RankedActorCollabs
    GROUP BY director_id
  ),

  -- 6) Total number of DISTINCT filtered films per director
  DirectorTotalFilms AS (
    SELECT
      director_id,
      COUNT(*) AS total_films
    FROM DirectorFilms
    GROUP BY director_id
  ),

  -- 7) Rank directors by descending h-index (tie-break by total_films)
  RankedDirectors AS (
    SELECT
      dhi.director_id,
      dhi.h_index,
      dtf.total_films,
      ROW_NUMBER() OVER (
        ORDER BY dhi.h_index DESC, dtf.total_films DESC
      ) AS rank
    FROM DirectorHIndex dhi
    JOIN DirectorTotalFilms dtf
      ON dhi.director_id = dtf.director_id
  )

-- 8) Final output
SELECT
  rd.rank,
  p.name                         AS director,
  rd.h_index                     AS actor_director_h_index,
  rd.total_films
FROM RankedDirectors rd
JOIN people p
  ON rd.director_id = p.person_id
ORDER BY rd.rank
LIMIT 4000;

