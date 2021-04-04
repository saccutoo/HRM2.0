USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[HR_WorkingDaySupplement_SendNew]    Script Date: 1/9/2019 3:42:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[HR_WorkingDaySupplement_SendNew]
	@UserID INT = 22947
AS
BEGIN
declare @StatusNew int
-- lấy trạng thái để chuyển
select @StatusNew= iif(ManagerID is null,3,iif(ManagerID=1,1210,iif(isnull(OfficePositionID,0) =252,6,1)))
 from ERP_v2.dbo.HR_ApprovementConfiguration a left join staff s on a.ManagerID=s.staffid where a.StaffID=@UserID
 UPDATE HR_WorkingDaySupplement SET Status = isnull(@StatusNew,1)  Where StaffID=@UserID AND Status=0-- Chờ ADMIN DUYỆT
END




