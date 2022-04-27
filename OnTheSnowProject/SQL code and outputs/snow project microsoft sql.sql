-- OnTheSnow data cleaning and exploration
-- Grayson Hineline


-- Cleaning the data --

use master;

select * from annualsnow;

Select 
	CASE When total_snowfall Like '%"%' Then Cast(Replace(total_snowfall, '"', '') as int)
	     When total_snowfall Like '%cm%' Then Cast(Replace(total_snowfall, 'cm', '') as int) * 0.393701
		 Else total_snowfall
		 End
From
	annualsnow;


-- Converting all columns in annualsnow and current season to numerical and into inches
Update annualsnow
	Set
		total_snowfall = (
			Case When total_snowfall Like '%cm%' Then Cast(Replace(total_snowfall, 'cm', '') as int) * 0.393701
				 Else Cast(Replace(total_snowfall, '"', '') as int)
			End),
		avg_base_dep = (
			Case When avg_base_dep Like '%cm%' Then Cast(Replace(avg_base_dep, 'cm', '') as int) * 0.393701
				 Else Cast(Replace(avg_base_dep, '"', '') as int)
			End),
		avg_sum_dep = (
			Case When avg_sum_dep Like '%cm%' Then Cast(Replace(avg_sum_dep, 'cm', '') as int) * 0.393701
				 Else Cast(Replace(avg_sum_dep, '"', '') as int)
			End),
		max_base_dep = (
			Case When max_base_dep Like '%cm%' Then Cast(Replace(max_base_dep, 'cm', '') as int) * 0.393701
				 Else Cast(Replace(max_base_dep, '"', '') as int)
			End),
		biggest_snowfall = (
			Case When biggest_snowfall Like '%cm%' Then Cast(Replace(biggest_snowfall, 'cm', '') as int) * 0.393701
				 Else Cast(Replace(biggest_snowfall, '"', '') as int)
			End);

Alter Table annualsnow Alter Column total_snowfall float null;
Alter Table annualsnow Alter Column snowfall_days int null;
Alter Table annualsnow Alter Column avg_base_dep float null;
Alter Table annualsnow Alter Column avg_sum_dep float null;
Alter Table annualsnow Alter Column max_base_dep float null;
Alter Table annualsnow Alter Column biggest_snowfall float null;


Update currentseason
	Set
		avg_snowfall = (
			Case When avg_snowfall Like '%cm%' Then Cast(Replace(avg_snowfall, 'cm', '') as int) * 0.393701
				 Else Cast(Replace(avg_snowfall, '"', '') as int)
				 End),
		avg_base_dep = (
			Case When avg_base_dep Like '%cm%' Then Cast(Replace(avg_base_dep, 'cm', '') as int) * 0.393701
				 Else Cast(Replace(avg_base_dep, '"', '') as int)
				 End),
		avg_sum_dep = (
			Case When avg_sum_dep Like '%cm%' Then Cast(Replace(avg_sum_dep, 'cm', '') as int) * 0.393701
				 Else Cast(Replace(avg_sum_dep, '"', '') as int)
				 End),
		max_base_dep = (
			Case When max_base_dep Like '%cm%' Then Cast(Replace(max_base_dep, 'cm', '') as int) * 0.393701
				 Else Cast(Replace(max_base_dep, '"', '') as int)
				 End),
		biggest_snowfall = (
			Case When biggest_snowfall Like '%cm%' Then Cast(Replace(biggest_snowfall, 'cm', '') as int) * 0.393701
				 Else Cast(Replace(biggest_snowfall, '"', '') as int)
				 End);

Alter Table currentseason Alter Column avg_snowfall float null;
Alter Table currentseason Alter Column snowfall_days int null;
Alter Table currentseason Alter Column avg_base_dep float null;
Alter Table currentseason Alter Column avg_sum_dep float null;
Alter Table currentseason Alter Column max_base_dep float null;
Alter Table currentseason Alter Column biggest_snowfall float null;


