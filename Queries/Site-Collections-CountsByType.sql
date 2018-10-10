select 
  CASE
    WHEN RefreshType = 1 THEN 'Manual'
    WHEN RefreshType = 2 THEN 'Schedule'
    WHEN RefreshType = 4 THEN 'Incremental - no schedule'
    WHEN RefreshType = 6 THEN 'Incremental - with schedule'
    Else 'Unknown'
  End as 'Refresh Type (Text)',
  RefreshType,
  count(*) as Count 
from dbo.v_Collection 
group by RefreshType
order by RefreshType
