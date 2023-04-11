/**The dataset that we use in this project contains a list of video games with sales greater than 100,000 copies.**/




/** We need to change the data type for a few of our columns.**/
ALTER TABLE vgsales
ALTER COLUMN NA_Sales decimal(10,2);

ALTER TABLE vgsales
ALTER COLUMN EU_Sales decimal(10,2);

ALTER TABLE vgsales
ALTER COLUMN JP_Sales decimal(10,2);

ALTER TABLE vgsales
ALTER COLUMN Other_Sales decimal(10,2);

ALTER TABLE vgsales
DROP COLUMN Global_Sales;

ALTER TABLE vgsales ADD Global_Sales decimal(10,2);
UPDATE vgsales SET Global_Sales = NA_Sales+EU_Sales+JP_Sales+Other_Sales;


/**===============================================================================================**/

/** Sales **/

GO
DROP TABLE IF EXISTS [SQLPortofolioProject_VideoGamesSales]..[vgsales_sales];

CREATE TABLE [SQLPortofolioProject_VideoGamesSales]..[vgsales_sales] (
    Year INT,
    Total_NA_Sales DECIMAL(10,2),
    Total_EU_Sales DECIMAL(10,2),
    Total_JP_Sales DECIMAL(10,2),
    Total_Other_Sales DECIMAL(10,2),
	Total_Global_Sales DECIMAL(10,2),
);

INSERT INTO [SQLPortofolioProject_VideoGamesSales]..[vgsales_sales] (Year, Total_NA_Sales, Total_EU_Sales, Total_JP_Sales, Total_Other_Sales, Total_Global_Sales)
	SELECT
		--[Rank]
		--[Name]
		--Platform
		CAST(Year as int) as Year
		--,Genre
		--,Publisher
		,SUM(NA_Sales) as Total_NA_Sales
		,SUM(EU_Sales) as Total_EU_Sales
		,SUM(JP_Sales) as Total_JP_Sales
		,SUM(Other_Sales) as Total_Other_Sales
		,SUM(Global_Sales) as Total_Global_Sales
	FROM [SQLPortofolioProject_VideoGamesSales]..[vgsales]
	--Some data have 'N/A' value, so we must drop those records. It also looks like the data has a problem capturing it after 2015.	
	--Then, we will only use data that capture before 2016
	WHERE Year <> 'N/A' AND CAST(Year as int)<'2016'
	GROUP BY Year
	ORDER BY Year

--The total number of copies of video games sold for each year (from 1980 to 2015) in NA, EU, JP, and all over the world (Global Sales)
SELECT *
FROM [SQLPortofolioProject_VideoGamesSales]..[vgsales_sales]
ORDER BY Year

/**===============================================================================================**/

/** Publisher **/

--The total number of video games that published by each publisher from 1980 to 2015 (We will only take the top 15 for simplification)
SELECT TOP(15) Publisher, COUNT(Publisher) as countpublisher
FROM [SQLPortofolioProject_VideoGamesSales]..vgsales
WHERE Year <> 'N/A' AND CAST(Year as int)<'2016'
GROUP BY Publisher
ORDER BY COUNT(Publisher) desc


GO
DROP TABLE IF EXISTS [SQLPortofolioProject_VideoGamesSales]..[vgsales_publisher];

CREATE TABLE [SQLPortofolioProject_VideoGamesSales]..[vgsales_publisher] (
    Year INT,
	Publisher NVARCHAR(50),
    Total_NA_Sales_Publisher DECIMAL(10,2),
    Total_EU_Sales_Publisher DECIMAL(10,2),
    Total_JP_Sales_Publisher DECIMAL(10,2),
    Total_Other_Sales_Publisher DECIMAL(10,2),
	Total_Global_Sales_Publisher DECIMAL(10,2),
);


