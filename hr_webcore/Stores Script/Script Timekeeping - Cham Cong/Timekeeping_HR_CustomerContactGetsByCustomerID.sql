USE ERP_HRM
GO
/****** Object:  StoredProcedure [dbo].[HR_CustomerContactGetsByCustomerID]    Script Date: 12/19/2018 3:05:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
/*
***************************************************************************
	-- Author:			nhungpt
	-- Description:		Get List of contract for customer		
***************************************************************************
*/

ALTER PROCEDURE[dbo].[HR_CustomerContactGetsByCustomerID]
@CustomerID								bigint=23408,
@RoleID								int=3
as

begin try 

	IF @RoleID = 3 OR @RoleID = 29
	BEGIN
		Select AutoID,FullName from [ERP_v2].dbo.CustomerContact WHere ContactTypeID in (578,579)	AND CustomerID = @CustomerID
	END
	ELSE IF  @RoleID = 5 --ACCOUNT
	BEGIN
	Select AutoID,FullName from [ERP_v2].dbo.CustomerContact WHere ContactTypeID in (578,580)	AND CustomerID = @CustomerID
	END
	ELSE
	BEGIN
		Select AutoID,FullName from [ERP_v2].dbo.CustomerContact WHere  CustomerID = @CustomerID
	END
	 
		 
	end try

	begin catch

		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),
				@SessionId				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= '[CustomerContactGetsByCustomerID]: ' + error_message()
		set @ErrorProc					= error_procedure()

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, '[CustomerContactGetsByCustomerID]', 'GET', @SessionId, @AddlInfo

	end catch





