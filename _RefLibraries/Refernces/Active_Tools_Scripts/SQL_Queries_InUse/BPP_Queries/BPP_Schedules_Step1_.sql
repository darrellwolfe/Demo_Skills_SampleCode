				select 
				cast(str(left(mBegTaxYear,4)) + '00000' as int) as TaxYear
				, mUserId as ScheduleType
				, case when year(mBegEffDate) <> 1800 then ltrim(str(datepart(month,mChangeTimeStamp))) + '/' + ltrim(str(datepart(day,mChangeTimeStamp))) + '/' + ltrim(str(datepart(year,mChangeTimeStamp)))
					   when year(mBegEffDate) = 1800 then 'Schedule copied from prior year' else '' end as DateRun
				, (select max(mChangeTimeStamp) from tppValSched tvs2 where tvs2.mEndTaxYear = tvs.mEndTaxYear) as LastDateScheduleModified
				from tppValSched tvs
				where mName = '00'
				order by 1