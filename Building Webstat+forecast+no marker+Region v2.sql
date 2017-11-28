USE [WebStatLight]
GO

------Declaring campaign_name which will be used for data aggregating. Should be like '%ikea%' for broad match or 'ikea' for exact match.
declare @campaign_name nvarchar(255)
set @campaign_name = N'Petelinka_Pitch16112017'

------Calculating [NumberOfRequest]
IF OBJECT_ID(N'tempdb..#TempWordNumberAll') IS NOT NULL 
		DROP TABLE #TempWordNumberAll;

	SELECT [Brand_Name],
		[Campaign_Name],
		[Source],
		[Word],
		[Region],
		COUNT(*) as [NumberOfRequest]
	INTO #TempWordNumberAll
	FROM (	SELECT DISTINCT [Brand_Name],
				[Campaign_Name],
				[Source],
				[Word],
				[Region],
				[DateTimeOfRequest]
			FROM [dbo].[SERP_Source_Data] aa
			JOIN [dbo].[Dim_Campaign] ss ON aa.[Campaign_ID] = ss.[Campaign_ID]
			JOIN [dbo].[Dim_Source] dd ON aa.[Source_ID] = dd.[Source_ID]
			JOIN [dbo].[Dim_Word] hh ON aa.[Word_ID] = hh.[Word_ID]
			JOIN [dbo].[Dim_Region] jj ON aa.[Region_ID] = jj.[Region_ID]
			) aa
	WHERE Campaign_Name LIKE @campaign_name
	GROUP BY [Brand_Name],
		[Campaign_Name],
		[Source],
		[Word],
		[Region]



------Calculating [NumberOfRequestAd]
IF OBJECT_ID(N'tempdb..#TempWordNumberAd') IS NOT NULL 
		DROP TABLE #TempWordNumberAd;

SELECT [Brand_Name],
	[Campaign_Name],
	[Source],
	[Word],
	[Region],
	COUNT(*) as [NumberOfRequestAd]
INTO #TempWordNumberAd
FROM (	SELECT DISTINCT [Brand_Name],
			[Campaign_Name],
			[Source],
			[Word],
			[Region],
			[DateTimeOfRequest]
		FROM [dbo].[SERP_Source_Data] aa
		JOIN [dbo].[Dim_Campaign] ss ON aa.[Campaign_ID] = ss.[Campaign_ID]
		JOIN [dbo].[Dim_Source] dd ON aa.[Source_ID] = dd.[Source_ID]
		JOIN [dbo].[Dim_Type] ff ON aa.[Type_ID] = ff.[Type_ID]
		JOIN [dbo].[Dim_Word] hh ON aa.[Word_ID] = hh.[Word_ID]
		JOIN [dbo].[Dim_Region] jj ON aa.[Region_ID] = jj.[Region_ID]
		WHERE [ItemType] = 'AD'
		) aa
WHERE Campaign_Name LIKE @campaign_name
GROUP BY [Brand_Name],
	[Campaign_Name],
	[Source],
	[Word],
	[Region]



------Merging [NumberOfRequest] and [NumberOfRequestAd]
IF OBJECT_ID(N'tempdb..#TempWordNumber') IS NOT NULL 
		DROP TABLE #TempWordNumber;

SELECT aa.[Brand_Name],
	aa.[Campaign_Name],
	aa.[Source],
	aa.[Word],
	aa.[Region],
	aa.[NumberOfRequest],
	ss.[NumberOfRequestAd]
	INTO #TempWordNumber
FROM #TempWordNumberAll aa
LEFT JOIN #TempWordNumberAd ss
ON aa.[Brand_Name] = ss.[Brand_Name]
AND aa.[Campaign_Name] = ss.[Campaign_Name]
AND aa.[Source] = ss.[Source]
AND aa.[Word] = ss.[Word]
AND aa.[Region] = ss.[Region]


------Calculating [NumberOfRequestTotal]
IF OBJECT_ID(N'tempdb..#TempRequestNumber') IS NOT NULL 
		DROP TABLE #TempRequestNumber;