-- Since skiresorts needed so much cleaning to make it function the way I wanted, I
-- just opted to make an entirely new table out of a cleaned select statement.
Select
	-- Creating column for continent
	Case when location = 'trentino' or location = 'northern-alps' or location = 'valais' then 'Europe'
		 Else 'North America'
		 End as continent,
	location as region,
	resort,
	Pass,
	limited_or_unlimited,
	cast(total_lifts as int) as total_lifts,
	-- Converting the following from meters to feet
	Case When sum_height Like '%m%' Then Cast(Replace(sum_height, 'm', '') as int) * 3.28084
		 Else Cast(Replace(sum_height, Char(39), '') as int)
		 End as sum_height,
	Case When vert_drop Like '%m%' Then Cast(Replace(vert_drop, 'm', '') as int) * 3.28084
		 Else Cast(Replace(vert_drop, Char(39), '') as int)
		 End as vert_drop,
	Case When base_elevation Like '%m%' Then Cast(Replace(base_elevation, 'm', '') as int) * 3.28084
		 Else Cast(Replace(base_elevation, Char(39), '') as int)
		 End as base_elevation,
	-- Some values are not the number of runs, but rather the total length of all runs, making these null
	Cast((Case When runs like '% %' Then NULL
			   Else runs
			   End) as int) as runs,
	-- Converting longest_run to miles
	Case When longest_run Like '% km%' Then Round(Cast(Replace(longest_run, ' km', '') as float) * 0.621371, 2)
		 Else Cast(Replace(longest_run, ' mi', '') as float)
		 End as longest_run,
	-- Converting resorts with terrain in acres to integers in their own column
	Case When terrain like '% ac%' Then Cast(Replace(terrain, ' ac', '') as int)
		 Else null
		 End as terrain_ac,
	-- Converting resorts with terrain in km to integers in their own column
	Case When terrain like '% km%' Then Cast(Replace(terrain, ' km', '') as float)
		 Else null
		 End as terrain_km,
	Case When snow_making like '% ac%' Then Cast(Replace(snow_making, ' ac', '') as int)
		 Else null
		 End as snow_making,
	Cast(SUBSTRING(proj_open, CHARINDEX(' ', proj_open)+ 9, 10) as Date) as proj_open,
	Cast(SUBSTRING(proj_close, CHARINDEX(' ', proj_close)+ 9, 10) as Date) as proj_close,
	Case When proj_days_open like '%N.A.%' then null
		 Else cast(proj_days_open as int)
		 End as proj_days_open,
	Case When days_open_2021 like '%N.A.%' then null
		 Else cast(days_open_2021 as int)
		 End as days_open_2021,
	Case When years_open like '%N.A.%' then null
		 Else cast(years_open as int)
		 End as years_open,
	Case When avg_snow like '%cm%' Then Cast(Replace(avg_snow, 'cm', '') as float) * 2.54
	     Else Cast(Replace(avg_snow, '"', '') as float)
		 End as avg_snow,
	Case When green_runs like '' Then null
		 Else Cast(Replace(green_runs, '%', '') as float) / 100
		 End as green_runs,
	Case When blue_runs like '' Then null
		 Else Cast(Replace(blue_runs, '%', '') as float) / 100
		 End as blue_runs,
	Case When black_runs like '' Then null
		 Else Cast(Replace(black_runs, '%', '') as float) / 100
		 End as black_runs,
	Case When double_blacks like '' Then null
		 Else Cast(Replace(double_blacks, '%', '') as float) / 100
		 End as double_blacks,
	Case When night_skiing = '' Then 'False'
		 Else 'True'
		 End as night_skiing
Into
	skiresorts2
From
	skiresorts;





-- Now let's explore the data

-- How many resorts are there for the Epic in Ikon passes in this data set? What about if we filter by continent?
Select
	pass,
	count(resort)
From
	skiresorts2
Group by pass

Select
	continent,
	pass,
	count(resort)
From
	skiresorts2
Group by pass, continent

-- Looks like onthesnow.com is missing a bunch of resorts for both passes, given
-- that Epic has 61 total resorts and Ikon has 57. So while this data may give some
-- insights, its not going to be able to draw any really big conclusions involving the total
-- value of either pass.


