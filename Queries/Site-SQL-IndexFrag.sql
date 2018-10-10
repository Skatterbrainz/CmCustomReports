DECLARE @current_time as NVarchar(20)

SET @current_time = CONVERT(Varchar, GETDATE(), 3) + ' ' + CONVERT(Varchar, getdate(), 24)

SELECT 
	@current_time as Timestamp,
	DB_NAME(database_id) AS [Database Name], 
	OBJECT_NAME(ps.OBJECT_ID) AS [Object Name],
	i.name AS [Index Name], 
	ps.index_id, index_type_desc,
	avg_fragmentation_in_percent, 
	fragment_count, 
	page_count
FROM 
	sys.dm_db_index_physical_stats(DB_ID(),NULL, NULL, NULL ,'LIMITED') AS ps
	INNER JOIN sys.indexes AS i WITH (NOLOCK)
	ON ps.[object_id] = i.[object_id] AND ps.index_id = i.index_id
WHERE 
	database_id = DB_ID() AND page_count > 1500
ORDER BY OBJECT_NAME(ps.OBJECT_ID), avg_fragmentation_in_percent DESC OPTION (RECOMPILE);
