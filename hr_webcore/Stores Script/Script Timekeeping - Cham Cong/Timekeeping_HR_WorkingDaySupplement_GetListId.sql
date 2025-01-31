USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[HR_WorkingDaySupplement_GetListId]    Script Date: 12/20/2018 1:25:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[HR_WorkingDaySupplement_GetListId]
	@ListAutoID NVARCHAR(MAX) ='3891',
	@LanguageID INT = 5
AS
BEGIN
	SELECT 
			 w.AutoID
			,w.StaffID
			,w.Type
			,TypeName= IIF(CAST(@LanguageID AS VARCHAR)=5, g.Name,g.NameEN)
			,w.Date
			,w.FromTime
			,w.ToTime
			,w.HourOff
			,w.DayOff
			,w.Status
			,StatusName = IIF(CAST(@LanguageID AS VARCHAR)=5, gs.Name,gs.NameEN)
			,ReasonTypeName = IIF(CAST(@LanguageID AS VARCHAR)=5, gr.Name,gr.NameEN) +  IIF(w.CustomerID iS NOT NULL AND w.ReasonType=1213,  ' : ' + (SELECT IIF(c.Website IS NOT NULL,c.Website, IIF(c.Fanpage IS NOT NULL,c.Fanpage,c.CustomerCode + ' - ' + c.FullName)) FROM [ERP_v2].dbo.Customer c WHere c.CustomerID = w.CustomerID),'')
			,w.Note
			,w.PercentPayrollID
			,StaffName = IIF(CAST(@LanguageID AS VARCHAR)=5, s.Fullname,s.FullnameEN)
			,CustomerContactName = (Select FullName from [ERP_v2].dbo.CustomerContact Where AutoID = w.CustomerContactID)
										,CustomerReasonTypeName = (Select  IIF(5=5, Name,NameEN) from GlobalList Where ParentID=1887 AND GlobalListID = w.CustomerReasonType)
	 FROM HR_WorkingDaySupplement w
	INNER JOIN GlobalList g on g.Value = w.Type AND g.ParentID = 84
	INNER JOIN GlobalList gs on gs.Value = w.Status AND gs.ParentID = 85
	INNER JOIN GlobalList gr on gr.GlobalListID = w.ReasonType AND gr.ParentID = 86
	INNER JOIN Staff s on s.StaffID = w.StaffID
	WHERE w.AutoID in (SELECT Data from Split(@ListAutoID,','))
END


--Select * from GlobalList gr Where gr.GlobalListId = 1213

--SELECT * FROM HR_WorkingDaySupplement WHERE AutoID = 3891

--SELECT * FROM Customer c WHere c.CustomerID = 231560

