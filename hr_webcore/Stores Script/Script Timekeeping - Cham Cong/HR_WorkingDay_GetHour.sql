 

ALTER PROCEDURE [dbo].[HR_WorkingDay_GetHour]
	
	@StaffID INT = 22947,
	@DateWork DateTime = '06/29/2018'
AS
BEGIN

	DECLARE @WorkingDayMachineID INT

	SELECT @WorkingDayMachineID= WorkingDayMachineID 
	FROM  HR_IDMapping m
	WHere m.StaffID = @StaffID AND IIF(m.WorkingDayMachineDate IS NULL,CAST(@DateWork AS DATE),cast(m.WorkingDayMachineDate as date)) <= CAST(@DateWork AS DATE)--DATEFROMPARTS(IIF((MONTH(GETDATE())-1)=0,YEAR(GETDATE())-1,YEAR(GETDATE())),IIF((MONTH(GETDATE())-1)=0,12,(MONTH(GETDATE())-1)),28)
	print ('@WorkingDayMachineID : ' + CAST(@WorkingDayMachineID AS NVARCHAR))
	SELECT * ,ISNULL(StartDate,cast(cast(datepart(year,getdate()) as char(4)) + '/' + cast(IIF((datepart(month,getdate()) -1)=0,12,(datepart(month,getdate()) -1)) as char(2))+ '/28' as datetime))
	
	from HR_WorkingDayMarchineDetail Where WorkingDayMachineID = @WorkingDayMachineID AND WorkingType=1 AND Status=1
		AND	 @DateWork BETWEEN ISNULL(StartDate,cast(cast(datepart(year,getdate()) as char(4)) + '/' + cast(IIF((datepart(month,getdate()) -1)=0,12,(datepart(month,getdate()) -1)) as char(2))+ '/28' as datetime)) AND ISNULL(EndDate,CAST(@DateWork AS DATE))

	

	--SELECT Top 1 w.* FROM HR_WorkingDay w
	----INNER JOIN HR_WorkingDayMachine wm on w.WorkingDayMachineID = wm.WorkingDayMachineID
	--INNER JOIN HR_IDMapping m on m.WorkingDayMachineID = w.WorkingDayMachineID
	--WHERE StaffID = @StaffID AND
	-- @DateWork BETWEEN ISNULL(w.StartDate,cast(cast(datepart(year,getdate()) as char(4)) + '/' + cast(datepart(month,getdate()) -1 as char(2))+ '/28' as datetime)) AND ISNULL(w.EndDate,GETDATE())
	-- Order by w.WorkingDayID
END

--select DATEFROMPARTS(YEAR(GETDATE()),IIF((MONTH(GETDATE())-1)=0,12,(MONTH(GETDATE())-1)),28)
