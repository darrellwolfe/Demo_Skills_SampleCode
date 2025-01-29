--Queries and scripts I used to find and remove the Virtual Allocations
--08/03/2010 RAS
--Copy this file into SQL Management Studio and run each step separately.

--Step 1. Find the reconciliation records with virtual allocations
select * from reconciliation where status = 'W' and method not in ('O','R') and lrsn in 
	(select lrsn from allocations where improvement_id = 'B' and status = 'A')

--COPY the list of lrsns to an input.txt file to use later 

--Step 2. Update the recon table to 'uncheck' the Override Land option from Correlation of Value screen for the above records
update  reconciliation  set  recon_override_land = 1 where status = 'W' and method not in ('O','R') 
	and lrsn in (select lrsn from allocations where improvement_id = 'B' and status = 'A')

--Step 3. Find the records in allocations that have Virtual allocations
select * from allocations where improvement_id = 'B' and status = 'A'

--Step 4. Delete the Virtual allocation records from the allocations table
delete from allocations where improvement_id = 'B' and status = 'A'


--Step 5. Final step is to batch price using the input file you created above after Step 1

--Step 6. Run the query from Step 3 above to verify all Virtual Allocations have been deleted and stayed deleted after pricing.