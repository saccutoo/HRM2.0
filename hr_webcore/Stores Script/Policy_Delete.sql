USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[Policy_Delete]    Script Date: 2/13/2019 11:15:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Policy_Delete]
	@PolicyID	int
as

	begin try
		
		delete from dbo.Policy	where PolicyID=@PolicyID
		DECLARE @PolicyAllowance int
		select @PolicyAllowance = count(*) from PolicyAllowance where PolicyID = @PolicyID
		if (@PolicyAllowance != 0)		
			begin
				delete from dbo.PolicyAllowance	where PolicyID=@PolicyID
			end	
	end try

	begin catch

		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),
				@SessionId				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'DeleteSec_StaffMarginLevel: ' + error_message()
		set @ErrorProc					= error_procedure()
		set @AddlInfo					= '@MenuID=' + convert(varchar, @PolicyID)

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Policy_Delete', 'DEL', @SessionId, @AddlInfo

	end catch




