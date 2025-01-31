USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[HR_WorkingDaySupplement_Add]    Script Date: 12/19/2018 11:31:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[HR_WorkingDaySupplement_Add]
	@AutoID INT,
	@StaffID int  ,
	@Type int  ,
	@Date date  ,
	@FromTime datetime ,
	@ToTime datetime ,
	@HourOff datetime ,
	@TimeOfActual datetime ,
	@DayOff float ,
	@MonthVacation nvarchar(50) ,
	@CreatedBy int  ,
	@CreatedDate datetime  ,
	@SuperiorBy int ,
	@SuperiorDate datetime ,
	@ConfirmBy int ,
	@ConfirmDate datetime ,
	@Status int  ,
	@Note nvarchar(500) ,
	@ManagerNote nvarchar(max) ,
	@HRNote nvarchar(max) ,
	@ReasonType int  ,
	@CustomerID int ,
	@PercentPayrollID int,
	@CustomerContactID int,
	@CustomerReasonType INT

AS
BEGIN

IF @AutoID =0 -- Thêm mới
BEGIN
		INSERT INTO [dbo].[HR_WorkingDaySupplement]
           ([StaffID]
           ,[Type]
           ,[Date]
           ,[FromTime]
           ,[ToTime]
           ,[HourOff]
           ,[TimeOfActual]
           ,[DayOff]
           ,[MonthVacation]
           ,[CreatedBy]
           ,[CreatedDate]
           ,[SuperiorBy]
           ,[SuperiorDate]
           ,[ConfirmBy]
           ,[ConfirmDate]
           ,[Status]
           ,[Note]
           ,[ManagerNote]
           ,[HRNote]
           ,[ReasonType]
           ,[CustomerID]
           ,[PercentPayrollID]
		   ,CustomerContactID
		   ,CustomerReasonType
		   )
     VALUES
           (@StaffID   ,
			@Type   ,
			@Date ,
			@FromTime  ,
			@ToTime  ,
			@HourOff  ,
			@TimeOfActual  ,
			@DayOff  ,
			@MonthVacation  ,
			@CreatedBy   ,
			@CreatedDate   ,
			@SuperiorBy  ,
			@SuperiorDate  ,
			@ConfirmBy  ,
			@ConfirmDate  ,
			@Status   ,
			@Note  ,
			@ManagerNote  ,
			@HRNote  ,
			@ReasonType   ,
			@CustomerID  ,
			@PercentPayrollID ,
			@CustomerContactID,
			@CustomerReasonType
			 )
