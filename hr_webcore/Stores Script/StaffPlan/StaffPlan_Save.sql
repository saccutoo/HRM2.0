USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[StaffPlan_Save]    Script Date: 3/27/2019 5:42:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[StaffPlan_Save]
@AutoID							int,
@UserID							int,
@OrganizationUnitID				int,
@CurrencyTypeID					int,
@Status							int,
@Comment						nvarchar(4000),
@Type							int,
@Year							int,
@M1								float,
@M2								float,
@M3								float,
@M4								float,
@M5								float,
@M6								float,
@M7								float,
@M8								float,
@M9								float,
@M10							float,
@M11							float,
@M12							float,
@CreatedBy						int,
@CreatedOn						datetime,
@ModifiedBy						int,
@ModifiedOn						datetime
AS
BEGIN
DECLARE @OrganizationUnitPlan_Save int
	select @OrganizationUnitPlan_Save = count(*) from  ERP_v2.dbo.StaffPlan where AutoID = @AutoID
	if (@OrganizationUnitPlan_Save = 0)		
		begin
			insert into  ERP_v2.dbo.StaffPlan (UserID,DS_OrganizationUnitID,CurrencyTypeID,[Status],Comment,[Type],[Year],M1,M2,M3,M4,M5,M6,M7,M8,M9,M10,M11,M12,CreatedBy,CreatedOn) 
			values(@UserID,@OrganizationUnitID,@CurrencyTypeID,@Status,@Comment,0,@Year,@M1,@M2,@M3,@M4,@M5,@M6,@M7,@M8,@M9,@M10,@M11,@M12,@CreatedBy,@CreatedOn)
		end	
	else
		begin
			UPDATE  ERP_v2.dbo.StaffPlan
			   SET 
				  UserID=@UserID
				 ,DS_OrganizationUnitID = @OrganizationUnitID
				 ,CurrencyTypeID = @CurrencyTypeID					
				 ,[Status] = @Status
				 ,Comment = @Comment
				 ,[Type]=0
				 ,[Year] = @Year
				 ,M1=@M1
				 ,M2=@M2
				 ,M3=@M3
				 ,M4=@M4
				 ,M5=@M5
				 ,M6=@M6
				 ,M7=@M7
				 ,M8=@M8
				 ,M9=@M9
				 ,M10=@M10
				 ,M11=@M11
				 ,M12=@M12
				 ,ModifiedBy= @ModifiedBy	
				 ,ModifiedOn= @ModifiedOn				 									
				 WHERE AutoID = @AutoID
		end	
END
