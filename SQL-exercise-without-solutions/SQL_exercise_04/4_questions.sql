-- Movie_theatres
-- 4.1 Select the title of all movies.
select title from movies;

-- 4.2 Show all the distinct ratings in the database.
select distinct rating from movies;

-- 4.3  Show all unrated movies.
select title from movies where rating is null;

-- 4.4 Select all movie theaters that are not currently showing a movie.
select name from movietheaters where movie is null;

-- 4.5 Select all data from all movie theaters 
    -- and, additionally, the data from the movie that is being shown in the theater (if one is being shown).
select a.*,b.title,b.rating  from movietheaters a left join movies b on a.movie = b.code ;

-- 4.6 Select all data from all movies and, if that movie is being shown in a theater, show the data from the theater.
select a.*,b.name theatername from movies a left join movietheaters b on b.movie = a.code ;

-- 4.7 Show the titles of movies not currently being shown in any theaters.
select a.title from movies a 
left join movietheaters b on b.movie = a.code
where b.name is null  ;

-- 4.8 Add the unrated movie "One, Two, Three".
insert into movies values (9,'One, Two, Three',null);

-- 4.9 Set the rating of all unrated movies to "G".
update movies set rating='G' where rating is null;

-- 4.10 Remove movie theaters projecting movies rated "NC-17".
delete from movietheaters a using movies b 
where a.movie=b.code and b.rating='NC-17';
