USE [ERP_v2]
GO
/****** Object:  StoredProcedure [dbo].[Quotation_GetInfo]    Script Date: 9/13/2018 9:38:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

/*
***************************************************************************
	-- Author:			Nhungpt
	-- Description:		Get List of Price_Google
	-- Date				PIC					create record
	-- 2017/05/07       Nhungpt             Addnew
***************************************************************************
*/

ALTER procedure[dbo].[Quotation_GetInfo]

	@QuotationID  						int	= null,
	@Roleid   					int=null,
	@LanguageID							int				= null

as

begin try
	
		  select [QuotationID]
      ,[CustomerID]
      ,[Code]
      ,[CurrencyID]
      ,[Status]
      ,[CreatedDate]
      ,[SubmittedDate]
      ,[ApprovedDate]
      ,[EstimatedBudget]
      ,[StaffID]
      ,[OtherInfor]
      ,[Note]
	  ,CustomerName			=	(select top 1 c.Fullname from customer c (nolock) where c.CustomerID = p.CustomerID)
	   ,DateSend			=	(select top 1 SubmittedDate from QuotationServiceApprovement d where d.Status= 120 and d.DS_QuotationID = @QuotationID order by SubmittedDate desc )
	    ,ApprovalDate			=	(select top 1 SubmittedDate from QuotationServiceApprovement d where d.Status!= 120 and d.DS_QuotationID = @QuotationID order by SubmittedDate desc )
	  ,Website			=	(select top 1 c.Website from customer c (nolock) where c.CustomerID = p.CustomerID)
		,CurrencyName	=	(select top 1 iif(@LanguageID=4,isnull(a.NameEN,a.name), a.name) from GlobalList a (nolock) where a.GlobalListID = p.CurrencyID )
		,BDName		=	(select top 1 u.Fullname from Staff u (nolock) where u.StaffID = p.StaffID )
		,[TargetCustomer]
		,ServicePackageName			=	(select stuff((select ', ' + iif(@LanguageID=4,isnull(a.PackageNameEN,a.PackageName), a.PackageName) as [text()]
																	from ServicePackage a (nolock) 
																	where  a.ServicePackageID in (select Data from [dbo].[Split](
																		(
			  																select stuff((select ', ' + convert(varchar, d.ServicePackageID) as [text()]
			  																from QuotationDetail d (nolock) 
			  																where d.DS_QuotationID  = p.QuotationID
			  																for xml path('')), 1, 1, '' )
																		)
																		, ',') where	Data <> '')
																	for xml path('')),1,1, '' ))	 
					,LanguageId=(select top 1 u.CurrentLanguageID from Sec_User u (nolock) where u.UserID = p.StaffID )
					  FROM [Quotation] p (nolock) where QuotationID=@QuotationID
					
	end try

	begin catch

		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),
				@SessionId				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'Quotation_GetInfo: ' + error_message()
		set @ErrorProc					= error_procedure()
		set @AddlInfo					= '@QuotationID=' + @QuotationID

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'dbo.Quotation', 'GET', @SessionId, @AddlInfo

	end catch





