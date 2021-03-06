USE [AdEx_data]
GO
/****** Object:  StoredProcedure [dbo].[Process_Data]    Script Date: 28.11.2017 10:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Maxim Pavlov>
-- Create date: <01.03.2017>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[Process_Data]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	/*
	--DROP TABLE JJ_Adex_Data_Raw
	CREATE TABLE JJ_Adex_Data_Raw
	(
	[Media Type] nvarchar(255) not null
      ,[Type] nvarchar(255) not null
      ,[Month] nvarchar(16) not null
      ,[Advertisers list] nvarchar(255) not null
      ,[Brands list] nvarchar(255) not null
      ,[Models list] nvarchar(255) not null
      ,[Model] nvarchar(255) not null
      ,[AdID] int not null
      ,[Article list4] nvarchar(255) not null
      ,[Format_TV_type] nvarchar(32) not null
      ,[Region] nvarchar(32) not null
      ,[Edition Type] nvarchar(32) not null
      ,[Quantity] smallint null
      ,[Cost Gross] real null
      ,[Year] smallint not null
      ,[Month Name] nvarchar(16) not null
      ,[Month Number] tinyint
      ,[Quart] nvarchar(8)
      ,[USD]real null
      ,[RUR]real null
      ,[EUR]real null
	)

	*/

	delete from [JJ_Adex_Data_source] where [RUR] is null or [RUR] = '' or [Discount] = 'Discount' or [RUR] ='0'

	MERGE INTO JJ_Adex_Data_Raw AS TARGET
	USING ( SELECT DISTINCT
			convert(nvarchar(255),[MediaType]) as [Media Type]
		  ,convert(nvarchar(255),[Type]) as [Type]
		  ,convert(nvarchar(16),[Month]) as [Month]
		  ,convert(nvarchar(255),[Advertiserslist]) as [Advertisers list]
		  ,convert(nvarchar(255),[Brandslist]) as [Brands list]
		  ,convert(nvarchar(255),[Modelslist]) as [Models list] 
		  ,convert(nvarchar(255),[Model]) as [Model]
		  ,convert(int,[AdID]) as [AdID]
		  ,convert(nvarchar(255),[Articlelist4]) as [Article list4]
		  ,convert(nvarchar(32),[Format_TV_type]) as [Format_TV_type]
		  ,convert(nvarchar(32),[Region]) as [Region]
		  ,convert(nvarchar(32),[EditionType]) as [Edition Type]
		  ,convert(smallint,replace(replace([Quantity],N'я',''),' ','')) as [Quantity]
		  ,convert(real,replace(replace([CostGross],N'я',''),' ','')) as [Cost Gross]
		  ,convert(smallint,[Year]) as [Year]
		  ,convert(nvarchar(16),[MonthName]) as [Month Name]
		  ,convert(tinyint,[MonthNumber])  as [Month Number]
		  ,convert(nvarchar(8),[Quart]) as [Quart]
		  ,convert(real,replace(replace([USD],' ',''),',','.')) as [USD]
		  ,convert(real,replace(replace([RUR],' ',''),',','.')) as [RUR]
		  ,convert(real,replace(replace([EUR],' ',''),',','.')) as [EUR]
		  FROM [AdEx_data].[dbo].[JJ_Adex_Data_source] WHERE [Month] <> ''
	) 
	AS SOURCE ON
	TARGET.[Media Type]=SOURCE.[Media Type] AND
	TARGET.[Type]=SOURCE.[Type] AND
	TARGET.[Month]=SOURCE.[Month] AND
	TARGET.[Advertisers list]=SOURCE.[Advertisers list] AND
	TARGET.[Brands list]=SOURCE.[Brands list] AND
	TARGET.[Models list]=SOURCE.[Models list] AND
	TARGET.[Model]=SOURCE.[Model] AND
	TARGET.[AdID]=SOURCE.[AdID] AND
	TARGET.[Article list4]=SOURCE.[Article list4] AND
	TARGET.[Format_TV_type]=SOURCE.[Format_TV_type] AND
	TARGET.[Region]=SOURCE.[Region] AND
	TARGET.[Edition Type]=SOURCE.[Edition Type]
	WHEN MATCHED THEN UPDATE SET
	[Quantity]=SOURCE.[Quantity],
	[Cost Gross]=SOURCE.[Cost Gross],
	[Year]=SOURCE.[Year],
	[Month Name]=SOURCE.[Month Name],
	[Month Number]=SOURCE.[Month Number],
	[Quart]=SOURCE.[Quart],
	[USD]=SOURCE.[USD],
	[RUR]=SOURCE.[RUR],
	[EUR]=SOURCE.[EUR]
	WHEN NOT MATCHED THEN INSERT
	(
	[Media Type]
      ,[Type]
      ,[Month]
      ,[Advertisers list]
      ,[Brands list]
      ,[Models list]
      ,[Model]
      ,[AdID]
      ,[Article list4]
      ,[Format_TV_type]
      ,[Region]
      ,[Edition Type]
      ,[Quantity]
      ,[Cost Gross]
      ,[Year]
      ,[Month Name]
      ,[Month Number]
      ,[Quart]
      ,[USD]
      ,[RUR]
      ,[EUR]
	)
	VALUES
	(
	SOURCE.[Media Type]
      ,SOURCE.[Type]
      ,SOURCE.[Month]
      ,SOURCE.[Advertisers list]
      ,SOURCE.[Brands list]
      ,SOURCE.[Models list]
      ,SOURCE.[Model]
      ,SOURCE.[AdID]
      ,SOURCE.[Article list4]
      ,SOURCE.[Format_TV_type]
      ,SOURCE.[Region]
      ,SOURCE.[Edition Type]
      ,SOURCE.[Quantity]
      ,SOURCE.[Cost Gross]
      ,SOURCE.[Year]
      ,SOURCE.[Month Name]
      ,SOURCE.[Month Number]
      ,SOURCE.[Quart]
      ,SOURCE.[USD]
      ,SOURCE.[RUR]
      ,SOURCE.[EUR]
	);

	--if object_id('dbo.JJ_SoS_data') is not null drop table [dbo].[JJ_SoS_data]
	SELECT	[Media Type]
			,[AdId]
			,[Brands list]
			,[Models list]
			,[Model]
			,[Year]
			,[Month Number]
			,sum([USD]) as [USD]
			,sum([RUR]) as [RUR]
	INTO #Temp_Spends
		FROM	( SELECT DISTINCT	
						CASE	WHEN [Media Type] = 'TV' AND [Format_TV_type] LIKE '%Sponsor%' THEN 'TV Sponsorship'
								WHEN [Media Type] = 'TV' AND [Type] = 'Local' AND [Format_TV_type] NOT LIKE '%Sponsor%' THEN 'TV Reg'
								WHEN [Media Type] = 'TV' AND [Type] <> 'Local' AND [Format_TV_type] NOT LIKE '%Sponsor%' THEN 'TV Nat'
						ELSE [Media Type]
						END as [Media Type]
						,[Brands list]
						,[AdId]
						,[Models list]
						,[Model]
						,[Year]
						,[Month Number]
						,[USD]
						,[RUR]
					FROM [dbo].[JJ_Adex_Data_Raw]
				) aa
		group by [Media Type]
			,[Brands list]
			,[Models list]
			,[Model]
			,[Year]
			,[Month Number]
			,[AdId]
	IF (OBJECT_ID(N'dbo.[JJ_SoS_data]') IS NOT NULL AND (SELECT COUNT(*) FROM #Temp_Spends) > 0) DROP TABLE dbo.[JJ_SoS_data]
		SELECT * INTO dbo.[JJ_SoS_data] FROM #Temp_Spends


	IF OBJECT_ID(N'[dbo].[JJ_Autocoeff]') IS NOT NULL DROP TABLE [dbo].[JJ_Autocoeff]
		SELECT * INTO [dbo].[JJ_Autocoeff] FROM [dbo].[view_Autocoeff]

/* Making full list of models*/
select * into #Temp1 from (select distinct replace([Models list], ';', ';;') as [Models list] from  [AdEx_data].[dbo].[JJ_SoS_data] UNION select distinct replace([Models list], ';', ';;') as [Models list] from [TV_Data].[dbo].[JJ_TV_Report_data]) aa
select * into #Temp2 from (select	ROW_NUMBER()  OVER (ORDER BY tmp.[Models list]) as [ID] 
																					,[Models list] 
																			from (select distinct replace([Models list], ';', ';;') as [Models list] from  [AdEx_data].[dbo].[JJ_SoS_data]UNION select distinct replace([Models list], ';', ';;') as [Models list] from [TV_Data].[dbo].[JJ_TV_Report_data]) tmp) aa


select * into #Temp from (select	ROW_NUMBER()  OVER (ORDER BY tmp.[Models list]) as [ID] 
							,[Models list] 
							from #Temp1 tmp
							) t1
