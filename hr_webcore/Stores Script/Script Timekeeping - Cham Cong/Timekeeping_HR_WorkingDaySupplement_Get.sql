USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[HR_WorkingDaySupplement_Get]    Script Date: 1/15/2019 2:25:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[HR_WorkingDaySupplement_Get]
	@FilterField  						nvarchar(max)	= '  ',
	@OrderByField							varchar(100)	= null,
	@PageIndex							int				= 1,				
	@PageSize							int				= 20,	
	@UserId								int				= 121994,
	@LanguageId							int= NULL,
	@CurrentType						INT =1 ,--0: Lấy cá nhân, 1 : Lấy quản lý
	@TotalRecord						int			=0	output
AS
BEGIN

	declare		@WhereSQL				nvarchar(max),
				@Delim					nvarchar(100),
				@StartIndex				bigint,
				@EndIndex				bigint,
				@SQL					nvarchar(max),
				@whereDefaultSQL					nvarchar(max),			
				@dynamicsql				nvarchar(max),
				@dynamicparamdec		nvarchar(max),
				@WhereUser				nvarchar(max),
				@Roleid								int,					
				@BrandID int=null
				
		SET @WhereSQL = ''
		SELECT @Roleid = RoleID FROM dbo.Sec_Role_User WHERE UserID = @UserId
		IF @OrderByField = '' OR @OrderByField IS NULL
			BEGIN
				set		@OrderByField	=' CreatedDate DESC'
			END

		set		@FilterField			= isnull(@FilterField,'')

		--1. Calculate to paging
		set		@StartIndex				= @PageSize * @PageIndex
		set		@EndIndex				= @StartIndex + @PageSize

		set		@StartIndex				= ((@PageIndex - 1) * @PageSize) + 1
		set		@EndIndex				= @PageIndex * @PageSize 
		DECLARE @contQL INT
		SELECT @contQL = COUNT(AutoID) FROM ERP_HRM.dbo.HR_ApprovementConfiguration WHERE ManagerID = @UserId OR HRID = @UserId
		IF @UserId = 1
		BEGIN
			set @WhereUser = ''
		END
		ELSE IF @contQL = 0
		BEGIN
			PRINT @contQL
			SET @FilterField = @FilterField + ' and a.StaffID = ' + CAST(@UserId AS VARCHAR) + ' '
			PRINT @FilterField
		END
		ELSE
		BEGIN
			set	@Delim				= ' and '
			set @WhereUser=@Delim +  'ac.ManagerID = '+CAST(@UserId AS VARCHAR)
		END
		if @FilterField <> ''
			begin
			
				set	@Delim				= ' and '
				set	@WhereSQL			= @WhereSQL + @Delim +  @FilterField
			end
			set @whereDefaultSQL=''
    
	if (@Roleid=10) -- HR
	begin
		print N'HR chốt công'
		set	@Delim				= ' and '
			set @WhereUser=@Delim + 'ac.HRID = '+CAST(@UserId AS VARCHAR)  
	end
	if @Roleid!=10 -- Khác HR và Admin
	BEGIN
		IF @Roleid!=1
		print @Roleid
		BEGIN
			SET	@Delim				= ' and '
			set @WhereUser=''  
		END
	END

	SET @SQL='
							SELECT  a.AutoID,a.StaffID,a.Type,a.TypeName,a.Date,a.FromTime,a.ToTime,a.HourOff,a.DayOff,a.Status,a.PercentPayrollID,a.StatusName ,a.ReasonTypeName 
									,a.Note,a.CreatedDate,a.StaffName ,a.ManagerNote,a.HRNote,a.MonthVacation,a.CustomerContactName,a.CustomerReasonTypeName
							FROM(
										SELECT 
											 w.AutoID
											,w.StaffID
											,w.Type
											,TypeName= IIF('+CAST(@LanguageID AS VARCHAR)+'=5, g.Name,g.NameEN)
											,w.Date
											,w.FromTime
											,w.ToTime
											,w.HourOff
											,w.DayOff
											,w.Status
											,w.PercentPayrollID
											,StatusName = IIF('+CAST(@LanguageID AS VARCHAR)+'=5, gs.Name,gs.NameEN)
											,ReasonTypeName = IIF('+CAST(@LanguageID AS VARCHAR)+'=5, gr.Name,gr.NameEN) +  IIF(w.CustomerID iS NOT NULL AND w.ReasonType=1213,  '' :'' + (SELECT IIF(c.Website IS NOT NULL,c.Website, IIF(c.Fanpage IS NOT NULL,c.Fanpage,c.CustomerCode + '' - '' + c.FullName)) FROM [erp_v2].dbo.customer c WHere c.CustomerID = w.CustomerID),'''')
											,w.Note
											,w.CreatedDate
											,StaffName = IIF('+CAST(@LanguageID AS VARCHAR)+'=5, s.Fullname,s.FullnameEN)
											,w.ManagerNote
											,w.HRNote
											,w.MonthVacation
											,CustomerContactName = (Select FullName from [erp_v2].dbo.CustomerContact Where AutoID = w.CustomerContactID)
								,CustomerReasonTypeName = (Select  IIF('+CAST(@LanguageID AS VARCHAR)+'=5, Name,NameEN) from NovaonAD.dbo.GlobalList Where ParentID=1887 AND GlobalListID = w.CustomerReasonType)
										FROM HR_WorkingDaySupplement w 
											INNER JOIN NovaonAD.dbo.GlobalList g on g.Value = w.Type AND g.ParentID = 84
											INNER JOIN NovaonAD.dbo.GlobalList gs on gs.Value = w.Status AND gs.ParentID = 85
											INNER JOIN NovaonAD.dbo.GlobalList gr on gr.GlobalListID = w.ReasonType AND gr.ParentID = 86
											INNER JOIN HR_ApprovementConfiguration  ac on ac.StaffID = w.StaffID
											INNER JOIN Staff s on s.StaffID = w.StaffID
										WHERE  1=1'+ @WhereUser +
										') a WHERE 1=1 '+ @WhereSQL+ ' order by ' + @OrderByField + 
								' OFFSET  '+ convert(varchar,(@PageIndex - 1) * @PageSize) +' ROWS  FETCH NEXT '+ convert(varchar,@PageSize) +' ROWS ONLY '
					print @SQL
					EXEC(@SQL)		
					set	@dynamicsql				=
						N'select @TotalRecord = count(a.AutoID)'+
						' from (
							SELECT 
											w.AutoID
											,w.StaffID
											,w.Type
											,TypeName= IIF('+CAST(@LanguageID AS VARCHAR)+'=5, g.Name,g.NameEN)
											,w.Date
											,w.FromTime
											,w.ToTime
											,w.HourOff
											,w.DayOff
											,w.Status
											,w.PercentPayrollID
											,StatusName = IIF('+CAST(@LanguageID AS VARCHAR)+'=5, gs.Name,gs.NameEN)
											,ReasonTypeName = IIF('+CAST(@LanguageID AS VARCHAR)+'=5, gr.Name,gr.NameEN) +  IIF(w.CustomerID iS NOT NULL AND w.ReasonType=1213,  '' :'' + (SELECT IIF(c.Website IS NOT NULL,c.Website, IIF(c.Fanpage IS NOT NULL,c.Fanpage,c.CustomerCode + '' - '' + c.FullName)) FROM [erp_v2].dbo.customer c WHere c.CustomerID = w.CustomerID),'''')
											,w.Note
											,w.CreatedDate
											,StaffName = IIF('+CAST(@LanguageID AS VARCHAR)+'=5, s.Fullname,s.FullnameEN)
											,w.ManagerNote
											,w.HRNote
											,w.MonthVacation
											,CustomerContactName = (Select FullName from [erp_v2].dbo.CustomerContact Where AutoID = w.CustomerContactID)
								,CustomerReasonTypeName = (Select  IIF('+CAST(@LanguageID AS VARCHAR)+'=5, Name,NameEN) from NovaonAD.dbo.GlobalList Where ParentID=1887 AND GlobalListID = w.CustomerReasonType)
										FROM HR_WorkingDaySupplement w 
											INNER JOIN NovaonAD.dbo.GlobalList g on g.Value = w.Type AND g.ParentID = 84
											INNER JOIN NovaonAD.dbo.GlobalList gs on gs.Value = w.Status AND gs.ParentID = 85
											INNER JOIN NovaonAD.dbo.GlobalList gr on gr.GlobalListID = w.ReasonType AND gr.ParentID = 86
											INNER JOIN HR_ApprovementConfiguration  ac on ac.StaffID = w.StaffID
											INNER JOIN Staff s on s.StaffID = w.StaffID
										WHERE 1=1' + @WhereUser + '					
						) a Where 1=1'+ @WhereSQL
						SELECT @dynamicparamdec = N'@TotalRecord INT OUTPUT'
	exec sp_executesql @dynamicsql, @dynamicparamdec, @TotalRecord OUTPUT
END



