USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[Get_All_OrganizationUnitWhereRole]    Script Date: 1/2/2019 10:44:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		thanhbt
-- alter date: 15-10-2018
-- Description:	lấy tất cả phòng ban
-- =============================================
ALTER PROCEDURE [dbo].[Get_All_OrganizationUnitWhereRole]
	-- Add the parameters for the stored procedure here
		@Staffid int=0,
		@chon INT,
		@Roleid int=null,
		@Result int output
as

	begin TRY
	if (@Roleid=1 or @Roleid=10  or @Roleid=11)
	begin
		IF @chon = 1
		BEGIN
			
		select OrganizationUnitID, Name from dbo.Organizationunit where Status = 1 AND Type != 902 ORDER BY Name
		END
		ELSE
		BEGIN
			SELECT OrganizationUnitID, Name FROM dbo.V_OrganizationUnit a where Status = 1 AND Type != 902 order by a.Deptlist
		end
	end
	else
		begin
			IF @chon = 1
		BEGIN
			
			select OrganizationUnitID, Name from dbo.Organizationunit where Status = 1 AND Type != 902
			and OrganizationUnitID in  (select OrganizationUnitID from staff e inner join Staff_Parent s on e.StaffID=s.StaffId where s.parentid=@StaffID)
			 ORDER BY Name
		END
		ELSE
		BEGIN
			SELECT OrganizationUnitID, Name FROM dbo.V_OrganizationUnit a where Status = 1 AND Type != 902 
			and OrganizationUnitID in  (select OrganizationUnitID from staff e inner join Staff_Parent s on e.StaffID=s.StaffId where s.parentid=@StaffID)
			order by a.Deptlist
		end
		end
		
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
		set @ErrorMsg					= 'Get_All_OrganizationUnit: ' + error_message()
		set @ErrorProc					= error_procedure()
		

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Get_All_OrganizationUnit', 'GAOU', @SessionId, @AddlInfo

	end catch




