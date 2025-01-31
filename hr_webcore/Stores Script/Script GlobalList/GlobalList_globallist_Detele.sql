USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[globallist_Detele]    Script Date: 12/24/2018 9:41:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[globallist_Detele]
	-- Add the parameters for the stored procedure here
	@GlobalListID	int,
	@Result		int output
as

	begin try
		
		delete from	dbo.Globallist		where GlobalListID=@GlobalListID 
		 

		set @Result = 1
	end try

	begin catch
		set @Result = 0
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),
				@SessionId				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'Globallist_Delete: ' + error_message()
		set @ErrorProc					= error_procedure()
		set @AddlInfo					= '@GlobalListID=' + convert(varchar, @GlobalListID)

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Globallist_Delete', 'DEL', @SessionId, @AddlInfo

	end catch




