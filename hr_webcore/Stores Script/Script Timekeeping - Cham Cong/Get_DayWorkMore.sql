USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[Get_DayWorkMore]    Script Date: 1/4/2019 1:20:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[Get_DayWorkMore]
	 @UserId INT = 22947,
	 @DateWork Datetime = '06/30/2018',
	 @FromHour VARCHAR(10)='08:00:00',
	 @ToHour VARCHAR(10)='15:30:00',
	 @DayWork FLOAT = 0 OUT
AS
BEGIN
	DECLARE @WorkingDayMachineID INT

	SELECT @WorkingDayMachineID= WorkingDayMachineID FROM  HR_IDMapping m
	WHere m.StaffID = @UserId AND IIF(m.WorkingDayMachineDate IS NULL,CAST(@DateWork AS DATE),cast(m.WorkingDayMachineDate as date)) <= CAST(@DateWork AS DATE)--DATEFROMPARTS(IIF((MONTH(GETDATE())-1)=0,YEAR(GETDATE())-1,YEAR(GETDATE())),IIF((MONTH(GETDATE())-1)=0,12,(MONTH(GETDATE())-1)),28)
	
	
	SELECT @DayWork = DayWork  FROM [Get_DayWorkByTime](CAST(@FromHour AS time(7)),CAST(@ToHour AS time(7)),@WorkingDayMachineID,CAST(@DateWork AS DATE))
	if @DayWork IS NULL
	BEGIN
		SET @DayWork = 0
	END
	PRINT  @DayWork
END