CROSS APPLY (SELECT XMLEncoded=(SELECT [Models list] AS [*] FROM #Temp2 t2
WHERE t1.[ID] = t2.[ID] FOR XML PATH('')
													)
								) EncodeXML



	select [Models list], [Model], [ModelNum]
		into #Temp3
		  from
			(
					SELECT 
						replace ([Models list],';;',';') as [Models list] ,
						NewXML.value('/Product[1]/Attribute[1]','nvarchar(255)') AS [1],
						NewXML.value('/Product[1]/Attribute[2]','nvarchar(255)') AS [2],
						NewXML.value('/Product[1]/Attribute[3]','nvarchar(255)') AS [3],
						NewXML.value('/Product[1]/Attribute[4]','nvarchar(255)') AS [4],
						NewXML.value('/Product[1]/Attribute[5]','nvarchar(255)') AS [5],
						NewXML.value('/Product[1]/Attribute[6]','nvarchar(255)') AS [6],
						NewXML.value('/Product[1]/Attribute[7]','nvarchar(255)') AS [7]
					FROM #Temp
					CROSS APPLY (SELECT NewXML=CAST('<Product><Attribute>'+REPLACE(XMLEncoded,';; ','</Attribute><Attribute>')+'</Attribute></Product>' AS XML)) CastXML
					) temp
				unpivot
					([Model] for [ModelNum] IN
						([1], [2],[3],[4],[5],[6],[7])
					) as unpvt
				where [Model] <> ''
				
		IF (OBJECT_ID(N'[TV_Data].[dbo].[JJ_Splitted_Model_List]') IS NOT NULL AND (SELECT COUNT(*) FROM #Temp3) > 0) DROP TABLE [TV_Data].[dbo].[JJ_Splitted_Model_List]
		SELECT * INTO [TV_Data].[dbo].[JJ_Splitted_Model_List] FROM #Temp3
END
