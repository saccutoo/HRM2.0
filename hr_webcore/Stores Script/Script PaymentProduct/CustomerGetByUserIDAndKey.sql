USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[Customer_Gets_ByUserID_and_key]    Script Date: 09/01/2019 11:39:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE[dbo].[Customer_Gets_ByUserID_and_key]
@UserID    int ,
@Key NVARCHAR(500)
as

begin try
	
		-- select u.* from sec_User u (nolock) where u.CustStatus <> 5 And u.CustType = 0 and u.ManagerId like N'%'+@UserId+',%' (','+u.ManagerId+',' like N'%,'+@UserId+',%'
		 select top 20 c.CustomerID,c.FullName, IIF(c.Website IS NOT NULL,c.Website, IIF(c.Fanpage IS NOT NULL,c.Fanpage,c.CustomerCode + ' - ' + c.FullName)) Website , Fanpage , c.CustomerCode  
		 from ERP_v2.dbo.Customer c 
		 where   (@key IS NULL OR  @Key = '' OR c.FullName like '%'+@Key+'%' OR c.Website LIKE '%'+@Key+'%' OR c.Fanpage LIKE '%'+@Key+'%')
		 and   
		 c.CustomerID in
			 (SELECT c.CustomerID FROM 
			 ERP_v2.dbo.Staff_Customer_CustomerManagementRole c inner join ERP_v2.dbo.Staff_parent k  
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





