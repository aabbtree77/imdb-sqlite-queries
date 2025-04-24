> "Is that you, John Wayne? Is this me?"
>
> — *[Full Metal Jacket (1987)](https://youtu.be/sUIzoiMCp-Q?t=89)*

## Introduction

[imdb-sqlite](https://github.com/jojje/imdb-sqlite) allows to download the public imdb data set and store it as a single SQLite file. 

Name it "imdb.db" (19GB), install sqlite3, and extract the schema:

```bash
sudo apt install sqlite3
sqlite3 --version
3.37.2 2022-01-06
sqlite3 imdb.sqlite .schema > imdb_schema.sql
```

One can then give the schema to an AI to build advanced queries. 

They won't be available on [imdb.com](https://www.imdb.com/). The query may take more than 5 minutes to execute, may produce 80MB file with a million rows. Such queries are too costly for web APIs, but they work well locally.

Below I present two such queries (SQL scripts).

## query_h.sql

"Show SQL query which ranks directors via "h-index" where instead of h publications and h citations of them we get the same h actors in h films of a given director. Show row numbers too. Restrict to solid films such as non-adult, no anime, no cartoons. Add the total film counter column used for each director."

"This does not feel right, I get James Bobin with h index 6 and 4 films. Remember, the h index is the maximal number of h films produced by the same director with the same actor set of size h."

After a few more iterations ChatGPT produces the desired result.

```bash
sqlite3 imdb.db < query_h.sql > top_h.txt
```

Neglecting the outliers at the top, these "h-sets" turn out to be unexpectedly tiny:

```text
1098  Woody Allen                   3                       51  
1111  Jean-Luc Godard               3                       44 
1142  Terence Young                 3                       36         
1143  Steven Spielberg              3                       35
1304  Éric Rohmer                   3                       24
...
```

Out of 44 films directed by Jean-Luc Godard and selected with the filter (type=movies, duration>60min), only 3 films feature the same trio of actors. The film crews are not theatrical troupes at all. They have no permanence.

## query_duo.sql

"Now do the same but instead of h-index show the maximal number of films with the same actor per director, also show that actor and total film count by director as in the script above. Add the second best entry if the director and actor are the same."

Ignoring the outliers, the appearances of the favorites are also not as big as one would have expected:

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

Many famous tandems turn out to be of very mild symbolic value if exist at all. The superstar hyper-productive directors largely work as lonesome wolves. Further analysis reveals that no same actress has ever played more than twice in Éric Rohmer's films!

## Notes

* Comment out `LIMIT` lines in the both files to get a complete output.

* AI can do rating trend analysis, but I do not find this interesting.

* There is no data for per country analysis.

* A small total number of films with relatively high h-index, e.g. Hal Hartley's 12 and 4 resp., might indicate unusual quality.

* How to reveal little-known outstanding films such as Vincent Gallo's Buffalo '66 (1998)?!