SELECT [Brand_Name],
	[Campaign_Name],
	[Source],
	[Region],
	COUNT(*) as [NumberOfRequestTotal]
INTO #TempRequestNumber
FROM (	SELECT DISTINCT [Brand_Name],
			[Campaign_Name],
			[Source],
			[Region],
			[DateTimeOfRequest]
		FROM [dbo].[SERP_Source_Data] aa
		JOIN [dbo].[Dim_Campaign] ss ON aa.[Campaign_ID] = ss.[Campaign_ID]
		JOIN [dbo].[Dim_Source] dd ON aa.[Source_ID] = dd.[Source_ID]
		JOIN [dbo].[Dim_Region] jj ON aa.[Region_ID] = jj.[Region_ID]
		) aa
WHERE Campaign_Name LIKE @campaign_name
GROUP BY [Brand_Name],
	[Campaign_Name],
	[Source],
	[Region]


------Making temporary source table and changing [NumberOnPage]
IF OBJECT_ID(N'tempdb..#TempDomain') IS NOT NULL 
		DROP TABLE #TempDomain;

SELECT [Brand_Name] as [Brand],
	[Campaign_Name] as [Campaign],
	[Source],
	[ItemType],
	[URL],
	[Domain],
	[Word],
	[Region],
	[DateTimeOfRequest],
	CASE	WHEN [Marker1] is NULL THEN 'Other' 
			ELSE [Marker1]
	END as [Marker1],
	CASE	WHEN [Marker1] = 'right' AND [ItemType] = 'AD' THEN [NumberOnPage] + 3
			WHEN ([Marker1] = 'central-bottom' OR [Marker1] = 'Bottom')	AND [ItemType] = 'AD' THEN [NumberOnPage] + 9
			ELSE [NumberOnPage]
	END as [NumberOnPage_v1],
	CASE	WHEN [Marker1] = 'right' AND [ItemType] = 'AD' THEN [NumberOnPage] * 100
			WHEN ([Marker1] = 'central-bottom' OR [Marker1] = 'Bottom')	AND [ItemType] = 'AD' THEN [NumberOnPage] * 100000
			ELSE [NumberOnPage]
	END as [NumberOnPage_ID],
	[NumberOnPage]
INTO #TempDomain
FROM [dbo].[SERP_Source_Data] aa
JOIN [dbo].[Dim_Campaign] ss ON aa.[Campaign_ID] = ss.[Campaign_ID]
JOIN [dbo].[Dim_Source] dd ON aa.[Source_ID] = dd.[Source_ID]
JOIN [dbo].[Dim_Type] ff ON aa.[Type_ID] = ff.[Type_ID]
JOIN [dbo].[Dim_URL] gg ON aa.[URL_ID] = gg.[URL_ID]
JOIN [dbo].[Dim_Word] hh ON aa.[Word_ID] = hh.[Word_ID]
JOIN [dbo].[Dim_Region] jj ON aa.[Region_ID] = jj.[Region_ID]
WHERE Campaign_Name LIKE @campaign_name


/*---------------------------------***************---------------------------------*/
/*--------------------------------Fixing wrong parsing-----------------------------*/


