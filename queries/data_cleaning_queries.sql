SELECT 
	facility_id,
	name,
	address,
	city,
	state,
	LEFT(zip, 5) AS zip,
	rural_or_urban,
	ccn_facility_type,
	provider_type,
	type_of_control,
	TO_CHAR(total_costs, 'FM$999,999,999') AS total_costs,
	TO_CHAR(total_charges, 'FM$999,999,999') AS total_charges,
	ROUND(COALESCE(cost_to_charge_ratio, (total_costs/total_charges)), 4) AS cost_to_charge_ratio,
	ROUND(total_charges / total_costs * 100 - 100, 2) || '%' AS profit_margin
FROM finance;

SELECT *
FROM finance;