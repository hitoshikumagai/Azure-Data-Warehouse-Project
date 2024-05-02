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

CREATE EXTERNAL TABLE dbo.trip (
	trip_id VARCHAR(50), 
	rideable_type VARCHAR(75), 
	start_at DATETIME, 
	ended_at DATETIME, 
	start_station_id VARCHAR(50), 
	end_station_id VARCHAR(50), 
	rider_id INTEGER
	)
	WITH (
	LOCATION = 'publictrip.txt',
	DATA_SOURCE = [deproject1234_deproject1234_dfs_core_windows_net],
	FILE_FORMAT = [SynapseDelimitedTextFormat]
	)
GO


SELECT TOP 100 * FROM dbo.trip
GO