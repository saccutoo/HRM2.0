USE [Hrm2.0]
GO
/****** Object:  StoredProcedure [dbo].[SalaryType_Get_GetSalaryTypeById]    Script Date: 2/22/2020 3:39:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE[dbo].[SalaryType_Del_DeleteSalaryType]
	 @Id BIGINT,
	 @DbName NVARCHAR(100)
AS
 
BEGIN
	 
	DECLARE @ExeQuery NVARCHAR(MAX), @params NVARCHAR(MAX)	   				
															 
	SET @ExeQuery = N'USE [Hrm_'+ @DbName + ']' + N'				
				IF((SELECT COUNT(Id) FROM dbo.Config_Salarytype_Mapper WHERE SalarytypeId=@Id AND IsDeleted=0)>0)
				BEGIN
					SELECT TOP 1 * FROM dbo.Config_Salarytype_Mapper WHERE SalarytypeId=@Id AND IsDeleted=0
				END			
				ELSE
				BEGIN
					UPDATE dbo.Config_Salary_Type SET IsDeleted=1 WHERE Id=@Id
				END				
			'
		SET @params ='@Id BIGINT'
		EXEC sp_executesql @ExeQuery,@params,@Id
	
END
