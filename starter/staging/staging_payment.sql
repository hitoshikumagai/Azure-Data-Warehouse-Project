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

CREATE EXTERNAL TABLE dbo.paymaent (
	payment_id INTEGER , 
	date DATE, 
	amount MONEY, 
	rider_id INTEGER
	)
	WITH (
	LOCATION = 'publicpayment.txt',
	DATA_SOURCE = [deproject1234_deproject1234_dfs_core_windows_net],
	FILE_FORMAT = [SynapseDelimitedTextFormat]
	)
GO


SELECT TOP 100 * FROM dbo.paymaent
GO