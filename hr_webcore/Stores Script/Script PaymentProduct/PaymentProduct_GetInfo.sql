USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[PaymentProduct_GetInfo]    Script Date: 11/01/2019 10:37:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

/*
***************************************************************************
	-- Author:			thanhbt
	-- Description:		Get List of PaymentProduct
	-- Date				PIC					alter record
	-- 2018/10/10       Nhungpt             Addnew
***************************************************************************
*/

ALTER procedure[dbo].[PaymentProduct_GetInfo]

	@UserID  						int	= null,
	@Roleid   					int=null,
	@LanguageID							int				= null,
	@CustomerID	int=null

as

begin try
	
		  select *,
		   CustomerName=(select CONCAT(FullName,'_', Website,'_', Fanpage) from ERP_v2.dbo.Customer c where c.CustomerID=@CustomerID),
		   UserLoginName= (select iif(@LanguageId=4,FullnameEN,Fullname) from Staff s where s.UserID=@UserId)
		   from PaymentProduct pd
		  
		   where CustomerID=@CustomerID
					
	end try

	begin catch

		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),
				@SessionId				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'PaymentProduct_GetInfo: ' + error_message()
		set @ErrorProc					= error_procedure()
		set @AddlInfo					= '@CustomerID=' + @CustomerID

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'dbo.PaymentProduct', 'GET', @SessionId, @AddlInfo

	end catch