-- Where are the different resorts located, and how many of those resorts are
-- given by the Epic pass or the Ikon pass?
Select 
	continent,
	region,
	pass,
	Count(region) as num_of_resorts
from 
	skiresorts2
Group by region, continent, pass
Order by num_of_resorts desc;

-- I live in the Pacific Northwest of North America, so lets filter for
-- resorts there:
select 
	region,
	pass,
	count(resort) as num_of_resorts
from skiresorts2
Where continent = 'North America'
	  and (region = 'british-columbia'
	  or region = 'washington'
	  or region = 'oregon')
group by region, pass
order by region, num_of_resorts;

-- What are the names of those resorts and what do their metrics look like?
select 
	*
from skiresorts2
Where continent = 'North America'
	  and (region = 'british-columbia'
	  or region = 'washington'
	  or region = 'oregon')
order by region;



-- Which ski resort had the snowfall for both the epic and Ikon pass...
-- the last ten years?
Select 
	resort,
	location,
	pass,
	year,
	total_snowfall
From
	annualsnow
Where total_snowfall = (Select
							max(total_snowfall)
						From annualsnow
						Where pass = 'Epic')
	  or total_snowfall = (Select
							max(total_snowfall)
							From annualsnow
						Where pass = 'Ikon');
	

-- This current year so far?
Select 
	resort,
	location,
	pass,
	year,
	total_snowfall
From
	annualsnow
Where (total_snowfall = (Select
							max(total_snowfall)
						From annualsnow
						Where pass = 'Epic' and year = '2021 - To Date')
	  or total_snowfall = (Select
							max(total_snowfall)
							From annualsnow
						Where pass = 'Ikon' and year = '2021 - To Date'))
	 and year = '2021 - To Date';


-- Which ski resort got the most snowfall in each month of this year?
With maxSnowfall(month, max_avg_snowfall) As
	(Select
		month,
		max(avg_snowfall)
	From currentseason
	Group by month)

Select
	a.resort,
	a.month,
	a.avg_snowfall
From 
	currentseason a
		join
	maxSnowfall b on a.avg_snowfall = b.max_avg_snowfall and a.month = b.month
order by avg_snowfall



-- What are the top 10 resorts with the highest average total snowfall?
Select top 10
	location,
	resort,
	pass,
	AVG(total_snowfall) as avg_total_snowfall
From annualsnow
Group by Resort, pass, Location
Order by avg_total_snowfall desc;



-- Have the averages for the different snow metrics changed in the last 10 years?
Select
	year,
	avg(total_snowfall) as avg_total_snowfall,
	avg(snowfall_days) as avg_snowfall_days,
	avg(avg_base_dep) as avg_avg_base_depth,
	avg(avg_sum_dep) as avg_avg_sum_depth,
	avg(max_base_dep) as avg_max_base_depth,
	avg(biggest_snowfall) as avg_biggest_snowfall
From annualsnow
group by year
order by year;

Select
	pass,
	year,
	avg(total_snowfall) as avg_total_snowfall,
	avg(snowfall_days) as avg_snowfall_days,
	avg(avg_base_dep) as avg_avg_base_depth,
	avg(avg_sum_dep) as avg_avg_sum_depth,
	avg(max_base_dep) as avg_max_base_depth,
	avg(biggest_snowfall) as avg_biggest_snowfall
From annualsnow
group by year, pass
order by year, pass;

Select
	location,
	year,
	avg(total_snowfall) as avg_total_snowfall,
	avg(snowfall_days) as avg_snowfall_days,
	avg(avg_base_dep) as avg_avg_base_depth,
	avg(avg_sum_dep) as avg_avg_sum_depth,
	avg(max_base_dep) as avg_max_base_depth,
	avg(biggest_snowfall) as avg_biggest_snowfall
From annualsnow
group by year, location
order by year, location;


