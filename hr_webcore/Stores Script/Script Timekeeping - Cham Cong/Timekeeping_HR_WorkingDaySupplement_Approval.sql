USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[HR_WorkingDaySupplement_Approval]    Script Date: 2/15/2019 2:47:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 



ALTER PROCEDURE[dbo].[HR_WorkingDaySupplement_Approval]
	@AutoID INT=10359,
	@UserID INT=121994,
	@Note NVARCHAR(MAX)='',
	@Type INT = 1, -- 1 : DUYỆT, 0: KHÔNG DUYỆT
	@ChoPhepDuyet INT = 0 OUT 

as

	begin try
	DECLARE @StartSupplement datetime,@EndSupplement datetime
	DECLARE @Status INT, @TypeSupplement INT, @StaffID INT
	DECLARE @StartTime DATETIME,@EndTime DATETIME
	DECLARE @HourLate VARCHAR(10),@HourEarly  VARCHAR(10)
	DECLARE @SubMin INT = 0
	DECLARE @HourOffLate DATETIME, @Late VARCHAR(10)
	DECLARE @TotalWorkingDay FLOAT
	DECLARE @StatusID INT
	--Kiểm tra trạng thái được duyệt
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
					SELECT @PositionID = s.OfficePositionID From Staff s WHere s.UserID = @UserID
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
	SELECT @Status= s.Status,@TypeSupplement = s.Type,@StaffID=s.StaffID FROM HR_WorkingDaySupplement s WHERE AutoID = @AutoID
	print @Status
	PRINT @StatusID
	IF @StatusID = @Status
	BEGIN
		SET @ChoPhepDuyet = 1
		IF @Status not in (5,10)
		BEGIN
			-- DUYỆT 
		IF @Type = 1
		BEGIn
		print (2)
							-- CHUYỂN HR DUYỆT
						IF @UserID = 1 -- admin duyệt
						BEGIN
							UPDATE HR_WorkingDaySupplement
									SET
										SuperiorBy = @UserId,
										SuperiorDate = GETDATE(),
										HRNote = @Note,
										[Status] = 10 -- ADMIN DUYỆT
									WHERE AutoID = @AutoID 
						END
						ELSE IF @Status = 3 AND (select count(userid) from Sec_Role_User where userid=@UserID and roleid=10)>0 -- HR và trạng thái Chờ HR duyệt
						BEGIN
						print N'HR DUYỆT'
							UPDATE HR_WorkingDaySupplement
									SET
										ConfirmBy = @UserId,
										ConfirmDate = GETDATE(),
										HRNote = @Note,
										[Status] = 5 -- HR DUYỆT
									WHERE AutoID = @AutoID
								  
						END
						ELSE IF @Status = 1 OR @Status = 6 OR @Status = 2  OR @Status = 7 -- Chờ quản lý duyệt
						BEGIn
						print N'CHUYỂN HR DUYỆT'
								UPDATE HR_WorkingDaySupplement
									SET
										SuperiorBy = @UserId,
										SuperiorDate = GETDATE(),
										ManagerNote = @Note,
										[Status] = 3 -- Chờ HR duyệt
									WHERE AutoID = @AutoID 
						END
						ELSE IF @Status = 8 -- Chờ Admin duyệt
						BEGIN
							UPDATE HR_WorkingDaySupplement
									SET
										SuperiorBy = @UserId,
										SuperiorDate = GETDATE(),
										HRNote = @Note,
										[Status] = 10 -- ADMIN DUYỆT
									WHERE AutoID = @AutoID 
						END
	



	

			IF EXISTS(SELECT s.Status FROM HR_WorkingDaySupplement s WHERE AutoID = @AutoID AND s.Status IN(5,10))
			BEGIN
			

				DECLARE @TimeOfActual DATETIME,@HourOff DATETIME,@Date DATE
				SELECT @TimeOfActual = s.TimeOfActual,@HourOff = s.HourOff,@Date = s.Date,@StaffID = s.StaffID
						FROM HR_WorkingDaySupplement s WHERE AutoID = @AutoID
					
				IF @TypeSupplement = 1
				BEGIN
						print (1)
						IF NOT EXISTS(SELECT * FROM HR_WorkingDaySummary WHere StaffID = @StaffID AND CONVERT(VARCHAR(10), Date,102) = CONVERT(VARCHAR(10), @Date,102))
				BEGIN
							INSERT INTO [dbo].[HR_WorkingDaySummary]
									   ([StaffID] ,[Date]	,[StartTime] ,[EndTime]
									   ,[WorkingDay],[Furlough] ,[LateDuration],[EarlyDuration]
									   ,[Overtime],[OvertimeRate],[TotalWorkingDay],[WorkingDaySupplement]
									   ,[WorkingDayLeave])
    								 VALUES
									   (@StaffID,@Date,NULL,NULL,
										0,0,NULL,NULL,
										0,NULL,0,0
										,0)
				END

			
					SELECT @StartTime =StartTime,@EndTime=EndTime  FROM HR_WorkingDaySummary WHERE StaffID = @StaffID AND Date = @Date

				
					SELECT @HourLate = HourLate, @HourEarly =HourEarly  FROM dbo.Get_TimeWork (@Date,CONVERT(nvarchar(8),@StartTime,108), CONVERT(nvarchar(8),@EndTime,108), @StaffID)
				
				
					IF (CONVERT(nvarchar(5),@TimeOfActual,108)=@HourLate)
					BEGIn
					 print 'a'
					
						SELECT @HourOffLate= s.HourOff FROM HR_WorkingDaySupplement s WHERE AutoID = @AutoID
						IF(CONVERT(nvarchar(5),@TimeOfActual,108)=CONVERT(nvarchar(5),@HourOffLate,108))
						BEGIN
							SET @Late = '00:00'
						END
						ELSE
						BEGIN
						print @HourOffLate
								SET @SubMin = DATEDIFF(minute, CONVERT(NVARCHAR(5),@HourOffLate,108), CONVERT(NVARCHAR(5),@TimeOfActual,108))
								SET @Late = CONVERT(varchar(5), DATEADD(minute,IIF(@SubMin>0,@SubMin,0) , 0), 114) 
								print @Late
						END
					
						UPDATE HR_WorkingDaySummary SET LateDuration =  @Late
						WHere StaffID = @StaffID AND CONVERT(VARCHAR(10), Date,102) = CONVERT(VARCHAR(10), @Date,102)
					END
					ELSE IF CONVERT(nvarchar(5),@TimeOfActual,108)=@HourEarly
					BEGIn
					print 'e'

						SELECT @HourOffLate= s.HourOff FROM HR_WorkingDaySupplement s WHERE AutoID = @AutoID
						IF(CONVERT(nvarchar(5),@TimeOfActual,108)=CONVERT(nvarchar(5),@HourOffLate,108))
						BEGIN
							SET @Late = '00:00'
						END
						ELSE
						BEGIN
						print @HourOffLate
								SET @SubMin = DATEDIFF(minute, CONVERT(NVARCHAR(5),@HourOffLate,108), CONVERT(NVARCHAR(5),@TimeOfActual,108))
								SET @Late = CONVERT(varchar(5), DATEADD(minute,IIF(@SubMin>0,@SubMin,0) , 0), 114) 
								print @Late
						END

						print 've som'
						UPDATE HR_WorkingDaySummary SET EarlyDuration = @Late-- (SELECT  s.HourOff FROM HR_WorkingDaySupplement s WHERE AutoID = @AutoID)
						WHere StaffID = @StaffID AND CONVERT(VARCHAR(10), Date,102) = CONVERT(VARCHAR(10), @Date,102)
					END
				END
				ELSE IF @TypeSupplement =2 --Nghỉ phép
				BEGIN
					DECLARE @Furlough FLOAT
					IF NOT EXISTS(SELECT * FROM HR_WorkingDaySummary WHere StaffID = @StaffID AND CONVERT(VARCHAR(10), Date,102) = CONVERT(VARCHAR(10), @Date,102))
					BEGIN
							SELECT @Furlough = s.DayOff FROM HR_WorkingDaySupplement s WHERE AutoID = @AutoID
							INSERT INTO [dbo].[HR_WorkingDaySummary]
									   ([StaffID] ,[Date]	,[StartTime] ,[EndTime]
									   ,[WorkingDay]
									   ,[Furlough]
									   ,[LateDuration]
									   ,[EarlyDuration]
									   ,[Overtime]
									   ,[OvertimeRate]
									   ,[TotalWorkingDay]
									   ,[WorkingDaySupplement]
									   ,[WorkingDayLeave])
    								 VALUES
									   (@StaffID,@Date,NULL,NULL,0,0,NULL,NULL,0,NULL,0,0,0)
					END
					ELSE
					BEGIn
					 SELECT @TotalWorkingDay = TotalWorkingDay,@Furlough=Furlough  FROM dbo.HR_WorkingDaySummary 
					 WHERE StaffID = @StaffID AND CONVERT(VARCHAR(10), Date,102) = CONVERT(VARCHAR(10), @Date,102)
					 SELECT @Furlough = sum(s.DayOff) FROM HR_WorkingDaySupplement s  WHERE StaffID = @StaffID AND Type =@TypeSupplement and Status IN(5,10) AND CONVERT(VARCHAR(10), Date,102) = CONVERT(VARCHAR(10), @Date,102)
					END
					-- loại trừ phút đi muộn về sơm
					SELECT @StartTime =StartTime,@EndTime=EndTime  FROM HR_WorkingDaySummary WHERE StaffID = @StaffID AND Date = @Date

					SELECT @HourLate = HourLate, @HourEarly =HourEarly  FROM dbo.Get_TimeWork (@Date,CONVERT(nvarchar(8),@StartTime,108), CONVERT(nvarchar(8),@EndTime,108), @StaffID)
				
					SELECT @StartSupplement= s.FromTime,@EndSupplement=s.ToTime FROM HR_WorkingDaySupplement s WHERE AutoID = @AutoID

					IF (CONVERT(nvarchar(5),@StartTime,108)>=@HourLate)
					BEGIn
						SELECT @HourOffLate= s.HourOff FROM HR_WorkingDaySupplement s WHERE AutoID = @AutoID
						IF(CONVERT(nvarchar(5),@StartTime,108)>=CONVERT(nvarchar(5),@StartSupplement,108) and CONVERT(nvarchar(5),@StartTime,108)<=CONVERT(nvarchar(5),@EndSupplement,108) )
						BEGIN
							SET @Late = '00:00'
						END
						ELSE
						BEGIN
						print @HourOffLate
							if (datediff(minute,0,cast(@HourLate as datetime))> DATEDIFF(minute, CONVERT(NVARCHAR(5),@EndSupplement,108), CONVERT(NVARCHAR(5),@StartTime,108)))
								begin
								SET @SubMin = DATEDIFF(minute, CONVERT(NVARCHAR(5),@EndSupplement,108), CONVERT(NVARCHAR(5),@StartTime,108))
								SET @Late = CONVERT(varchar(5), DATEADD(minute,IIF(@SubMin>0,@SubMin,0) , 0), 114) 
								print @Late
							end
							else
							begin
								set @Late=@HourLate
							end
						END
						UPDATE HR_WorkingDaySummary SET LateDuration =  @Late
						WHere StaffID = @StaffID AND CONVERT(VARCHAR(10), Date,102) = CONVERT(VARCHAR(10), @Date,102)
					END
					ELSE IF CONVERT(nvarchar(5),@EndTime,108)<=@HourEarly
					BEGIn
						SELECT @HourOffLate= s.HourOff FROM HR_WorkingDaySupplement s WHERE AutoID = @AutoID
						IF(CONVERT(nvarchar(5),@EndTime,108)>=CONVERT(nvarchar(5),@StartSupplement,108) and CONVERT(nvarchar(5),@EndTime,108)<=CONVERT(nvarchar(5),@EndSupplement,108) )
						BEGIN
							SET @Late = '00:00'
						END
						ELSE
						BEGIN
								SET @SubMin = DATEDIFF(minute, CONVERT(NVARCHAR(5),@EndSupplement,108), CONVERT(NVARCHAR(5),@EndTime,108))
								SET @Late = CONVERT(varchar(5), DATEADD(minute,IIF(@SubMin>0,@SubMin,0) , 0), 114) 
								print @Late
						END
						UPDATE HR_WorkingDaySummary SET EarlyDuration = @Late-- (SELECT  s.HourOff FROM HR_WorkingDaySupplement s WHERE AutoID = @AutoID)
						WHere StaffID = @StaffID AND CONVERT(VARCHAR(10), Date,102) = CONVERT(VARCHAR(10), @Date,102)
					END
					--Cập nhật lại tổng công trong bảng tổng hợp công
					IF @TotalWorkingDay + @Furlough > 1
					BEGIN
						UPDATE dbo.HR_WorkingDaySummary SET Furlough = 1 - @TotalWorkingDay
						WHERE StaffID = @StaffID AND CONVERT(VARCHAR(10), Date,102) = CONVERT(VARCHAR(10), @Date,102)
						UPDATE dbo.HR_WorkingDaySummary SET TotalWorkingDay = 1
						WHERE StaffID = @StaffID AND CONVERT(VARCHAR(10), Date,102) = CONVERT(VARCHAR(10), @Date,102)
					END
					ELSE
					BEGIN
						UPDATE dbo.HR_WorkingDaySummary SET TotalWorkingDay = @TotalWorkingDay + @Furlough, Furlough = Furlough + @Furlough
						WHERE StaffID = @StaffID AND CONVERT(VARCHAR(10), Date,102) = CONVERT(VARCHAR(10), @Date,102)
					END
				END
				ELSE IF  @TypeSupplement = 3 -- Không lương
				BEGIn
				print 3
					DECLARE @WorkingDayLeave FLOAT
					IF NOT EXISTS(SELECT * FROM HR_WorkingDaySummary WHere StaffID = @StaffID AND CONVERT(VARCHAR(10), Date,102) = CONVERT(VARCHAR(10), @Date,102))
					BEGIN
							SELECT @WorkingDayLeave = s.DayOff FROM HR_WorkingDaySupplement s WHERE AutoID = @AutoID
							INSERT INTO [dbo].[HR_WorkingDaySummary]
									   ([StaffID] ,[Date]	,[StartTime] ,[EndTime]
									   ,[WorkingDay]
									   ,[Furlough]
									   ,[LateDuration]
									   ,[EarlyDuration]
									   ,[Overtime]
									   ,[OvertimeRate]
									   ,[TotalWorkingDay]
									   ,[WorkingDaySupplement]
									   ,[WorkingDayLeave])
    								 VALUES
									   (@StaffID,@Date,NULL,NULL,
										0,
										0
										,NULL,NULL,0,NULL,0,0,0)
					END
					ELSE
					BEGIn
						 SELECT @TotalWorkingDay = TotalWorkingDay  FROM dbo.HR_WorkingDaySummary WHERE StaffID = @StaffID AND CONVERT(VARCHAR(10), Date,102) = CONVERT(VARCHAR(10), @Date,102)
						 SELECT @WorkingDayLeave=sum(s.DayOff) FROM HR_WorkingDaySupplement s  WHERE StaffID = @StaffID AND Type =3 and Status IN(5,10) AND CONVERT(VARCHAR(10), Date,102) = CONVERT(VARCHAR(10), @Date,102)
					  END
					SELECT @StartTime =StartTime,@EndTime=EndTime  FROM HR_WorkingDaySummary WHERE StaffID = @StaffID AND Date = @Date

					SELECT @HourLate = HourLate, @HourEarly =HourEarly  FROM dbo.Get_TimeWork (@Date,CONVERT(nvarchar(8),@StartTime,108), CONVERT(nvarchar(8),@EndTime,108), @StaffID)
				
					SELECT @StartSupplement= s.FromTime,@EndSupplement=s.ToTime FROM HR_WorkingDaySupplement s WHERE AutoID = @AutoID

					IF (CONVERT(nvarchar(5),@StartTime,108)>=@HourLate)
					BEGIn
					 print 'a'
					
						SELECT @HourOffLate= s.HourOff FROM HR_WorkingDaySupplement s WHERE AutoID = @AutoID
						IF(CONVERT(nvarchar(5),@StartTime,108)>=CONVERT(nvarchar(5),@StartSupplement,108) and CONVERT(nvarchar(5),@StartTime,108)<=CONVERT(nvarchar(5),@EndSupplement,108) )
						BEGIN
							SET @Late = '00:00'
						END
						ELSE
						BEGIN
						print('nhung')
						print @HourOffLate
							if (datediff(minute,0,cast(@HourLate as datetime))> DATEDIFF(minute, CONVERT(NVARCHAR(5),@EndSupplement,108), CONVERT(NVARCHAR(5),@StartTime,108)))
								begin
								SET @SubMin = DATEDIFF(minute, CONVERT(NVARCHAR(5),@EndSupplement,108), CONVERT(NVARCHAR(5),@StartTime,108))
								SET @Late = CONVERT(varchar(5), DATEADD(minute,IIF(@SubMin>0,@SubMin,0) , 0), 114) 
								print @Late
							end
							else
							begin
								set @Late=@HourLate
							end
						END
					
						UPDATE HR_WorkingDaySummary SET LateDuration =  @Late
						WHere StaffID = @StaffID AND CONVERT(VARCHAR(10), Date,102) = CONVERT(VARCHAR(10), @Date,102)
					END
					IF CONVERT(nvarchar(5),@EndTime,108)>=@HourEarly
					BEGIn
					print 'e'

						SELECT @HourOffLate= s.HourOff FROM HR_WorkingDaySupplement s WHERE AutoID = @AutoID
						IF(CONVERT(nvarchar(5),@EndTime,108)>=CONVERT(nvarchar(5),@StartSupplement,108) and CONVERT(nvarchar(5),@EndTime,108)<=CONVERT(nvarchar(5),@EndSupplement,108) )
						BEGIN
							SET @Late = '00:00'
						END
						ELSE
						BEGIN
						print @HourOffLate
						
								SET @SubMin = DATEDIFF(minute, CONVERT(NVARCHAR(5),@EndSupplement,108), CONVERT(NVARCHAR(5),@EndTime,108))
								SET @Late = CONVERT(varchar(5), DATEADD(minute,IIF(@SubMin>0,@SubMin,0) , 0), 114) 
								print @Late
						END

						print 've som'
						UPDATE HR_WorkingDaySummary SET EarlyDuration = @Late-- (SELECT  s.HourOff FROM HR_WorkingDaySupplement s WHERE AutoID = @AutoID)
						WHere StaffID = @StaffID AND CONVERT(VARCHAR(10), Date,102) = CONVERT(VARCHAR(10), @Date,102)
					END
					--Cập nhật lại tổng công trong bảng tổng hợp công
					IF @TotalWorkingDay - @WorkingDayLeave < 0
					BEGIN
						UPDATE dbo.HR_WorkingDaySummary SET TotalWorkingDay = 0, WorkingDayLeave = TotalWorkingDay
						WHERE StaffID = @StaffID AND CONVERT(VARCHAR(10), Date,102) = CONVERT(VARCHAR(10), @Date,102)
					END
					ELSE
					BEGIN
						UPDATE dbo.HR_WorkingDaySummary SET TotalWorkingDay = @TotalWorkingDay - @WorkingDayLeave , WorkingDayLeave = WorkingDayLeave + @WorkingDayLeave
						WHERE StaffID = @StaffID AND CONVERT(VARCHAR(10), Date,102) = CONVERT(VARCHAR(10), @Date,102)
					END
				END
				ELSE IF  @TypeSupplement = 4 --Bổ sung công
				BEGIn
				print 4
					DECLARE @WorkingDaySupplement FLOAT
					IF NOT EXISTS(SELECT * FROM HR_WorkingDaySummary WHere StaffID = @StaffID AND CONVERT(VARCHAR(10), Date,102) = CONVERT(VARCHAR(10), @Date,102))
					BEGIN
							INSERT INTO [dbo].[HR_WorkingDaySummary]
									   ([StaffID] ,[Date]	,[StartTime],[EndTime]
									   ,[WorkingDay]
									   ,[Furlough]
									   ,[LateDuration]
									   ,[EarlyDuration]
									   ,[Overtime]
									   ,[OvertimeRate]
									   ,[TotalWorkingDay]
									   ,[WorkingDaySupplement]
									   ,[WorkingDayLeave])
    								 VALUES
									   (@StaffID,@Date,(SELECT FromTime FROM HR_WorkingDaySupplement WHERE AutoID = @AutoID),(SELECT ToTime FROM HR_WorkingDaySupplement WHERE AutoID = @AutoID),
										0,0,NULL,NULL,0,NULL,0
										,0,0)
					END
					ELSE
					BEGIN
					--Cập nhật lại thời gian nếu thời gian đến hoặc thời gian về bằng NULL
						Update HR_WorkingDaySummary SET 
						StartTime = IIF(StartTime IS NULL,(select FromTime FROM HR_WorkingDaySupplement WHERE AutoID = @AutoID),StartTime),
						EndTime = IIF(EndTime IS NULL,(SELECT ToTime FROM HR_WorkingDaySupplement WHERE AutoID = @AutoID), EndTime)
						WHERE StaffID = @StaffID AND CONVERT(VARCHAR(10), Date,102) = CONVERT(VARCHAR(10), @Date,102)
						 SELECT @TotalWorkingDay = TotalWorkingDay FROM dbo.HR_WorkingDaySummary WHERE StaffID = @StaffID AND CONVERT(VARCHAR(10), Date,102) = CONVERT(VARCHAR(10), @Date,102)
						 SELECT @WorkingDaySupplement=sum(s.DayOff) FROM HR_WorkingDaySupplement s  WHERE StaffID = @StaffID AND Type =@TypeSupplement and Status IN(5,10) AND CONVERT(VARCHAR(10), Date,102) = CONVERT(VARCHAR(10), @Date,102) 
					 END
					 SELECT @StartTime =StartTime,@EndTime=EndTime  FROM HR_WorkingDaySummary WHERE StaffID = @StaffID AND Date = @Date

					SELECT @HourLate = HourLate, @HourEarly =HourEarly  FROM dbo.Get_TimeWork (@Date,CONVERT(nvarchar(8),@StartTime,108), CONVERT(nvarchar(8),@EndTime,108), @StaffID)
				
					SELECT @StartSupplement= s.FromTime,@EndSupplement=s.ToTime FROM HR_WorkingDaySupplement s WHERE AutoID = @AutoID

					IF (CONVERT(nvarchar(5),@StartTime,108)>=@HourLate)
					BEGIn
					 print 'a'
					
						SELECT @HourOffLate= s.HourOff FROM HR_WorkingDaySupplement s WHERE AutoID = @AutoID
						IF(CONVERT(nvarchar(5),@StartTime,108)>=CONVERT(nvarchar(5),@StartSupplement,108) and CONVERT(nvarchar(5),@StartTime,108)<=CONVERT(nvarchar(5),@EndSupplement,108) )
						BEGIN
							SET @Late = '00:00'
						END
						ELSE
						BEGIN
						print @HourOffLate
							if (datediff(minute,0,cast(@HourLate as datetime))> DATEDIFF(minute, CONVERT(NVARCHAR(5),@EndSupplement,108), CONVERT(NVARCHAR(5),@StartTime,108)))
								begin
								SET @SubMin = DATEDIFF(minute, CONVERT(NVARCHAR(5),@EndSupplement,108), CONVERT(NVARCHAR(5),@StartTime,108))
								SET @Late = CONVERT(varchar(5), DATEADD(minute,IIF(@SubMin>0,@SubMin,0) , 0), 114) 
								print @Late
							end
							else
							begin
								set @Late=@HourLate
							end
						END
					
						UPDATE HR_WorkingDaySummary SET LateDuration =  @Late
						WHere StaffID = @StaffID AND CONVERT(VARCHAR(10), Date,102) = CONVERT(VARCHAR(10), @Date,102)
					END
					ELSE IF CONVERT(nvarchar(5),@EndTime,108)<=@HourEarly
					BEGIn
					print 'e'

						SELECT @HourOffLate= s.HourOff FROM HR_WorkingDaySupplement s WHERE AutoID = @AutoID
						IF(CONVERT(nvarchar(5),@EndTime,108)>=CONVERT(nvarchar(5),@StartSupplement,108) and CONVERT(nvarchar(5),@EndTime,108)<=CONVERT(nvarchar(5),@EndSupplement,108) )
						BEGIN
							SET @Late = '00:00'
						END
						ELSE
						BEGIN
						print @HourOffLate
						
								SET @SubMin = DATEDIFF(minute, CONVERT(NVARCHAR(5),@EndSupplement,108), CONVERT(NVARCHAR(5),@EndTime,108))
								SET @Late = CONVERT(varchar(5), DATEADD(minute,IIF(@SubMin>0,@SubMin,0) , 0), 114) 
								print @Late
						END

						print 've som'
						UPDATE HR_WorkingDaySummary SET EarlyDuration = @Late-- (SELECT  s.HourOff FROM HR_WorkingDaySupplement s WHERE AutoID = @AutoID)
						WHere StaffID = @StaffID AND CONVERT(VARCHAR(10), Date,102) = CONVERT(VARCHAR(10), @Date,102)
					END
					--Cập nhật lại tổng công trong bảng tổng hợp công
					IF @TotalWorkingDay + @WorkingDaySupplement > 1
					BEGIN
						UPDATE dbo.HR_WorkingDaySummary SET TotalWorkingDay = 1, WorkingDaySupplement = 1 - TotalWorkingDay
						WHERE StaffID = @StaffID AND CONVERT(VARCHAR(10), Date,102) = CONVERT(VARCHAR(10), @Date,102)
					END
					ELSE
					BEGIN
						UPDATE dbo.HR_WorkingDaySummary SET TotalWorkingDay = @TotalWorkingDay + @WorkingDaySupplement, WorkingDaySupplement = WorkingDaySupplement + @WorkingDaySupplement
						WHERE StaffID = @StaffID AND CONVERT(VARCHAR(10), Date,102) = CONVERT(VARCHAR(10), @Date,102)
					END
				END
				ELSE IF  @TypeSupplement = 5 --Bổ sung công thêm
				BEGIn
				DECLARE @Overtime FLOAT
				IF NOT EXISTS(SELECT * FROM HR_WorkingDaySummary WHere StaffID = @StaffID AND CONVERT(VARCHAR(10), Date,102) = CONVERT(VARCHAR(10), @Date,102))
					BEGIN
						SELECT @Overtime = s.DayOff FROM HR_WorkingDaySupplement s WHERE AutoID = @AutoID
						INSERT INTO [dbo].[HR_WorkingDaySummary]
									   ([StaffID] ,[Date]	,[StartTime] ,[EndTime]
									   ,[WorkingDay]  ,[Furlough]
									   ,[LateDuration]   ,[EarlyDuration]
									   ,[Overtime]	   ,[OvertimeRate]
									   ,[TotalWorkingDay]  ,[WorkingDaySupplement]
									   ,[WorkingDayLeave])
    								 VALUES
									   (@StaffID,@Date,NULL,NULL,
										0,0
										,null,null
										,0, (SELECT  s.PercentPayrollID FROM HR_WorkingDaySupplement s WHERE AutoID = @AutoID)							
										,0,0
										,0)
					END
					ELSE
					BEGIN
						--Update HR_WorkingDaySummary SET Overtime = ISNULL(Overtime,0) +  (SELECT  s.DayOff FROM HR_WorkingDaySupplement s WHERE AutoID = @AutoID)
						--WHere StaffID = @StaffID AND  Date = CONVERT(VARCHAR(10), @Date,102)
						SELECT @TotalWorkingDay = TotalWorkingDay,@Overtime=Overtime  FROM dbo.HR_WorkingDaySummary 
						WHERE StaffID = @StaffID AND CONVERT(VARCHAR(10), Date,102) = CONVERT(VARCHAR(10), @Date,102)
						SELECT @Overtime = s.DayOff FROM HR_WorkingDaySupplement s WHERE AutoID = @AutoID
					END
					--Cập nhật lại tổng công trong bảng tổng hợp công
					UPDATE dbo.HR_WorkingDaySummary SET TotalWorkingDay = @TotalWorkingDay + @Overtime , Overtime = Overtime + @Overtime
					WHERE StaffID = @StaffID AND CONVERT(VARCHAR(10), Date,102) = CONVERT(VARCHAR(10), @Date,102)
				END
			END
		END
		ELSE IF @Type=0 -- KHÔNG DUYỆT
		BEGIN
				IF @UserID = 1 -- ADMIN KHONG DUYET
						UPDATE HR_WorkingDaySupplement
						SET
							SuperiorBy = @UserId,
							SuperiorDate = GETDATE(),
							HRNote = @Note,
							[Status] = 9
						WHERE AutoID = @AutoID 
			 ELSE IF @Status = 1 --QL KHONG DUYET
			BEGIn
				UPDATE HR_WorkingDaySupplement
					SET
						SuperiorBy = @UserId,
						SuperiorDate = GETDATE(),
						ManagerNote = @Note,
						[Status] = 2
					WHERE AutoID = @AutoID 
			END
			ELSE IF @Status = 6 --CCO KHONG DUYET
			BEGIn
				UPDATE HR_WorkingDaySupplement
					SET
						SuperiorBy = @UserId,
						SuperiorDate = GETDATE(),
						ManagerNote = @Note,
						[Status] = 7
					WHERE AutoID = @AutoID 
			END
			ELSE IF @Status = 3 --HR KHONG DUYET
			BEGIn
				UPDATE HR_WorkingDaySupplement
					SET
						ConfirmBy = @UserId,
						ConfirmDate = GETDATE(),
						HRNote = @Note,
						[Status] = 4
					WHERE AutoID = @AutoID 
			END
			ELSE IF @Status = 8 --ADMIN KHONG DUYET
			BEGIn
				UPDATE HR_WorkingDaySupplement
					SET
						SuperiorBy = @UserId,
						SuperiorDate = GETDATE(),
						HRNote = @Note,
						[Status] = 9
					WHERE AutoID = @AutoID 
			END
		END
		END
	END
	ELSE
	BEGIN
		SET @ChoPhepDuyet = 0
	END








	--SELECT * from GlobalList WHere ParentID = 85 ORDER BY GlobalListID
	--SELECT * from GlobalList WHere ParentID =84
		--SELECT * from GlobalList WHere ParentID = 20
	end try

	begin catch

		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),
				@SessionId				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= '[HR_WorkingDaySupplement]: ' + error_message()
		set @ErrorProc					= error_procedure()

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'HR_WorkingDaySupplement', 'UPDATE', @SessionId, @AddlInfo

	end catch






