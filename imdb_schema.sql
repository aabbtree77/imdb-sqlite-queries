CREATE TABLE people (
  person_id VARCHAR PRIMARY KEY,
  name VARCHAR,
  born INTEGER,
  died INTEGER
);
CREATE TABLE titles (
  title_id VARCHAR PRIMARY KEY,
  type VARCHAR,
  primary_title VARCHAR,
  original_title VARCHAR,
  is_adult INTEGER,
  premiered INTEGER,
  ended INTEGER,
  runtime_minutes INTEGER,
  genres VARCHAR
);
CREATE TABLE akas (
  title_id VARCHAR,
  title VARCHAR,
  region VARCHAR,
  language VARCHAR,
  types VARCHAR,
  attributes VARCHAR,
  is_original_title INTEGER
);
CREATE TABLE crew (
  title_id VARCHAR,
  person_id VARCHAR,
  category VARCHAR,
  job VARCHAR,
  characters VARCHAR
);
CREATE TABLE episodes (
  episode_title_id VARCHAR,
  show_title_id VARCHAR,
  season_number INTEGER,
  episode_number INTEGER
);
CREATE TABLE ratings (
  title_id VARCHAR PRIMARY KEY,
  rating INTEGER,
  votes INTEGER
);
CREATE INDEX ix_people_person_id ON people (person_id);
CREATE INDEX ix_people_name ON people (name);
CREATE INDEX ix_titles_type ON titles (type);
CREATE INDEX ix_titles_primary_title ON titles (primary_title);
CREATE INDEX ix_titles_original_title ON titles (original_title);
CREATE INDEX ix_akas_title_id ON akas (title_id);
CREATE INDEX ix_akas_title ON akas (title);
CREATE INDEX ix_crew_title_id ON crew (title_id);
CREATE INDEX ix_crew_person_id ON crew (person_id);
CREATE INDEX ix_crew_category ON crew (category);
CREATE INDEX ix_episodes_episode_title_id ON episodes (episode_title_id);
CREATE INDEX ix_episodes_show_title_id ON episodes (show_title_id);
CREATE TABLE sqlite_stat1(tbl,idx,stat);