IF OBJECT_ID(N'tempdb..#TempPivotedResult') IS NOT NULL DROP TABLE  #TempPivotedResult
SELECT 
					--,[Day]
					[ItemType]
					,[Word]
					,[DateTimeOfRequest]
					--,COUNT([Word]) as [Quantity]
					--,SUM([Word]) as [SumNumberOnPage]
					--,COUNT([Word]) as [CountNumberOnPage]
					,SUM([1]) as [1]
					,SUM([2]) as [2]
					,SUM([3]) as [3]
					,SUM([4]) as [4]
					,SUM([5]) as [5]
					,SUM([6]) as [6]
					,SUM([7]) as [7]
					,SUM([8]) as [8]
					,SUM([9]) as [9]
					,SUM([10]) as [10]
					,SUM([11]) as [11]
					,SUM([12]) as [12]
					,SUM([13]) as [13]
					,SUM([14]) as [14]
					,SUM([15]) as [15]
					,SUM([16]) as [16]
					,SUM([17]) as [17]
					,SUM([18]) as [18]
					,SUM([Sum]) as [Sum]
					,SUM([Flag]) as [Flag]
				INTO #TempPivotedResult
				FROM (
					SELECT 
					[Word]
					,[ItemType]
					,[DateTimeOfRequest]
					, [1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],
					[1]+[2]+[3]+[4]+[5]+[6]+[7]+[8]+[9]+[10]+[11]+[12]+[13]+[14]+[15]+[16]+[17]+[18]+[19]+[20] as [Sum]
					,[11]+[12]+[13]+[14]+[15]+[16]+[17]+[18]+[19]+[20] as [Flag]
					--INTO #PivotNumberOnPage 
					FROM
						(SELECT 
							[Word]
							,[NumberOnPage]
							,[DateTimeOfRequest]
							--,[Day]
							,[ItemType]
							FROM #TempDomain
							where [Source] = 'yandex'
							and [Domain] <> 'Not_Collected'
							 ) as #SourcePivot
						PIVOT
							(
							COUNT(NumberOnPage)
							FOR NumberOnPage IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20])
							) as #PivotTable
					) aa
					group by [ItemType]
					,[Word]
					,[DateTimeOfRequest]
					order by [DateTimeOfRequest]


IF OBJECT_ID(N'tempdb..#TempDomainFixed') IS NOT NULL DROP TABLE  #TempDomainFixed

select  
	[Brand],
	[Campaign],
	aa.[ItemType],
	[Source],
	[URL],
	[Domain],
	aa.[Word],
	aa.NumberOnPage,
	[Marker1],
	ss.[Sum],
	aa.[DateTimeOfRequest],
	[Region]
INTO #TempDomainFixed
from #TempDomain aa
left join #TempPivotedResult ss
		on aa.word = ss.word and aa.DateTimeOfRequest = ss.DateTimeOfRequest and aa.ItemType = ss.ItemType
where aa.DateTimeOfRequest not in (select distinct DateTimeOfRequest 
								from #TempPivotedResult 
								where [Flag] > 0  and itemtype = 'organic')
								
/*---------------------------------***************---------------------------------*/


/*------------------------------Making new numeration------------------------------*/
/*---------------------------------***************---------------------------------*/

--This table will be used for joining with #TempDomain
SET NOCOUNT ON 
IF OBJECT_ID(N'tempdb..#Dim_NumOnPage') IS NOT NULL
			drop table #Dim_NumOnPage
create table #Dim_NumOnPage
(
	TotalID int not null,
	--[NumberOnPage_ID] int not null,
	--[New_NumberOnPage] int not null,
	[Bottom] int not null,
	[Right] int not null,
	[Top] int not null
)

declare @i int
declare @j int
declare @k int
declare @sumi int
declare @sumj int
declare @sumk int
declare @ID int
set @i = 0
set @j = 0
set @k = 0
set @sumi = 0
set @sumj = 0
set @sumk = 0
set @ID = 0
while @i < 5
begin
	set @sumj = 0
	set @sumi = @sumi + @i*100000
	while @j < 16
	begin
		set @sumk = 0
		set @sumj = @sumj + @j*100
		while @k<6
		begin
			set @sumk = @sumk + @k
			set @ID = @sumi+ @sumj+@sumk
			--print @ID
			insert into #Dim_NumOnPage (TotalID,[Bottom],[Right],[Top]) values
			(@ID,@i,@j,@k)
			set @k = @k +1
			if @k=6 break
		end
		set @k = 0
		set @j = @j +1
		if @j=16 break
		else continue
	end
	set @j = 0
	set @i = @i +1
	if @i = 5 break
	else continue
end
SET NOCOUNT OFF

