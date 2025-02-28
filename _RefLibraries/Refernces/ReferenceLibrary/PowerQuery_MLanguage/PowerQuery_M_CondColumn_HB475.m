------------------------------------------
-- Conditional Columns for the old HB475 Monstrosity that came from IT for New Dev Roll
------------------------------------------

      if [YearBuilt] = 2021 or [YearBuilt] = 2022 then
            if [TaxableValue] < 125000 then [TaxableValue] * 2
            else [TaxableValue] + 125000
        else if [YearBuilt] <= 2020 then
            if [TaxableValue] < 100000 then [TaxableValue] * 2
            else [TaxableValue] + 100000
        else null