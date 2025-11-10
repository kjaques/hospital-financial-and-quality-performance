SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'financials';

--When importing the CSVs, the empty cells were seen as empty strings and had to be imported as varchar data type. This updates the table to make these cells actual nulls to simplify later queries.  
UPDATE financials
SET fte_employees = NULLIF(fte_employees, ''),
	interns_and_residents = NULLIF(interns_and_residents, ''),
	total_days = NULLIF(total_days, ''),
	total_discharges = NULLIF(total_discharges, ''),
	number_of_beds = NULLIF(number_of_beds, ''),
	total_days_for_adults_and_peds = NULLIF(total_days_for_adults_and_peds, ''),
	total_bed_days_available_for_adults_and_peds = NULLIF(total_bed_days_available_for_adults_and_peds, ''),
	total_discharges_for_adults_and_peds = NULLIF(total_discharges_for_adults_and_peds, ''),
	overhead_nonsal_costs = NULLIF(overhead_nonsal_costs, ''),
	total_costs = NULLIF(total_costs, ''),
	total_charges = NULLIF(total_charges, ''),
	total_salaries = NULLIF(total_salaries, ''),
	total_patient_revenue = NULLIF(total_patient_revenue, ''),
	net_patient_revenue = NULLIF(net_patient_revenue, ''),
	less_operating_expense = NULLIF(less_operating_expense, ''),
	net_income_from_service_to_patients = NULLIF(net_income_from_service_to_patients, ''),
	total_income = NULLIF(total_income, ''),
	net_income = NULLIF(net_income, ''),
	cost_to_charge_ratio = NULLIF(cost_to_charge_ratio, '');

--This updates the appropriate columns from varchar to numeric for calculations to simplify later queries.
ALTER TABLE financials
	ALTER COLUMN fte_employees TYPE numeric USING fte_employees::numeric,
	ALTER COLUMN interns_and_residents TYPE numeric USING interns_and_residents::numeric,
	ALTER COLUMN total_days TYPE numeric USING total_days::numeric,
	ALTER COLUMN total_discharges TYPE numeric USING total_discharges::numeric,
	ALTER COLUMN number_of_beds TYPE numeric USING number_of_beds::numeric,
	ALTER COLUMN total_days_for_adults_and_peds TYPE numeric USING total_days_for_adults_and_peds::numeric,
	ALTER COLUMN total_bed_days_available_for_adults_and_peds TYPE numeric USING total_bed_days_available_for_adults_and_peds::numeric,
	ALTER COLUMN total_discharges_for_adults_and_peds TYPE numeric USING total_discharges_for_adults_and_peds::numeric,
	ALTER COLUMN overhead_nonsal_costs TYPE numeric USING overhead_nonsal_costs::numeric,
	ALTER COLUMN total_costs TYPE numeric USING total_costs::numeric,
	ALTER COLUMN total_charges TYPE numeric USING total_charges::numeric,
	ALTER COLUMN total_salaries TYPE numeric USING total_salaries::numeric,
	ALTER COLUMN total_patient_revenue TYPE numeric USING total_patient_revenue::numeric,
	ALTER COLUMN net_patient_revenue TYPE numeric USING net_patient_revenue::numeric,
	ALTER COLUMN less_operating_expense TYPE numeric USING less_operating_expense::numeric,
	ALTER COLUMN net_income_from_service_to_patients TYPE numeric USING net_income_from_service_to_patients::numeric,
	ALTER COLUMN total_income TYPE numeric USING total_income::numeric,
	ALTER COLUMN net_income TYPE numeric USING net_income::numeric,
	ALTER COLUMN cost_to_charge_ratio TYPE numeric USING cost_to_charge_ratio::numeric;