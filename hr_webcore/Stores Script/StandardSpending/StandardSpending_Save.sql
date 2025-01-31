USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[StandardSpending_Save]    Script Date: 3/12/2019 4:02:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[StandardSpending_Save]
@Id							int,
@StaffLevelId				int,
@StandardSpendingAmount		float,
@PolicyID					int,
@MinSpending				float,
@MinPerson					int,
@StartDate					datetime,
@EndDate					datetime,
@Status						int,
@CreatedBy					int,
@CreatedDate				datetime,
@ModifiedBy					int,
@ModifiedDate				datetime
AS
BEGIN
DECLARE @StandardSpending_Save int
	select @StandardSpending_Save = count(*) from ERP_v2.dbo.StandardSpending where Id = @Id
	if (@StandardSpending_Save = 0)		
		begin
			insert into ERP_v2.dbo.StandardSpending (StaffLevelId,StandardSpendingAmount,PolicyID,MinSpending,MinPerson,StartDate,EndDate,Status,CreatedBy,CreatedDate) 
			values(@StaffLevelId,@StandardSpendingAmount,@PolicyID,@MinSpending,@MinPerson,@StartDate,@EndDate,@Status,@CreatedBy,@CreatedDate)
		end	
	else
		begin
			UPDATE ERP_v2.dbo.StandardSpending
			   SET 
				  StaffLevelId = @StaffLevelId
				 ,StandardSpendingAmount = @StandardSpendingAmount					
				 ,PolicyID = @PolicyID
				 ,MinSpending = @MinSpending
				 ,MinPerson=@MinPerson
				 ,StartDate = @StartDate
				 ,EndDate = @EndDate
				 ,Status = @Status
				 ,ModifiedBy = @ModifiedBy
				 ,ModifiedDate = @ModifiedDate								
				 WHERE Id = @Id
		end	
END
