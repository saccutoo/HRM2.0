USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[HR_WorkingDaySupplement_GetByAutoId]    Script Date: 1/3/2019 11:34:58 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[HR_WorkingDaySupplement_GetByAutoId]
	@ListAutoID NVARCHAR(MAX) ='3891',
	@LanguageID INT = 5
AS
BEGIN
	SELECT * FROM dbo.HR_WorkingDaySupplement WHERE AutoID = @ListAutoID
END