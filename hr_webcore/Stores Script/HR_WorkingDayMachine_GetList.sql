USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[HR_WorkingDayMachine_GetList]    Script Date: 1/22/2019 5:38:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[HR_WorkingDayMachine_GetList]
	@DayOffWeekFormat int=0
AS
BEGIN
	select * from dbo.HR_WorkingDayMachine 
END	
