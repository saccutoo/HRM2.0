USE ERP_HRM

GO
alter FUNCTION [dbo].[F_ReportAccountByStaff_Staff]
	(
		@LanguageID					INT			 = NULL,
		@DateFrom					CHAR(19)	 = NULL,
		@DateTo						CHAR(19)	 = NULL,
		@CurrencyID					CHAR(5)		 = 0,
		@SpendingCorresponding1Account  INT =1,
		@MarginCorresponding1Account	INT =1,
		@LastDOM					CHAR(19)	 = NULL
	)
RETURNS TABLE
as 
RETURN 
	SELECT
		 StaffName	=	(SELECT IIF(@LanguageID = 5,s.Fullname, s.FullnameEN) FROM dbo.Staff s WHERE StaffID = a.StaffID)
		, OrganizationUnitName = a.Department
		, VIP			=	ISNULL(SUM(IIF(a.RankId=3398 and T>0,T,0)),0)
		, Advanced		=	ISNULL(SUM(IIF(a.RankId=3399 and T>0,T,0)),0)
		, [Standard]	=	ISNULL(SUM(IIF(a.RankId=1729 and T>0,T,0)),0)
		, Substandard	=	ISNULL(SUM(IIF(a.RankId=1728 and T>0,T,0)),0)
		, Invalid		=	ISNULL(SUM(IIF(a.RankId=1727 and T>0,T,0)),0)
		, VIPS			=	ISNULL(SUM(IIF(a.RankId=3398 and T<0,T,0)),0) 
		, AdvancedS		=	ISNULL(SUM(iif(a.RankId=3399 and T<0,T,0)),0)
		, StandardS		=	ISNULL(SUM(IIF(a.RankId=1729 and T<0,T,0)),0)
		, FeeAmount		=	ISNULL(SUM(FeeAmount),0)
		, Margin		=	ISNULL(SUM(Margin),0)
		, AccountsConvertedBySpending = ISNULL(SUM(FeeAmount),0)/@SpendingCorresponding1Account
		, AccountsConvertedByMargin = ISNULL(SUM(Margin),0)/@MarginCorresponding1Account
		, TotalAccountsConverted = 
			ISNULL(SUM(FeeAmount),0)/@SpendingCorresponding1Account 
			+ ISNULL(SUM(Margin),0)/@MarginCorresponding1Account + ISNULL(SUM(a.AccountConversion),0)
		, RateACBSPerTAC =100 * ((ISNULL(SUM(FeeAmount),0)/@SpendingCorresponding1Account)/IIF((ISNULL(SUM(FeeAmount),0)/@SpendingCorresponding1Account + ISNULL(SUM(Margin),0)/@MarginCorresponding1Account + ISNULL(SUM(a.AccountConversion),0))!=0,(ISNULL(SUM(FeeAmount),0)/@SpendingCorresponding1Account + ISNULL(SUM(Margin),0)/@MarginCorresponding1Account) + ISNULL(SUM(a.AccountConversion),0),1))
		, RateOfMarginFeePerTotalMargin =100 * (ISNULL(SUM(Margin),0)/IIF(ISNULL(SUM(FeeAmount+Margin),0)!=0,ISNULL(SUM(FeeAmount+Margin),0),1))
	FROM(
			SELECT * FROM ERP_v2.dbo.F_ReportAccount_GET(@LanguageID,@DateFrom,@DateTo,@CurrencyID, @LastDOM)
		) a
	LEFT JOIN dbo.Organizationunit o ON o.OrganizationUnitID = a.OrganizationUnitID
	
	WHERE o.DS_CompanyID = 1221 AND o.OrganizationUnitID IS NOT NULL
	GROUP BY a.StaffID,a.Department