-- We will only use the top 15 countpublisher to simplify the data
WITH cte_publisher AS(
	SELECT TOP(15) Publisher, COUNT(Publisher) as countpublisher
	FROM [SQLPortofolioProject_VideoGamesSales]..vgsales
	WHERE Year <> 'N/A' AND CAST(Year as int)<'2016'
	GROUP BY Publisher
	ORDER BY COUNT(Publisher) desc
),
cte_publisher2 AS(
	SELECT
	CAST(vgsales.Year as int) as Year,
	vgsales.Publisher,
	vgsales.NA_Sales,
	vgsales.EU_Sales,
	vgsales.JP_Sales,
	vgsales.Other_Sales,
	vgsales.Global_Sales
	FROM [SQLPortofolioProject_VideoGamesSales]..vgsales
	WHERE Year <> 'N/A' AND CAST(Year as int)<'2016'
)
INSERT INTO [SQLPortofolioProject_VideoGamesSales]..[vgsales_publisher] (Year, Publisher, Total_NA_Sales_Publisher, Total_EU_Sales_Publisher, Total_JP_Sales_Publisher, Total_Other_Sales_Publisher, Total_Global_Sales_Publisher)
	SELECT 	
		cte_publisher2.Year,
		cte_publisher2.Publisher,
		SUM(cte_publisher2.NA_Sales) as Total_NA_Sales_Publisher,
		SUM(cte_publisher2.EU_Sales) as Total_EU_Sales_Publisher,
		SUM(cte_publisher2.JP_Sales) as Total_JP_Sales_Publisher,
		SUM(cte_publisher2.Other_Sales) as Total_Other_Sales_Publisher,
		SUM(cte_publisher2.Global_Sales) as Total_Global_Sales_Publisher
	FROM cte_publisher INNER JOIN cte_publisher2 ON cte_publisher.Publisher = cte_publisher2.Publisher
	GROUP BY cte_publisher2.Year, cte_publisher2.Publisher
	ORDER BY Publisher

--Total number of copies of video games sold based on the publisher for each year (from 1980 to 2015) in NA, EU, JP, and all over the world (Global Sales)
SELECT *
FROM [SQLPortofolioProject_VideoGamesSales]..[vgsales_publisher]

--Total number of copies of video games sold based on the publisher from 1980 to 2015 in NA, EU, JP, and all over the world (Global Sales)
SELECT Publisher,
SUM(Total_NA_Sales_Publisher) as NA,
SUM(Total_EU_Sales_Publisher) as EU,
SUM(Total_JP_Sales_Publisher) as JP,
SUM(Total_Other_Sales_Publisher) as Other,
SUM(Total_Global_Sales_Publisher) as Global
FROM [SQLPortofolioProject_VideoGamesSales]..[vgsales_publisher]
GROUP BY Publisher

/**===============================================================================================**/

--The total number of video games released for each genre from 1980 to 2015
SELECT Genre, COUNT(Genre) as countgenre
FROM [SQLPortofolioProject_VideoGamesSales]..vgsales
WHERE Year <> 'N/A' AND CAST(Year as int)<'2016'
GROUP BY Genre
ORDER BY COUNT(Genre) desc

--The total number of copies of video games sold based on the genre from 1980 to 2015 in NA, EU, JP, and all over the world (Global Sales).
SELECT Genre
		,SUM(NA_Sales) as Total_NA_Sales
		,SUM(EU_Sales) as Total_EU_Sales
		,SUM(JP_Sales) as Total_JP_Sales
		,SUM(Other_Sales) as Total_Other_Sales
		,SUM(Global_Sales) as Total_Global_Sales
FROM [SQLPortofolioProject_VideoGamesSales]..vgsales
WHERE Year <> 'N/A' AND CAST(Year as int)<'2016'
GROUP BY Genre
ORDER BY Genre asc


GO
DROP TABLE IF EXISTS [SQLPortofolioProject_VideoGamesSales]..[vgsales_genre];

CREATE TABLE [SQLPortofolioProject_VideoGamesSales]..[vgsales_genre] (
    Year INT,
	Genre NVARCHAR(50),
    Total_NA_Sales_Publisher DECIMAL(10,2),
    Total_EU_Sales_Publisher DECIMAL(10,2),
    Total_JP_Sales_Publisher DECIMAL(10,2),
    Total_Other_Sales_Publisher DECIMAL(10,2),
	Total_Global_Sales_Publisher DECIMAL(10,2),
);

