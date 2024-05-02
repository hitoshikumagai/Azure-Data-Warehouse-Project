IF NOT EXISTS (SELECT * FROM sys.external_file_formats WHERE name = 'SynapseDelimitedTextFormat') 
	CREATE EXTERNAL FILE FORMAT [SynapseDelimitedTextFormat] 
	WITH ( FORMAT_TYPE = DELIMITEDTEXT ,
	       FORMAT_OPTIONS (
			 FIELD_TERMINATOR = ',',
			 USE_TYPE_DEFAULT = FALSE
			))
GO

IF NOT EXISTS (SELECT * FROM sys.external_data_sources WHERE name = 'deproject1234_deproject1234_dfs_core_windows_net') 
	CREATE EXTERNAL DATA SOURCE [deproject1234_deproject1234_dfs_core_windows_net] 
	WITH (
		LOCATION = 'abfss://deproject1234@deproject1234.dfs.core.windows.net' 
	)
GO

CREATE EXTERNAL TABLE dbo.dim_station
WITH (
    LOCATION     = 'dim_station',
    DATA_SOURCE = [deproject1234_deproject1234_dfs_core_windows_net],
    FILE_FORMAT = [SynapseDelimitedTextFormat]
)  
AS
SELECT 
    station_id,
    name,
    latitude,
    longitude
FROM dbo.station;
GO

IF EXISTS (SELECT * FROM sys.external_tables WHERE name = 'dim_rider')
	DROP EXTERNAL TABLE dbo.dim_rider
GO

CREATE EXTERNAL TABLE dbo.dim_rider
WITH (
    LOCATION     = 'dim_rider',
    DATA_SOURCE = [deproject1234_deproject1234_dfs_core_windows_net],
    FILE_FORMAT = [SynapseDelimitedTextFormat]
)  
AS
	SELECT
	CONCAT([R].[rider_id],[rideable_type]) AS rider_id_rideable_type
	,[first]
	,[last]
	,[address]
	,[birthday]
	,[account_start_date]
	,[account_end_date]
	,[is_member]
	,[rideable_type]
	FROM [dbo].[rider] as R
	LEFT OUTER JOIN [dbo].[trip] as T
	ON [T].[rider_id] = [R].[rider_id]
GO

IF EXISTS (SELECT * FROM sys.external_tables WHERE name = 'fact_trip')
	DROP EXTERNAL TABLE dbo.fact_trip
GO

CREATE EXTERNAL TABLE dbo.fact_trip
WITH (
    LOCATION     = 'fact_trip',
    DATA_SOURCE = [deproject1234_deproject1234_dfs_core_windows_net],
    FILE_FORMAT = [SynapseDelimitedTextFormat]
)  
AS
	SELECT
	[trip_id]
	,CONCAT([T].[rider_id],[rideable_type]) AS rider_id_rideable_type
	,CAST([start_at] AS DATE) AS start_at
	,CAST([ended_at] AS DATE) AS ended_at
	,[start_station_id]
	,[end_station_id]
	,DATEDIFF(minute, [start_at], [ended_at]) AS duration
	,DATEDIFF(month, [account_start_date],[start_at]) AS account_age
	FROM [dbo].[trip] AS T
	LEFT OUTER JOIN [dbo].[rider] AS R
	ON [T].[rider_id] = [R].[rider_id];


IF EXISTS (SELECT * FROM sys.external_tables WHERE name = 'fact_payment')
	DROP EXTERNAL TABLE dbo.fact_payment
GO

CREATE EXTERNAL TABLE dbo.fact_payment
WITH (
    LOCATION     = 'fact_payment',
    DATA_SOURCE = [deproject1234_deproject1234_dfs_core_windows_net],
    FILE_FORMAT = [SynapseDelimitedTextFormat]
)  
AS
	SELECT [payment_id]
	,CONCAT([R].[rider_id],[rideable_type]) AS rider_id_rideable_type
	,[date]
	,[amount]
	,[account_start_date]
	,[account_end_date]
	,DATEDIFF(year, [birthday], [account_start_date]) AS rider_age
	FROM [dbo].[payment] as P 
	LEFT OUTER JOIN [dbo].[rider] as R 
	ON [P].[rider_id] = [R].[rider_id]
	LEFT OUTER JOIN [dbo].[trip] as T 
	ON [P].[rider_id] = [T].[rider_id]

IF EXISTS (SELECT * FROM sys.external_tables WHERE name = 'dim_time')
	DROP EXTERNAL TABLE dbo.dim_time
GO

CREATE EXTERNAL TABLE dbo.dim_time
WITH (
    LOCATION     = 'dim_time',
    DATA_SOURCE = [deproject1234_deproject1234_dfs_core_windows_net],
    FILE_FORMAT = [SynapseDelimitedTextFormat]
)  
AS
	SELECT DISTINCT [date]
	,DATEPART(YEAR, [date]) as year 
	,DATEPART(QUARTER, [date]) as quater
	,DATEPART(MONTH, [date]) as month
	,DATEPART(WEEK, [date]) as week_of_year
	,DATEPART(DAY, [date]) as day
	,DATEPART(WEEKDAY, [date]) as day_of_week
	FROM [dbo].[payment] 
	ORDER BY [date]
GO