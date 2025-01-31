USE [Hrm2.0]
GO
/****** Object:  StoredProcedure [dbo].[SalaryElement_Get_GetSalaryElementBySalaryTypeId]    Script Date: 2/23/2020 3:47:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE[dbo].[SalaryElement_Get_GetSalaryElementBySalaryTypeId]
	 @Id BIGINT,
	 @DbName NVARCHAR(100)
AS
 
BEGIN
	 
	DECLARE @ExeQuery NVARCHAR(MAX), @params NVARCHAR(MAX)	   				
															 
	SET @ExeQuery = N'USE [Hrm_'+ @DbName + ']' + N'				
				SELECT 
					CSE.Id,
					CSE.Name,
					CSE.Code,
					CSE.TypeId,
					CSE.DataTypeId,
					CSE.Formula,
					CSTE.IsEdit,
					CSTE.IsShowSalary,
					CSTE.IsShowPayslip,
					CSTE.OrderNo,
					CSE.MergeCells,
					CSE.Css
				FROM  dbo.Config_Salary_Element CSE
				INNER JOIN dbo.Config_Salarytype_Element CSTE ON CSTE.SalaryElementId=CSE.Id
				WHERE CSE.IsDeleted=0 AND CSTE.IsDeleted=0 AND CSTE.SalaryTypeId=@Id
				ORDER BY CSTE.OrderNo ASC							
			'
		SET @params ='@Id BIGINT'
		EXEC sp_executesql @ExeQuery,@params,@Id
	
END
