USE [ERP_HRM]
GO
/****** Object:  StoredProcedure [dbo].[Teamplate_Save]    Script Date: 3/5/2019 10:58:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Teamplate_Save]
@AutoID			int,
@Name			nvarchar(100),
@NameEN			nvarchar(100),
@Value			nvarchar(50),
@Type			int,
@DisplayType	int,
@Align			nvarchar(50),
@Css			nvarchar(100),
@OrderNo		int,
@Hide			nvarchar(5),
@Colspan		int,
@DataFormat		int,
@CustomHTML		nvarchar(2000),
@HideRow		nvarchar(5),
@Output			int output
AS
BEGIN
DECLARE @Teamplate_Save int
DECLARE @MaxOrderNo int

	select @Teamplate_Save = count(*) from Template where AutoID = @AutoID
				print @Teamplate_Save
				if (@Teamplate_Save = 0)		
					begin
						set @MaxOrderNo = (SELECT TOP 1 OrderNo FROM  Template ORDER BY OrderNo DESC) +1
						insert into Template(Name,NameEN,Value,Type,DisplayType,Align,Css,OrderNo,Hide,Colspan,DataFormat,CustomHTML,HideRow) values(@Name,@NameEN,@Value,@Type,@DisplayType,@Align,@Css,@MaxOrderNo,@Hide,@Colspan,@DataFormat,@CustomHTML,@HideRow)
						 select @Output=2
						 print @Output
						--insert thành công
					end														
				else
				begin
						UPDATE  Template
						   SET 
							  Name = @Name
							 ,NameEN = @NameEN					
							 ,Type = @Type
							 ,Value=@Value
							 ,DisplayType=@DisplayType
							 ,Align=@Align
							 ,Css=@Css
							 ,OrderNo=@OrderNo
							 ,Hide=@Hide
							 ,Colspan=@Colspan
							 ,DataFormat=@DataFormat
							 ,CustomHTML=@CustomHTML
							 ,HideRow=@HideRow	
							 WHERE AutoID = @AutoID
						select @Output=1
						--cập nhập thành công
					end	
	
END
