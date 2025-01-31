USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[HR_WorkingDayMachineDetail_Save]    Script Date: 2/25/2019 4:12:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[HR_WorkingDayMachineDetail_Save]
@AutoID					int,
@WorkingDayMachineID	int,
@StartTime				time(7),
@EndTime				time(7),
@StartDate				datetime,
@EndDate				datetime,
@Status					int,
@WorkingType			bit,
@Timekeeping			float
AS
BEGIN
DECLARE @HR_WorkingDayMachineDetail_Save int
	select @HR_WorkingDayMachineDetail_Save = count(*) from HR_WorkingDayMarchineDetail where AutoID = @AutoID
	if (@HR_WorkingDayMachineDetail_Save = 0)		
		begin
			insert into HR_WorkingDayMarchineDetail (WorkingDayMachineID,StartTime,EndTime,StartDate,EndDate,[Status],WorkingType,Timekeeping) values(@WorkingDayMachineID,@StartTime,@EndTime,CONVERT(DATE,@StartDate),CONVERT(DATE,@EndDate),@Status,@WorkingType,@Timekeeping)
		end	
	else
		begin
			UPDATE  HR_WorkingDayMarchineDetail
			   SET 
				 WorkingDayMachineID = @WorkingDayMachineID
				 ,StartTime = @StartTime					
				 ,EndTime = @EndTime
				 ,StartDate=CONVERT(DATE,@StartDate)
				 ,EndDate=CONVERT(DATE,@EndDate)
				 ,[Status]=@Status
				 ,WorkingType=@WorkingType
				 ,Timekeeping=@Timekeeping
				 WHERE AutoID = @AutoID
		end	
END
