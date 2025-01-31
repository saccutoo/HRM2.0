USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[StandardSpending_Delete]    Script Date: 3/12/2019 3:58:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[StandardSpending_Delete]
	@Id	int
as

	begin try
		
		delete from ERP_v2.dbo.StandardSpending where  Id=@Id		
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
		set @AddlInfo					= '@MenuID=' + convert(varchar, @Id)

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'StandardSpending_Delete', 'DEL', @SessionId, @AddlInfo

	end catch




