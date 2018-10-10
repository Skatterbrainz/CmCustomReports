SELECT 
	v_Collection.CollectionID, 
	v_Collection.Name, 
	v_Collection.Comment, 
	v_Collection.LastChangeTime, 
	v_Collection.EvaluationStartTime, 
    v_Collection.LastRefreshTime, 
	v_Collection.RefreshType, 
	v_Collection.CollectionType, 
	v_Collection.CurrentStatus, 
	v_Collection.MemberCount, 
    v_Collection.MemberClassName, 
	v_Collection.LastMemberChangeTime, 
	v_Collection.CollID, 
	Collection_Rules_SQL.QueryKey, 
	Collection_Rules_SQL.WQL, 
    Collection_Rules_SQL.SQL
FROM 
	dbo.v_Collection INNER JOIN
	Collection_Rules_SQL ON v_Collection.CollID = Collection_Rules_SQL.CollectionID
ORDER BY
	Name 
