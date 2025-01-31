USE [ERP_HRM]
GO
/****** Object:  UserDefinedFunction [dbo].[F_PaymentProduct]    Script Date: 11/01/2019 10:26:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
ALTER function [dbo].[F_PaymentProduct]
	(@LanguageId							int= NULL,
	@UserId									int=NULL
	)
RETURNS TABLE
as 
RETURN 
select   pd.CustomerID,
pd.OrganizationunitID,
pd.ProductID,
pd.Amount,
pd.AccountNumber,
pd.CreatedDate,
pd.CreatedBy,
pd.StaffID,
pd.[Status],
pd.PaymentDate,
pd.AutoID
,StatusName= (select top 1 iif(@LanguageId=4,nameEN,name) from NovaonAD.dbo.globallist g where g.globallistid=pd.[Status])
,ProductName= (select top 1 iif(@LanguageId=4,nameEN,name) from NovaonAD.dbo.globallist g where g.globallistid=pd.ProductID)
,OrganizationUnitName=iif(@LanguageId=4,o.nameEN,o.name)
,BDName=(select Fullname from Staff s where s.StaffID=pd.StaffID)
,Website=(select Website from ERP_v2.dbo.Customer c where c.CustomerID=pd.CustomerID)
,Email=(select Email from ERP_v2.dbo.Customer c where c.CustomerID=pd.CustomerID)
,CustomerName=(select FullName + '_' + Website +'_' + Fanpage from ERP_v2.dbo.Customer c where c.CustomerID=pd.CustomerID)

--,OfficeName= (select top 1 iif(@LanguageId=4,nameEN,name) from NovaonAD.dbo.globallist g where g.globallistid=b.OfficeID)
--,OfficePositionName= (select iif(@LanguageId=4,nameEN,name) from NovaonAD.dbo.globallist g where g.globallistid=b.OfficePositionID)
--,CompanyName=(select top 1  iif( @LanguageId=4,d.nameEN,d.name) from OrganizationUnit d where d.OrganizationUnitid=b.CompanyID)
--,OrganizationUnitName=iif(@LanguageId=4,o.nameEN,o.name)
--,BranchName=(select  iif( @LanguageId=4,d.nameEN,d.name) from OrganizationUnit d where d.OrganizationUnitid=o.ds_branchid)

--,c.WorkingDayMachineID
--,WorkingManagerID=d.[ManagerID],WorkingHRID=d.[HRID]

--,u.UserName,u.IsActivated,Roleid=(select top 1 roleid from [NovaonAD].dbo.Sec_Role_User ar where ar.userid=a.staffid),b.CompanyID
from PaymentProduct pd 
LEFT JOIN OrganizationUnit o on pd.Organizationunitid=o.Organizationunitid
