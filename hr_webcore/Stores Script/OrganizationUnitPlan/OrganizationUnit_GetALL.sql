USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[OrganizationUnit_GetALL]    Script Date: 3/27/2019 5:30:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[OrganizationUnit_GetALL]
AS
BEGIN
	select * from ERP_v2.dbo.Organizationunit
END	
