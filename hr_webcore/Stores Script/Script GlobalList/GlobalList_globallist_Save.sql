USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[globallist_Save]    Script Date: 12/24/2018 8:40:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<honghv>
-- alter date: <08/10/2018>
-- Description:	<save and update globallist>
-- =============================================
ALTER PROCEDURE [dbo].[globallist_Save] 
	-- Add the parameters for the stored procedure here
	@GlobalListID INT,
	@Name nvarchar(100),
	@NameEN nvarchar(100),
	@Value nvarchar(max),
	@ValueEN nvarchar(max),
	@IsActive bit,
	@Descriptions nvarchar(max),
	@ParentID int,
	@OrderNo int,
	@CreatedBy nvarchar(max),
	@ModifiedBy nvarchar(max) = NULL,
	@TreeLevel int = 0,
	@HasChild bit = 0,
	@ParentDetailID INT
AS
BEGIN TRY
	DECLARE @createby INT
	DECLARE @datenow DATETIME
	SELECT @datenow = GETDATE()
	SELECT @createby = UserID FROM ERP_HRM.dbo.staff  WHERE Fullname = @CreatedBy
	PRINT @createby
	IF @GlobalListID>0
    BEGIN
		DECLARE @modifiedby1 INT
		SELECT @modifiedby1 = UserID FROM ERP_HRM.dbo.staff  WHERE Fullname = @ModifiedBy
		update dbo.globallist set IsActive=@IsActive,Name=@Name,NameEN=@NameEN,Value=@Value,ValueEN=@ValueEN,Descriptions=@Descriptions,ParentID=@ParentID,OrderNo=isnull(@OrderNo,0),ModifiedDate=@datenow,ModifiedBy=@modifiedby1,ParentDetailID=@ParentDetailID
		where GlobalListID=@GlobalListID
     
    END
	else
	begin 
	INSERT INTO dbo.Globallist
           ([IsActive]
           ,[Name]
           ,[NameEN]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[Value]
           ,[ValueEN]
           ,[Descriptions]
		   ,[ParentID]	
		   ,[OrderNo]
		   ,[TreeLevel]
		   ,[HasChild]
		   ,[ParentDetailID]
		   )
     VALUES
           (@IsActive
           ,@Name
           ,@NameEN
           ,@datenow
           ,@createby
           ,@Value
           ,@ValueEN
           ,@Descriptions
		   ,@ParentID
		   ,@OrderNo
		   ,0
		   ,0
		   ,@ParentDetailID
		   )
	end

END TRY
BEGIN CATCH

	DECLARE	@ErrorNum 	int,
			@ErrorMsg 	varchar(200),
			@ErrorProc 	varchar(50),
			@SessionId 	int,
			@AddlInfo 	varchar(MAX)

	SET @ErrorNum 	= error_number()
	SET @ErrorMsg 	= '[dbo].[globallist_Save]: ' + error_message()
	SET @ErrorProc 	= error_procedure()
	SET @AddlInfo 	= 'INSERT OR UPDATE FAIL: ' + GETDATE()

	EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'globallist', 'IOU', @SessionId, @AddlInfo

END CATCH

--endregion


