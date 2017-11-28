
DECLARE @table_name VARCHAR(100)
 
DECLARE table_cursor CURSOR FOR 
  SELECT 
    [name]
  FROM 
    dbo.sysobjects 
  WHERE 
    OBJECTPROPERTY(id, N'IsUserTable') = 1
FOR READ ONLY
 
CREATE TABLE #temp_table (
  tableName varchar(100),
  numberofRows varchar(100),
  reservedSize varchar(50),
  dataSize varchar(50),
  indexSize varchar(50),
  unusedSize varchar(50)
)
 
OPEN table_cursor
 
FETCH NEXT FROM table_cursor INTO @table_name
 
WHILE (@@Fetch_Status >= 0)
BEGIN
    INSERT #temp_table EXEC sp_spaceused @table_name
 
    FETCH NEXT FROM table_cursor INTO @table_name
END
 
CLOSE table_cursor
DEALLOCATE table_cursor
 
SELECT * FROM #temp_table ORDER BY tableName