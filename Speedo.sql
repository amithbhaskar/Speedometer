

Tasks to Do:
1. Data Flow Document
	PetrolLog.csv is loaded to STG_FCT_Raw_Data_Log Table with an entry to STG_Batch_Extraction_Details.
	*ServiceLog.csv is loaded to STG_FCT_Service_Log Table with an entry to STG_Batch_Extraction_Details.
	Data quality and Transformations are performed on STG_FCT_Raw_Data_Log Table & STG_FCT_Service_Log.
		- Spaces are removed.
		- Datetime of Rows loaded into STG tables are captured.
		- Datatypes are established.
	Power BI connects to DB and provides UI.
	
2. Mapping Document

- Source Files
	PetrolLog.csv
	ServiceLog.csv
	
- Staging Layer
	STG_FCT_Raw_Data_Log
	*STG_FCT_Service_Log
	STG_Batch_Extraction_Details --exec sp_rename 'Batch_Details', 'STG_Batch_Extraction_Details'
	STG_FCT_Vehicle_GS150R
	STG_FCT_Vehicle_Activa
	STG_FCT_Vehicle_Jupiter

- EDW Layer: With calculated Averages 
	T_DIM_Vehicle
	T_DIM_Date
	T_DIM_Temperature
	T_FCT_MIL_GS150R
	T_FCT_MIL_Activa
	T_FCT_MIL_Jupiter

- Reports
	prev_Petrol_Date	
	Latest_Mileage	
	total_Petrol_Amt	
	kms_to_Drive	
	Avg_mileage	
	last_5_mileages	
	Service_Dates	
	Next_Service_Date	
	Days_Left_Service	
	Total_Kms
	
select * from STG_FCT_Raw_Data_Log;
select * from Batch_Details;
select * from STG_FCT_Vehicle_GS150R;
select * from STG_FCT_Vehicle_Activa;
select * from STG_FCT_Vehicle_Jupiter;



	
CREATE TABLE Batch_Details(
  Batch_ID INTEGER,
  Loaded_Until DATE,
  Status VARCHAR(50),
  Number_of_Rows INTEGER,
  Run_Date DATE
  )
  
 create table STG_FCT_Vehicle_GS150R(
  FuelTrans_ID VARCHAR(50),
  FuelDate DATE,
  FilledBy VARCHAR(50),
  KMSreading INTEGER,
  FuelAmt INTEGER,
  FuelPrice NUMERIC(19,3),
  Vehicle VARCHAR(50),
  FuelIndicator VARCHAR(50),
  FuelinTank NUMERIC(19,3),
  CREATD_DTTM datetime not null default CURRENT_TIMESTAMP
  );

 create table STG_FCT_Vehicle_Activa(
  FuelTrans_ID VARCHAR(50),
  FuelDate DATE,
  FilledBy VARCHAR(50),
  KMSreading INTEGER,
  FuelAmt INTEGER,
  FuelPrice NUMERIC(19,3),
  Vehicle VARCHAR(50),
  FuelIndicator VARCHAR(50),
  FuelinTank NUMERIC(19,3),
  CREATD_DTTM datetime not null default CURRENT_TIMESTAMP
  );

  create table STG_FCT_Vehicle_Jupiter(
  FuelTrans_ID VARCHAR(50),
  FuelDate DATE,
  FilledBy VARCHAR(50),
  KMSreading INTEGER,
  FuelAmt INTEGER,
  FuelPrice NUMERIC(19,3),
  Vehicle VARCHAR(50),
  FuelIndicator VARCHAR(50),
  FuelinTank NUMERIC(19,3),
  CREATD_DTTM datetime not null default CURRENT_TIMESTAMP
  );


BULK INSERT STG_FCT_Raw_Data_Log
FROM 'C:\Users\Chaitra Amith\Desktop\Petrol Log - RawData.csv'
WITH
(
FIRSTROW = 2,
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'

)
GO


CREATE SEQUENCE [DBO].BatchIdGen AS INT
 START WITH 1
 INCREMENT BY 1
GO

INSERT INTO [dbo].[Batch_Details]
           ([Batch_ID]
           ,[Loaded_Until]
           ,[Status]
           ,[Number_of_Rows]
           ,[Run_Date])
     VALUES
           (NEXT VALUE FOR DBO.BatchIdGen
           ,(select max(CONVERT(date,SUBSTRING([Timestamp],1,10),103)) from dbo.STG_FCT_Raw_Data_Log)
           ,'Success'
           ,(Select count(*) from dbo.STG_FCT_Raw_Data_Log)
           ,GETDATE()
		   )
GO

CREATE SEQUENCE [DBO].FuelTransIdGen_GS150R AS INT
 START WITH 1
 INCREMENT BY 1
GO

ALTER SEQUENCE [DBO].FuelTransIdGen_GS150R
Restart with 1
GO 

