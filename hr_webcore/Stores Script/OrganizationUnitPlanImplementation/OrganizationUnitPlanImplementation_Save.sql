USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[OrganizationUnitPlanImplementation_Save]    Script Date: 3/27/2019 5:37:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[OrganizationUnitPlanImplementation_Save]
@AutoID							int,
@OrganizationUnitID				int,
@CurrencyTypeID					int,
@Status							int,
@Comment						nvarchar(4000),
@Type							int,
@ContractType					int,
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
	select @OrganizationUnitPlan_Save = count(*) from ERP_v2.dbo.OrganizationUnitPlanImplementation where AutoID = @AutoID
	if (@OrganizationUnitPlan_Save = 0)		
		begin
			insert into ERP_v2.dbo.OrganizationUnitPlanImplementation (OrganizationUnitID,CurrencyTypeID,[Status],Comment,[Type],ContractType,[Year],M1,M2,M3,M4,M5,M6,M7,M8,M9,M10,M11,M12,CreatedBy,CreatedOn) 
			values(@OrganizationUnitID,@CurrencyTypeID,@Status,@Comment,0,@ContractType,@Year,@M1,@M2,@M3,@M4,@M5,@M6,@M7,@M8,@M9,@M10,@M11,@M12,@CreatedBy,@CreatedOn)
		end	
	else
		begin
			UPDATE ERP_v2.dbo.OrganizationUnitPlanImplementation
			   SET 
				  OrganizationUnitID = @OrganizationUnitID
				 ,CurrencyTypeID = @CurrencyTypeID					
				 ,[Status] = @Status
				 ,Comment = @Comment
				 ,[Type]=0
				 ,ContractType=@ContractType
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
