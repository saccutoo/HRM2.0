USE [ERP_v2]
GO
/****** Object:  StoredProcedure [dbo].[Quotation_Gets]    Script Date: 6/19/2019 5:27:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

/*
***************************************************************************
	-- Author:			Nhungpt
	-- Description:		Get List of Price_Google
	-- Date				PIC					alter record
	-- 2017/05/07       Nhungpt             Addnew
***************************************************************************
*/

ALTER procedure[dbo].[Quotation_Gets]

	@FilterField  						nvarchar(max)	= null,
	@OrderByField   					nvarchar(max)	= null,
	@PageIndex							int				= null,				
	@PageSize							int				= null,
	@UserId								int				= null,
	@RoleId							int				= null,
	@DeptId							int				= null,
	@LanguageID						int,				
	@TotalRecord						int				output

as

begin try
	
		declare	@WhereSQL				nvarchar(max),
			@WhereSQLUser				nvarchar(max),
				@Delim					varchar(100),
				@SQL					nvarchar(max),
				
				@dynamicsql				nvarchar(max),
				@dynamicparamdec		nvarchar(max),
				@SearchResult			bigint,

				@OrderBySQL				varchar(max),
				@OffsetSize				int, 
				@Level				int

		set		@OrderByField			= isnull(@OrderByField,'Id ASC')
		set		@FilterField			= isnull(@FilterField,'')
		set		@WhereSQL				= ''
		set		@WhereSQLUser				= ''
		set		@Delim					= ' where '
		set		@OffsetSize				=	(@PageIndex-1) * @PageSize 
		--select @isManager=iif( (PositionId=7 or PositionId=5),1,0),@Level=level from sec_User where   UserId=@UserId

		-- set		@PageIndex				= case when isnull(@PageIndex,0)	= 0 then 1 else convert(int,@PageIndex) end
		-- set		@PageSize				= case when isnull(@PageSize,0)	= 0 then 50 else convert(int,@PageSize) end 
		--1. Build where clause
		if @FilterField <> ''
			begin
			 
				set	@WhereSQL			=  ' and ' +  @FilterField
				
			end	 
			print (@WhereSQL)
		if @RoleId=3 OR @RoleId=28-- BD
		begin
		set	@Delim				= ' and '
		set	@WhereSQLUser			= @WhereSQLUser + @Delim +  
		'  (   p.StaffID  in (  select u.StaffId from Staff_Parent u where u.type=0 and u.ParentId= '+cast(@UserId as varchar(20))+') ) '
	 
		end
		 else if @RoleId=4 or @RoleId=5    --Media, Account
			begin
			declare @listDept varchar(200)
				select @listDept=LTRIM(STUFF ((SELECT        ',' + deptlist
                                 FROM            V_OrganizationUnit o
                                                          
                                 WHERE        o.deptchild like '%,'+ cast(s.OrganizationUnitID as varchar) +',%' FOR XML PATH('')), 1, 1, '')) 
								 
								  from OrganizationUnit s   where s.OrganizationUnitid= @DeptId 
			set	@Delim				= ' and '
			set	@WhereSQLUser			= @WhereSQLUser + @Delim +  
				' ( p.QuotationID in ( select QuotationID from QuotationService u where u.OrganizationUnitid in    ('+cast(@listDept as varchar(2000))+')   ) )  '
					 
			end 
		else if @RoleId=7 or @RoleId=6  --, DS
		begin
			set	@Delim				= ' and '
			set	@WhereSQLUser			= @WhereSQLUser + @Delim +  
					'(p.QuotationID in (select QuotationID from QuotationService u WHERE u.OrganizationUnitID in
					(Select ParentID FROM V_OrganizationUnit s where s.DeptChild like  ''%,'+cast(@DeptId as varchar(20))+',%'' )))'
		end
		else if  @RoleId=26 --Media Performance 
		begin

			set	@Delim				= ' and '
			IF @DeptId = 56 -- Phong Marketing
			BEGIN
				set	@WhereSQLUser			= @WhereSQLUser + @Delim +  
				' ( p.QuotationID in ( select QuotationID from QuotationService u inner join V_OrganizationUnit s on u.OrganizationUnitID=s.OrganizationUnitID where  s.DeptChild LIKE ''%,56,%''  )   ) '
				 
			END
			ELSE
			BEGIN
				set	@WhereSQLUser			= @WhereSQLUser + @Delim +  
				' ( p.QuotationID in ( select QuotationID from QuotationService u inner join V_OrganizationUnit s on u.OrganizationUnitID=s.OrganizationUnitID where  s.DeptChild LIKE ''%,1179,%''  OR s.DeptChild LIKE ''%,1197,%'' )   ) '
				 
			END

			
		end
		else if @RoleId!=1-- khác Admin
			begin
			set	@Delim				= ' and '
			set	@WhereSQLUser			= @WhereSQLUser + @Delim +  
				' ( p.QuotationID in ( select DS_QuotationID from Staff_Parent u inner join QuotationService_Staff s on u.StaffId=s.StaffID where u.type=0 and u.ParentId= '+cast(@UserId as varchar(20))+' )  ) '
				 
			end 
			
		--set @OrderBySQL = @OrderByField
		--2. Build select query
		set	@SQL	 = 
				 -- ' select 	RowIndex= row_number() over (order by '+@OrderByField+' ),
					N' select * from ( select [QuotationID]
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
	   ,StatusList=  '',''+stuff((select '','' + cast(Status as varchar)
													from (select a.Status from QuotationService a where a.QuotationID  =p.QuotationID
																	union select p.Status ) a
																	for xml path('''')),1,1, '''' ) + '',''
	   ,StatusName=  stuff((select distinct '', '' + iif('+cast(@LanguageId as varchar(20))+'=4,isnull(d.NameEN,d.name), d.name)  as [text()]
																	from GlobalList d (nolock) inner join (select a.Status from QuotationService a where a.QuotationID  =p.QuotationID
																	union select p.Status) a on a.Status=d.GlobalListID and d.ParentID=2
																	where d.ParentID =2
																	for xml path('''')),1,1, '''' )  
	     ,MediaName= stuff((select distinct '', '' + iif('+cast(@LanguageId as varchar(20))+'=4,isnull(a.FullnameEN,a.Fullname), a.Fullname)  as [text()]
																	from QuotationService_Staff d (nolock) inner join Staff a on a.StaffID=d.StaffID 
																	where  d.DS_QuotationID  =p.QuotationID and d.roleId=4
																	for xml path('''')),1,1, '''' ) 
 ,AccounName= stuff((select distinct '', '' + iif('+cast(@LanguageId as varchar(20))+'=4,isnull(a.FullnameEN,a.Fullname), a.Fullname)  as [text()]
																	from QuotationService_Staff d (nolock) inner join Staff a on a.StaffID=d.StaffID 
																	where  d.DS_QuotationID  =p.QuotationID and d.roleId=5
																	for xml path('''')),1,1, '''' )    	
	  ,Website			=	(select top 1 c.Website from customer c (nolock) where c.CustomerID = p.CustomerID)
		,CurrencyName	=	(select top 1 iif('+cast(@LanguageID as varchar)+'=4,isnull(a.NameEN,a.name), a.name) from GlobalList a (nolock) where a.GlobalListID = p.CurrencyID )
		,BDName		=	(select top 1 u.Fullname from Staff u (nolock) where u.StaffID = p.StaffID )
		,ServicePackageName			=	 stuff((select '', '' +   iif('+cast(@LanguageID as varchar)+'=4,isnull(a.PackageNameEN,a.PackageName), a.PackageName) 
																	from ServicePackage a  inner join QuotationDetail d on a.ServicePackageID=d.ServicePackageID 
																	where d.DS_QuotationID  = p.QuotationID 
																		 group by a.ServicePackageID, iif('+cast(@LanguageID as varchar)+'=4,isnull(a.PackageNameEN,a.PackageName), a.PackageName) 
																	for xml path('''')),1,1, '''' )   
					   	   ,DateSend			=	(select top 1 SubmittedDate from QuotationServiceApprovement d where d.Status= 120 and d.DS_QuotationID = p.QuotationID order by SubmittedDate desc )
	    ,ApprovalDate			=	(select top 1 SubmittedDate from QuotationServiceApprovement d where d.Status!= 120 and d.DS_QuotationID = p.QuotationID order by SubmittedDate desc ) '+
	
			
					'   FROM [Quotation] p (nolock) where 1=1 ' + @WhereSQLUser + ') p where 1=1 ' + @WhereSQL + 
					' order by p.QuotationID desc' +
					' OFFSET  '+ convert(varchar,@OffsetSize) +' ROWS  FETCH NEXT '+ convert(varchar,@PageSize) +' ROWS ONLY '

		 print (@SQL)
		 exec(@SQL)
		 -- ALTER INDEX ALL ON dbo.Cust_Website REBUILD WITH (ONLINE = ON);

		--3. Count
		set	@dynamicsql				=
		N'select @ItemCount	= count(p.QuotationID)'	+
		' from ( select  [QuotationID]
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
	  ,StatusList=  '',''+stuff((select '','' + cast(Status as varchar)
													from (select a.Status from QuotationService a where a.QuotationID  =p.QuotationID
																	union select p.Status ) a
																	for xml path('''')),1,1, '''' ) + '',''
	   ,StatusName=  stuff((select distinct '', '' + iif('+cast(@LanguageId as varchar(20))+'=4,isnull(d.NameEN,d.name), d.name)  as [text()]
																	from GlobalList d (nolock) inner join (select a.Status from QuotationService a where a.QuotationID  =p.QuotationID
																	union select p.Status) a on a.Status=d.GlobalListID and d.ParentID=2
																	where d.ParentID =2
																	for xml path('''')),1,1, '''' )    
	    ,MediaName= stuff((select distinct '', '' + iif('+cast(@LanguageId as varchar(20))+'=4,isnull(a.FullnameEN,a.Fullname), a.Fullname)  as [text()]
																	from QuotationService_Staff d (nolock) inner join Staff a on a.StaffID=d.StaffID 
																	where  d.DS_QuotationID  =p.QuotationID and d.roleId=4
																	for xml path('''')),1,1, '''' )   														  
	    ,AccounName= stuff((select distinct '', '' + iif('+cast(@LanguageId as varchar(20))+'=4,isnull(a.FullnameEN,a.Fullname), a.Fullname)  as [text()]
																	from QuotationService_Staff d (nolock) inner join Staff a on a.StaffID=d.StaffID 
																	where  d.DS_QuotationID  =p.QuotationID and d.roleId=5
																	for xml path('''')),1,1, '''' )  
	  ,Website			=	(select top 1 c.Website from customer c (nolock) where c.CustomerID = p.CustomerID)
		,CurrencyName	=	(select top 1 iif('+cast(@LanguageID as varchar)+'=4,isnull(a.NameEN,a.name), a.name) from GlobalList a (nolock) where a.GlobalListID = p.CurrencyID )
		,BDName		=	(select top 1 u.Fullname from Staff u (nolock) where u.StaffID = p.StaffID )
		,ServicePackageName			=	 stuff((select '', '' +   iif('+cast(@LanguageID as varchar)+'=4,isnull(a.PackageNameEN,a.PackageName), a.PackageName) 
																	from ServicePackage a  inner join QuotationDetail d on a.ServicePackageID=d.ServicePackageID 
																	where d.DS_QuotationID  = p.QuotationID 
																		 group by a.ServicePackageID, iif('+cast(@LanguageID as varchar)+'=4,isnull(a.PackageNameEN,a.PackageName), a.PackageName) 
																	for xml path('''')),1,1, '''' )  
				   ,DateSend			=	(select top 1 SubmittedDate from QuotationServiceApprovement d where d.Status= 120 and d.DS_QuotationID = p.QuotationID order by SubmittedDate desc )
	    ,ApprovalDate			=	(select top 1 SubmittedDate from QuotationServiceApprovement d where d.Status!= 120 and d.DS_QuotationID = p.QuotationID order by SubmittedDate desc ) '+
	
									
					' from [Quotation] p (nolock) where 1=1 ' + @WhereSQLUser + ') p where 1=1 ' + @WhereSQL
		
		set @dynamicparamdec = '@ItemCount int output'
 
		execute sp_executesql @dynamicsql,@dynamicparamdec,@TotalRecord  output

					
	end try

	begin catch

		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),
				@SessionId				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'Quotation_Gets: ' + error_message()
		set @ErrorProc					= error_procedure()
		set @AddlInfo					= '@FilterField=' + @FilterField

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'dbo.Quotation', 'GET', @SessionId, @AddlInfo

	end catch






