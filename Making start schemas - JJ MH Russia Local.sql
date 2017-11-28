USE [DM_1285_JJRussiaLocal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/* =============================================================
    Author:			Ben Plastow
    Updated By:		Maxim Pavlov
    Created Date:	17 December 2014
	Updated Date:	20 May 2015
    Description:	sp_build_Star_Schema_RussiaLocal
	Note:			
    =============================================================*/
CREATE PROCEDURE [dbo].[sp_build_Star_Schema_RussiaLocal]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Dim_Audience
	--DROP TABLE Dim_Audience

	CREATE TABLE [dbo].[Dim_Audience] (
	[Audience_ID] bigint  NOT NULL primary key identity(1,1)  
	,[Audience_Name] [varchar](255) NULL
	,[All_Individuals_Audience_Flag] varchar(3) NULL
	)

    --Dim_Country

	CREATE TABLE [dbo].[Dim_Country] (
	[Country_ID] bigint  NOT NULL  
	,[Cluster_Name] varchar(255)  NOT NULL  
	,[Country_Name] varchar(255)  NOT NULL 
	,[Primus_Market_Flag] [varchar](3) NULL
	)

	ALTER TABLE [dbo].[Dim_Country] ADD CONSTRAINT [Dim_Country_PK] PRIMARY KEY CLUSTERED (
	[Country_ID]
	)

	--Dim_Data_Source
	--Note: table is not needed

	/*CREATE TABLE [dbo].[Dim_Data_Source](
	[Data_Source_ID] [bigint] NOT NULL,
	[Data_Source_Name] [varchar](255) NULL,
	 CONSTRAINT [Dim_Data_Source_PK] PRIMARY KEY CLUSTERED 
	(
		[Data_Source_ID] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
	*/

	--Dim_Date
	--drop table dim_date
	--drop table fact_competitive_spend
	--drop table fact_competitive_tv_grps

	CREATE TABLE [dbo].[Dim_Date] (
	[Date_ID] bigint NOT NULL  
	,[Date] datetime NOT NULL  
	,[Year] int NOT NULL  
	,[Quarter_ID] int NOT NULL  
	,[Quarter] varchar(255) NOT NULL  
	,[Month_ID] int NOT NULL  
	,[Month] varchar(255) NOT NULL  
	,[Date_ISO] varchar(255) NOT NULL  
	,[Week_ISO] varchar(255) NOT NULL  
	,[Month_ISO] varchar(255) NOT NULL  
	,[Year_ISO] varchar(255) NOT NULL  
	,[Month_MMM] [char](3) NULL
	,[Year_Month] [int] NULL
	/*
	,[No_Days_Since_1900] [int] NULL
	,[Month_Days_1900] [int] NULL
	,[Week_Days_1900] [int] NULL
	*/
	)

	ALTER TABLE [dbo].[Dim_Date] ADD CONSTRAINT [Dim_Date_PK] PRIMARY KEY CLUSTERED (
	[Date_ID]
	)

	--Dim_DayPart
	/*
	CREATE TABLE [dbo].[Dim_Day_Part] (
	[Day_Part_ID] bigint  NOT NULL primary key identity(1,1)
	, [Day_Part_Description] varchar(255)  NULL
	)
	*/
	--Dim_JandJ_Product
	--DROP TABLE Dim_JandJ_Product
	--SELECT * FROM Dim_JandJ_Product

	CREATE TABLE [dbo].[Dim_JandJ_Product](
		[Product_ID] [bigint] IDENTITY(1,1) NOT NULL,
		[Product_Name] [varchar](255) NOT NULL,
		[Brand_Name] [varchar](255) NOT NULL,
		[Manufacturer_Name] [varchar](255) NOT NULL,
		[Franchise_Name] [varchar](255) NOT NULL,
		[Category_ID] bigint  NOT NULL,
		[Excluded_Flag] [varchar](3) NULL
	PRIMARY KEY CLUSTERED 
	(
		[Product_ID] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]

	--Dim_Media_Type
	--DROP TABLE Dim_Media_Type

	CREATE TABLE [dbo].[Dim_Media_Type] (
	[Media_ID] [bigint] IDENTITY(1,1) NOT NULL
	, [Media_Category] varchar(255)  NOT NULL  
	, [Media_Name] varchar(255)  NOT NULL
	)

	ALTER TABLE [dbo].[Dim_Media_Type] ADD CONSTRAINT [Dim_Media_Type_PK] PRIMARY KEY CLUSTERED (
	[Media_ID]
	)

	--Dim_Product
	--DROP TABLE Dim_Product
	--SELECT * FROM Dim_Product

	CREATE TABLE [dbo].[Dim_Product] (
	[Product_ID] bigint IDENTITY(1,1) NOT NULL --Auto-number
	, [JandJ_Product_ID] [bigint] NULL
	, [Category_ID] bigint  NULL  
	, [Product_Name] varchar(255)  NULL  
	, [Brand_Name] varchar(255)  NULL  
	, [Manufacturer_Name] varchar(255)  NULL
	--, [Franchise_Name] varchar(255)  NULL  
	--, [Category_Tree] varchar(255)  NULL  
	, [Reporting_Manufacturer_Name] [nvarchar](max) NULL
	, [Reporting_Manufacturer_Group] [nvarchar](max) NULL
	, [Excluded_Flag] [varchar](3) NULL
	--, [Product_Code] bigint NULL
	)

	ALTER TABLE [dbo].[Dim_Product] ADD CONSTRAINT [Dim_Product_PK] PRIMARY KEY CLUSTERED (
	[Product_ID]
	)
	
	--Apply non-clustered index to the table to prevent duplicate Products from being inserted

	CREATE UNIQUE NONCLUSTERED INDEX [UniqueNonClusteredIndex-20141217-180000] ON [dbo].[Dim_Product] --Note the datetime in the name of the non-clustered index
	(
				  [Product_Name] ASC,
				  [Brand_Name] ASC,
				  [Manufacturer_Name] ASC,
				  [Category_ID] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

	--Dim_Product_Category
	--DROP TABLE Dim_Product_Category

	CREATE TABLE [dbo].[Dim_Product_Category] (
	[Category_ID] bigint  IDENTITY(1,1) NOT NULL
	, [Category_Level_1] varchar(255) NULL  
	, [Category_Level_2] varchar(255) NULL  
	, [Category_Level_3] varchar(255) NULL  
	, [Category_Tree] varchar(255) NULL  
	, [Franchise_Name] varchar(255) NULL  
	)

	ALTER TABLE [dbo].[Dim_Product_Category] ADD CONSTRAINT [Dim_Product_Category_PK] PRIMARY KEY CLUSTERED (
	[Category_ID]
	)

	--Dim_Publisher

	CREATE TABLE [dbo].[Dim_Publisher] (
	[Publisher_ID] bigint  NOT NULL primary key identity(1,1)  
	, [Publisher_Name] varchar(255)  NULL  
	, [Channel_Name] varchar(255)  NULL  
	)

	--Apply non-clustered index to the table to prevent duplicate Publishers from being inserted

	CREATE UNIQUE NONCLUSTERED INDEX [UniqueNonClusteredIndex-20150324-170000] ON [dbo].Dim_Publisher
	(
					[Publisher_Name] ASC,
					[Channel_Name] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

	--Dim_Region

	CREATE TABLE [dbo].[Dim_Region] (
	[Region_ID] [bigint] primary key identity(1,1)
	,[Region_Name] [varchar](255) NULL
	/*,[Country_ID] [bigint] NULL
	,[Country_Name] [varchar](255) NULL
	*/
	)

	--Dim_Spot
	/* Old version
	CREATE TABLE [dbo].[Dim_Spot] (
	[Spot_ID] bigint  NOT NULL  primary key identity(1,1)
	, [Film_Code_ID] varchar(255)  NULL  
	, [Position_In_Break_Description] varchar(255)  NULL  
	, [Break_Code_Description] varchar(255)  NULL  
	, [Day_Part_Description] varchar(255)  NULL
	, [Duration_Seconds] varchar(255)  NULL  
	, [Start_Time] varchar(255)  NULL  
	, [End_Time] varchar(255)  NULL  
	, [Week_Number] int  NOT NULL
	)
	*/
	
	-- Decomposition of [Dim_spot] --

 	CREATE TABLE [dbo].[Dim_Spot] (
	[Spot_ID] bigint  NOT NULL  primary key identity(1,1)
	, [Film_Code_ID] bigint NOT NULL  
	, [Position_In_Break_Description] varchar(255)  NULL  
	, [Duration_Seconds] decimal(4,0)  NULL --Can be 0 for sponsorship
	, [Clip_type] varchar(255)  NOT NULL  --Spot, Sponsorship etc.
	, [Clip_distribution] varchar(16) NOT NULL DEFAULT 'National' --National, Orbital, Local
	, [Daypart_ID] int NOT NULL
	, [Article_List] nvarchar(255) NOT NULL  --all advertised articles in this spot
	, [Models_List] nvarchar(255) NOT NULL --all advertised products in this spot
	)
	
	CREATE TABLE [dbo].[Dim_Daypart] (
	[Daypart_ID] int primary key identity(1,1)
	,[Start_Time] time NULL --expected to be hour-based
	,[End_Time] time NULL --expected to be hour-based
	,[PrimeOffPrime_Description] varchar (16) --Prime, Off-prime
	,[Day_Part_Description] varchar (255)
	,[Day_Type] varchar (255) --Weekday,weekend,holiday,mourning day
	)

	ALTER TABLE [dbo].[Dim_Spot] WITH CHECK ADD CONSTRAINT [Dim_Spot_Dim_Daypart_FK1] FOREIGN KEY (
	[Daypart_ID]
	)
	REFERENCES [dbo].[Dim_Daypart] (
	[Daypart_ID]
	)

	-- End of decomposition --

	--Dim_Mapping_Product_Count; BP updated (26/06/14): table is required for Germany TV GRPs business logic
	--Note: table is not required for France local reporting

	--drop table Dim_Mapping_Product_Count
	/*CREATE TABLE [dbo].Dim_Mapping_Product_Count (
	[Dim_Mapping_Product_ID] bigint  NOT NULL primary key identity(1,1) --Auto-number
	,[Motivcode] bigint NOT NULL
	,[Product_ID] bigint NOT NULL
	, [Count_Category_ID] bigint  NOT NULL
	)
	*/

	--Dim_Distribution_Channel; BP updated (17/12/14)
	--drop table [Dim_Distribution_Channel]
	/*
	CREATE TABLE [dbo].[Dim_Distribution_Channel](
		[Product_ID] BIGINT NOT NULL,
		[Distribution_Channel_Name] [varchar](255) NOT NULL,
	PRIMARY KEY CLUSTERED 
	(
		[Product_ID] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
	
	--BP updated (12/02/15)
	ALTER TABLE [dbo].Dim_Distribution_Channel  WITH CHECK ADD CONSTRAINT [Dim_Product_FK1] FOREIGN KEY([Product_ID])
	REFERENCES [dbo].[Dim_Product] (Product_ID)
	
	--[Mapping_Manufacturer]

	CREATE TABLE [dbo].[Mapping_Manufacturer](
	[Manufacturer_ID] [bigint] NOT NULL primary key identity (1,1),
	[Manufacturer_Name] [varchar](255) NULL,
	[Source_Market] [varchar](255) NULL,
	[Reporting_Manufacturer_Name] [varchar](255) NULL,
	[Reporting_Manufacturer_Group] [varchar](255) NULL,
	[Product_ID] [bigint] NOT NULL,
	[Brand_Name] [varchar](255) NULL
	) ON [PRIMARY]
	
	--Cube_Process_History

	CREATE TABLE [dbo].[Cube_Process_History](
		[Processed_ID] [bigint] IDENTITY(1,1) NOT NULL,
		[Last_Processed_Date] [datetime] NULL,
		[Processed_Description] NVARCHAR(250) NULL
	) ON [PRIMARY]
	
	ALTER TABLE [dbo].[Cube_Process_History] ADD DEFAULT (DATEADD(HOUR,5,GETDATE())) FOR [Last_Processed_Date]
	
	--Cube_Fact_Tables_Periodicity
	--drop table [Cube_Fact_Tables_Periodicity]

	CREATE TABLE [dbo].[Cube_Fact_Tables_Periodicity](
		[Processed_ID] [bigint] IDENTITY(1,1) NOT NULL,
		[Country_ID] [bigint] NOT NULL,
		[Country_Name] NVARCHAR(250) NULL,
		[Dataset_Name] NVARCHAR(250) NULL,
		[Max_Date] [datetime] NULL
	) ON [PRIMARY]
	*/
	--Fact_Competitive_Spend
	--DROP TABLE Fact_Competitive_Spend

	CREATE TABLE [dbo].[Fact_Competitive_Spend] (
	[Competitive_Spend_ID] bigint NOT NULL primary key identity(1,1)  
	, [Country_ID] bigint NULL  
	, [Date_ID] bigint NULL  
	, [Media_ID] bigint NULL  
	, [Publisher_ID] bigint NULL  
	, [Region_ID] bigint NULL   
	, [Category_ID] bigint NULL  
	, [Product_ID] bigint NULL  
	, [Gross_Spend_Local] float NULL  
	, [Gross_Spend_USD] float NULL  
	, [Net_Spend_Local] float NULL  
	, [Net_Spend_USD] float NULL  
	)

	--Fact_Competitive_TV_GRPs
	--DROP TABLE [Fact_Competitive_TV_GRPs]

	CREATE TABLE [dbo].[Fact_Competitive_TV_GRPs] (
	[TV_GRPs_ID] bigint NOT NULL primary key identity (1,1) 
	, [Country_ID] bigint NULL  
	, [Date_ID] bigint NULL  
	, [Media_ID] bigint NULL  
	, [Publisher_ID] bigint NULL  
	, [Region_ID] bigint NULL  
	, [Category_ID] bigint NULL  
	, [Product_ID] bigint NULL  
	, [Spot_ID] bigint NULL
	--, [Day_Part_ID] bigint NULL  
	, [Audience_ID] bigint NULL  
	, [Actual_GRPs] float NULL  
	, [30sec_GRPs] float NULL  
	, [Reach_000s] float NULL  
	)

	--FK constraints
	--Fact_Competitive_Spend

	ALTER TABLE [dbo].[Fact_Competitive_Spend] WITH CHECK ADD CONSTRAINT [Dim_Country_Fact_Competitive_Spend_FK1] FOREIGN KEY (
	[Country_ID]
	)
	REFERENCES [dbo].[Dim_Country] (
	[Country_ID]
	)
	ALTER TABLE [dbo].[Fact_Competitive_Spend] WITH CHECK ADD CONSTRAINT [Dim_Product_Fact_Competitive_Spend_FK1] FOREIGN KEY (
	[Product_ID]
	)
	REFERENCES [dbo].[Dim_Product] (
	[Product_ID]
	)
	ALTER TABLE [dbo].[Fact_Competitive_Spend] WITH CHECK ADD CONSTRAINT [Dim_Product_Category_Fact_Competitive_Spend_FK1] FOREIGN KEY (
	[Category_ID]
	)
	REFERENCES [dbo].[Dim_Product_Category] (
	[Category_ID]
	)
	ALTER TABLE [dbo].[Fact_Competitive_Spend] WITH CHECK ADD CONSTRAINT [Dim_Date_Fact_Competitive_Spend_FK1] FOREIGN KEY (
	[Date_ID]
	)
	REFERENCES [dbo].[Dim_Date] (
	[Date_ID]
	)
	ALTER TABLE [dbo].[Fact_Competitive_Spend] WITH CHECK ADD CONSTRAINT [Dim_Media_Type_Fact_Competitive_Spend_FK1] FOREIGN KEY (
	[Media_ID]
	)
	REFERENCES [dbo].[Dim_Media_Type] (
	[Media_ID]
	)
	ALTER TABLE [dbo].[Fact_Competitive_Spend] WITH CHECK ADD CONSTRAINT [Dim_Region_Fact_Competitive_Spend_FK1] FOREIGN KEY (
	[Region_ID]
	)
	REFERENCES [dbo].[Dim_Region] (
	[Region_ID]
	)
	ALTER TABLE [dbo].[Fact_Competitive_Spend] WITH CHECK ADD CONSTRAINT [Dim_Publisher_Fact_Competitive_Spend_FK1] FOREIGN KEY (
	[Publisher_ID]
	)
	REFERENCES [dbo].[Dim_Publisher] (
	[Publisher_ID]
	)

	--Fact_Competitive_TV_GRPs
	ALTER TABLE [dbo].[Fact_Competitive_TV_GRPs] WITH CHECK ADD CONSTRAINT [Dim_Media_Type_Fact_Competitive_TV_GRPs_FK1] FOREIGN KEY (
	[Media_ID]
	)
	REFERENCES [dbo].[Dim_Media_Type] (
	[Media_ID]
	)
	ALTER TABLE [dbo].[Fact_Competitive_TV_GRPs] WITH CHECK ADD CONSTRAINT [Dim_Region_Fact_Competitive_TV_GRPs_FK1] FOREIGN KEY (
	[Region_ID]
	)
	REFERENCES [dbo].[Dim_Region] (
	[Region_ID]
	)
	ALTER TABLE [dbo].[Fact_Competitive_TV_GRPs] WITH CHECK ADD CONSTRAINT [Dim_Publisher_Fact_Competitive_TV_GRPs_FK1] FOREIGN KEY (
	[Publisher_ID]
	)
	REFERENCES [dbo].[Dim_Publisher] (
	[Publisher_ID]
	)
	ALTER TABLE [dbo].[Fact_Competitive_TV_GRPs] WITH CHECK ADD CONSTRAINT [Dim_Product_Category_Fact_Competitive_TV_GRPs_FK1] FOREIGN KEY (
	[Category_ID]
	)
	REFERENCES [dbo].[Dim_Product_Category] (
	[Category_ID]
	)
	ALTER TABLE [dbo].[Fact_Competitive_TV_GRPs] WITH CHECK ADD CONSTRAINT [Dim_Audience_Fact_Competitive_TV_GRPs_FK1] FOREIGN KEY (
	[Audience_ID]
	)
	REFERENCES [dbo].[Dim_Audience] (
	[Audience_ID]
	)
	ALTER TABLE [dbo].[Fact_Competitive_TV_GRPs] WITH CHECK ADD CONSTRAINT [Dim_Product_Fact_Competitive_TV_GRPs_FK1] FOREIGN KEY (
	[Product_ID]
	)
	REFERENCES [dbo].[Dim_Product] (
	[Product_ID]
	)
	ALTER TABLE [dbo].[Fact_Competitive_TV_GRPs] WITH CHECK ADD CONSTRAINT [Dim_Spot_Fact_Competitive_TV_GRPs_FK1] FOREIGN KEY (
	[Spot_ID]
	)
	REFERENCES [dbo].[Dim_Spot] (
	[Spot_ID]
	)
	ALTER TABLE [dbo].[Fact_Competitive_TV_GRPs] WITH CHECK ADD CONSTRAINT [Dim_Date_Fact_Competitive_TV_GRPs_FK1] FOREIGN KEY (
	[Date_ID]
	)
	REFERENCES [dbo].[Dim_Date] (
	[Date_ID]
	)
	ALTER TABLE [dbo].[Fact_Competitive_TV_GRPs] WITH CHECK ADD CONSTRAINT [Dim_Country_Fact_Competitive_TV_GRPs_FK1] FOREIGN KEY (
	[Country_ID]
	)
	REFERENCES [dbo].[Dim_Country] (
	[Country_ID]
	)
	/*
	ALTER TABLE [dbo].[Fact_Competitive_TV_GRPs] WITH CHECK ADD CONSTRAINT [Dim_Day_Part_Fact_Competitive_TV_GRPs_FK1] FOREIGN KEY (
	[Day_Part_ID]
	)
	REFERENCES [dbo].[Dim_Day_Part] (
	[Day_Part_ID]
	)
	*/
	/*
	--Process_History table
    CREATE TABLE [dbo].Process_History(
       [Process_ID] [bigint] IDENTITY(1,1) NOT NULL,
       [Start_Time] DATETIME,
       [End_Time] DATETIME,
       [Run_Time] TIME,
       [Process_Name] VARCHAR(50),
       [Process_Status] VARCHAR(50) NULL
       )
    
    --Mapping_Media table
    --drop table [France_Mapping_Media]
    
    CREATE TABLE [dbo].[France_Mapping_Media](
	[Media_Type] [nvarchar](50) NULL,
	[Media_ID]  bigint NULL
	)

	--Create processing tables
	--drop table [France_Processed_Competitive_Spend]
	
	--Spend
	CREATE TABLE [dbo].[France_Processed_Competitive_Spend](
		Country [nvarchar](4000) NULL
		,Family [nvarchar](4000) NULL
		,Class [nvarchar](4000) NULL
		,Sector [nvarchar](4000) NULL
		,Variety [nvarchar](4000) NULL
		,Company_Advertiser_Group [nvarchar](4000) NULL
		,Company_Advertiser [nvarchar](4000) NULL
		,Brand_Name [nvarchar](4000) NULL
		,Product_Name [nvarchar](4000) NULL
		,Media_Type [nvarchar](4000) NULL
		,[Year] [nvarchar](4000) NULL
		,[Month] [nvarchar](4000) NULL
		,Gross_EUR [float] NULL
		,Net_EUR [float] NULL
		,Gross_USD [float] NULL
		,Net_USD [float] NULL
		,[Country_ID] [bigint] NULL
		,[Date_ID] [bigint] NULL
		,[Media_ID] [bigint] NULL
		,[Publisher_ID] [bigint] NULL
		,[Region_ID] [bigint] NULL
		,[Category_ID] [bigint] NULL
		,[Product_ID] [bigint] NULL
		,[Processed_Date] [datetime] NULL
	) ON [PRIMARY]

	ALTER TABLE [dbo].[France_Processed_Competitive_Spend] ADD DEFAULT (getutcdate()) FOR [Processed_Date]
	
	--TV GRPs
	CREATE TABLE [dbo].[France_Processed_Competitive_TV_GRPs](
		[Country] [nvarchar](4000) NULL,
		[Family] [nvarchar](4000) NULL,
		[Class] [nvarchar](4000) NULL,
		[Sector] [nvarchar](4000) NULL,
		[Variety] [nvarchar](4000) NULL,
		[Company_Advertiser_Group] [nvarchar](4000) NULL,
		[Company_Advertiser] [nvarchar](4000) NULL,
		[Brand_Name] [nvarchar](4000) NULL,
		[Product_Name] [nvarchar](4000) NULL,
		[Year] [nvarchar](4000) NULL,
		[Month] [nvarchar](4000) NULL,
		[Week] [nvarchar](4000) NULL,
		[Date] [nvarchar](4000) NULL,
		[Channel] [nvarchar](4000) NULL,
		[Spot_Length] [nvarchar](4000) NULL,
		[Time_Slot] [nvarchar](4000) NULL,
		[Position_In_Break] [nvarchar](4000) NULL,
		[Start_Time] [nvarchar](4000) NULL,
		[End_Time] [nvarchar](4000) NULL,
		[Day_Part_Description] [nvarchar](4000) NULL,
		[Audience_Name] [nvarchar](4000) NULL,
		[Actual_GRPs] [float] NULL,
		[30sec_GRPs] [float] NULL,
		[Reach_000s] [float] NULL,
		[Country_ID] [bigint] NULL,
		[Date_ID] [bigint] NULL,
		[Media_ID] [bigint] NULL,
		[Publisher_ID] [bigint] NULL,
		[Region_ID] [bigint] NULL,
		[Category_ID] [bigint] NULL,
		[Product_ID] [bigint] NULL,
		[Spot_ID] [bigint] NULL,
		[Day_Part_ID] [bigint] NULL,
		[Audience_ID] [bigint] NULL,
		[Processed_Date] [datetime] NULL
	) ON [PRIMARY]

	ALTER TABLE [dbo].[France_Processed_Competitive_TV_GRPs] ADD DEFAULT (getutcdate()) FOR [Processed_Date]
	*/
	END