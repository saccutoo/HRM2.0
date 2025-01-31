USE [ERP_HRM]
GO
/****** Object:  UserDefinedFunction [dbo].[F_HR_WorkingDaySummary_1]    Script Date: 1/31/2019 8:59:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
ALTER function [dbo].[F_HR_WorkingDaySummary_1]
	(@Month							int= NULL
	,@Year						int= NULL
	)
RETURNS TABLE
as 
RETURN 
	select s.StaffID
				, a.Date
				, IIF (DATEPART(dw,a.Date)=1,'CN','T.'+ cast (datepart(dw,a.Date) as varchar)) AS DayOfWeeks
				, convert(VARCHAR(8),CAST(a.StartTime as time)) AS HourCheckIn
				, CONVERT(VARCHAR(8),CAST(a.EndTime as time)) AS HourCheckOut
				, convert(VARCHAR(8),CAST(a.StartTimeSupplement as time)) AS StartTimeSupplement
				, convert(VARCHAR(8),CAST(a.EndTimeSupplement as time)) AS EndTimeSupplement
				,  a.WorkingDay as WorkingDay 
				, a.Furlough as Furlough
				, a.Overtime AS Overtime
				, a.WorkingDaySupplement AS WorkingDaySupplement
				, a.WorkingDayLeave AS WorkingDayLeave
				, (DATEDIFF(SECOND, '00:00:00', a.LateDuration )) AS SecondLateDuration
				, (DATEDIFF(SECOND, '00:00:00', a.EarlyDuration )) AS SecondEarlyDuration
				, convert(VARCHAR(5),CAST(a.LateDuration as time)) AS HourLate
				, convert(VARCHAR(5),CAST(a.EarlyDuration as time)) AS HourEarly
				, a.TotalWorkingDay
				from staff s left join OrganizationUnit o on o.OrganizationUnitID = s.OrganizationUnitID 
				left join [erp_v2].dbo.HR_IDMapping m on s.StaffID=m.StaffID left join [erp_v2].dbo.[HR_WorkingDayConfig] c on m.WorkingDayMachineID=c.WorkingDayMachineID
				left join
				 dbo.HR_WorkingDaySummaryFinal a on a.staffid=s.staffid  
				   and a.Date between cast(iif(c.DateFromNumber>=c.DateToNumber and @month=1 ,@year-1,@year) as varchar) + '-'+ cast(IIF(IIF(c.DateFromNumber>=c.DateToNumber,@month-1,@month)=0,12,@month-1) AS VARCHAR)+'-' + cast(c.DateFromNumber as varchar)
				and cast(@year as varchar)+ '-'+ cast(@month as varchar)+'-' + cast(c.DateToNumber as varchar)
				
				where s.Status IN (879,880) 