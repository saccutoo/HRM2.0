USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[PersonalIncomeTax_Delete]    Script Date: 2/21/2019 6:12:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[PersonalIncomeTax_Delete]
	@AutoID					int
as
	begin try
		delete from	PersonalIncomeTax where AutoID = @AutoID
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),
				@SessionId				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'Insurance_Position_Del: ' + error_message()
		set @ErrorProc					= error_procedure()
		set @AddlInfo					= '@AutoID=' + convert(varchar, @AutoID)
		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Insurance_Position_Del', 'DEL', @SessionId, @AddlInfo
	end catch




