select CustomerKey,FullName,[Age Range],[Salary Range],[Distance Range],City,Province, Country, [Years Patronized]
from
(select CustomerKey, FirstName+' '+LastName FullName, datediff(year, BirthDate, getdate()) AGE,
		YearlyIncome, TotalChildren, datediff(year, DateFirstPurchase, getdate()) [Years Patronized],
		CommuteDistance Distance, B.GeographyKey as code, city, StateProvinceName Province, EnglishCountryRegionName Country,
CASE
		when datediff(year, BirthDate, getdate()) > 100 then 'aged'
		when datediff(year, BirthDate, getdate()) > 70 then 'old'
		when datediff(year, BirthDate, getdate()) > 50 then 'elderly'
		else  'middle age'
end [Age Range],
CASE
		when Yearlyincome > 150000 then 'wealthy'
		when Yearlyincome > 100000 then 'high-income earner'
		when Yearlyincome > 50000 then 'average earner'
		else  'low-income earner'
end [Salary Range],
CASE
		when CommuteDistance = '10+ Miles' then 'Very Far'
		when CommuteDistance = '5-10 Miles' then 'Far'
		when CommuteDistance = '2-5 Miles' then 'A Bit Far'
		when CommuteDistance = '1-2 Miles' then 'Close By'
		else  'Arounnd the Block'
end [Distance Range]
from DimCustomer A
full outer join DimGeography B
on A.GeographyKey=B.GeographyKey
where customerkey is not null) subquery
order by [Years Patronized] desc

select *
from DimCustomer
select *
from DimGeography

