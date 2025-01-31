USE [ERP_HRM]
GO

DECLARE	@return_value int,
		@Status int,
		@Message nvarchar(max)

EXEC	@return_value = [dbo].[HR_UpdateTimekeeping]
		@WorkingDayMachineID = 16,
		@MachineName = N'ChamcongT5',
		@DateUpdate = N'2019.03.05',
		@Status = @Status OUTPUT,
		@Message = @Message OUTPUT

SELECT	@Status as N'@Status',
		@Message as N'@Message'

SELECT	'Return Value' = @return_value

GO
