USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[HR_WorkingDaySupplement_CheckBoSung]    Script Date: 1/29/2019 11:09:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[HR_WorkingDaySupplement_CheckBoSung]
	@Date NVARCHAR(50)= NULL,
	@FromTime VARCHAR(50)= NULL,
	@ToTime VARCHAR(50)= NULL,
	@UserID INT= NULL,
	@AutoID INT = NULL,
	@CheckExists INT = NULL OUT
AS
BEGIN
	SET @CheckExists=1
	IF(SELECT COUNT(w.AutoID) FROM dbo.HR_WorkingDaySummary w WHERE w.StaffID = @UserID AND w.AutoID <> @AutoID
		AND w.Date LIKE @Date
		AND ((CAST(@FromTime AS TIME) BETWEEN CAST(w.StartTime AS TIME) AND CAST(w.EndTime AS TIME)) 
		or (CAST(@ToTime AS TIME) BETWEEN CAST(w.StartTime AS TIME) AND CAST(w.EndTime AS TIME)))) >0
	BEGIN
		SET @CheckExists=0
	END
END