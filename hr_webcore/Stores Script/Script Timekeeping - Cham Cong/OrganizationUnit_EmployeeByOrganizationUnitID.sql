USE [ERP_HRM_20190214]
GO
/****** Object:  StoredProcedure [dbo].[EmployeeByOrganizationUnitID]    Script Date: 2/14/2019 6:02:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		honghv
-- alter date: 10/01/2019
-- Description:	lấy thông tin nhân viên theo phòng ban
-- =============================================
ALTER PROCEDURE [dbo].[EmployeeByOrganizationUnitID]
	@OrganizationUnitID 		int = NULL,
	@Roleid   					int=null,
	@StaffID   					int=null,
	@LanguageID							int				= null

as

begin TRY
	IF (@OrganizationUnitID = 0) AND (@Roleid != 1) AND (@Roleid != 11) AND (@Roleid != 10) --Lấy nhân viên theo nhân viên đăng nhập (bao gồm cả quản lý)
	BEGIN
		SELECT a.*, (a.Fullname + '_' +b.Name) AS NamePB FROM staff a , dbo.Organizationunit b where  a.OrganizationUnitID = b.OrganizationUnitID AND a.staffid in (SELECT a.StaffID FROM HR_ApprovementConfiguration a WHERE a.ManagerID=@StaffID or a.StaffID = @StaffID) order by fullname
	END
	ELSE IF (@OrganizationUnitID = 0) AND (@Roleid = 10) --Lấy nhân viên theo đăng nhập là HR
	BEGIN
		SELECT a.*, (a.Fullname + '_' +b.Name) AS NamePB FROM staff a , dbo.Organizationunit b where  a.OrganizationUnitID = b.OrganizationUnitID AND a.staffid in (SELECT a.StaffID FROM HR_ApprovementConfiguration a WHERE a.HRID=@StaffID or a.StaffID = @StaffID) order by fullname
	END
	ELSE
	BEGIN
		if (@Roleid=11) and isnull(@OrganizationUnitID,0)>0
		begin
			  select a.*, (a.Fullname + '_' +b.Name) AS NamePB FROM staff a, dbo.Organizationunit b where  a.OrganizationUnitID = b.OrganizationUnitID AND b.DS_CompanyID in (select CompanyID from Sec_User_ViewCompany where UserID=@StaffID) and a.OrganizationUnitID=@OrganizationUnitID AND a.Status in (879,1553, 2293,880) order by fullname
			  print(1)
		end
		else if (@Roleid=11) and  isnull(@OrganizationUnitID,0)<=0
		begin
			select a.*, (a.Fullname + '_' +b.Name) AS NamePB FROM staff a, dbo.Organizationunit b where  a.OrganizationUnitID = b.OrganizationUnitID  AND b.DS_CompanyID in (select CompanyID from Sec_User_ViewCompany where UserID=@StaffID)  AND a.Status in (879,1553, 2293,880)   order by fullname
			print(2)
		end
		else if (@Roleid!=1) and isnull(@OrganizationUnitID,0)>0 AND (@Roleid != 10)
		begin
			  select a.*, (a.Fullname + '_' +b.Name) AS NamePB FROM staff a, dbo.Organizationunit b where  a.OrganizationUnitID = b.OrganizationUnitID AND a.staffid in (SELECT a.StaffID FROM HR_ApprovementConfiguration a WHERE a.ManagerID=@StaffID or a.StaffID = @StaffID) and a.OrganizationUnitID=@OrganizationUnitID AND a.Status in (879,1553, 2293,880) order by fullname
			  print(1)
		end
		else if (@Roleid!=1) and isnull(@OrganizationUnitID,0)>0 AND (@Roleid = 10)
		begin
			  select a.*, (a.Fullname + '_' +b.Name) AS NamePB FROM staff a, dbo.Organizationunit b where  a.OrganizationUnitID = b.OrganizationUnitID AND a.staffid in (SELECT a.StaffID FROM HR_ApprovementConfiguration a WHERE a.HRID=@StaffID or a.StaffID = @StaffID) and a.OrganizationUnitID=@OrganizationUnitID AND a.Status in (879,1553, 2293,880) order by fullname
			  print(1)
		end
		else if (@Roleid=1) and isnull(@OrganizationUnitID,0)>0 --Admin lấy toàn bộ nhân viên
		begin
			  select a.*, (a.Fullname + '_' +b.Name) AS NamePB FROM staff a, dbo.Organizationunit b where  a.OrganizationUnitID=@OrganizationUnitID AND a.OrganizationUnitID = b.OrganizationUnitID AND a.Status = 879 order by fullname
		end
		else if (@Roleid=1)  --Admin lấy nhân viên theo phòng ban
		begin
			select a.*, (a.Fullname + '_' +b.Name) AS NamePB FROM staff a, dbo.Organizationunit b where  a.OrganizationUnitID = b.OrganizationUnitID AND a.Status in (879,1553, 2293,880) order by fullname
		end 

	END


	end try

	begin catch

		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),
				@SessionId				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'Get_EmployeeWhereOrganizationUnitID: ' + error_message()
		set @ErrorProc					= error_procedure()
		set @AddlInfo					= '@OrganizationUnitID=' + @OrganizationUnitID

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'dbo.Employee', 'GET', @SessionId, @AddlInfo

	end catch




