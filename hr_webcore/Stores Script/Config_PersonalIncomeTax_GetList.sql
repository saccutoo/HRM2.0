USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[Config_PersonalIncomeTax_GetList]    Script Date: 3/1/2019 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Config_PersonalIncomeTax_GetList]
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

	set @cSqlFrom = N'select * from dbo.Config_PersonalIncomeTax a'

	SELECT @cSql = @cSqlFrom + iif(@FilterField != '',ISNULL(+ ' ' +'WHERE ' + @FilterField, ''),'') + ' order by a.ID desc  '+ ' OFFSET  '+ CONVERT(VARCHAR,(@PageNumber - 1) * @PageSize) +' ROWS  FETCH NEXT ' + CONVERT(VARCHAR,@PageSize) +' ROWS ONLY '
	print (@cSql)
	exec(@cSql )
		SELECT  @cSql = ''
	SELECT @cSql = N'SELECT @TotalRecord = COUNT(a.ID) from ( '+ @cSqlFrom + +' '+iif(@FilterField != '',ISNULL('WHERE ' + @FilterField, ''),'')+' ) a'
	print (@cSql)
	SELECT @dynamicparamdec = N'@TotalRecord INT OUTPUT'
	exec sp_executesql @cSql, @dynamicparamdec, @TotalRecord OUTPUT
end
ELSE
BEGIN
	set @cSqlFrom =  N'select * from dbo.Config_PersonalIncomeTax a'
	SELECT @cSql = @cSqlFrom +' '+iif(@FilterField != '',ISNULL('AND ' + @FilterField, ''),'') 
	set @TotalRecord = 0
	exec sp_executesql @cSql
END
	
END

