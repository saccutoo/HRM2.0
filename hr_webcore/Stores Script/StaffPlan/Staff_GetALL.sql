USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[Staff_GetALL]    Script Date: 3/27/2019 5:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Staff_GetALL]
AS
BEGIN
	select * from ERP_v2.dbo.Staff 
END	