INSERT INTO [dbo].[STG_FCT_Vehicle_GS150R]
           ([FuelTrans_ID]
           ,[FuelDate]
           ,[FilledBy]
           ,[KMSreading]
           ,[FuelAmt]
           ,[FuelPrice]
           ,[Vehicle]
           ,[FuelIndicator]
           ,[FuelinTank]
		   ,[CREATD_DTTM])
     SELECT 
		   NEXT VALUE FOR FuelTransIdGen_GS150R  as [FuelTrans_ID]
           ,CONVERT(date,SUBSTRING([Timestamp],1,10),103)
           ,IIF([Email address] = 'amithbhaskar.312@gmail.com', 'Amith' , 'Chaitra') as FilledBy
		   ,MAX(REPLACE([Current KMS reading],' ','')) as KMSreading
		   ,SUM(CAST(REPLACE([Amount Filled],' ','') as int)) as FuelAmt
		   ,MAX(Cast(REPLACE([Petrol price per litre],' ','') as decimal(18,2))) as FuelPrice
		   ,[Vehicle Name] as Vehicle
		   ,[Reserve Indicator] as FuelIndicator
		   ,cast((SUM(CAST([Amount Filled] as INT))/MAX(CAST(REPLACE([Petrol price per litre],' ','') as decimal(18,2))))as decimal(18,2)) as FuelinTank
  FROM dbo.STG_FCT_Raw_Data_Log
  group by [Timestamp], [Vehicle Name],[Email address],[Reserve Indicator]
  having [Vehicle Name]='Suzuki GS150R'
GO


CREATE SEQUENCE [DBO].FuelTransIdGen_Jupiter AS INT
 START WITH 1
 INCREMENT BY 1
GO

ALTER SEQUENCE [DBO].FuelTransIdGen_Jupiter
Restart with 1
GO 

  INSERT INTO [dbo].[STG_FCT_Vehicle_Jupiter]
           ([FuelTrans_ID]
           ,[FuelDate]
           ,[FilledBy]
           ,[KMSreading]
           ,[FuelAmt]
           ,[FuelPrice]
           ,[Vehicle]
           ,[FuelIndicator]
           ,[FuelinTank])
     SELECT 
		   NEXT VALUE FOR FuelTransIdGen_Jupiter  as [FuelTrans_ID]
           ,CONVERT(date,SUBSTRING([Timestamp],1,10),103)
           ,IIF([Email address] = 'amithbhaskar.312@gmail.com', 'Amith' , 'Chandra') as FilledBy
		   ,MAX(REPLACE([Current KMS reading],' ','')) as KMSreading
		   ,SUM(CAST(REPLACE([Amount Filled],' ','') as int)) as FuelAmt
		   ,MAX(Cast(REPLACE([Petrol price per litre],' ','') as decimal(18,2))) as FuelPrice
		   ,[Vehicle Name] as Vehicle
		   ,[Reserve Indicator] as FuelIndicator
		   ,cast((SUM(CAST([Amount Filled] as INT))/MAX(CAST(REPLACE([Petrol price per litre],' ','') as decimal(18,2))))as decimal(18,2)) as FuelinTank
  FROM dbo.STG_FCT_Raw_Data_Log
  group by [Timestamp], [Vehicle Name],[Email address],[Reserve Indicator]
  having [Vehicle Name]='Jupiter'
GO


CREATE SEQUENCE [DBO].FuelTransIdGen_Activa AS INT
 START WITH 1
 INCREMENT BY 1
GO

ALTER SEQUENCE [DBO].FuelTransIdGen_Activa
Restart with 1
GO 

  INSERT INTO [dbo].[STG_FCT_Vehicle_Activa]
           ([FuelTrans_ID]
           ,[FuelDate]
           ,[FilledBy]
           ,[KMSreading]
           ,[FuelAmt]
           ,[FuelPrice]
           ,[Vehicle]
           ,[FuelIndicator]
           ,[FuelinTank])
     SELECT 
		   NEXT VALUE FOR FuelTransIdGen_Activa  as [FuelTrans_ID]
           ,CONVERT(date,SUBSTRING([Timestamp],1,10),103)
           ,IIF([Email address] = 'amithbhaskar.312@gmail.com', 'Amith' , 'Chaitra') as FilledBy
		   ,MAX(REPLACE([Current KMS reading],' ','')) as KMSreading
		   ,SUM(CAST(REPLACE([Amount Filled],' ','') as int)) as FuelAmt
		   ,MAX(Cast(REPLACE([Petrol price per litre],' ','') as decimal(18,2))) as FuelPrice
		   ,[Vehicle Name] as Vehicle
		   ,[Reserve Indicator] as FuelIndicator
		   ,cast((SUM(CAST([Amount Filled] as INT))/MAX(CAST(REPLACE([Petrol price per litre],' ','') as decimal(18,2))))as decimal(18,2)) as FuelinTank
  FROM dbo.STG_FCT_Raw_Data_Log
  group by [Timestamp], [Vehicle Name],[Email address],[Reserve Indicator]
  having [Vehicle Name]='Activa'
GO


