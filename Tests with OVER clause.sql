

SELECT	[date],
		[Ad_id],
		[Links]
FROM (
	SELECT	[date],
			[Ad_id],
			[Monitoring_Start],
			[Links]-ISNULL(SUM([Links]) OVER (	partition by [Ad_id] 
												order by [date]
												ROWS BETWEEN 1 PRECEDING  AND 1 PRECEDING),0) as [links]
	FROM (	select	aa.[date],
					aa.[Ad_id],
					min([date]) OVER (PARTITION BY [Ad_id]) as [Monitoring_Start],
					sum(aa.[links]) as [Links]
			from [dbo].[view_VK_Ad_Posts_Reach_Full] aa
			where date in (	select distinct max([datetime]) OVER (PARTITION BY [date]) as [max_datetime]
							from	(	select distinct [date] as [datetime], convert(date,[date]) as [date] from
									[dbo].[view_VK_Ad_Posts_Reach_Full]) aa
									)
			AND links > 0
			group by aa.[date],aa.[Ad_id]
		) aa
	) aa
WHERE [date]<>[Monitoring_Start]
AND [links] > 0

drop view [VKEffectiveness_v]
CREATE VIEW [dbo].[VKEffectiveness_v] as 
select C.AccountID, C.ClientID, Cl.Name as Client, C.ID as CampaignID, C.Name as Campaign, 
	A.ID as AdID, A.Title as AdTitle, isnull(A.Description, '') as AdDescription, A.URL, A.Format, A.isVideo, 
	Ads.Date, Ads.Spend, Ads.Impressions, AdS.Clicks, AdS.Reach as DailyReach, AdS.VideoViews, AdS.VideoViewsHalf, AdS.VideoViewsFull, 
	AdS.VideoClicksSite, Ads.JoinRate, MR.Reach as MonthlyReach, ss.[Links]
	from VKAdsStats AdS 
	join VKAds A on AdS.ID=A.ID 
	join VKCampaigns C on C.ID = A.CampaignID 
	join VKClients Cl on Cl.ID = C.ClientID
	left join 
	(select distinct * from VKMonthlyReach) MR on C.ID = MR.CampaignID and month(AdS.Date) = MR.Month and year(AdS.Date) = MR.Year
	LEFT JOIN	(
				SELECT	convert(date,[date]) as [date],
						[Ad_id],
						[Links]
				FROM (
					SELECT	[date],
							[Ad_id],
							[Monitoring_Start],
							[Links]-ISNULL(SUM([Links]) OVER (	partition by [Ad_id] 
																order by [date]
																ROWS BETWEEN 1 PRECEDING  AND 1 PRECEDING),0) as [links]
					FROM (	select	aa.[date],
									aa.[Ad_id],
									min([date]) OVER (PARTITION BY [Ad_id]) as [Monitoring_Start],
									sum(aa.[links]) as [Links]
							from [dbo].[view_VK_Ad_Posts_Reach_Full] aa
							where date in (	select distinct max([datetime]) OVER (PARTITION BY [date]) as [max_datetime]
											from	(	select distinct [date] as [datetime], convert(date,[date]) as [date] from
													[dbo].[view_VK_Ad_Posts_Reach_Full]) aa
													)
							AND links > 0
							group by aa.[date],aa.[Ad_id]
						) aa
					) aa
				WHERE --[date]<>[Monitoring_Start] AND
				 [links] > 0
				) ss ON A.ID = ss.[Ad_id] and Ads.[date] = ss.[date]
				--where Links is not null

	
