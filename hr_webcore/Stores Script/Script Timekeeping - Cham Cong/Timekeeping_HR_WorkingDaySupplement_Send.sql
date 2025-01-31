
CREATE PROCEDURE [dbo].[HR_WorkingDaySupplement_Send]
	@UserID INT = 22947
AS
BEGIN
	--SELECT * FROM GlobalList WHere ParentID=	85
	IF (Select COUNT(*) from STAFF WHERE StaffID IN (Select Data from Split((Select g.Value from GlobalList g Where GlobalListID = 1616),',')) AND StaffID = @UserID)>0
		BEGIN
			print N'Nhân sự'
			UPDATE HR_WorkingDaySupplement SET Status = 8  Where StaffID=@UserID AND Status=0-- Chờ ADMIN DUYỆT
		END
	ELSE IF EXISTS( SELECT * FROM HR_ApprovementConfiguration a WHERE a.StaffID=@UserID AND a.HRID > 0 AND a.ManagerID IS NULL)
	BEGIN
		print N'Chờ HR duyệt (trường hợp đặc biệt config)'
		UPDATE HR_WorkingDaySupplement SET Status = 3  Where StaffID=@UserID AND Status=0-- Chờ HR duyệt (trường hợp đặc biệt config)
	END
	ELSE IF EXISTS( SELECT * FROM HR_ApprovementConfiguration a WHERE a.StaffID=@UserID AND a.HRID IS NULL AND a.ManagerID >0)
	BEGIN
		UPDATE HR_WorkingDaySupplement SET Status = 1  Where StaffID=@UserID AND Status=0-- CHUYỂN QUẢN LÝ (trường hợp đặc biệt config)
	END
	ELSE
	BEGIN
		--254 Trưởng phòng
		--262 Giám đốc kinh doanh

		DECLARE @PositionID INT
		Select @PositionID = s.OfficePositionID FROM Staff s WHere UserID = @UserID


	
		
		 IF @PositionID = 254 or @PositionID = 255 --Trưởng phòng -- phó phòng -- trưởng nhóm không có trưởng phòng
					or ( @PositionID = 256 and (SELECT count(StaffID) FROM STAFF WHERE StaffID IN (SElect ParentId from Staff_Parent WHere StaffID = @UserID) AND Status = 879 AND OfficePositionID IN (254,255))<=0 )
					
		BEGIN
		
	--SELECT * FROM STAFF WHERE StaffID IN (SElect ParentId from Staff_Parent WHere StaffID = @UserID) AND Status = 879 AND OfficePositionID IN (252,262)
			IF EXISTS (SELECT * FROM STAFF WHERE StaffID IN (SElect ParentId from Staff_Parent WHere StaffID = @UserID) AND Status = 879 AND OfficePositionID IN (252,262))
			BEGIN
			print N'Trưởng phòng'
				UPDATE HR_WorkingDaySupplement SET Status = 6  Where StaffID=@UserID AND Status=0-- Chờ CCO DUYỆT
			END
			ELSE
			BEGIN
			print N'Trưởng phòng1'
					UPDATE HR_WorkingDaySupplement SET Status = 3  Where StaffID=@UserID AND Status=0-- Chờ HR
			END
		END 
		ELSE IF @PositionID IN (262,252,260) --Giám đốc kinh doanh
		BEGIN
				print N'Giám đốc kinh doanh'
			UPDATE HR_WorkingDaySupplement SET Status = 3  Where StaffID=@UserID AND Status=0-- Chờ HR
		END
		ELSE
		BEGIN
			print N'Chờ quản lý duyệt'
			UPDATE HR_WorkingDaySupplement SET Status = 1  Where StaffID=@UserID AND Status=0-- Chờ quản lý duyệt
		END

		
	END
		


END




