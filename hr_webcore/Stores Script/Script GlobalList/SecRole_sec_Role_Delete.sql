USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[sec_Role_Delete]    Script Date: 12/24/2018 10:26:51 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<honghv>
-- alter date: <14/09/2018>
-- Description:	<xóa 1 bản ghi trong sec_controller>
-- =============================================
ALTER PROCEDURE [dbo].[sec_Role_Delete]
@id		int=0
as

	begin try
	print @id
		delete	from dbo.Sec_Role			where RoleID = @id
		print 'success'
		 
end try
begin catch
		print 'error'
end catch
		