-- Lets look at the average snowfall metrics for the top 15 resorts in
-- North America with the most terrain
Select top 15
	s.continent,
	s.region,
	s.resort,
	s.pass,
	s.runs,
	s.terrain_ac,
	s.proj_days_open,
	avg(a.total_snowfall) as avg_total_snowfall,
	avg(a.snowfall_days) as avg_snowfall_days,
	avg(a.avg_base_dep) as avg_avg_base_depth,
	avg(a.avg_sum_dep) as avg_avg_sum_depth,
	avg(a.max_base_dep) as avg_max_base_depth,
	avg(a.biggest_snowfall) as avg_biggest_snowfall
From skiresorts2 s
		join
	 annualsnow a on s.resort = a.resort
Where continent = 'North America'
Group by s.Resort, s.pass, s.region, s.continent, s.pass, s.runs, s.terrain_ac, s.proj_days_open
order by terrain_ac desc;


-- What are the average snowfall metrics for the top 15 resorts in
-- North America with the most terrain
Select top 15
	s.continent,
	s.region,
	s.resort,
	s.pass,
	s.runs,
	s.terrain_ac,
	s.proj_days_open,
	avg(a.total_snowfall) as avg_total_snowfall,
	avg(a.snowfall_days) as avg_snowfall_days,
	avg(a.avg_base_dep) as avg_avg_base_depth,
	avg(a.avg_sum_dep) as avg_avg_sum_depth,
	avg(a.max_base_dep) as avg_max_base_depth,
	avg(a.biggest_snowfall) as avg_biggest_snowfall
From skiresorts2 s
		join
	 annualsnow a on s.resort = a.resort
Where continent = 'North America'
Group by s.Resort, s.pass, s.region, s.continent, s.pass, s.runs, s.terrain_ac, s.proj_days_open
order by terrain_ac desc;


-- We know from this that the top 15 resorts with the most terrain in north america all have at
-- least 3000 acres of terrain, so lets order them by average snow depth at the summit
Select top 15
	s.continent,
	s.region,
	s.resort,
	s.pass,
	s.runs,
	s.terrain_ac,
	s.proj_days_open,
	avg(a.avg_sum_dep) as avg_avg_sum_depth
From skiresorts2 s
		join
	 annualsnow a on s.resort = a.resort
Where continent = 'North America' and terrain_ac > 3000
Group by s.Resort, s.pass, s.region, s.continent, s.pass, s.runs, s.terrain_ac, s.proj_days_open
order by avg_avg_sum_depth desc;


-- Compare this to resorts in north america that don't have 3000 acres of terain?
Select
	s.continent,
	s.region,
	s.resort,
	s.pass,
	s.runs,
	s.terrain_ac,
	s.proj_days_open,
	avg(a.avg_sum_dep) as avg_avg_sum_depth
From skiresorts2 s
		join
	 annualsnow a on s.resort = a.resort
Where continent = 'North America' and terrain_ac <= 3000
Group by s.Resort, s.pass, s.region, s.continent, s.pass, s.runs, s.terrain_ac, s.proj_days_open
order by avg_avg_sum_depth desc;


-- Last thing concerning terrain, what does the difficulty of the terrain look like
-- in those resorts with at least 3000 acres? I care about difficult terrain, so I'll put
-- those at the top:
Select 
	region,
	resort,
	pass,
	terrain_ac,
	green_runs,
	blue_runs,
	black_runs,
	double_blacks
From
	skiresorts2
Where terrain_ac > 3000
Order by black_runs desc, double_blacks desc;


-- That leads to a question, of the two passes, in North America, what percent of the total
-- runs for all resorts are of each type of difficulty? Since we don't have data for the runs for a lot
-- of resorts, lets only do resorts that at least have green and blue runs recorded.
Select
	a.pass,
	b.num_of_resorts,
	round(sum(a.green_runs) / b.num_of_resorts, 4) * 100 as perc_green_runs,
	round(sum(a.blue_runs) / b.num_of_resorts, 4) * 100 as perc_blue_runs,
	round(sum(a.black_runs) / b.num_of_resorts, 4) * 100 as perc_black_runs,
	round(sum(a.double_blacks) / b.num_of_resorts, 4) * 100 as perc_dbl_black_runs