END
ELSE IF @Status<>0 AND @AutoID > 0 -- UPDATE KHI KHÔNG DUYỆT
BEGIN
print 'update'

	declare @UpdStatus INT
	--IF EXISTS( SELECT * FROM HR_ApprovementConfiguration a WHERE a.StaffID=@CreatedBy AND a.HRID > 0 AND a.ManagerID IS NULL)
	--BEGIN
	--	SET @UpdStatus = 3-- Chờ HR duyệt (trường hợp đặc biệt config)
	--END
	--ELSE
	--BEGIN
	--	--254 Trưởng phòng
	--	--262 Giám đốc kinh doanh

	--	DECLARE @PositionID INT
	--	Select @PositionID = s.OfficePositionID FROM Staff s WHere UserID = @CreatedBy
	--	IF @PositionID = 254 --Trưởng phòng
	--	BEGIN
	--		SET @UpdStatus = 6 -- Chờ CCO DUYỆT
	--	END 
	--	ELSE IF @PositionID = 262 --Giám đốc kinh doanh
	--	BEGIN
	--		SET @UpdStatus = 3 -- Chờ HR
	--	END
	--	ELSE
	--	BEGIN
	--		SET @UpdStatus = 1-- Chờ quản lý duyệt
	--	END

		
	--END
		IF (Select COUNT(*) from STAFF WHERE StaffID IN (Select Data from Split((Select g.Value from GlobalList g Where GlobalListID = 1616),',')) AND StaffID = @CreatedBy)>0
		BEGIN
						print N'Nhân sự'
						SET @UpdStatus = 8-- Chờ ADMIN DUYỆT
		END
		ELSE IF EXISTS( SELECT * FROM HR_ApprovementConfiguration a WHERE a.StaffID=@CreatedBy AND a.HRID > 0 AND a.ManagerID IS NULL)
		BEGIN
						print N'Chờ HR duyệt (trường hợp đặc biệt config)'
						SET @UpdStatus = 3-- Chờ HR duyệt (trường hợp đặc biệt config)
		END
		ELSE IF EXISTS( SELECT * FROM HR_ApprovementConfiguration a WHERE a.StaffID=@CreatedBy AND a.HRID IS NULL AND a.ManagerID >0)
		BEGIN
						SET @UpdStatus = 1-- CHUYỂN QUẢN LÝ (trường hợp đặc biệt config)
		END
		ELSE
		BEGIN
		--254 Trưởng phòng
		--262 Giám đốc kinh doanh
					DECLARE @PositionID INT
					Select @PositionID = s.OfficePositionID FROM Staff s WHere UserID = @CreatedBy
					IF @PositionID = 254 or @PositionID = 255 --Trưởng phòng -- phó phòng -- trưởng nhóm không có trưởng phòng
					or ( @PositionID = 256 and (SELECT count(StaffID) FROM STAFF WHERE StaffID IN (SElect ParentId from Staff_Parent WHere StaffID = @CreatedBy) AND Status = 879 AND OfficePositionID IN (254,255))<=0 )
					BEGIN

					IF EXISTS (SELECT * FROM STAFF WHERE StaffID IN (SElect ParentId from Staff_Parent WHere StaffID = @CreatedBy) AND Status = 879 AND OfficePositionID IN (252,262))
					BEGIN
							print N'Trưởng phòng'
							SET @UpdStatus = 6-- Chờ CCO DUYỆT
					END
					ELSE
					BEGIN
							print N'Trưởng phòng1'
							SET @UpdStatus = 3-- Chờ HR
					END
					END 
					ELSE IF @PositionID IN (262,252,260) --Giám đốc kinh doanh
					BEGIN
							print N'Giám đốc kinh doanh'
							SET @UpdStatus = 3-- Chờ HR
					END
					ELSE
					BEGIN
							print N'Chờ quản lý duyệt'
							SET @UpdStatus = 1-- Chờ quản lý duyệt
					END
		END



UPDATE [dbo].[HR_WorkingDaySupplement]
   SET 
		Type = @Type
       ,[Date] = @Date
      ,[FromTime] = @FromTime
      ,[ToTime] = @ToTime
      ,[HourOff] = @HourOff
      ,[TimeOfActual] = @TimeOfActual
      ,[DayOff] = @DayOff
      ,[MonthVacation] = @MonthVacation
      ,[CreatedBy] = @CreatedBy
      ,[CreatedDate] = @CreatedDate
      ,[Note] = @Note
      ,[ManagerNote] = @ManagerNote
      ,[ReasonType] = @ReasonType
      ,[CustomerID] = @CustomerID
      ,[PercentPayrollID] = PercentPayrollID
	   ,CustomerContactID = @CustomerContactID
		,CustomerReasonType = @CustomerReasonType
	  ,Status = @UpdStatus
 WHERE AutoID= @AutoID
 
END
ELSE --UPDATE KHI THÊM MỚI
BEGIN
	UPDATE [dbo].[HR_WorkingDaySupplement]
   SET 
       [Date] = @Date
      ,[FromTime] = @FromTime
      ,[ToTime] = @ToTime
      ,[HourOff] = @HourOff
      ,[TimeOfActual] = @TimeOfActual
      ,[DayOff] = @DayOff
      ,[MonthVacation] = @MonthVacation
      ,[CreatedBy] = @CreatedBy
      ,[CreatedDate] = @CreatedDate
      ,[Note] = @Note
      ,[ManagerNote] = @ManagerNote
      ,[ReasonType] = @ReasonType
      ,[CustomerID] = @CustomerID
      ,[PercentPayrollID] = PercentPayrollID
	   ,CustomerContactID = @CustomerContactID
		,CustomerReasonType = @CustomerReasonType
 WHERE AutoID= @AutoID
END
END


