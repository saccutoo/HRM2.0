USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[HR_GetStatusForCheckApproval]    Script Date: 1/15/2019 3:39:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[HR_GetStatusForCheckApproval]
	@UserID INT = 2,
	@StatusID INT = 0 OUT
AS
BEGIN
		IF (SELECT RoleID FROM dbo.Sec_Role_User WHERE UserID = @UserID) = 10
		BEGIN
			SET @StatusID = 3
		END
		ELSE IF @UserID = 1
		BEGIN
			SET @StatusID = 8
		END
		ELSE
		BEGIN
					DECLARE @PositionID INT
					SELECT @PositionID = s.OfficePositionID From Staff s WHere s.UserID = @UserId
					print @PositionID
					IF @PositionID = 254 OR @PositionID = 252 -- Trưởng Phòng
					BEGIN
						SET @StatusID =1	
					END
					ELSE IF @PositionID = 262 --Giám đốc kinh doanh BU (CCO)
					BEGIN
						SET @StatusID = 6
					END
					ELSE
					BEGIN
						SET @StatusID =0	
					END

		END

		print  @StatusID
END




