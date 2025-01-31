USE [ERP_v2]
GO
/****** Object:  StoredProcedure [dbo].[Quotation_Del]    Script Date: 6/19/2019 5:27:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

/*
***************************************************************************
	-- Author:			Nhungpt
	-- Description:		Get Quotation_Del
***************************************************************************
*/

ALTER procedure[dbo].[Quotation_Del]

	@QuotationID					varchar(500),
	@Result							int output
as

	begin try
		delete from	[QuotationServiceApprovement]			where DS_QuotationID in (select a.val from splitId( @QuotationID,',') a)
		delete from	QuotationService_Staff		where DS_QuotationID  in (select a.val from splitId( @QuotationID,',') a)
		delete from	QuotationService	where QuotationID  in (select a.val from splitId( @QuotationID,',') a)
		delete from	QuotationDetail	where DS_QuotationID  in (select a.val from splitId( @QuotationID,',') a)
		delete from	Quotation		where QuotationID  in (select a.val from splitId( @QuotationID,',') a)
		 

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
		set @ErrorMsg					= 'Quotation_Del: ' + error_message()
		set @ErrorProc					= error_procedure()
		set @AddlInfo					= '@QuotationID=' + convert(varchar, @QuotationID)

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Quotation_Del', 'DEL', @SessionId, @AddlInfo

	end catch




