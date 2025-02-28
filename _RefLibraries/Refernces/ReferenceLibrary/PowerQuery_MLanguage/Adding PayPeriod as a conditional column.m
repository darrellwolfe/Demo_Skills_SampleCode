let
    Source = Excel.CurrentWorkbook(){[Name="Table1"]}[Content],
    #"Changed Type" = Table.TransformColumnTypes(
        Source,
        {
            {"Date", type date},
            {"Date Long", type date},
            {"Time Start", type time},
            {"Time Stop", type time},
            {"Time Start2", type time},
            {"Time Stop2", type time},
            {"Time Start3", type time},
            {"Time Stop3", type time},
            {"Total Time", type number},
            {"Over/Under", type number},
            {"Type Used", type text},
            {"Notes", type text}
        }
    ),
    #"Added Custom" = Table.AddColumn(
        #"Changed Type",
        "PayPeriod",
        each let
            StartDate = #date(2024, 3, 24),
            PeriodLength = 14,
            DaysSinceStart = Duration.Days([Date] - StartDate),
            PeriodNumber = Number.RoundUp((DaysSinceStart + 1) / PeriodLength)
        in
            PeriodNumber
    )
in
    #"Added Custom"
