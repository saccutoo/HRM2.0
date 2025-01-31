USE ERP_HRM
GO
/****** Object:  StoredProcedure [dbo].[Customer_Gets_ByUserID]    Script Date: 12/19/2018 2:57:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

/*
***************************************************************************
	-- Author:			Nhungpt
	-- Description:		Get List of States		
***************************************************************************
*/

ALTER PROCEDURE[dbo].[Customer_Gets_ByUserID]
@UserID    int 
as

begin try
	
		-- select u.* from sec_User u (nolock) where u.CustStatus <> 5 And u.CustType = 0 and u.ManagerId like N'%'+@UserId+',%' (','+u.ManagerId+',' like N'%,'+@UserId+',%'
		 select c.CustomerID,c.FullName, IIF(c.Website IS NOT NULL,c.Website, IIF(c.Fanpage IS NOT NULL,c.Fanpage,c.CustomerCode + ' - ' + c.FullName)) Website , Fanpage , c.CustomerCode  from [ERP_v2].dbo.Customer c 
		 where       c.CustomerID in
			 (SELECT c.CustomerID FROM 
			 [ERP_v2].dbo.Staff_Customer_CustomerManagementRole c inner join Staff_parent k  
			   on c.StaffID =k.StaffId
			where k.Parentid=@UserID AND c.Status=1)  
		
	end try

	begin catch

		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),
				@SessionId				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= '[erp_PriceGoogle_User_GetCustomerByEmployee]: ' + error_message()
		set @ErrorProc					= error_procedure()

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'AP_Domain', 'GET', @SessionId, @AddlInfo

	end catch





