USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[PersonalIncomeTax_GetList]    Script Date: 3/1/2019 9:15:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[PersonalIncomeTax_GetList]
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

	set @cSqlFrom = N'SELECT a.*, StatusName = (SELECT Name FROM dbo.Globallist WHERE ParentID = 88 AND Value = a.Status),
			CurrencyName=(SELECT Name FROM dbo.Globallist WHERE ParentID = 3 AND OrderNo = a.CurrencyID),
			CountryName=(SELECT Name FROM dbo.Globallist WHERE ParentID = 44 AND Value = a.CountryID)
					FROM dbo.PersonalIncomeTax a'

	SELECT @cSql = @cSqlFrom + iif(@FilterField != '',ISNULL(+ ' ' +'WHERE ' + @FilterField, ''),'') + ' order by a.AutoID desc  '+ ' OFFSET  '+ CONVERT(VARCHAR,(@PageNumber - 1) * @PageSize) +' ROWS  FETCH NEXT ' + CONVERT(VARCHAR,@PageSize) +' ROWS ONLY '
	print (@cSql)
	exec(@cSql )
		SELECT  @cSql = ''
	SELECT @cSql = N'SELECT @TotalRecord = COUNT(a.AutoID) from ( '+ @cSqlFrom + +' '+iif(@FilterField != '',ISNULL('WHERE ' + @FilterField, ''),'')+' ) a'
	print (@cSql)
	SELECT @dynamicparamdec = N'@TotalRecord INT OUTPUT'
	exec sp_executesql @cSql, @dynamicparamdec, @TotalRecord OUTPUT
end
ELSE
BEGIN
	set @cSqlFrom =  N'SELECT a.*, StatusName = (SELECT Name FROM dbo.Globallist WHERE ParentID = 88 AND Value = a.Status),
			CurrencyName=(SELECT Name FROM dbo.Globallist WHERE ParentID = 3 AND OrderNo = a.CurrencyID),
			CountryName=(SELECT Name FROM dbo.Globallist WHERE ParentID = 44 AND Value = a.CountryID)
					FROM dbo.PersonalIncomeTax a'
	SELECT @cSql = @cSqlFrom +' '+iif(@FilterField != '',ISNULL('AND ' + @FilterField, ''),'') 
	set @TotalRecord = 0
	exec sp_executesql @cSql
END
	
END

