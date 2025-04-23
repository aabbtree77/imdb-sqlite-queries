-- Top actor–director pairs, plus second-best when a director’s #1 is themselves

.headers on
.mode column

WITH
  -- 1) “Solid” feature films
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

  -- 2) Distinct films per director
  DirectorFilms AS (
    SELECT DISTINCT
      dir.person_id AS director_id,
      dir.title_id
    FROM crew dir
    JOIN FilteredMovies fm USING (title_id)
    WHERE dir.category = 'director'
  ),

  -- 3) Collaboration counts per (director, actor)
  CollabCounts AS (
    SELECT
      df.director_id,
      act.person_id AS actor_id,
      COUNT(DISTINCT df.title_id) AS films_together
    FROM DirectorFilms df
    JOIN crew act
      ON df.title_id = act.title_id
     AND act.category = 'actor'
    GROUP BY df.director_id, act.person_id
  ),

  -- 4) Rank actors for each director
  ActorRanks AS (
    SELECT
      director_id,
      actor_id,
      films_together,
      ROW_NUMBER() OVER (
        PARTITION BY director_id
        ORDER BY films_together DESC
      ) AS rk
    FROM CollabCounts
  ),

  -- 5) Identify self-directors (their top-ranked actor is themselves)
  SelfDirectors AS (
    SELECT director_id
    FROM ActorRanks
    WHERE rk = 1
      AND actor_id = director_id
  ),

  -- 6) Pull rank = 1 for everyone, plus rank = 2 for self-directors
  TopPairs AS (
    SELECT director_id, actor_id, films_together
    FROM ActorRanks
    WHERE rk = 1
    UNION ALL
    SELECT director_id, actor_id, films_together
    FROM ActorRanks
    WHERE rk = 2
      AND director_id IN (SELECT director_id FROM SelfDirectors)
  ),

  -- 7) Total number of distinct filtered films per director
  DirectorTotalFilms AS (
    SELECT
      director_id,
      COUNT(*) AS total_films
    FROM DirectorFilms
    GROUP BY director_id
  ),

  -- 8) Global ranking of all these pairs
  RankedPairs AS (
    SELECT
      ROW_NUMBER() OVER (
        ORDER BY tp.films_together DESC, dtf.total_films DESC
      ) AS rank,
      tp.director_id,
      tp.actor_id,
      tp.films_together,
      dtf.total_films
    FROM TopPairs tp
    JOIN DirectorTotalFilms dtf
      ON tp.director_id = dtf.director_id
  )

-- 9) Final output
SELECT
  rp.rank,
  pdir.name     AS director,
  pact.name     AS actor,
  rp.films_together,
  rp.total_films
FROM RankedPairs rp
JOIN people pdir ON rp.director_id = pdir.person_id
JOIN people pact ON rp.actor_id    = pact.person_id
ORDER BY rp.rank
LIMIT 10000;

