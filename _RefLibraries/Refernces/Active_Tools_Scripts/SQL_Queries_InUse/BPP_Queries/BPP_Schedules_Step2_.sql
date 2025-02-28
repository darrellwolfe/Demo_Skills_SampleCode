DECLARE @CurrentDate DATE = GETDATE();

DECLARE @CurrentYear INT = YEAR(GETDATE());

DECLARE @Year INT;

--Change this to choose which day in January the program begins reading rolled over assets.
-- This checks if today's date is after January 15 of the current year
IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 10) --01/01/20xx
--IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 15) --01/01/20xx
--IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 31) --01/01/20xx

    SET @Year = @CurrentYear; -- After January 15, set @Year to the current year
ELSE
    SET @Year = @CurrentYear - 1; -- Before or on January 15, set @Year to the previous year


Declare @TaxYear int = @Year;


WITH 

	CTECountySpecificSchedules (EndTaxYear, ScheduleId, MaxAge)
	as
	(select distinct
	  mEndTaxYear as BegTaxYear
	 ,mScheduleId as ScheduleId
	 ,(select max(mAge) from tppValSchedDetail tvsd where tvsd.mScheduleId = t.mScheduleId and tvsd.mEndTaxYear = t.mEndTaxYear) as MaxAge
	 from tppValSched t
	 where mUserId not like 'TSB%'
	 and mEndTaxYear = (select max(mEndTaxYear) from tppValSched tsub where tsub.mScheduleId = t.mscheduleId)
	 and left(cast(mEndTaxYear as char),4) = @TaxYear
	 )
,

	CTECounters (Counters)
	as
	(select 1 union
	 select 2 union
	 select 3 union
	 select 4 union
	 select 5 union
	 select 6 union
	 select 7 union
	 select 8 union
	 select 9 union
	 select 10 union
	 select 11 union
	 select 12 union
	 select 13 union
	 select 14 union
	 select 15 union
	 select 16 union
	 select 17 union
	 select 18 union
	 select 19 union
	 select 20 union
	 select 21 union
	 select 22 union
	 select 23 union
	 select 24 union
	 select 25 union
	 select 26 union
	 select 27 union
	 select 28 union
	 select 29 union
	 select 30 
	 )
	 --select * from CTECountySpecificSchedules
	 --select * from CTECounters

	select vsd.*, mAge as Counters, vs.mName as Name
	from tppValSchedDetail vsd
	inner join tppValSched vs
	on vs.mScheduleId = vsd.mScheduleId
	and vs.mEndTaxYear = vsd.mEndTaxYear  
	where left(cast(vsd.mEndTaxYear as char),4) = @TaxYear
	union
	select t.mId, t.mBegTaxYear, t.mEndTaxYear, t.mBegEffDate, t.mEndEffDate, t.mEffStatus, t.mChangeTimeStamp, 'command' as mUserId, t.mScheduleId, 0 as mAge, mMult = 0, mTrend = 0, mPcntGood = 0, 
	Counters = cte2.Counters, vs.mName as Name
	from CTECounters cte2
	left outer join tppValSchedDetail t 
	on cte2.counters > t.mAge
	left outer join tppValSched vs
	on vs.mScheduleId = t.mScheduleId
	and vs.mEndTaxYear = t.mEndTaxYear
	where t.mScheduleId in (select cte1.ScheduleId from CTECountySpecificSchedules cte1 where cte1.MaxAge < 30) 
	and cte2.Counters > (select cte1.MaxAge from CTECountySpecificSchedules cte1 where cte1.ScheduleId = t.mScheduleId )
	and left(cast(t.mEndTaxYear as char),4) = @TaxYear
	order by 15,9,2,14