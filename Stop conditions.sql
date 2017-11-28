if object_id('tempdb..#TempCampaigns') is not null drop table #TempCampaigns

SELECT * INTO #TempCampaigns  FROM [SERP_Config_Production].[dbo].[Dim_Campaigns] WHERE [Active] = 1
SELECT * FROM #TempCampaigns
--UPDATE #TempCampaigns SET [StopConditionNumberOfResults] = 1500
--UPDATE #TempCampaigns SET [ActivationDate] = GETDATE()

SELECT [Campaign_Name] FROM #TempCampaigns WHERE [StopConditionDate] <= GETDATE()
UNION
SELECT
	aa.[Campaign_Name]
	FROM (
		select COUNT([DateTimeOfRequest]) as [Count]
		,ss.[Campaign_Name]
		,hh.[StopConditionNumberOfAdResults]
		FROM [WebStatLight].[dbo].[SERP_Source_Data] aa
		JOIN [WebStatLight].[dbo].[Dim_Campaign] ss ON aa.[Campaign_ID] = ss.[Campaign_ID]
		JOIN [WebStatLight].[dbo].[Dim_Type] dd ON aa.[Type_ID] = dd.[Type_ID]
		JOIN [WebStatLight].[dbo].[Dim_Source] ff ON aa.[Source_ID] = ff.[Source_ID]
		JOIN #TempCampaigns hh ON ss.Campaign_Name = hh.Campaign_Name
		WHERE aa.[DateTimeOfRequest] >= hh.ActivationDate AND [ItemType] ='Ad'
		GROUP BY ss.[Campaign_Name]
		,hh.[StopConditionNumberOfAdResults]
	) aa
	WHERE ISNULL([StopConditionNumberOfAdResults],0) <= [Count]
UNION
SELECT
	aa.[Campaign_Name]
	FROM (
		select COUNT([DateTimeOfRequest]) as [Count]
		,ss.[Campaign_Name]
		,hh.[StopConditionNumberOfResults]
		FROM [WebStatLight].[dbo].[SERP_Source_Data] aa
		JOIN [WebStatLight].[dbo].[Dim_Campaign] ss ON aa.[Campaign_ID] = ss.[Campaign_ID]
		JOIN [WebStatLight].[dbo].[Dim_Type] dd ON aa.[Type_ID] = dd.[Type_ID]
		JOIN [WebStatLight].[dbo].[Dim_Source] ff ON aa.[Source_ID] = ff.[Source_ID]
		JOIN #TempCampaigns hh ON ss.Campaign_Name = hh.Campaign_Name
		WHERE aa.[DateTimeOfRequest] >= hh.ActivationDate
		GROUP BY ss.[Campaign_Name]
		,hh.[StopConditionNumberOfResults]
	) aa
	WHERE ISNULL([StopConditionNumberOfResults],0) <= [Count]