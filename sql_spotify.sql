select * from spotify;

-- Total rows
select count(*) from spotify;

-- EDA 
select count(distinct artist) from spotify;  -- total artists
select count(distinct track) from spotify;  -- total tracks

-- Total tracks in an album
select album, count(*) as "total_tracks"
from spotify 
group by album;

select max(duration_min) from spotify;
select min(duration_min) from spotify;

-- deleting outliers
delete from spotify 
where duration_min = 0;

select count(distinct channel) from spotify; -- total channels

select distinct most_played_on from spotify;  -- total platforms where tracks are being played

------------------------------------------------------------
-- Data Analysis
------------------------------------------------------------
-- 1. Retrieve the names of all tracks that have more than 1 billion streams.
select *
from spotify
where stream > 1000000000;

-- 2. List all albums along with their respective artists.
select distinct album, artist from spotify
order by 1;

-- 3. Get the total number of comments for tracks where licensed = TRUE.
select sum(comments) as "total_comments"
from spotify 
where licensed = "True";

-- 4. Find all tracks that belong to the album type single.
select track 
from spotify 
where album_type = 'single';
 
-- 5. Count the total number of tracks by each artist.
select artist, count(track) as "total_tracks"
from spotify
group by artist;

-- 6. Calculate the average danceability of tracks in each album.
select album,  avg(danceability) as "avg_danceability"
from spotify
group by album;

-- 7. Find the top 5 tracks with the highest energy values.
select track, max(energy) "energy_value"
from spotify
group by track
order by 2 desc limit 5;

-- 8. List all tracks along with their views and likes where official_video = TRUE.
select track, sum(views) "total_views", sum(likes) "total_likes"
from spotify
where official_video = 'TRUE'
group by track;

-- 9. For each album, calculate the total views of all associated tracks.
select album, track, sum(views) as "total_views"
from spotify
group by album, track
order by 1;

-- 10. Retrieve the track names that have been streamed on Spotify more than YouTube.
with cte as
	(select track,
	coalesce(sum(case when most_played_on = 'spotify' then stream end),0) as "Spotify",
	coalesce(sum(case when most_played_on = 'youtube' then stream end),0) as "Youtube"
	from spotify 
	group by track)
select *
from cte
where spotify > youtube and youtube <> 0;

-- 11. Find the top 3 most-viewed tracks for each artist using window functions.
with cte as
	(select artist, track, sum(views) as "total_views",
	dense_rank() over(partition by artist order by sum(views) desc) "rn"
	from spotify 
	group by artist, track)
select artist, track, total_views
from cte
where rn <= 3;

-- 12. Write a query to find tracks where the liveness score is above the average.
with cte as
	(select track, liveness, avg(liveness) over() as "avg_liveness"
	from spotify)
select *
from cte
where liveness > avg_liveness;

-- 13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
with cte as
	(select album, min(energy) "min_energy", max(energy) "max_energy"
	from spotify
	group by album)
select *, (max_energy - min_energy) as "energy_difference"
from cte;

-- 14. Find tracks where the energy-to-liveness ratio is greater than 1.2.
select * from
	(select track, energy/liveness as "energy_to_liveness_ratio"
	from spotify) t
where energy_to_liveness_ratio > 1.2;

-- 15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
select track, likes,
sum(likes) over(order by views rows between unbounded preceding and current row) cume_sum
from spotify;
