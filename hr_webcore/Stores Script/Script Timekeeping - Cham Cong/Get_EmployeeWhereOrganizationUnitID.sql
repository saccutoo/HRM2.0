USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[Get_EmployeeWhereOrganizationUnitID]    Script Date: 1/9/2019 5:37:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		thanhbt
-- alter date: 07/11/2018
-- Description:	lấy thông tin nhân viên theo phòng ban
-- =============================================
ALTER PROCEDURE [dbo].[Get_EmployeeWhereOrganizationUnitID]
	@OrganizationUnitID 						NVARCHAR(500) = NULL,
	@Roleid   					int=null,
	@StaffID   					int=null,
	@LanguageID							int				= null

as

begin TRY
	IF @OrganizationUnitID = N'' OR @OrganizationUnitID =NULL
	BEGIN
		SELECT * FROM staff a where a.staffid in (select staffid from Staff_Parent where parentid=@StaffID) order by fullname
	END
	ELSE
	BEGIN
		DECLARE @id INT
		DECLARE @len INT
		SET @len = 0
		SELECT @len =  OrganizationUnitID FROM dbo.Organizationunit WHERE Name = @OrganizationUnitID
		IF @len = 0
		BEGIN
			SET @id = CAST(@OrganizationUnitID AS int)
		END
		ELSE
		BEGIN
			SELECT @id = OrganizationUnitID FROM dbo.Organizationunit WHERE Name = @OrganizationUnitID
		END
		if (@Roleid=11) and isnull(@id,0)>0
		begin
			  select a.*, (a.Fullname + '_' +b.Name) AS NamePB FROM staff a, dbo.Organizationunit b where  a.OrganizationUnitID = b.OrganizationUnitID AND b.DS_CompanyID in (select CompanyID from Sec_User_ViewCompany where UserID=@StaffID) and a.OrganizationUnitID=@id order by fullname
			  print(1)
		end
		else if (@Roleid=11) and  isnull(@id,0)<=0
		begin
			select a.*, (a.Fullname + '_' +b.Name) AS NamePB FROM staff a, dbo.Organizationunit b where  a.OrganizationUnitID = b.OrganizationUnitID  AND b.DS_CompanyID in (select CompanyID from Sec_User_ViewCompany where UserID=@StaffID)    order by fullname
			print(2)
		end
		else if (@Roleid!=1) and isnull(@id,0)>0
		begin
			  select a.*, (a.Fullname + '_' +b.Name) AS NamePB FROM staff a, dbo.Organizationunit b where  a.OrganizationUnitID = b.OrganizationUnitID AND a.staffid in (select staffid from Staff_Parent where parentid=@StaffID) and a.OrganizationUnitID=@id order by fullname
			  print(1)
		end
		
		
		else if (@Roleid!=1) and  isnull(@id,0)<=0
		begin
			select a.*, (a.Fullname + '_' +b.Name) AS NamePB FROM staff a, dbo.Organizationunit b where  a.OrganizationUnitID = b.OrganizationUnitID AND b.DS_CompanyID in (select CompanyID from Sec_User_ViewCompany where UserID=@StaffID)   order by fullname
			print(2)
		end
		else if (@Roleid=1) and isnull(@id,0)>0
		begin
			  select a.*, (a.Fullname + '_' +b.Name) AS NamePB FROM staff a, dbo.Organizationunit b where  a.OrganizationUnitID=@id AND a.OrganizationUnitID = b.OrganizationUnitID order by fullname
		end
		else if (@Roleid=1)  
		begin
			select a.*, (a.Fullname + '_' +b.Name) AS NamePB FROM staff a, dbo.Organizationunit b where  a.OrganizationUnitID = b.OrganizationUnitID order by fullname
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
		set @AddlInfo					= '@OrganizationUnitID=' + @id

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'dbo.Employee', 'GET', @SessionId, @AddlInfo

	end catch