IF OBJECT_ID(N'tempdb..#TempTotalAdsID') IS NOT NULL 
		DROP TABLE #TempTotalAdsID;

select	aa.Brand,
		aa.Campaign,
		aa.Source,
		aa.ItemType,
		aa.word,
		aa.DateTimeOfRequest,
		aa.[Region],
		sum(aa.NumberOnPage_ID) as [TotalAdsID]
into #TempTotalAdsID
from #TempDomain aa
group by aa.Brand,aa.Campaign,aa.Source,aa.ItemType,aa.word, aa.DateTimeOfRequest,[Region]

IF OBJECT_ID(N'tempdb..#TempDomainFixed2') IS NOT NULL DROP TABLE  #TempDomainFixed2

select aa.*,ss.TotalAdsID,dd.[Top],dd.[Right],dd.[Bottom],
	CASE	WHEN [Marker1] = 'right' AND aa.[ItemType] = 'AD' THEN [NumberOnPage] + [Top]
			WHEN ([Marker1] = 'central-bottom' OR [Marker1] = 'Bottom')	AND aa.[ItemType] = 'AD' THEN [NumberOnPage]+ [Top]+[Right]
			ELSE [NumberOnPage]
	END as [NumberOnPage_v2]
into #TempDomainFixed2
from #TempDomainFixed aa 
left join #TempTotalAdsID ss ON aa.Brand = ss.Brand
	and aa.Campaign = ss.Campaign
	and aa.Source = ss.Source
	and aa.ItemType = ss.ItemType
	and aa.word = ss.word
	and aa.DateTimeOfRequest = ss.DateTimeOfRequest
	and aa.[Region] = ss.[Region]
left join #Dim_NumOnPage dd ON ss.TotalAdsID = dd.TotalID

/*---------------------------------***************---------------------------------*/

