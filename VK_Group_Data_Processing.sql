USE [VK_Group_Data]
GO
/****** Object:  StoredProcedure [dbo].[Process_Data]    Script Date: 23.11.2016 15:55:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Maxim Pavlov>
-- Create date: <23 11 2016>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[Process_Data]
AS
BEGIN
	/*
	TRUNCATE TABLE [dbo].[All_Users_Info_Raw]
	TRUNCATE TABLE [dbo].[Commented_Last_Posts_Raw]
	TRUNCATE TABLE [dbo].[Last_Posts_Raw]
	TRUNCATE TABLE [dbo].[Liked_Last_Posts_Raw]
	TRUNCATE TABLE [dbo].[Liked_Photos_Raw]
	TRUNCATE TABLE [dbo].[Photos_Raw]
	TRUNCATE TABLE [dbo].[Reposted_Last_Posts_Raw]
	TRUNCATE TABLE [dbo].[Topics_Comments_Raw]

	 
	SELECT COUNT (*) FROM [dbo].[All_Users_Info_Raw]
	SELECT COUNT (*) FROM [dbo].[Commented_Last_Posts_Raw]
	SELECT COUNT (*) FROM [dbo].[Last_Posts_Raw]
	SELECT COUNT (*) FROM [dbo].[Liked_Last_Posts_Raw]
	SELECT COUNT (*) FROM [dbo].[Liked_Photos_Raw]
	SELECT COUNT (*) FROM [dbo].[Photos_Raw]
	SELECT COUNT (*) FROM [dbo].[Reposted_Last_Posts_Raw]
	SELECT COUNT (*) FROM [dbo].[Topics_Comments_Raw]
	*/

	SET NOCOUNT ON;
	MERGE INTO [dbo].[All_Users_Info_Raw] AS TARGET
	USING (SELECT DISTINCT 
				  convert(numeric,[uid]) as [uid]
				  ,[first_name]
				  ,[last_name]
				  ,[sex]
				  ,[bdate]
				  ,case when [hidden]='' then NULL else convert(numeric,[hidden]) end as [hidden]
				  ,[university_name]
				  ,[faculty_name]
				  ,[graduation]
				  ,[home_town]
				  ,[education_form]
				  ,[education_status]
				  ,[deactivated]
				  ,[link]
				  ,[age]
				  ,[country_name]
				  ,[city_name]
				  ,convert(numeric,[group_id]) as [group_id]
				  ,convert(numeric,[user_in_group]) as [user_in_group]
				  ,CASE WHEN LEN(bdate)>5 THEN year(getdate())-year(CONVERT(date,bdate,104)) END as 'age2' 
			  FROM [VK_Group_Data].[dbo].[all_users_info_source]) AS SOURCE
	ON TARGET.[user_id] = SOURCE.[uid]
	AND TARGET.[group_id] = SOURCE.[group_id]
		WHEN MATCHED THEN UPDATE SET 
                    [first_name] = SOURCE.[first_name]
                    ,[last_name] = SOURCE.[last_name]
                    ,[sex] = SOURCE.[sex]
                    ,[b_date] = SOURCE.[bdate]
                    ,[hidden] = SOURCE.[hidden]
                    ,[university_name] = SOURCE.[university_name]
                    ,[faculty_name] = SOURCE.[faculty_name]
                    ,[graduation] = SOURCE.[graduation]
                    ,[home_town] = SOURCE.[home_town]
                    ,[education_form] = SOURCE.[education_form]
                    ,[education_status] = SOURCE.[education_status]
                    ,[deactivated] = SOURCE.[deactivated]
                    ,[link] = SOURCE.[link]
                    ,[age] = SOURCE.[age2]
                    ,[country_name] = SOURCE.[country_name]
                    ,[city_name] = SOURCE.[city_name]
                    ,[user_in_group] = SOURCE.[user_in_group]
					,[date_updated] = getdate()
	WHEN NOT MATCHED THEN
	INSERT ([user_id]
      ,[first_name]
      ,[last_name]
      ,[sex]
      ,[b_date]
      ,[hidden]
      ,[university_name]
      ,[faculty_name]
      ,[graduation]
      ,[home_town]
      ,[education_form]
      ,[education_status]
      ,[deactivated]
      ,[link]
      ,[age]
      ,[country_name]
      ,[city_name]
      ,[user_in_group]
      ,[group_id]
	  ,[date_updated])
	VALUES (convert(numeric,SOURCE.[uid])
      ,SOURCE.[first_name]
      ,SOURCE.[last_name]
      ,SOURCE.[sex]
      ,SOURCE.[bdate]
      ,SOURCE.[hidden]
      ,SOURCE.[university_name]
      ,SOURCE.[faculty_name]
      ,SOURCE.[graduation]
      ,SOURCE.[home_town]
      ,SOURCE.[education_form]
      ,SOURCE.[education_status]
      ,SOURCE.[deactivated]
      ,SOURCE.[link]
      ,SOURCE.[age2]
      ,SOURCE.[country_name]
      ,SOURCE.[city_name]
      ,SOURCE.[user_in_group]
	  ,SOURCE.[group_id]
	  ,getdate());

	MERGE INTO [dbo].[Commented_Last_Posts_Raw] AS TARGET
	USING (SELECT DISTINCT [comment_id]
      ,[user_id]
      ,[date]
      ,[text]
      ,case when [reply_to_user_id]='' then NULL else convert(numeric,[reply_to_user_id]) end as [reply_to_user_id]
      ,case when [reply_to_comment_id]='' then NULL else convert(numeric,[reply_to_comment_id]) end as [reply_to_comment_id]
      ,[post_id]
      ,[group_id]
      ,[user_in_group]
	  FROM	[dbo].[commented_last_posts_source]) AS SOURCE
	ON TARGET.[user_id] = CONVERT(numeric,SOURCE.[user_id])
	AND TARGET.[group_id] = CONVERT(numeric,SOURCE.[group_id])
	AND TARGET.[post_id] = CONVERT(numeric,SOURCE.[post_id])
	AND TARGET.[comment_id] = CONVERT(numeric,SOURCE.[comment_id])
		WHEN MATCHED THEN UPDATE SET 
				  [date] = convert(datetime,SOURCE.[date])
				  ,[text] = SOURCE.[text]
				  ,[reply_to_user_id] = SOURCE.[reply_to_user_id]
				  ,[reply_to_comment_id] = SOURCE.[reply_to_comment_id]
				  ,[user_in_group] = convert(numeric,SOURCE.[user_in_group])
				  ,[date_updated] = getdate()
	WHEN NOT MATCHED THEN
	INSERT ([comment_id]
      ,[user_id]
      ,[date]
      ,[text]
      ,[reply_to_user_id]
      ,[reply_to_comment_id]
      ,[post_id]
      ,[group_id]
      ,[user_in_group]
	  ,[date_updated])
	VALUES (convert(numeric,SOURCE.[comment_id])
      ,convert(numeric,SOURCE.[user_id])
      ,convert(datetime,SOURCE.[date])
      ,SOURCE.[text]
      ,SOURCE.[reply_to_user_id]
      ,SOURCE.[reply_to_comment_id]
      ,convert(numeric,SOURCE.[post_id])
      ,convert(numeric,SOURCE.[group_id])
      ,convert(numeric,SOURCE.[user_in_group])
	  ,getdate());

	MERGE INTO [dbo].[Last_Posts_Raw] AS TARGET
	USING (SELECT DISTINCT convert(numeric,[id]) as [id]
      ,convert(datetime,[date]) as [date]
      ,[text]
      ,[link_to_post]
      ,[author]
      ,[author_link]
      ,[post_type]
      ,[attachements]
      ,convert(int,[comments_count]) as [comments_count]
      ,convert(int,[likes_count]) as [likes_count]
      ,convert(int,[reposts_count]) as [reposts_count]
	  ,convert(numeric,[group_id]) as [group_id]
	  FROM	[dbo].[last_posts_source]) AS SOURCE
	ON TARGET.[post_id] = SOURCE.[id]
	AND TARGET.[group_id] = SOURCE.[group_id]
		WHEN MATCHED THEN UPDATE SET 
				  [date] = SOURCE.[date]
				  ,[text] = SOURCE.[text]
				  ,[link_to_post] = SOURCE.[link_to_post]
				  ,[author] = SOURCE.[author]
				  ,[author_link] = SOURCE.[author_link]
				  ,[post_type] = SOURCE.[post_type]
				  ,[attachements] = SOURCE.[attachements]
				  ,[comments_count] = SOURCE.[comments_count]
				  ,[likes_count] = SOURCE.[likes_count]
				  ,[reposts_count] = SOURCE.[reposts_count]
				  ,[date_updated] = getdate()
	WHEN NOT MATCHED THEN
	INSERT ([post_id]
      ,[date]
      ,[text]
      ,[link_to_post]
      ,[author]
      ,[author_link]
      ,[post_type]
      ,[attachements]
      ,[comments_count]
      ,[likes_count]
      ,[reposts_count]
	  ,[group_id]
	  ,[date_updated])
	VALUES (SOURCE.[id]
      ,SOURCE.[date]
      ,SOURCE.[text]
      ,SOURCE.[link_to_post]
      ,SOURCE.[author]
      ,SOURCE.[author_link]
      ,SOURCE.[post_type]
      ,SOURCE.[attachements]
      ,SOURCE.[comments_count]
      ,SOURCE.[likes_count]
      ,SOURCE.[reposts_count]
	  ,SOURCE.[group_id]
	  ,getdate());

	  
	MERGE INTO [dbo].[Liked_Last_Posts_Raw] AS TARGET
	USING (
	select distinct 
		convert(numeric,[user_id]) as [user_id]
		,convert(numeric,[post_id]) as [post_id]
		,convert(numeric,[group_id]) as [group_id]
		,convert(numeric,[user_in_group]) as [user_in_group]
	from [VK_Group_Data].[dbo].[liked_last_posts_source]) AS SOURCE
	ON TARGET.[user_id] = SOURCE.[user_id]
	AND TARGET.[post_id] = SOURCE.[post_id]
	AND TARGET.[group_id] = SOURCE.[group_id]
		WHEN MATCHED THEN UPDATE SET 
				  [user_in_group] = SOURCE.[user_in_group]
				  ,[date_updated] = getdate()
	WHEN NOT MATCHED THEN
	INSERT ([user_id]
      ,[post_id]
      ,[group_id]
      ,[user_in_group]
	  ,[date_updated])
	VALUES (SOURCE.[user_id]
      ,SOURCE.[post_id]
      ,SOURCE.[group_id]
      ,SOURCE.[user_in_group]
	  ,getdate());

	MERGE INTO [dbo].[Liked_Photos_Raw] AS TARGET
	USING (
	select distinct 
		convert(numeric,[user_id]) as [user_id]
		,convert(numeric,[photo_id]) as [photo_id]
		,convert(numeric,[group_id]) as [group_id]
		,convert(numeric,[user_in_group]) as [user_in_group]
	from [VK_Group_Data].[dbo].[liked_photos_source]) AS SOURCE
	ON TARGET.[user_id] = SOURCE.[user_id]
	AND TARGET.[photo_id] = SOURCE.[photo_id]
	AND TARGET.[group_id] = SOURCE.[group_id]
		WHEN MATCHED THEN UPDATE SET 
				  [user_in_group] = SOURCE.[user_in_group]
				  ,[date_updated] = getdate()
	WHEN NOT MATCHED THEN
	INSERT ([user_id]
      ,[photo_id]
      ,[group_id]
      ,[user_in_group]
	  ,[date_updated])
	VALUES (SOURCE.[user_id]
      ,SOURCE.[photo_id]
      ,SOURCE.[group_id]
      ,SOURCE.[user_in_group]
	  ,getdate());
	  
	MERGE INTO [dbo].[Reposted_Last_Posts_Raw] AS TARGET
	USING (
	select distinct 
		convert(numeric,[user_id]) as [user_id]
		,convert(numeric,[post_id]) as [post_id]
		,convert(numeric,[group_id]) as [group_id]
		,convert(numeric,[user_in_group]) as [user_in_group]
	from [VK_Group_Data].[dbo].[reposted_last_posts_source]) AS SOURCE
	ON TARGET.[user_id] = SOURCE.[user_id]
	AND TARGET.[post_id] = SOURCE.[post_id]
	AND TARGET.[group_id] = SOURCE.[group_id]
		WHEN MATCHED THEN UPDATE SET 
				  [user_in_group] = SOURCE.[user_in_group]
				  ,[date_updated] = getdate()
	WHEN NOT MATCHED THEN
	INSERT ([user_id]
      ,[post_id]
      ,[group_id]
      ,[user_in_group]
	  ,[date_updated])
	VALUES (SOURCE.[user_id]
      ,SOURCE.[post_id]
      ,SOURCE.[group_id]
      ,SOURCE.[user_in_group]
	  ,getdate());

	MERGE INTO [dbo].[Photos_Raw] AS TARGET
	USING (
		  SELECT DISTINCT
			  convert(numeric,[album_id]) as [album_id]
			  ,convert(numeric,[photo_id]) as [photo_id]
			  ,convert(numeric,[owner_id]) as [owner_id]
			  ,[text]
			  ,[date_created]
			  ,convert(numeric,[likes_count]) as [likes_count]
			  ,convert(numeric,[reposts_count]) as [reposts_count]
			  ,convert(numeric,[comments_count]) as [comments_count]
			  ,convert(numeric,[user_id_posted]) as [user_id_posted]
			  ,[link]
			  ,convert(datetime,[date]) as [date]
			  ,convert(numeric,[group_id]) as [group_id]
		  FROM [VK_Group_Data].[dbo].[photos_source]) AS SOURCE
	ON TARGET.[photo_id] = SOURCE.[photo_id]
	AND TARGET.[group_id] = SOURCE.[group_id]
		WHEN MATCHED THEN UPDATE SET 
				  [album_id] = SOURCE.[album_id]
				  ,[owner_id] = SOURCE.[owner_id]
				  ,[text] = SOURCE.[text]
				  ,[likes_count] = SOURCE.[likes_count]
				  ,[reposts_count] = SOURCE.[reposts_count]
				  ,[comments_count] = SOURCE.[comments_count]
				  ,[user_id_posted] = SOURCE.[user_id_posted]
				  ,[link] = SOURCE.[link]
				  ,[date] = SOURCE.[date]
				  ,[date_updated] = getdate()
	WHEN NOT MATCHED THEN
	INSERT ([album_id]
      ,[photo_id]
      ,[owner_id]
      ,[text]
      ,[likes_count]
      ,[reposts_count]
      ,[comments_count]
      ,[user_id_posted]
      ,[link]
      ,[date]
	  ,[group_id]
	  ,[date_updated])
	VALUES (SOURCE.[album_id]
      ,SOURCE.[photo_id]
      ,SOURCE.[owner_id]
      ,SOURCE.[text]
      ,SOURCE.[likes_count]
      ,SOURCE.[reposts_count]
      ,SOURCE.[comments_count]
      ,SOURCE.[user_id_posted]
      ,SOURCE.[link]
      ,SOURCE.[date]
	  ,SOURCE.[group_id]
	  ,getdate());

	  
	MERGE INTO [dbo].[Topics_Comments_Raw] AS TARGET
	USING (
		  SELECT DISTINCT
			  convert(numeric,[topic_id]) as [topic_id]
			  ,convert(numeric,[id]) as [id]
			  ,convert(numeric,[from_user_id]) as [from_user_id]
			  ,convert(datetime,[date]) as [date]
			  ,[text]
			  ,[Topic_title]
			  ,convert(numeric,[group_id]) as [group_id]
		  FROM [VK_Group_Data].[dbo].[topics_comments_source]) AS SOURCE
	ON TARGET.[topic_id] = SOURCE.[topic_id]
	AND TARGET.[group_id] = SOURCE.[group_id]
	AND TARGET.[id] = SOURCE.[id]
		WHEN MATCHED THEN UPDATE SET 
				  [from_user_id] = SOURCE.[from_user_id]
				  ,[date] = SOURCE.[date]
				  ,[text] = SOURCE.[text]
				  ,[Topic_title] = SOURCE.[Topic_title]
				  ,[group_id] = SOURCE.[group_id]
				  ,[date_updated] = getdate()
	WHEN NOT MATCHED THEN
	INSERT ([topic_id]
      ,[id]
      ,[from_user_id]
      ,[date]
      ,[text]
      ,[Topic_title]
      ,[group_id]
	  ,[date_updated])
	VALUES (SOURCE.[topic_id]
      ,SOURCE.[id]
      ,SOURCE.[from_user_id]
      ,SOURCE.[date]
      ,SOURCE.[text]
      ,SOURCE.[Topic_title]
      ,SOURCE.[group_id]
	  ,getdate());


END
