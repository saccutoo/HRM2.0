USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[Config_Allowance_Save]    Script Date: 1/28/2019 10:06:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Config_Allowance_Save]
@AllowanceID			int,
@Name					nvarchar(200),
@Content				nvarchar(500),
@FromAmount				float,
@ToAmount				float,
@sFormular			nvarchar(MAX),
@Note				nvarchar(500)
AS
BEGIN
DECLARE @Config_Allowance_Save int
	select @Config_Allowance_Save = count(*) from Config_Allowance where AllowanceID = @AllowanceID
	if (@Config_Allowance_Save = 0)		
		begin
			insert Config_Allowance ([Name],Content,FromAmount,ToAmount,sFormular,Note) values(@Name, @Content,@FromAmount,@ToAmount,@sFormular,@Note)
		end	
	else
		begin
			UPDATE  Config_Allowance
			   SET 
				  [Name]=@Name
				 ,Content = @Content
				 ,FromAmount = @FromAmount					
				 ,ToAmount = @ToAmount
				 ,sFormular = @sFormular
				 ,Note=@Note				
				 WHERE AllowanceID = @AllowanceID
		end	
END
