USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[HR_CheckFurlough]    Script Date: 1/6/2019 12:25:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[HR_CheckFurlough]
	@UserID INT = 121911,
	@Year INT = 2017,
	@LanguageId INT = 5,
	@Furlough FLOAT = 1,
	@CheckFurlough INT = 0 OUT
AS
BEGIN
		DECLARE @TotalFurloughYearRemaining FLOAT, @TotalFurloughPending FLOAT
		SELECT @TotalFurloughYearRemaining=ISNULL(TotalFurloughYearRemaining,0) FROM [dbo].[F_Get_FurloughMonth](CAST(@UserId AS VARCHAR),CAST(@Year AS VARCHAR),CAST(@LanguageId AS VARCHAR)) WHERE StaffID = @UserID

		SELECT @TotalFurloughPending = ISNULL(SUM(ISNULL(DayOff,0)),0) FROM HR_WorkingDaySupplement h WHere h.StaffID = @UserID AND Type = 2 AND MonthVacation LIKE N'%-'+CAST(@Year AS VARCHAR)+'%' AND Status IN (0,1,3,6,8)
		--Select @TotalFurloughPending
		IF @TotalFurloughYearRemaining<(@Furlough + @TotalFurloughPending)
		BEGIN
			SET @CheckFurlough = 1 -- HẾT PHÉP
		END
		ELSE
		BEGIN
			SET @CheckFurlough =0 --CÒN PHÉP
		END

		SELECT @CheckFurlough

	--	SELECT * FROM GlobalList WHere ParentID=85
END


