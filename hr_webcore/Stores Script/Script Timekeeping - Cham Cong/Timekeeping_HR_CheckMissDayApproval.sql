USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[HR_CheckMissDayApproval]    Script Date: 1/4/2019 1:27:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[HR_CheckMissDayApproval]
	@UserID INT = 242921,
	@ShowTabApproval INT = 0  OUT


AS
BEGIN
		DECLARE @PositionID INT
		SELECT @PositionID= s.OfficePositionID FROM Staff s WHERE s.StaffID= @UserID
	
		IF @PositionID IN (254,262,263,252) OR
		
		  (select count(userid) from Sec_Role_User where userid=@UserID and roleid=10)>0 -- HR và trạng thái Chờ HR duyệt
		  
		BEGIN
			SET @ShowTabApproval = 1
		END
		ELSE IF (EXISTS(SELECT * FROM HR_ApprovementConfiguration WHERE ManagerID = @UserID))
		BEGIN
			SET @ShowTabApproval = 1
		END
		ELSE
		BEGIn
			SET @ShowTabApproval = 0
		END
		print @ShowTabApproval
END


