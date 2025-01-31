USE [Hrm2.0]
GO
/****** Object:  StoredProcedure [dbo].[SalaryType_Update_SaveSalaryType]    Script Date: 2/23/2020 3:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE[dbo].[SalaryType_Update_SaveSalaryType]
	 @Id						BIGINT,
	 @Name						NVARCHAR(500),
	 @StatusId					BIGINT,
	 @Description				NVARCHAR(500),
	 @IsAutoLock				BIT,
     @DayLock					BIGINT,
	 @MaximumDay				BIGINT,
	 @CreatedBy					BIGINT,
	 @UpdatedBy					BIGINT,
	 @SalaryElementType			SalaryElementType READONLY,
	 @ListSalarytypeMapper		SalarytypeMapperType READONLY,
	 @DbName					NVARCHAR(500)
AS
 
BEGIN

	DECLARE @ExeQuery NVARCHAR(MAX), @params NVARCHAR(MAX)	   				
															 
	SET @ExeQuery = N'USE [Hrm_'+ @DbName + ']' + N'
				
				IF(@Id=0)
				BEGIN
					INSERT INTO dbo.Config_Salary_Type
							( Name ,
							  StatusId ,
							  Description ,
							  IsAutoLock ,
							  DayLock ,
							  MaximumDay ,
							  IsDeleted ,
							  CreatedBy ,
							  CreatedDate 
							)
					VALUES  ( @Name , -- Name - nvarchar(500)
							  @StatusId , -- StatusId - bigint
							  @Description , -- Description - nvarchar(500)
							  @IsAutoLock , -- IsAutoLock - bit
							  @DayLock , -- DayLock - int
							  @MaximumDay , -- MaximumDay - int
							  0 , -- IsDeleted - bit
							  @CreatedBy , -- CreatedBy - int
							  GETDATE()  -- CreatedDate - datetime
        
					)

					SET @Id=SCOPE_IDENTITY()

					IF((SELECT COUNT(Id) FROM @SalaryElementType)>0)
					BEGIN
						INSERT INTO dbo.Config_Salarytype_Element
								( SalaryTypeId ,
								  SalaryElementId ,
								  IsEdit,
								  IsShowSalary ,
								  IsShowPayslip,
								  IsDeleted,
								  OrderNo
								)
						SELECT   @Id , -- SalaryTypeId - bigint
								  ST.Id , -- SalaryElementId - bigint
								  ST.IsEdit,-- IsEdit - bit
								  ST.IsShowSalary , -- IsShowSalary - bit
								  ST.IsShowPayslip , -- IsShowPayslip - bit
								  0,  -- IsDeleted - bit
								  ST.OrderNo
						FROM @SalaryElementType ST 
					END

					IF((SELECT COUNT(Id) FROM @ListSalarytypeMapper)>0)
					BEGIN
						INSERT INTO dbo.Config_Salarytype_Mapper
								( SalarytypeId ,
								  TypeId ,
								  DataId ,
								  CreatedBy ,
								  CreatedDate ,
								  IsDeleted
								)
						SELECT   @Id , -- SalarytypeId - bigint
								  LSM.TypeId, -- TypeId - bigint
								  LSM.DataId , -- DataId - bigint
								  @CreatedBy , -- CreatedBy - int
								  GETDATE() , -- CreatedDate - datetime
								  0  -- IsDeleted - bit
						FROM @ListSalarytypeMapper LSM
					END
				END
				ELSE
				BEGIN
					UPDATE dbo.Config_Salary_Type 
						SET	Name=@Name,
							StatusId=@StatusId,
							Description=@Description,
							IsAutoLock=@IsAutoLock,
							DayLock=@DayLock,
							MaximumDay=@MaximumDay,
							UpdatedBy=@UpdatedBy,
							UpdatedDate=GETDATE()
					WHERE Id=@Id

					UPDATE dbo.Config_Salarytype_Element SET IsDeleted=1 WHERE SalarytypeId=@Id

					IF((SELECT COUNT(Id) FROM @SalaryElementType)>0)
					BEGIN						
						
						UPDATE CSE
							SET CSE.IsShowSalary=ST.IsShowSalary,
								CSE.IsShowPayslip=ST.IsShowPayslip,
								CSE.IsEdit=ST.IsEdit,
								CSE.IsDeleted=0,
								CSE.OrderNo=ST.OrderNo
						FROM dbo.Config_Salarytype_Element CSE
						INNER JOIN @SalaryElementType ST ON CSE.SalaryTypeId=@Id AND CSE.SalaryElementId=ST.Id

						INSERT INTO dbo.Config_Salarytype_Element
								( SalaryTypeId ,
								  SalaryElementId ,
								  IsShowSalary ,
								  IsShowPayslip ,
								  IsDeleted ,
								  IsEdit,
								  OrderNo
								)
						SELECT   @Id , -- SalaryTypeId - bigint
								  ST.Id , -- SalaryElementId - bigint
								  ST.IsShowSalary , -- IsShowSalary - bit
								  ST.IsShowPayslip , -- IsShowPayslip - bit
								  0 , -- IsDeleted - bit
								  ST.IsEdit,  -- IsEdit - bit
								  ST.OrderNo
						FROM  @SalaryElementType ST
						LEFT JOIN dbo.Config_Salarytype_Element CSE ON CSE.SalaryTypeId=@Id AND CSE.SalaryElementId=ST.Id
						WHERE ISNULL(CSE.Id,0)=0 
					END

					UPDATE dbo.Config_Salarytype_Mapper SET IsDeleted=1 WHERE SalarytypeId=@Id

					IF((SELECT COUNT(Id) FROM @ListSalarytypeMapper)>0)
					BEGIN						
							UPDATE CSM
								SET CSM.IsDeleted=0,
									CSM.UpdatedBy=@UpdatedBy,
									CSM.UpdatedDate=GETDATE()
							FROM dbo.Config_Salarytype_Mapper CSM
							INNER JOIN @ListSalarytypeMapper LSTM ON  CSM.TypeId=LSTM.TypeId AND CSM.DataId=LSTM.DataId
							WHERE CSM.SalarytypeId=@Id

							INSERT INTO dbo.Config_Salarytype_Mapper
									( SalarytypeId ,
									  TypeId ,
									  DataId ,
									  CreatedBy ,
									  CreatedDate,
									  IsDeleted
									)
							SELECT    @Id, -- SalarytypeId - bigint
									  LSTM.TypeId , -- TypeId - bigint
									  LSTM.DataId , -- DataId - bigint
									  @CreatedBy , -- CreatedBy - int
									  GETDATE() , -- CreatedDate - datetime
									  0  -- IsDeleted - bit
							 FROM  @ListSalarytypeMapper LSTM 
							 LEFT JOIN dbo.Config_Salarytype_Mapper CSM ON CSM.SalarytypeId=@Id AND CSM.TypeId=LSTM.TypeId AND CSM.DataId = LSTM.DataId
							 WHERE ISNULL(CSM.Id,0)=0
					END
				END
																	
			'
		SET @params =' @Id BIGINT,@Name	NVARCHAR(500),@StatusId	BIGINT,@Description	NVARCHAR(500),@IsAutoLock BIT,@DayLock BIGINT,@MaximumDay BIGINT,@CreatedBy	BIGINT
		,@UpdatedBy	BIGINT,@SalaryElementType SalaryElementType READONLY,@ListSalarytypeMapper SalarytypeMapperType READONLY'
		EXEC sp_executesql @ExeQuery,@params,@Id,@Name,@StatusId,@Description,@IsAutoLock,@DayLock,@MaximumDay,@CreatedBy,@UpdatedBy,@SalaryElementType,@ListSalarytypeMapper
	
END
