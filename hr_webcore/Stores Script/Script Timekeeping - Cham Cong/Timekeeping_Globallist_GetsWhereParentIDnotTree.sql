USE [NovaonAD]
GO
/****** Object:  StoredProcedure [dbo].[Globallist_GetsWhereParentIDnotTree]    Script Date: 12/24/2018 3:56:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
/*
***************************************************************************
	-- Author:			Nhungpt
	-- Description:		Get List of globallist where parentid
	-- Date				PIC					alter record
	-- 2018/10/09       Nhungpt             Addnew
***************************************************************************
*/

ALTER procedure [dbo].[Globallist_GetsWhereParentIDnotTree]

	@ParentID int,
	@LanguageID	int

as

begin try
	 SELECT       
	[GlobalListID]
      ,[Name]
      ,[NameEN]
      ,[Value]
      ,[ValueEN]
      ,[IsActive]
      ,[Descriptions]
      ,[ParentID]
      ,[TreeLevel]
      ,[HasChild]
      ,[OrderNo]
      ,[CreatedDate]
      ,[CreatedBy]
      ,[ModifiedDate]
      ,[ModifiedBy]
	  ,DisplayName=iif(@LanguageID=4,[NameEN],[Name])
	  ,DisplayValue=iif(@LanguageID=4,[ValueEN],[Value])
     FROM     dbo.GlobalList AS p WITH (nolock)
	   WHERE   ParentID =@ParentID 
	  order by [OrderNo] 
	 
					
	end try

	begin catch

		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),
				@SessionId				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'Globallist_GetsWhereParentID: ' + error_message()
		set @ErrorProc					= error_procedure()
		set @AddlInfo					= '@Parentid=' + @Parentid

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'dbo.Globallist', 'GET', @SessionId, @AddlInfo

	end catch






