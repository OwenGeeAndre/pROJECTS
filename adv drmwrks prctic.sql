--select *
--from dimcurrency


--SELECT  title,count(title)
--FROM DimEmployee
--group by title
--order by count(title) desc

--SELECT englishcountryregionname,city, count(englishcountryregionname)
--FROM DimGeography	
--group by englishcountryregionname, city
--order by EnglishCountryRegionName

--select*
--from FactSalesQuota

--SELECT firstname + ' '+ lastname [Full Name], count(firstname + ' '+ lastname) Count,
--		avg(salesamountquota) [Avg Sales Quota], avg(datediff(year, HireDate, getdate())) [Years Employed]
--FROM DimEmployee A
--full outer join FactSalesQuota B
--on A.EmployeeKey = B.EmployeeKey

--where  SalesAmountQuota is not null 

--group by firstname + ' '+ lastname

select CustomerKey, firstname+' '+lastname [Full  Name], datediff(year, BirthDate,getdate()) as Age,
		YearlyIncome, City, EnglishOccupation, datepart(year, DateFirstPurchase) [First Purchase],
		CommuteDistance,
CASE 
	when datediff(year, BirthDate,getdate()) between 35 and 55 then 'Middle-Aged'
	when datediff(year, BirthDate,getdate()) between 56 and 75 then 'Advanced'
	when datediff(year, BirthDate,getdate()) > 75 then  'Aged'
	else 'young adult'
END as [age range]
from DimCustomer A
left outer join Dimgeography B
on  A.GeographyKey=B.GeographyKey
order by YearlyIncome

--select 
--		CustomerKey, [Full  Name], Age,
--		 [age range], YearlyIncome, City, EnglishOccupation, [First Purchase],
--		CommuteDistance
--from
--	(select CustomerKey, firstname+' '+lastname [Full  Name], datediff(year, BirthDate,getdate()) as Age,
--		 YearlyIncome, City, EnglishOccupation, datepart(year, DateFirstPurchase) [First Purchase],
--		CommuteDistance,
--CASE 
--	when datediff(year, BirthDate,getdate()) between 35 and 55 then 'Middle-Aged'
--	when datediff(year, BirthDate,getdate()) between 56 and 75 then 'Advanced'
--	when datediff(year, BirthDate,getdate()) > 75 then  'Aged'
--	else 'young adult'
--END as [age range]
--from DimCustomer A
--left outer join Dimgeography B
--on  A.GeographyKey=B.GeographyKey) as subquery
--order by [age range]



select *
from DimCustomer

select *
from DimGeography
