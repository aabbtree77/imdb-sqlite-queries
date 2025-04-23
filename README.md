> "Is that you, John Wayne? Is this me?"
>
> — *[Full Metal Jacket (1987)](https://youtu.be/sUIzoiMCp-Q?t=89)*

## Introduction

[imdb-sqlite](https://github.com/jojje/imdb-sqlite) allows to download the public imdb data set and store it as a single SQLite file, say imdb.db, which will be around 19GB. It will lack movie budgets, salaries, and geographic locations, but otherwise presents insane amount of information. After acquiring such a file, extract the schema:

```bash
sudo apt install sqlite3
sqlite3 --version
3.37.2 2022-01-06
sqlite3 imdb.sqlite .schema > imdb_schema.sql
```

One can then give the schema to an AI to build various SQL queries which won't be available on [imdb.com](https://www.imdb.com/). The query may take more than 5 minutes to execute, may produce 80MB file with a million rows. Such queries are not viable online, but they are manageable locally, and nowadays even Ubuntu's gedit with ctrl+f search will allow one to navigate such files.

Below I present two such queries (SQL scripts) which I found interesting.

## query_h.sql

"Show SQL query which ranks directors via "h-index" where instead of author numbers and publications we get actor numbers and films with the same actors. Show row numbers too. Restrict to solid films such as non-adult, no anime, no cartoons. Add the total film counter column used for each director."

"This does not feel right, I get James Bobin with h index 6 and 4 films. Remember, the h index is the maximal number of h films produced by the same director with the same actor set of size h."

After a few more iterations ChatGPT produces an amazing script.

```bash
sqlite3 imdb.db < query_h.sql > top_h.txt
```

Note that despite a few outliers at the top, the "h-sets" turn out to be unexpectedly tiny:

```text
1098  Woody Allen                   3                       51  
1111  Jean-Luc Godard               3                       44 
1142  Terence Young                 3                       36         
1143  Steven Spielberg              3                       35
1304  Éric Rohmer                   3                       24
...
```

Out of 44 films directed by Jean-Luc Godard and selected with the filter (type=movies, duration>60min), only 3 films feature the same trio of actors. Some of these directors may look like indie makers, but their crews are not theatrical troupes at all. The teams have no permanence, they vary from film to film wildly. 

## query_duo.sql

Some film directors do have their favorites, but if we ignore the outliers, the appearances are also not as big as one would expect:

```text
23     Woody Allen                           Woody Allen                      27              51  
843    Jean-Luc Godard                       Jean-Luc Godard                  7               44
1775   Jean-Luc Godard                       László Szabó                     5               44
1779   Werner Herzog                         Klaus Kinski                     5               41  
1792   Steven Spielberg                      Tom Hanks                        5               35
2883   Éric Rohmer                           Pascal Greggory                  4               24  
4759   Woody Allen                           John Doumanian                   3               51 
...
```

The script includes the second best runner when a director features himself as an actor.

Further analysis shows that no same actress has ever played more than twice in Éric Rohmer's films.

## Notes

* Comment out `LIMIT` lines in the both files to get a complete output. The limit is here only not to upload 100MB files on github by accident.

* AI can do all sorts of things with the SQL like rating trend analysis, but I do not find this interesting.

* A serious drawback of [imdb-sqlite](https://github.com/jojje/imdb-sqlite) is that one can only study things globally, there is no country data.

* One challenge is to come up with various filters and think of the criteria of a good film other than mass voting. For instance, a small total number of films with relatively high h-index, e.g. Hal Hartley's 12 and 4 resp., might indicate some unusual quality.

* It is not clear how to reveal little-known outstanding films such as Vincent Gallo's Buffalo '66 (1998).

