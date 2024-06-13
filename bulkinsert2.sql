drop table if exists #trialyoutube
create table #trialyoutube
(rank int,
Youtuber	nvarchar(max),
subscribers	int null,
[video views]	float null,
category	nvarchar(max),
Title	nvarchar(max),
uploads	int null,
Country	nvarchar(max),
Abbreviation	nvarchar(max),
channel_type	nvarchar(max),
video_views_rank	int null,
country_rank	int null,
channel_type_rank	int null,
video_views_for_the_last_30_days	bigint null,
created_year	int null,
created_month	nvarchar(max),
created_date int)


bulk insert #trialyoutube
from 'C:\Users\FUJISU\Desktop\dATA aNALYTICS\pROJECTS tO bE dONE\Youtube\Global_YouTube_Statistics_Content2.csv'
WITH ( FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n',
		firstrow = 2
--		,batchsize = 1260
)




