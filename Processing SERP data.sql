USE [WebStatLight]
GO
/****** Object:  StoredProcedure [dbo].[sp_processing_SERP_data]    Script Date: 28.11.2017 10:27:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Maxim Pavlov>
-- Create date: <29/10/2015
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[sp_processing_SERP_data]
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID(N'tempdb..#Processed_StatisitcItem') IS NOT NULL 
	DROP TABLE #Processed_StatisitcItem

	CREATE TABLE #Processed_StatisitcItem (
		[ID] bigint NOT NULL
		,[NumberOnPage] bigint NOT NULL
		,[Url] nvarchar(max) NOT NULL
		,[Campaign] nvarchar(max) NOT NULL
		,[Source] nvarchar(50) NOT NULL
		,[Marker1] nvarchar(50)NULL
		,[Marker2] nvarchar(50)NULL
		,[Marker3] nvarchar(50)NULL
		,[DateTimeOfRequest] datetime2(7) NOT NULL
		,[ItemType] nvarchar(50) NOT NULL
		,[Word] nvarchar(2000) NOT NULL
		,[Brand]  nvarchar(2000) NOT NULL
		,[Region]  nvarchar(100) NULL
		,[Host] nvarchar(100) NULL
		,[SerptTextId] bigint NULL
		,URL_ID bigint NULL
		,Campaign_ID int NULL
		,Source_ID  smallint NULL
		,Word_ID bigint NULL
		,[Type_ID] smallint NULL
		,[Region_ID] int NULL
	  )

	INSERT INTO #Processed_StatisitcItem  
	([Id]
	  ,[NumberOnPage]
      ,[Url]
      ,[Campaign]
      ,[Source]
      ,[Marker1]
      ,[Marker2]
      ,[Marker3]
      ,[DateTimeOfRequest]
      ,[ItemType]
      ,[Word]
      ,[Brand]
      ,[SerptTextId]
	  ,[Region]
	  ,[Host])
	 SELECT [Id]
	  ,[NumberOnPage]
      ,[Url]
      ,[Campaign]
      ,[Source]
      ,[Marker1]
      ,[Marker2]
      ,[Marker3]
      ,[DateTimeOfRequest]
      ,[ItemType]
      ,case when substring([Word],1,1) = ' ' then substring([Word],2,len([Word])-1)
	  else [Word]
	  end
      ,[Brand]
      ,[SerptTextId]
	  ,isnull([Region],N'Default regionality')
	  ,[Host]
	  FROM [WebStatLight].[dbo].[StatisticItem]
	  

	------- Filling Dim_URL -------

	IF OBJECT_ID(N'tempdb..#URL_List') IS NOT NULL 
	DROP TABLE #URL_List

	SELECT DISTINCT CONVERT(nvarchar(1000), [Url]) as [Url]
	INTO #URL_List
	FROM #Processed_StatisitcItem

	INSERT INTO Dim_URL
		([Url])
	SELECT aa.[Url]
	FROM #URL_List aa
		LEFT JOIN Dim_URL ss
			ON aa.[Url] = ss.[Url]
	WHERE ss.URL_ID IS NULL

	UPDATE aa
	SET aa.URL_ID = ss.URL_ID
	FROM #Processed_StatisitcItem aa
		JOIN Dim_URL ss ON  CONVERT(nvarchar(1000), aa.[Url]) = ss.[Url]

	DROP TABLE #URL_List

	------- Filling [Dim_Campaign] -------

	IF OBJECT_ID(N'tempdb..#Campaign_List') IS NOT NULL 
	DROP TABLE #Campaign_List

	SELECT DISTINCT [Brand],[Campaign]
	INTO #Campaign_List
	FROM #Processed_StatisitcItem

	INSERT INTO [dbo].[Dim_Campaign]
		(Brand_Name, Campaign_Name)
	SELECT [Brand],[Campaign]
	FROM #Campaign_List aa
		LEFT JOIN [Dim_Campaign] ss
			ON aa.[Campaign] = ss.[Campaign_Name]
			AND aa.[Brand] = ss.Brand_Name
	WHERE ss.[Campaign_ID] IS NULL

	UPDATE aa
	SET aa.[Campaign_ID] = ss.[Campaign_ID]
	FROM #Processed_StatisitcItem aa
		JOIN [Dim_Campaign] ss 
		ON aa.[Campaign] = ss.[Campaign_Name]
		AND aa.[Brand] = ss.Brand_Name

	DROP TABLE #Campaign_List

	------- Filling Dim_Source -------
	
	IF OBJECT_ID(N'tempdb..#Source_List') IS NOT NULL 
	DROP TABLE #Source_List

	SELECT DISTINCT[Source]
	INTO #Source_List
	FROM #Processed_StatisitcItem

	INSERT INTO Dim_Source
		(Source)
	SELECT aa.[Source]
	FROM #Source_List aa
		LEFT JOIN Dim_Source ss
			ON aa.[Source] = ss.[Source]
	WHERE ss.Source_ID IS NULL

	UPDATE aa
	SET aa.Source_ID = ss.Source_ID
	FROM #Processed_StatisitcItem aa
		JOIN Dim_Source ss ON aa.[Source] = ss.[Source]

	DROP TABLE #Source_List

	------- Filling Dim_Type -------

	IF OBJECT_ID(N'tempdb..#ItemType_List') IS NOT NULL 
	DROP TABLE #ItemType_List

	SELECT DISTINCT[ItemType]
	INTO #ItemType_List
	FROM #Processed_StatisitcItem

	INSERT INTO Dim_Type
		(ItemType)
	SELECT aa.[ItemType]
	FROM #ItemType_List aa
		LEFT JOIN Dim_Type ss
			ON aa.ItemType = ss.ItemType
	WHERE ss.Type_ID IS NULL

	UPDATE aa
	SET aa.Type_ID = ss.Type_ID
	FROM #Processed_StatisitcItem aa
		JOIN Dim_Type ss ON aa.ItemType = ss.ItemType

	DROP TABLE #ItemType_List

	------- Filling Dim_Word -------

	IF OBJECT_ID(N'tempdb..#Word_List') IS NOT NULL 
	DROP TABLE #Word_List

	SELECT DISTINCT convert(nvarchar(1000),Word) as Word
	INTO #Word_List
	FROM #Processed_StatisitcItem

	INSERT INTO Dim_Word
		(Word)
	SELECT convert(nvarchar(1000),aa.Word)
	FROM #Word_List aa
		LEFT JOIN Dim_Word ss
			ON convert(nvarchar(1000),aa.Word) = ss.Word
	WHERE ss.Word_ID IS NULL

	UPDATE aa
	SET aa.Word_ID = ss.Word_ID
	FROM #Processed_StatisitcItem aa
		JOIN Dim_Word ss ON convert(nvarchar(1000),aa.Word) = ss.Word

	DROP TABLE #Word_List

	
	------- Filling Dim_Region -------

	IF OBJECT_ID(N'tempdb..#Region_List') IS NOT NULL 
	DROP TABLE #Region_List

	SELECT DISTINCT [Region]
	INTO #Region_List
	FROM #Processed_StatisitcItem

	INSERT INTO Dim_Region
		(Region)
	SELECT aa.[Region]
	FROM #Region_List aa
		LEFT JOIN Dim_Region ss
			ON aa.[Region] = ss.[Region]
		WHERE ss.Region_ID IS NULL

	UPDATE aa
	SET aa.Region_ID = ss.Region_ID
	FROM #Processed_StatisitcItem aa
		JOIN Dim_Region ss ON aa.[Region] = ss.[Region]

	DROP TABLE #Region_List

	------- Filling final table -------
	--TRUNCATE TABLE [dbo].[SERP_Source_Data]

	MERGE INTO [dbo].[SERP_Source_Data] as TARGET
	USING #Processed_StatisitcItem as SOURCE
	ON TARGET.[URL_ID] = SOURCE.[URL_ID]
	AND TARGET.[Campaign_ID] = SOURCE.[Campaign_ID]
	AND TARGET.[Source_ID] = SOURCE.[Source_ID]
	AND TARGET.[Word_ID] = SOURCE.[Word_ID]
	AND TARGET.[Type_ID] = SOURCE.[Type_ID]
	AND TARGET.[Region_ID] = SOURCE.[Region_ID]
	AND TARGET.[NumberOnPage] = SOURCE.[NumberOnPage]
	/*AND TARGET.[Marker1] = SOURCE.[Marker1]
	AND TARGET.[Marker2] = SOURCE.[Marker2]
	AND TARGET.[Marker3] = SOURCE.[Marker3]*/
	AND CONVERT(datetime,TARGET.[DateTimeOfRequest]) = CONVERT(datetime,SOURCE.[DateTimeOfRequest])
	--AND TARGET.[SerpTextId] = SOURCE.[SerptTextId]
	WHEN NOT MATCHED THEN 
	INSERT ([URL_ID]
      ,[Campaign_ID]
      ,[Source_ID]
      ,[Word_ID]
      ,[Type_ID]
      ,[NumberOnPage]
      ,[Marker1]
      ,[Marker2]
      ,[Marker3]
      ,[DateTimeOfRequest]
      ,[SerpTextId]
	  ,[Region_ID])
	  VALUES (SOURCE.[URL_ID]
      ,SOURCE.[Campaign_ID]
      ,SOURCE.[Source_ID]
      ,SOURCE.[Word_ID]
      ,SOURCE.[Type_ID]
      ,SOURCE.[NumberOnPage]
      ,SOURCE.[Marker1]
      ,SOURCE.[Marker2]
      ,SOURCE.[Marker3]
      ,SOURCE.[DateTimeOfRequest]
      ,SOURCE.[SerptTextId]
	  ,SOURCE.[Region_ID]);

	  SELECT [ID] INTO #Temp_IDs FROM #Processed_StatisitcItem
	  
	  --select * into [StatisticItem_Backup] from #Processed_StatisitcItem
	  --TRUNCATE TABLE[WebStatLight].[dbo].[StatisticItem_Backup]
	INSERT INTO [WebStatLight].[dbo].[StatisticItem_Backup]
	([id]
	  ,[NumberOnPage]
      ,[Url]
      ,[Campaign]
      ,[Source]
      ,[Marker1]
      ,[Marker2]
      ,[Marker3]
      ,[DateTimeOfRequest]
      ,[ItemType]
      ,[Word]
      ,[Brand]
      ,[SerptTextId]
	  ,[Host]
	  ,[Region])
	 SELECT [id]
	  ,[NumberOnPage]
      ,[Url]
      ,[Campaign]
      ,[Source]
      ,[Marker1]
      ,[Marker2]
      ,[Marker3]
      ,[DateTimeOfRequest]
      ,[ItemType]
      ,[Word]
      ,[Brand]
      ,[SerptTextId]
	  ,[Host]
	  ,[Region]
	  FROM #Processed_StatisitcItem

	  DELETE FROM [dbo].[StatisticItem] WHERE [Id] IN (SELECT [ID] FROM #Temp_IDs)

	  DROP TABLE #Processed_StatisitcItem

	  DROP TABLE #Temp_IDs

	  -------Updating [Domain] in [Dim_URL]---------

		IF OBJECT_ID(N'tempdb..#Temp') IS NOT NULL 
		DROP TABLE #Temp;

		SELECT DISTINCT [Url] INTO #Temp FROM [dbo].[Dim_URL] WHERE  [Domain] is NULL

		
		IF OBJECT_ID(N'tempdb..#Temp_1') IS NOT NULL 
		DROP TABLE #Temp_1;

		SELECT [Url],
		CASE WHEN CHARINDEX('://',[Url]) > 0 THEN SUBSTRING([Url],CHARINDEX('://',[Url])+3,LEN([Url])- CHARINDEX('://',[Url])+2)
		ELSE [Url]
		END as [Url_1]
		INTO #Temp_1
		FROM #Temp
		
		IF OBJECT_ID(N'tempdb..#Temp_1_1') IS NOT NULL 
		DROP TABLE #Temp_1_1;

		SELECT [Url],
		CASE WHEN CHARINDEX('//',[Url_1]) > 0 THEN SUBSTRING([Url_1],CHARINDEX('//',[Url_1])+2,LEN([Url_1])- CHARINDEX('//',[Url_1])+1)
		ELSE [Url_1]
		END as [Url_1]
		INTO #Temp_1_1
		FROM #Temp_1

		IF OBJECT_ID(N'tempdb..#Temp_2') IS NOT NULL 
		DROP TABLE #Temp_2;

		SELECT [Url],[Url_1],
		CASE WHEN CHARINDEX('www.',[Url_1]) > 0 THEN SUBSTRING([Url_1],CHARINDEX('www.',[Url_1])+4,LEN([Url_1])- CHARINDEX('www.',[Url_1])+3)
		ELSE [Url_1]
		END as [Url_2]
		INTO #Temp_2
		FROM #Temp_1_1

		IF OBJECT_ID(N'tempdb..#Temp_3') IS NOT NULL 
		DROP TABLE #Temp_3;

		SELECT [Url],[Url_1],[Url_2],
		CASE WHEN CHARINDEX('/',[Url_2]) > 0 THEN SUBSTRING([Url_2],1,CHARINDEX('/',[Url_2])-1)ELSE [Url_2]
		END as [Url_3]
		INTO #Temp_3
		FROM #Temp_2
		


		---O$en144q

		
		IF OBJECT_ID(N'tempdb..#Temp_4') IS NOT NULL 
		DROP TABLE #Temp_4;

		SELECT [Url],[Url_1],
		[Url_2],[Url_3],
		CASE WHEN CHARINDEX(' &rsaquo',[Url_3]) > 0 THEN 
		SUBSTRING([Url_3],1,CHARINDEX(' &rsaquo',[Url_3])-1)ELSE [Url_3]
		END as [Url_4]
		INTO #Temp_4
		FROM #Temp_3

		/*
		SELECT [Url],[Url_3],[Url_4],
		CASE WHEN CHARINDEX('.',SUBSTRING([Url_4],CHARINDEX(N'.',[Url_4])+1,LEN([Url_4])- CHARINDEX(N'.',[Url_4]))) > 0 THEN 
		SUBSTRING([Url_4],CHARINDEX(N'.',[Url_4])+1,LEN([Url_4])- CHARINDEX(N'.',[Url_4]))
		ELSE [Url_4]
		END as [Url_5]
		INTO #Temp_5
		FROM #Temp_4

		SELECT [Url],[Url_4],[Url_5],
		CASE WHEN CHARINDEX(';',[Url_5]) > 0 THEN 
		SUBSTRING([Url_5],CHARINDEX(N';',[Url_5])+1,LEN([Url_5])- CHARINDEX(N';',[Url_5]))
		ELSE [Url_5]
		END as [Url_6]
		INTO #Temp_6
		FROM #Temp_5

		SELECT [Url],[Url_5],[Url_6],
		CASE WHEN CHARINDEX(N'.',SUBSTRING([Url_6],CHARINDEX(N'.',[Url_6])+1,LEN([Url_6])- CHARINDEX(N'.',[Url_6]))) > 0 THEN 
		SUBSTRING([Url_6],CHARINDEX(N'.',[Url_6])+1,LEN([Url_6])- CHARINDEX(N'.',[Url_6]))
		ELSE [Url_6]
		END as [Url_7]
		INTO #Temp_7
		FROM #Temp_6


		SELECT [Url],--[Url_6],[Url_7],
		CASE WHEN CHARINDEX(N'.',SUBSTRING([Url_7],CHARINDEX(N'.',[Url_7])+1,LEN([Url_7])- CHARINDEX(N'.',[Url_7]))) > 0 THEN 
		SUBSTRING([Url_7],CHARINDEX(N'.',[Url_7])+1,LEN([Url_7])- CHARINDEX(N'.',[Url_7]))
		ELSE [Url_7]
		END as [Url_8]
		INTO #Temp_8
		FROM #Temp_7

		SELECT [Url],
		CASE WHEN CHARINDEX('›',[Url_8]) > 0 THEN SUBSTRING([Url_8],1,CHARINDEX('›',[Url_8])-1)ELSE [Url_8]
		END as [Domain]
		INTO #Temp_9
		FROM #Temp_8

		*/
		
		IF OBJECT_ID(N'tempdb..#Temp_6') IS NOT NULL 
		DROP TABLE #Temp_6;

		SELECT [Url],[Url_4],
		CASE WHEN CHARINDEX('?utm',[Url_4]) > 0 THEN 
		SUBSTRING([Url_4],1, CHARINDEX(N'?utm',[Url_4])-1)
		ELSE [Url_4]
		END as [Url_6]
		INTO #Temp_6
		FROM #Temp_4
		
		IF OBJECT_ID(N'tempdb..#Temp_6_1') IS NOT NULL 
		DROP TABLE #Temp_6_1;

		SELECT [Url],[Url_4],
		CASE WHEN CHARINDEX('?clid',[Url_4]) > 0 THEN 
		SUBSTRING([Url_4],1, CHARINDEX(N'?clid',[Url_4])-1)
		ELSE [Url_4]
		END as [Url_6]
		INTO #Temp_6_1
		FROM #Temp_6

		IF OBJECT_ID(N'tempdb..#Temp_6_2') IS NOT NULL 
		DROP TABLE #Temp_6_2;

		SELECT [Url],[Url_4],
		CASE WHEN CHARINDEX('?cid',[Url_6]) > 0 THEN 
		SUBSTRING([Url_6],1, CHARINDEX(N'?cid',[Url_6])-1)
		ELSE [Url_4]
		END as [Url_6]
		INTO #Temp_6_2
		FROM #Temp_6_1


		IF OBJECT_ID(N'tempdb..#Temp_7') IS NOT NULL 
		DROP TABLE #Temp_7;

		SELECT [Url],[Url_6],
		CASE WHEN CHARINDEX(';',[Url_6]) > 0 THEN 
		SUBSTRING([Url_6],CHARINDEX(N';',[Url_6])+1,LEN([Url_6])- CHARINDEX(N';',[Url_6]))
		ELSE [Url_6]
		END as [Url_7]
		INTO #Temp_7
		FROM #Temp_6

		IF OBJECT_ID(N'tempdb..#Temp_9') IS NOT NULL 
		DROP TABLE #Temp_9;


		SELECT [Url],
		CASE WHEN CHARINDEX('›',[Url_7]) > 0 THEN SUBSTRING([Url_7],1,CHARINDEX('›',[Url_7])-1)ELSE [Url_7]
		END as [Domain]
		INTO #Temp_9
		FROM #Temp_7

		UPDATE aa
		SET aa.[Domain] = CONVERT(nvarchar(255),ss.[Domain])
		FROM [dbo].[Dim_URL] aa JOIN #Temp_9 ss ON aa.[URL] = CONVERT(nvarchar(1000),ss.[Url])

		select distinct dd.Domain,ss.Campaign_Name, ss.Brand_Name
		INTO #Temp_Link_Campaign_Domain
		from SERP_Source_Data aa
		JOIN Dim_Campaign ss ON aa.Campaign_ID = ss.Campaign_ID
		JOIN Dim_URL dd ON aa.URL_ID = dd.URL_ID

		MERGE INTO [dbo].[Link_Campaign_Domain] as TARGET
		USING #Temp_Link_Campaign_Domain as SOURCE
		ON TARGET.[Domain] = SOURCE.[Domain]
		AND TARGET.[Campaign_Name] = SOURCE.[Campaign_Name]
		AND TARGET.[Brand_Name] = SOURCE.[Brand_Name]
		WHEN NOT MATCHED THEN
		INSERT ([Domain],
				[Campaign_Name],
				[Brand_Name])
		VALUES (SOURCE.[Domain],
				SOURCE.[Campaign_Name],
				SOURCE.[Brand_Name]);

END
