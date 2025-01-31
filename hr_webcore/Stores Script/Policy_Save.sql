USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[PolicyAllowance_Save]    Script Date: 2/19/2019 8:46:58 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[PolicyAllowance_Save]
@AutoID					int,
@PolicyID				int,
@AllowanceID				int
AS
BEGIN
DECLARE @PolicyAllowance_Save int
	if(@AutoID!=0)
		begin
			UPDATE PolicyAllowance
			   SET 
				  [PolicyID]=@PolicyID
				 ,[AllowanceID] = @AllowanceID				 
				 WHERE AutoID=@AutoID
		end
	select @PolicyAllowance_Save = count(*) from PolicyAllowance where PolicyID = @PolicyID and AllowanceID=@AllowanceID
	if (@PolicyAllowance_Save = 0)		
		begin
			insert  PolicyAllowance (PolicyID,AllowanceID) values(@PolicyID,@AllowanceID)
		end	
	else
		begin
			UPDATE PolicyAllowance
			   SET 
				  [PolicyID]=@PolicyID
				 ,[AllowanceID] = @AllowanceID				 
				 WHERE PolicyID = @PolicyID and AllowanceID=@AllowanceID
		end	
END