------Making final table
------Currently NumberOnPage_v2 as NumberOnPage
IF OBJECT_ID(N'tempdb..#TempData') IS NOT NULL 
		DROP TABLE #TempData;

		SELECT aa.[Domain]
				,aa.[Source]
				--,aa.[Marker1]
				,aa.[ItemType]
				,aa.[Brand]
				,aa.[Campaign]
				,aa.[Word]
				,aa.[Region]
				,ss.[Quantity]
				,CONVERT(real,ss.[SumNumberOnPage])/CONVERT(real,ss.[CountNumberOnPage]) as [AverageNumberOnPage]
				--,ss.[CountDomain]
				--,dd.[CountDomainPerWord]
				,ff.[NumberOfRequest]
				,gg.[NumberOfRequestTotal]
				,ff.[NumberOfRequestAd]
				,[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16]
		INTO #TempData
		FROM (
				SELECT 
					[Domain]
					,[Source]
					--,[Marker1]
					--,[Day]
					,[ItemType]
					,[Brand]
					,[Campaign]
					,[Word]
					,[Region]
					--,COUNT([Word]) as [Quantity]
					--,SUM([Word]) as [SumNumberOnPage]
					--,COUNT([Word]) as [CountNumberOnPage]
					,SUM([1]) as [1]
					,SUM([2]) as [2]
					,SUM([3]) as [3]
					,SUM([4]) as [4]
					,SUM([5]) as [5]
					,SUM([6]) as [6]
					,SUM([7]) as [7]
					,SUM([8]) as [8]
					,SUM([9]) as [9]
					,SUM([10]) as [10]
					,SUM([11]) as [11]
					,SUM([12]) as [12]
					,SUM([13]) as [13]
					,SUM([14]) as [14]
					,SUM([15]) as [15]
					,SUM([16]) as [16]
				FROM (
					SELECT [Domain]
					,[Url]
					,[Word]
					,[Source]
					,[Region]
					--,[Marker1]
					,[ItemType]
					,[Brand]
					,[Campaign]
					, [1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16] --INTO #PivotNumberOnPage 
					FROM
						(SELECT [Domain]
							,[Url]
							,[Brand]
							,[Campaign]
							,[Region]
							,[Source]
							--,[Marker1]
							,[Word]
							,NumberOnPage_v2 as [NumberOnPage]
							--,[Day]
							,[ItemType]
							FROM #TempDomainFixed2
							 ) as #SourcePivot
						PIVOT
							(
							COUNT([NumberOnPage])
							FOR [NumberOnPage] IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16])
							) as #PivotTable
					) aa
				GROUP BY [Domain],[Source],[Word],[ItemType],[Brand],[Campaign],[Region]--,[Marker1]
			) aa
			JOIN (SELECT 
					[Domain]
					,[Source]
					--,[Marker1]
					--,[Day]
					,[ItemType]
					,[Brand]
					,[Campaign]
					,[Word]
					,[Region]
					,COUNT([Word]) as [Quantity]
					,SUM([NumberOnPage]) as [SumNumberOnPage]
					,COUNT([NumberOnPage]) as [CountNumberOnPage]
					FROM (SELECT [Domain]
							,[Url]
							,[Brand]
							,[Campaign]
							,[Source]
							,[Region]
							--,[Marker1]
							,[Word]
							,NumberOnPage_v2 as [NumberOnPage]
							--,[Day]
							,[ItemType]
							FROM #TempDomainFixed2
							) aa
					GROUP BY [Domain],[Source],[Word],[ItemType],[Brand],[Campaign],[Region]--,[Marker1]
					) ss
				ON aa.[Domain]=ss.[Domain] AND 
				aa.[Source]=ss.[Source] AND 
				--aa.[Marker1]=ss.[Marker1] AND
				aa.[Word]=ss.[Word] AND
				aa.[ItemType]=ss.[ItemType] AND
				aa.[Brand]=ss.[Brand] AND
				aa.[Campaign]=ss.[Campaign] AND 
				aa.[Region] = ss.[Region]
			JOIN #TempWordNumber ff
				ON 	aa.[Source] = ff.[Source] 
				AND aa.[Word] = ff.[Word]
				AND aa.[Campaign] = ff.[Campaign_Name]
				AND aa.[Brand] = ff.[Brand_Name]
				AND aa.[Region] = ff.[Region]
			JOIN #TempRequestNumber gg
				ON 	aa.[Source] = gg.[Source]
				AND aa.[Campaign] = gg.[Campaign_Name]
				AND aa.[Brand] = gg.[Brand_Name]
				AND aa.[Region] = gg.[Region]


------Fixing [Quantity] for organic search with respect to 'Not_Collected' results
	IF OBJECT_ID(N'tempdb..#Temp_NotCollected') IS NOT NULL 
		DROP TABLE #Temp_NotCollected;

	SELECT * INTO #Temp_NotCollected FROM #TempData WHERE [Domain] ='Not_Collected'

	UPDATE aa
	SET aa.[Quantity] = aa.[Quantity] + ss.[Quantity]
	FROM #TempData aa
		JOIN #Temp_NotCollected ss 
			ON aa.[Source] = ss.[Source]
			--AND aa.[Marker1] = ss.[Marker1]
			AND aa.[Word] = ss.[Word]
			AND aa.[ItemType] = ss.[ItemType]
			AND aa.[Brand] = ss.[Brand]
			AND aa.[Campaign] = ss.[Campaign]
			AND aa.[ItemType] = 'ORGANIC'

	UPDATE aa
		SET aa.[Quantity] = aa.[Quantity] /2
		FROM #TempData aa WHERE aa.[ItemType] = 'ORGANIC'
		AND [Domain] ='Not_Collected'
		

		/*
		Select distinct aa.Word,ff.Word_Group
		from #TempData aa
		join [SERP_Config].[dbo].[Dim_Words] ss on aa.[Word] = ss.[Word]
		join [SERP_Config].[dbo].[Dim_Word_Groups] ff on ss.[Word_Group_ID] = ff.[Word_Group_ID]
		*/
		--select * from #TempData aa 
		/*select distinct aa.*, [Word_Group] from #TempData aa 
		JOIN 
			(
			select distinct aa.[Campaign_Name],dd.[Word_Group],ss.[Word] from [SERP_Config].[dbo].[Dim_Campaigns] aa
			join [SERP_Config].[dbo].[Dim_Word_Groups] dd on aa.[Campaign_ID] = dd.[Campaign_ID]
			join [SERP_Config].[dbo].[Dim_Words] ss on ss.[Word_Group_ID] = dd.[Word_Group_ID]
			) ss ON aa.[Campaign] = ss.[Campaign_Name] AND aa.[Word] = ss.[Word]
			*/
