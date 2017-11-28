CREATE FUNCTION dbo.Split (@sep nchar(1), @s nvarchar(512))
RETURNS table
AS
RETURN (
    WITH Pieces(pn, start, stop) AS (
      SELECT 1, 1, CHARINDEX(@sep, @s)
      UNION ALL
      SELECT pn + 1, stop + 1, CHARINDEX(@sep, @s, stop + 1)
      FROM Pieces
      WHERE stop > 0
    )
    SELECT pn,
      SUBSTRING(@s, start, CASE WHEN stop > 0 THEN stop-start ELSE 512 END) AS s
    FROM Pieces
  )

 create FUNCTION dbo.NSplit (@sep nvarchar(10), @s nvarchar(4000))
RETURNS table
AS
RETURN (
    WITH Pieces(pn, start, stop) AS (
      SELECT 1, 1, CHARINDEX(@sep, @s)
      UNION ALL
      SELECT pn + 1, stop + (datalength(@sep)/2), CHARINDEX(@sep, @s, stop + (datalength(@sep)/2))
      FROM Pieces
      WHERE stop > 0
    )
    SELECT pn,
      SUBSTRING(@s, start, CASE WHEN stop > 0 THEN stop-start ELSE 4000 END) AS s
    FROM Pieces
  )

  