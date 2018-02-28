/****** Script for SelectTopNRows command from SSMS  ******/
 SELECT [Timestamp] as FuelDate
      ,IIF([Email address] = 'amithbhaskar.312@gmail.com', 'Amith' , 'Chaitra') as FilledBy
      ,MAX([Current KMS reading]) as KMSreading
      ,SUM([Amount Filled]) as FuelAmt
      ,MAX([Petrol price per litre]) as FuelPrice
      ,[Vehicle Name] as Vehicle
      ,[Reserve Indicator] as FuelIndicator
	  ,cast((SUM([Amount Filled])/MAX([Petrol price per litre]))as decimal(18,2)) as FuelinTank
	  --, as Mileage
  --INTO Activa
  FROM [Speedometer]  
  group by [Timestamp], [Vehicle Name],[Email address],[Reserve Indicator]
  having [Vehicle Name]='Suzuki GS150R'

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
  