--DQ check date
with cte as (
select fueldate,KMSreading,lag(KMSreading) over (order by FuelDate) as lag,
		case when KMSreading<(lag(KMSreading) over (order by FuelDate)) then 1 else 0 end as grp
from STG_FCT_Vehicle_GS150R
) select * from cte where cte.grp=1
GO-- fix for date = 2018-01-25





select max(fueldate) as FuelDate, 
	   max(FilledBy) as FilledBy, 
	   max(KMSreading) as KMSreading,
	   sum(FuelAmt) as FuelAmt, 
	   max(FuelPrice) as FuelPrice,
	   cast((SUM(FuelAmt)/MAX(FuelPrice))as decimal(18,2)) as FuelinTank,
	   cast(((ISNULL((KMSreading-(lag(KMSreading) over (order by FuelDate))),0))/FuelinTank)as decimal(18,2)) as Mileage
	  --into SuzukiGS150R
from (select *, sum(case when fuelindicator = 'Reserve' then 1 else 0 end) 
			  over (partition by vehicle order by fueldate desc) as grp 
	  from STG_FCT_Vehicle_GS150R ) GS150R
group by grp
order by fueldate;



















  --Delete duplicate rows using Common Table Expression(CTE)
  With CTE_Duplicates as
   (select KMSreading, row_number() over(partition by KMSreading order by KMSreading ) rownumber 
   from GS150R  )
   delete from CTE_Duplicates where rownumber!=1

	--Sum of NonReserve to Reserve
	 select max(fueldate) as FuelDate, 
			max(FilledBy) as FilledBy, 
			max(KMSreading) as KMSreading,
			sum(FuelAmt) as FuelAmt, 
			max(FuelPrice) as FuelPrice, 
			Vehicle, 
			'Reserve' as FuelFillIndicator,
			GS150R.grp as SumOnReserve
			,cast((SUM(FuelAmt)/MAX(FuelPrice))as decimal(18,2)) as FuelinTank
	  into SuzukiGS150R
	  from (select GS150R.*,
             sum(case when fuelindicator = 'Reserve' then 1 else 0 end) over (partition by vehicle order by fueldate desc) as grp 
			 from GS150R
	  ) GS150R
	  group by grp, Vehicle
	  order by fueldate;

-- Final Table with Mileage
select * from SuzukiGS150R

With tblDifference as
(	Select Row_Number() OVER (Order by FuelDate) as RowNumber,* from  SuzukiGS150R	)
Select Cur.FuelDate
	 , Cur.KMSreading
	 , Cur.FuelPrice
	 , Cur.FuelAmt
	 , Cur.FuelinTank
	 , ISNULL((Cur.KMSreading-Prv.KMSreading),Cur.KMSreading) as KMSdriven
	 , cast(((ISNULL((Cur.KMSreading-Prv.KMSreading),Cur.KMSreading))/Cur.FuelinTank)as decimal(18,2)) as Mileage
from tblDifference Cur 
Left Outer Join tblDifference Prv 
On Cur.RowNumber=Prv.RowNumber+1

--Mileage View Creation
CREATE VIEW MileageGS150R AS
With tblDifference as
(	Select Row_Number() OVER (Order by FuelDate) as RowNumber,* from  SuzukiGS150R	)
Select Cur.FuelDate
	 , Cur.KMSreading
	 , Cur.FuelPrice
	 , Cur.FuelAmt
	 , Cur.FuelinTank
	 , ISNULL((Cur.KMSreading-Prv.KMSreading),Cur.KMSreading) as KMSdriven
	 , cast(((ISNULL((Cur.KMSreading-Prv.KMSreading),Cur.KMSreading))/Cur.FuelinTank)as decimal(18,2)) as Mileage
from tblDifference Cur 
Left Outer Join tblDifference Prv 
On Cur.RowNumber=Prv.RowNumber+1

SELECT [FuelDate]
      ,[KMSreading]
      ,[FuelPrice]
      ,[FuelAmt]
      ,[FuelinTank]
      ,[KMSdriven]
      ,[Mileage]
  FROM [dbo].[MileageGS150R]
  
--Predicted values
SELECT top 1 [FuelDate] as LastFuelledDate
      ,[KMSreading] as KMStillNow
      ,[FuelPrice] as PrevFuelPrice
      ,[FuelAmt] as LastFilledAmt
      ,[FuelinTank] 
      ,[KMSdriven] as PredKMS
      ,[Mileage] as PrevMileage
  FROM [dbo].[MileageGS150R]
  order by FuelDate desc
  
--Recent 5 values
SELECT top 5 [FuelDate] as LastFuelledDate
      ,[KMSreading] as KMStillNow
      ,[FuelPrice] as PrevFuelPrice
      ,[Mileage] as PrevMileage
  FROM [dbo].[MileageGS150R]
  order by FuelDate desc

--Monthly Avg mileage
SELECT MONTH([FuelDate]) as MonthNum
	  ,AVG([Mileage]) as AvgMileage
  FROM [dbo].[MileageGS150R]
  group by MONTH([FuelDate])
  
