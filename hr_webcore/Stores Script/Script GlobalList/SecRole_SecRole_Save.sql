USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[SecRole_Save]    Script Date: 12/24/2018 10:25:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
***************************************************************************
	-- Author:			HongHv
	-- Description:		Update SecRole
	-- Date				5/11/2018					Update record
***************************************************************************
*/

ALTER PROCEDURE[dbo].[SecRole_Save]
		@RoleID INT OUTPUT,
		@Name NVARCHAR(MAX),
		@NameEN NVARCHAR(MAX)
	
as
 
 BEGIN TRY

if(@RoleID>0)
begin

UPDATE NovaonAD.dbo.Sec_Role
   SET Name = @Name,
		NameEN = @NameEN
 WHERE RoleID=@RoleID

end
else
BEGIN
INSERT INTO NovaonAD.dbo.Sec_Role
        ( Name, NameEN )
VALUES  ( @Name, -- Name - nvarchar(100)
          @NameEN  -- NameEN - nvarchar(100)
          )
SET @RoleID = scope_Identity()
end
	

end try

	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),
				@SessionId				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= '[SecRole_Save: ' + error_message()
		set @ErrorProc					= error_procedure()
		set @AddlInfo					= '@FilterField'

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'dbo.Sec_Role', 'GET', @SessionId, @AddlInfo

	end catch
