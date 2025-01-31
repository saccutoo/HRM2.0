USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[HR_WorkingDayMachineSatList_Save]    Script Date: 3/25/2019 5:39:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[HR_WorkingDayMachineSatList_Save]
@AutoID					int,
@WorkingDayMachineID	int,
@Day					date,
@IsFullday				int,
@Note					nvarchar(500),
@CreatedDate			datetime,
@CreatedBy				int,
@ModifiedDate			datetime,
@Modifiedby				int
AS
BEGIN
DECLARE @WorkingDayMachineSatList_Save int
	select @WorkingDayMachineSatList_Save = count(*) from HR_WorkingDayMachineSatList where AutoID = @AutoID
	if (@WorkingDayMachineSatList_Save = 0)		
		begin
			insert HR_WorkingDayMachineSatList (WorkingDayMachineID, [Day],IsFullday,Note,CreatedDate,CreatedBy) values(@WorkingDayMachineID, @Day,@IsFullday,@Note,@CreatedDate,@CreatedBy)
		end	
	else
		begin
			UPDATE HR_WorkingDayMachineSatList
			   SET 
				WorkingDayMachineID=@WorkingDayMachineID
				  ,[Day] = @Day
				 ,IsFullday = @IsFullday
				 ,Note = @Note					
				 ,ModifiedDate = @ModifiedDate
				 ,Modifiedby = @CreatedBy				
				 WHERE AutoID = @AutoID
		end	
END