/*-------------------------------logical checking------------------------------*/
/*
select distinct aa.Source,aa.Campaign
from #TempData aa
where aa.AverageNumberOnPage > 10
and ItemType = 'organic'
and Source = 'yandex'

update #TempData set Brand = 'IKEA' where Brand = 'Ikea'
update #TempData set Campaign = 'IKEA_19_04' where Campaign = 'Ikea_19_04'
select distinct Campaign from #TempData
--select top 100 * from #TempData where  [Domain] like '%wikipedia%'
--select top 1000 * from #TempData where  [Domain] like '%ikea.ru%' and ItemType = 'AD'and Source = 'Yandex'*/
/*-------------------------------logical checking------------------------------*/
--DROP TABLE SERP_Aggregated_Nivea
/*SELECT * 
INTO [Reports_And_Catalogs].[dbo].[AggregatedWebStat_v2_NoDate] 
FROM #TempData -- WHERE [ItemType] = 'AD'
*/ 
--select distinct [Word] from #TempData where substring([Word],1,1) = ' '
/*-------------------------------Merging data into [AggregatedWebStat_NoDate]-----------------------------*/

DELETE FROM [Reports_And_Catalogs].[dbo].[AggregatedWebStat_v2_Region] WHERE Campaign IN (SELECT DISTINCT Campaign FROM #TempData)

INSERT INTO [Reports_And_Catalogs].[dbo].[AggregatedWebStat_v2_Region] (
	[Domain]
      ,[Source]
      ,[ItemType]
      ,[Brand]
	  ,[Region]
      ,[Campaign]
      ,[Word]
      ,[Quantity]
      ,[AverageNumberOnPage]
      ,[NumberOfRequest]
      ,[1]
      ,[2]
      ,[3]
      ,[4]
      ,[5]
      ,[6]
      ,[7]
      ,[8]
      ,[9]
      ,[10]
      ,[11]
      ,[12]
      ,[13]
      ,[14]
      ,[15]
      ,[16]
      ,[NumberOfRequestTotal]
      ,[NumberOfRequestAd]
	)
SELECT [Domain]
      ,[Source]
      ,[ItemType]
      ,[Brand]
	  ,[Region]
      ,[Campaign]
      ,[Word]
      ,[Quantity]
      ,[AverageNumberOnPage]
      ,[NumberOfRequest]
      ,[1]
      ,[2]
      ,[3]
      ,[4]
      ,[5]
      ,[6]
      ,[7]
      ,[8]
      ,[9]
      ,[10]
      ,[11]
      ,[12]
      ,[13]
      ,[14]
      ,[15]
      ,[16]
      ,[NumberOfRequestTotal]
      ,[NumberOfRequestAd]
	FROM #TempData

	/*
	select distinct convert(nvarchar(255),word)
	from [Reports_And_Catalogs].[dbo].[AggregatedWebStat_NoDate]
	where word not in (select distinct Word from [BudgetForecast].[dbo].[view_Shows_Average])
	*/
	/*
	update aa
	set [MonthlyShowNumber] = ss.[AverageShows]
	from [Reports_And_Catalogs].[dbo].[AggregatedWebStat_NoDate] aa
	join [BudgetForecast].[dbo].[view_Shows_Average] ss
	on aa.[Word] = ss.[Word]
	--and aa.[Source] = N'YANDEX'
	*/



/*------------------------------------------*/

--ÑKÑÄÑèÑÜÑÜÑyÑàÑyÑuÑ~ÑÑÑç ÑtÑ|Ñë ÑÅÑuÑÇÑuÑrÑÄÑtÑp Ñr Avg ÑÇÑpÑÉÑÉÑâÑyÑÑÑpÑ~Ñç ÑyÑx Google Keyword Estimator
/*
IF OBJECT_ID(N'tempdb..#TempGoogleForecaster') IS NOT NULL 
		DROP TABLE #TempGoogleForecaster;

SELECT 
	[Word],
	[Region],
	[Month],
	[KeywordMatchType],
	'Google' as [Source],
	/*([MinClicksPerDay]+[MaxClicksPerDay])/2 as [AvgClicksPerDay],
	([MinClicksPerDay]+[MaxClicksPerDay])/2*30*0.987 as [AvgClicksPerMonth],
	([MinImpressionsPerDay]+[MaxImpressionsPerDay])/2 as [AvgImpressionsPerDay],
	([MinImpressionsPerDay]+[MaxImpressionsPerDay])/2*30*0.913 as [AvgImpressionsPerMonth]
	*/
	[MaxClicksPerDay] as [AvgClicksPerDay],
	[MaxClicksPerDay]*30*0.987 as [AvgClicksPerMonth],
	[MaxImpressionsPerDay] as [AvgImpressionsPerDay],
	[MaxImpressionsPerDay]*30*0.913 as [AvgImpressionsPerMonth]

--INTO #TempGoogleForecaster
FROM (	SELECT [Region],
			[Word],
			[KeywordMatchType],
			[Month],
			AVG([MinClicksPerDay]) as [MinClicksPerDay],
			AVG([MinImpressionsPerDay]) as [MinImpressionsPerDay],
			AVG([MaxClicksPerDay]) as [MaxClicksPerDay],
			AVG([MaxImpressionsPerDay]) as [MaxImpressionsPerDay]
		FROM (	SELECT [Region],
					[Word],
					[KeywordMatchType],
					[MinClicksPerDay],
					[MinImpressionsPerDay],
					[MaxClicksPerDay],
					[MaxImpressionsPerDay],
					MONTH([CreationDate]) as [Month]
				FROM [GAdWForecaster].[dbo].[view_GAdWForecaster]
				WHERE [KeywordMatchType] = 'BROAD'
			) aa
	GROUP BY [Region],
		[Word],
		[KeywordMatchType],
		[Month]
	) aa
	
SELECT * FROM #TempGoogleForecaster

IF OBJECT_ID(N'tempdb..#TempYandexForecaster') IS NOT NULL 
		DROP TABLE #TempYandexForecaster;

SELECT [Region],
	[Month],
	[Word],
	'Yandex' as [Source],
	AVG([Clicks]) as [Clicks],
	AVG([Shows]) as [Shows]
INTO #TempYandexForecaster
FROM(	SELECT [Region],
			MONTH([CreationDate]) as [Month],
			[Word],
			[Clicks],
			[Shows]
		FROM [BudgetForecast].[dbo].[view_Budget_Forecast]
	) aa
GROUP BY [Region],
	[Month],
	[Word]


SELECT  aa.[Domain]
		,aa.[Source]
		,aa.[Marker1]
		,aa.[ItemType]
		,aa.[Brand]
		,aa.[Campaign]
		,aa.[Word]
		,aa.[Quantity]
		,aa.[AverageNumberOnPage]
		,aa.[NumberOfRequest]
		--,[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16]
		,CONVERT(int,[AvgClicksPerMonth]) as [AvgClicksPerMonth]
		,CONVERT(int,[AvgImpressionsPerMonth]) as [AvgImpressionsPerMonth]
FROM #TempData aa 
LEFT JOIN #TempGoogleForecaster ss ON CONVERT(nvarchar(500),aa.[Word]) = CONVERT(nvarchar(500),ss.[Word])
AND aa.[Source] = ss.[Source]*/