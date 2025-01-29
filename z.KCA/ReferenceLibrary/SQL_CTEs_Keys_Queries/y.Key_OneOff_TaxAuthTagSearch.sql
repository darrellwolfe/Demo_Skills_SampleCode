/*
This was a special search for a particular set of tags
*/

WITH CTE_TagCounts (TAG, TagCounter) AS (
Select 
LTRIM(RTRIM(TagDescr)),
COUNT(LTRIM(RTRIM(TagDescr))) AS [CountOfTag]
From KCv_AumentumEasy_TagTaxAuthorities
Group By TagDescr
)

Select 
LTRIM(RTRIM(TagDescr)) AS [TAGs],
tc.TagCounter,
TaxAuthorityId,
TaxAuthorityDescr
From KCv_AumentumEasy_TagTaxAuthorities AS tta
Join CTE_TagCounts AS tc ON tta.TagDescr=tc.TAG
Where tc.TagCounter=10
And (TaxAuthorityId ='1'
OR TaxAuthorityId ='227'
OR TaxAuthorityId ='1032'
OR TaxAuthorityId ='1034'
OR TaxAuthorityId ='1118'
OR TaxAuthorityId ='254'
OR TaxAuthorityId ='271'
OR TaxAuthorityId ='272'
OR TaxAuthorityId ='351'
OR TaxAuthorityId ='354')