INSERT INTO [SQLPortofolioProject_VideoGamesSales]..[vgsales_genre] (Year, Genre, Total_NA_Sales_Publisher, Total_EU_Sales_Publisher, Total_JP_Sales_Publisher, Total_Other_Sales_Publisher, Total_Global_Sales_Publisher)
	SELECT
		CAST(vgsales.Year as int) as Year,
		vgsales.Genre,
		SUM(vgsales.NA_Sales) as Total_NA_Sales_Genre,
		SUM(vgsales.EU_Sales) as Total_EU_Sales_Genre,
		SUM(vgsales.JP_Sales) as Total_JP_Sales_Genre,
		SUM(vgsales.Other_Sales) as Total_Other_Sales_Genre,
		SUM(vgsales.Global_Sales) as Total_Global_Sales_Genre
	FROM [SQLPortofolioProject_VideoGamesSales]..vgsales
	WHERE Year <> 'N/A' AND CAST(Year as int)<'2016'
	GROUP BY Genre, Year
	ORDER BY Year

--The total number of copies of video games sold based on the genre for each year (from 1980 to 2015) in NA, EU, JP, and all over the world (Global Sales).
SELECT *
FROM [SQLPortofolioProject_VideoGamesSales]..[vgsales_genre]
ORDER BY Year

/**===============================================================================================**/

--Total number of video games that we can play on each console from 1980 to 2015
SELECT Platform, COUNT(Platform) as countplatform
FROM [SQLPortofolioProject_VideoGamesSales]..vgsales
WHERE Year <> 'N/A' AND CAST(Year as int)<'2016'
GROUP BY Platform
ORDER BY COUNT(Platform) desc

--Total number of copies of video games sold based on consoles from 1980 to 2015 in NA, EU, JP, and all over the world (Global Sales)
SELECT Platform
		,SUM(NA_Sales) as Total_NA_Sales
		,SUM(EU_Sales) as Total_EU_Sales
		,SUM(JP_Sales) as Total_JP_Sales
		,SUM(Other_Sales) as Total_Other_Sales
		,SUM(Global_Sales) as Total_Global_Sales
FROM [SQLPortofolioProject_VideoGamesSales]..vgsales
WHERE Year <> 'N/A' AND CAST(Year as int)<'2016'
GROUP BY Platform
ORDER BY Platform asc


GO
DROP TABLE IF EXISTS [SQLPortofolioProject_VideoGamesSales]..[vgsales_consoles];

CREATE TABLE [SQLPortofolioProject_VideoGamesSales]..[vgsales_consoles] (
    Year INT,
	Platform NVARCHAR(50),
    Total_NA_Sales_Publisher DECIMAL(10,2),
    Total_EU_Sales_Publisher DECIMAL(10,2),
    Total_JP_Sales_Publisher DECIMAL(10,2),
    Total_Other_Sales_Publisher DECIMAL(10,2),
	Total_Global_Sales_Publisher DECIMAL(10,2),
);

INSERT INTO [SQLPortofolioProject_VideoGamesSales]..[vgsales_consoles] (Year, Platform, Total_NA_Sales_Publisher, Total_EU_Sales_Publisher, Total_JP_Sales_Publisher, Total_Other_Sales_Publisher, Total_Global_Sales_Publisher)
	SELECT
		CAST(vgsales.Year as int) as Year,
		vgsales.Platform,
		SUM(vgsales.NA_Sales) as Total_NA_Sales_Genre,
		SUM(vgsales.EU_Sales) as Total_EU_Sales_Genre,
		SUM(vgsales.JP_Sales) as Total_JP_Sales_Genre,
		SUM(vgsales.Other_Sales) as Total_Other_Sales_Genre,
		SUM(vgsales.Global_Sales) as Total_Global_Sales_Genre
	FROM [SQLPortofolioProject_VideoGamesSales]..vgsales
	WHERE Year <> 'N/A' AND CAST(Year as int)<'2016'
	GROUP BY Platform, Year

--Total number of copies of video games sold based on consoles for each year (from 1980 to 2015) in NA, EU, JP, and all over the world (Global Sales)
SELECT *
FROM [SQLPortofolioProject_VideoGamesSales]..[vgsales_consoles]