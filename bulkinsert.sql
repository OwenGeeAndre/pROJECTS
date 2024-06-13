drop table if exists #temptable20
create table #temptable20
(continent nvarchar(max),	location nvarchar(max),	[date] date,	population bigint
)


BULK INSERT #temptable20 
FROM 'C:\Users\FUJISU\Desktop\dATA aNALYTICS\mY vIDEOS\aLEX tHE aNALYST\Covid19 Project\CovidDeaths.csv'
WITH ( FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n',
		firstrow = 2
--		,batchsize = 1260
)


select *
from #temptable20