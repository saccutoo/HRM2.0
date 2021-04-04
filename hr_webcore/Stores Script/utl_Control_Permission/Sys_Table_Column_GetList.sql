USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[Sys_Table_Column_GetList]    Script Date: 3/29/2019 4:02:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Sys_Table_Column_GetList]
@RoleID		int
AS
BEGIN
		select a.* from  Sys_Table_Column a,Sys_Table_Column_Role b where b.TableColumnId=a.Id and b.RoleId=1	
END	
