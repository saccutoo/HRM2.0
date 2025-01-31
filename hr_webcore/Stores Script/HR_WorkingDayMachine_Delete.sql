USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[HR_WorkingDayMachine_Delete]    Script Date: 2/1/2019 10:48:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[HR_WorkingDayMachine_Delete]
	@ID	int
as

	begin try
		
		delete from dbo.HR_WorkingDayMachine	where WorkingDayMachineID=@ID 
		 

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
		set @AddlInfo					= '@MenuID=' + convert(varchar, @ID)

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'HR_WorkingDayMachine_Delete', 'DEL', @SessionId, @AddlInfo

	end catch




