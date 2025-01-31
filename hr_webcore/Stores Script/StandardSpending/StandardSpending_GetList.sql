USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[StandardSpending_GetList]    Script Date: 3/13/2019 10:00:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[StandardSpending_GetList]
@FilterField		NVARCHAR(MAX) = '',
	@OrderBy			VARCHAR(100) = '',
	@PageNumber			INT = 1,
	@PageSize			INT = 20,
	@TotalRecord int = 0 output,
	@type int = 1
AS
BEGIN
DECLARE @StartIndex BIGINT, @EndIndex BIGINT, @cSql NVARCHAR(MAX), @cBeginSql NVARCHAR(MAX), @cSqlFrom NVARCHAR(MAX), @WhereSQL NVARCHAR(MAX),@vcWhereStatus NVARCHAR(MAX)
DECLARE @Delim	nvarchar(100)
DECLARE @dynamicparamdec NVARCHAR(2000)
IF(@type = 1)
	begin
	IF (ISNULL(@OrderBy, '') = '' )
		SELECT @OrderBy = ' ORDER BY AutoID DESC'

	SELECT @PageNumber = ISNULL(@PageNumber, 1), @PageSize = ISNULL(@PageSize, 50)
	SELECT @StartIndex = ((@PageNumber - 1) * @PageSize) + 1
	SELECT @EndIndex = @PageNumber * @PageSize

	set @cSqlFrom = N' select a.*,
				  Name=(SELECT Name FROM dbo.Policy WHERE a.PolicyID=PolicyID),
				  StaffLevelName = (SELECT Name FROM dbo.Globallist WHERE ParentID = 21 AND GlobalListID = a.StaffLevelId),
				  StatusName = (SELECT Name FROM dbo.Globallist WHERE ParentID = 88 AND Value = a.Status)
				  from ERP_v2.dbo.StandardSpending a'

	SELECT @cSql = @cSqlFrom + iif(@FilterField != '',ISNULL(+ ' WHERE ' +'a.' + @FilterField, ''),'') + ' order by a.Id desc  '+ ' OFFSET  '+ CONVERT(VARCHAR,(@PageNumber - 1) * @PageSize) +' ROWS  FETCH NEXT ' + CONVERT(VARCHAR,@PageSize) +' ROWS ONLY '
	--SELECT @cSql = @cSqlFrom +' where 1=1 '+iif(@FilterField != '',ISNULL('AND ' +'a.' + @FilterField, ''),'') + ' order by a.Id desc  '+ ' OFFSET  '+ CONVERT(VARCHAR,(@PageNumber - 1) * @PageSize) +' ROWS  FETCH NEXT '+ CONVERT(VARCHAR,@PageSize) +' ROWS ONLY '

	print (@cSql)
	exec(@cSql )
		SELECT  @cSql = ''
	SELECT @cSql = N'SELECT @TotalRecord = COUNT(a.Id) from ( '+ @cSqlFrom + +' '+iif(@FilterField != '',ISNULL('WHERE ' +'a.'+ + @FilterField, ''),'')+' ) a'
	print (@cSql)
	SELECT @dynamicparamdec = N'@TotalRecord INT OUTPUT'
	exec sp_executesql @cSql, @dynamicparamdec, @TotalRecord OUTPUT
end
ELSE
BEGIN
	set @cSqlFrom =  N' select a.*,
				  Name=(SELECT Name FROM dbo.Policy WHERE a.PolicyID=PolicyID),
				  StaffLevelName = (SELECT Name FROM dbo.Globallist WHERE ParentID = 21 AND GlobalListID = a.StaffLevelId),
				  StatusName = (SELECT Name FROM dbo.Globallist WHERE ParentID = 88 AND Value = a.Status)
				  from ERP_v2.dbo.StandardSpending a'
	SELECT @cSql = @cSqlFrom +' '+iif(@FilterField != '',ISNULL('AND ' + @FilterField, ''),'') 
	set @TotalRecord = 0
	exec sp_executesql @cSql
END
	
END

