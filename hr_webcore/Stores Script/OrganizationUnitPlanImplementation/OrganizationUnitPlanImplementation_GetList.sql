USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[OrganizationUnitPlanImplementation_GetList]    Script Date: 3/27/2019 5:36:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[OrganizationUnitPlanImplementation_GetList]
@FilterField		NVARCHAR(MAX) = '',
	@OrderBy			VARCHAR(100) = '',
	@PageNumber			INT = 1,
	@PageSize			INT = 20,
	@TotalRecord int = 0 output,
	@TotalRecordM1 float = 0 output,
	@TotalRecordM2 float = 0 output,
	@TotalRecordM3 float = 0 output,
	@TotalRecordM4 float = 0 output,
	@TotalRecordM5 float = 0 output,
	@TotalRecordM6 float = 0 output,
	@TotalRecordM7 float = 0 output,
	@TotalRecordM8 float = 0 output,
	@TotalRecordM9 float = 0 output,
	@TotalRecordM10 float = 0 output,
	@TotalRecordM11 float = 0 output,
	@TotalRecordM12 float = 0 output,
	@TotalRecordSumMonth float = 0 output,
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

	set @cSqlFrom = N'select a.*,StatusName=(SELECT Name FROM NovaonAD.dbo.Globallist WHERE ParentID = 88 AND Value = a.Status) 
			,OrganizationUnitName=(SELECT Name FROM dbo.Organizationunit WHERE  OrganizationUnitID=a.OrganizationUnitID) 
			,CurrencyName=(SELECT Name FROM NovaonAD.dbo.Globallist WHERE ParentID = 3 AND GlobalListID = a.CurrencyTypeID)
			,ContractTypeName=(SELECT Name FROM NovaonAD.dbo.Globallist WHERE ParentID = 1949 AND GlobalListID = a.ContractType)
			 ,iif(a.M1 is null, 0, a.M1) + iif(a.M2 is null, 0, a.M2)+ iif(a.M3 is null, 0, a.M3)+ iif(a.M4 is null, 0, a.M4)
			 + iif(a.M5 is null, 0, a.M5)+ iif(a.M6 is null, 0, a.M6) + iif(a.M7 is null, 0, a.M7)+ iif(a.M8 is null, 0, a.M8)+ 
			 iif(a.M9 is null, 0, a.M9)+ iif(a.M10 is null, 0, a.M10)+ iif(a.M11 is null, 0, a.M11)+ iif(a.M12 is null, 0, a.M12) as SumValue
			from ERP_v2.dbo.OrganizationUnitPlanImplementation a'

	SELECT @cSql = @cSqlFrom + iif(@FilterField != '',ISNULL(+ ' WHERE ' + @FilterField, ''),'') + ' order by a.AutoID desc  '+ ' OFFSET  '+ CONVERT(VARCHAR,(@PageNumber - 1) * @PageSize) +' ROWS  FETCH NEXT ' + CONVERT(VARCHAR,@PageSize) +' ROWS ONLY '

	print (@cSql)
	exec(@cSql )
		SELECT  @cSql = ''
	SELECT @cSql = N'SELECT @TotalRecord = COUNT(a.AutoID),@TotalRecordM1= SUM(iif(M1 is null, 0, M1)), @TotalRecordM2= SUM(iif(M2 is null, 0, M2)),@TotalRecordM3= SUM(iif(M3 is null, 0, M3)),@TotalRecordM4= SUM(iif(M4 is null, 0, M4)),
	@TotalRecordM5= SUM(iif(M5 is null, 0, M5)),@TotalRecordM6= SUM(iif(M6 is null, 0, M6)),@TotalRecordM7= SUM(iif(M7 is null, 0, M7)),@TotalRecordM8= SUM(iif(M8 is null, 0, M8)),@TotalRecordM9= SUM(iif(M9 is null, 0, M9)),@TotalRecordM10= SUM(iif(M10 is null, 0, M10))
	,@TotalRecordM11= SUM(iif(M11 is null, 0, M11)),@TotalRecordM12= SUM(iif(M12 is null, 0, M12)),@TotalRecordSumMonth=Sum(SumValue)
		from ( '+ @cSqlFrom + +' '+iif(@FilterField != '',ISNULL('WHERE ' + @FilterField, ''),'')+' ) a'
	print (@cSql)
	SELECT @dynamicparamdec = N'@TotalRecord INT OUTPUT,@TotalRecordM1 FLOAT OUTPUT,@TotalRecordM2 FLOAT OUTPUT,@TotalRecordM3 FLOAT OUTPUT
	,@TotalRecordM4 FLOAT OUTPUT,@TotalRecordM5 FLOAT OUTPUT,@TotalRecordM6 FLOAT OUTPUT,@TotalRecordM7 FLOAT OUTPUT,@TotalRecordM8 FLOAT OUTPUT
	,@TotalRecordM9 FLOAT OUTPUT,@TotalRecordM10 FLOAT OUTPUT,@TotalRecordM11 FLOAT OUTPUT,@TotalRecordM12 FLOAT OUTPUT,@TotalRecordSumMonth FLOAT OUTPUT'
	exec sp_executesql @cSql, @dynamicparamdec, @TotalRecord OUTPUT,@TotalRecordM1 OUTPUT,@TotalRecordM2 OUTPUT,@TotalRecordM3 OUTPUT,
	@TotalRecordM4 OUTPUT,@TotalRecordM5 OUTPUT,@TotalRecordM6 OUTPUT,@TotalRecordM7 OUTPUT,@TotalRecordM8 OUTPUT,@TotalRecordM9 OUTPUT,
	@TotalRecordM10 OUTPUT,@TotalRecordM11 OUTPUT,@TotalRecordM12 OUTPUT,@TotalRecordSumMonth OUTPUT
end
ELSE
BEGIN
	set @cSqlFrom =  N' select a.*,StatusName=(SELECT Name FROM NovaonAD.dbo.Globallist WHERE ParentID = 88 AND Value = a.Status) 
			,OrganizationUnitName=(SELECT Name FROM dbo.Organizationunit WHERE  OrganizationUnitID=a.OrganizationUnitID) 
			,CurrencyName=(SELECT Name FROM NovaonAD.dbo.Globallist WHERE ParentID = 3 AND GlobalListID = a.CurrencyTypeID)
			,ContractTypeName=(SELECT Name FROM NovaonAD.dbo.Globallist WHERE ParentID = 1949 AND GlobalListID = a.ContractType)
			 ,iif(a.M1 is null, 0, a.M1) + iif(a.M2 is null, 0, a.M2)+ iif(a.M3 is null, 0, a.M3)+ iif(a.M4 is null, 0, a.M4)
			 + iif(a.M5 is null, 0, a.M5)+ iif(a.M6 is null, 0, a.M6) + iif(a.M7 is null, 0, a.M7)+ iif(a.M8 is null, 0, a.M8)+ 
			 iif(a.M9 is null, 0, a.M9)+ iif(a.M10 is null, 0, a.M10)+ iif(a.M11 is null, 0, a.M11)+ iif(a.M12 is null, 0, a.M12) as SumValue
			from ERP_v2.dbo.OrganizationUnitPlanImplementation a'
	SELECT @cSql = @cSqlFrom +' '+iif(@FilterField != '',ISNULL('AND ' + @FilterField, ''),'') 
	set @TotalRecord = 0
	exec sp_executesql @cSql
END
	
END

