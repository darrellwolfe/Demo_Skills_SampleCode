
/*
AsTxDBProd
GRM_Main

LTRIM(RTRIM())
*/


--ValueType vs ValueTypes MERGED


Select
ValType,
ValueChar,
ValDesc

From ValueTypes

UNION

Select
Id AS [ValType],
ShortDescr AS [ValueChar],
Descr AS [ValDesc]

From ValueType

Order By
ValType;






--ValueType vs ValueTypes

Select
Id,
ShortDescr,
Descr

From ValueType

Order By
Id;


--ValueType vs ValueTypes

Select
ValType,
ValueChar,
ValDesc

From ValueTypes

Order By
ValType;

