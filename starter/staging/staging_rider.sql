
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

CREATE EXTERNAL TABLE dbo.rider (
	rider_id INTEGER, 
	first VARCHAR(50), 
	last VARCHAR(50), 
	address VARCHAR(100), 
	birthday DATE, 
	account_start_date DATE, 
	account_end_date DATE, 
	is_member bit
	)
	WITH (
	LOCATION = 'publicrider.txt',
	DATA_SOURCE = [deproject1234_deproject1234_dfs_core_windows_net],
	FILE_FORMAT = [SynapseDelimitedTextFormat]
	)
GO


SELECT TOP 100 * FROM dbo.rider
GO