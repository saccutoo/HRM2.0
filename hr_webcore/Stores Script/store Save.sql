USE [ERP_v2]
GO
/****** Object:  StoredProcedure [dbo].[Quotation_Save]    Script Date: 9/13/2018 9:16:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--region [dbo].[usp_InsertUpdateQuotation]

------------------------------------------------------------------------------------------------------------------------
-- Tác giả:     Nhungpt
-- Tên thủ tục: [dbo].[usp_InsertUpdateQuotation]
-- Ngày tạo:    05/10/2017
------------------------------------------------------------------------------------------------------------------------

ALTER PROCEDURE [dbo].[Quotation_Save]
	@CustomerID int=null,
	@Code nvarchar(100)=null,
	@CurrencyID int=null,
	@Status int=null,
	@CreatedDate nvarchar(30)=null,
--	@SubmittedDate datetime=null,
	--@ApprovedDate datetime=null,
	@EstimatedBudget float=null,
	@StaffID int=null,
	@OtherInfor nvarchar(2000)=null,
	@Note nvarchar(max)=null,
	@TargetCustomer nvarchar(max)=null,
	@Userid int=null,
	@CopyID int=null,
	@QuotationID int OUTPUT
AS
 
BEGIN TRY
    IF @QuotationID>0
    begin
	UPDATE [dbo].[Quotation] SET
		[CustomerID] = @CustomerID,
		[Code] = @Code,
		[CurrencyID] = @CurrencyID,
		--[Status] = @Status,
		[CreatedDate] =   convert(date,convert(varchar(20),@CreatedDate,103),103) , 
		[StaffID] = @StaffID,
		[OtherInfor] = @OtherInfor,
		[Note] = @Note,
		
		--[Note] = iif(@Note is not null,isnull(Note + '<br>','') +(select a.UserName from Sec_User a where a.UserID=@Userid) +' [' + convert(varchar(19),getdate(),113)+ ']: '+ @Note,Note),
		[TargetCustomer]=@TargetCustomer
    	WHERE
		[QuotationID] = @QuotationID
     
    END
	else
	begin
INSERT INTO [dbo].[Quotation]
           ([CustomerID]
           ,[Code]
           ,[CurrencyID]
           ,[Status]
           ,[CreatedDate] 
           ,[EstimatedBudget]
           ,[StaffID]
           ,[OtherInfor]
           ,[Note],[TargetCustomer])
     VALUES
           (@CustomerID
           ,@Code
           ,@CurrencyID
           ,@Status
           ,convert(date,convert(varchar(20),@CreatedDate,103),103)
           
           ,@EstimatedBudget
           ,@StaffID
           ,@OtherInfor
           ,@Note,@TargetCustomer)
		   set	 @QuotationID	= scope_Identity()

	end
       

END TRY
BEGIN CATCH

	DECLARE	@ErrorNum 	int,
			@ErrorMsg 	varchar(200),
			@ErrorProc 	varchar(50),
			@SessionId 	int,
			@AddlInfo 	varchar(MAX)

	SET @ErrorNum 	= error_number()
	SET @ErrorMsg 	= '[dbo].[Quotation_Save]: ' + error_message()
	SET @ErrorProc 	= error_procedure()
	SET @AddlInfo 	= 'INSERT OR UPDATE FAIL: ' + GETDATE()

	EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Quotation', 'IOU', @SessionId, @AddlInfo

END CATCH

--endregion

