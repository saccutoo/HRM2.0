USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[globallist_GetByGlobalListID]    Script Date: 12/24/2018 9:38:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<thanhbt>
-- alter date: <10/08/2018>
-- Description:	<lấy bản ghi theo global_list_id>
-- =============================================
ALTER PROCEDURE [dbo].[globallist_GetByGlobalListID] 
	-- Add the parameters for the stored procedure here
	@GlobalListID int=0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT c.GlobalListID, c.Name,c.NameEN, c.Value,c.ValueEN,c.IsActive,c.Descriptions
	,c.ParentID,c.ParentDetailID,c.TreeLevel,c.HasChild,c.OrderNo,c.CreatedDate,
	CreatedBy1=(SELECT Fullname FROM dbo.Staff  WHERE UserID = c.CreatedBy),c.ModifiedDate,
	ModifiedBy1=(SELECT Fullname FROM dbo.Staff  WHERE UserID = c.ModifiedBy),c.idOld,c.ListChildID
	FROM globallist c where c.GlobalListID=@GlobalListID
END