From
	skiresorts2 a
		Join
	(Select
		 pass,
		 count(resort) as num_of_resorts
	 From
		 skiresorts2
	 Where continent = 'North America' and green_runs is not null and blue_runs is not null
	 Group by pass) b on a.pass = b.pass
Where continent = 'North America' and green_runs is not null and blue_runs is not null
Group by a.pass, b.num_of_resorts;




-- What is the average amount of snowfall for a season for all the resorts and
-- all seasons? And how many seasons for both the Epic and Ikon pass's resorts have exceeded that average?
Declare @pop_average float;
Set @pop_average = (Select 
						Avg(total_snowfall) as pop_average
					From annualsnow);
Select
	a.pass,
	Count(a.pass) as seasons_w_above_avg_snowfall
From
	annualsnow a
Where a.total_snowfall > @pop_average
Group by a.pass;


-- What about if we filter the data such that only North American resorts are included?
Declare @pop_average float;
Set @pop_average = (Select 
						Avg(total_snowfall) as pop_average
					From annualsnow);
Select
	a.pass,
	Count(a.pass) as seasons_w_above_avg_snowfall
From
	annualsnow a
		Join
	skiresorts2 s on a.resort = s.resort
Where total_snowfall > @pop_average and continent = 'North America'
Group by a.pass;


-- For some reason, joining the tables results in more rows than there should be.
-- Let's figure out which resorts are being counted more than once.
select
	a.resort,
	count(a.Resort) as num_of_resorts
From annualsnow a
		join
	 skiresorts2 s on a.Resort = s.resort
Group by a.resort
Order by num_of_resorts desc;


-- Because Sun Valley and Snowbasin are listed with the epic pass and the ikon pass (they have
-- deals with both) they are being joined twice. That can be fixed by just joining a table that
-- is only distinct values.
Declare @pop_average float;
Set @pop_average = (Select 
						Avg(total_snowfall) as pop_average
					From annualsnow);

With distinctresorts(continent, resort) As
	(Select
		continent,
		resort
	From skiresorts2
	group by resort, continent)

Select
	s.continent,
	a.pass,
	Count(a.pass) as seasons_w_above_avg_snowfall
From
	annualsnow a
		Join
	distinctresorts s on a.resort = s.resort
Where total_snowfall > @pop_average and continent = 'North America'
Group by a.pass, s.continent;


-- Finally, we'll find the average total snowfall in a season for all North American Resorts, then find what percentage
-- of the all of the Epic and Ikon's respective total number of seasons had total snowfall above that average, and
-- filter those results such that we can see what percentage of those seasons were given to unlimited and limtited
-- access resorts.
Declare @pop_average float;
Set @pop_average = (Select 
						Avg(total_snowfall) as pop_average
					From annualsnow
					Where resort in (Select
									     resort
									 from skiresorts2
									 Where continent = 'North America'));

With distinctresorts(continent, resort, limited_or_unlimited) As
	(Select
		continent,
		resort,
		limited_or_unlimited
	From skiresorts2
	group by resort, continent, limited_or_unlimited),

	total_seasons(pass, total_seasons) As
	(Select 
		pass,
		count(total_snowfall)
	 From annualsnow
	 Where resort in (Select
						resort
					  from skiresorts2
				      Where continent = 'North America')
	 Group by pass)

Select
	s.continent,
	a.pass,
	s.limited_or_unlimited,
	Count(a.pass) as num_of_seasons_w_above_avg_snowfall,
	t.total_seasons as total_seasons_for_pass,
	round((cast(count(a.pass) as float) / t.total_seasons) * 100, 2) as percent_of_total_seasons_for_pass,
	round(@pop_average, 2) as average_snowfall_in_north_american_resorts
From
	annualsnow a
		Join
	distinctresorts s on a.resort = s.resort
		Join
	total_seasons t on a.Pass = t.pass
Where a.total_snowfall > @pop_average and continent = 'North America'
Group by a.pass, s.limited_or_unlimited, continent, t.total_seasons
order by a.pass, s.limited_or_unlimited;



select 
	year,
	avg(total_snowfall) as overall_average
	from annualsnow
group by Year