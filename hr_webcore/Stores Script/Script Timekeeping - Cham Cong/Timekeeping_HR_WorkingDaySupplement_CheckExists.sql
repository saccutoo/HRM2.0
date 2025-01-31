USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[HR_WorkingDaySupplement_CheckExists]    Script Date: 1/7/2019 10:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[HR_WorkingDaySupplement_CheckExists]
	@Date NVARCHAR(50)= NULL,
	@FromTime VARCHAR(50)= NULL,
	@ToTime VARCHAR(50)= NULL,
	@TypeCheck INT = NULL,--1 : Bổ sung, nghỉ phép, không lương; 2: Bổ sung công thêm; 3: Bổ sung phép,không lương,công nhiều ngày; 4 : 
	@UserID INT= NULL,
	@AutoID INT = NULL,
	@CheckExists INT = NULL OUT
AS
BEGIN
	SET @CheckExists=0
	IF @TypeCheck = 1
	BEGIN
		IF (
			(SELECT COUNT(w.AutoID) FROM HR_WorkingDaySupplement w WHERE w.StaffID = @UserID AND w.Type in(2,3,4) AND w.Status>=0 AND w.AutoID <> @AutoID
			AND w.Date LIKE @Date
			AND (	(CAST(FromTime AS TIME) BETWEEN @FromTime and @ToTime)	OR 	(CAST(ToTime AS TIME) BETWEEN @FromTime and @ToTime))) = 0
		)
		BEGIN
			SET @CheckExists=1
		END

		print @CheckExists
	END
	ELSE IF @TypeCheck=2
	BEGIN
		IF (
			(SELECT COUNT(w.AutoID) FROM HR_WorkingDaySupplement w WHERE w.StaffID = @UserID AND w.Type in(5) AND w.Status>=0 AND w.AutoID <> @AutoID
			AND w.Date LIKE @Date
			AND (	(CAST(FromTime AS TIME) BETWEEN @FromTime and @ToTime)	OR 	(CAST(ToTime AS TIME) BETWEEN @FromTime and @ToTime))) = 0
		)
		BEGIN
			SET @CheckExists=1
		END
	END
	ELSE IF @TypeCheck=3
	BEGIN
	
		SELECT @FromTime = IIF(@FromTime IS NULL,d.StartTime,@FromTime)  FROM HR_WorkingDayMarchineDetail d
		INNER JOIN HR_IDMapping m on m.WorkingDayMachineID = d.WorkingDayMachineID
		WHERE m.StaffID = @UserID AND d.Status=1 AND d.WorkingType=1--@UserID AND  227568
		ORDER BY d.StartTime

		SELECT @ToTime = IIF(@ToTime IS NULL,d.EndTime,@ToTime)  FROM HR_WorkingDayMarchineDetail d
		INNER JOIN HR_IDMapping m on m.WorkingDayMachineID = d.WorkingDayMachineID
		WHERE m.StaffID = @UserID AND d.Status=1 AND d.WorkingType=1--@UserID AND  227568
		ORDER BY d.EndTime
		
		print @FromTime
		print @ToTime
		print @Date
		IF (
			(SELECT COUNT(w.AutoID) FROM HR_WorkingDaySupplement w WHERE w.StaffID = @UserID AND w.Type in(2,3,4,5) AND w.Status>=0 AND w.AutoID <> @AutoID
			AND w.Date LIKE @Date
			AND (	(CAST(FromTime AS TIME) BETWEEN @FromTime and @ToTime)	OR 	(CAST(ToTime AS TIME) BETWEEN @FromTime and @ToTime))) = 0
		)
		BEGIN
			SET @CheckExists=1
		END


		
	END
	ELSE IF @TypeCheck=4
	BEGIN
		IF (SELECT COUNT(w.AutoID) FROM HR_WorkingDaySupplement w WHERE w.StaffID = @UserID AND w.Type =1 AND w.Status>=0 AND w.AutoID <> @AutoID AND w.Date LIKE @Date) = 0
		BEGIN
			SET @CheckExists=1
		END
	END
END


