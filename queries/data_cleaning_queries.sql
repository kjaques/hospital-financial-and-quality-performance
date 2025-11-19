WITH
	finance AS (
	--Cleaning and prepping finances table which contains all financial info.
	SELECT 
		RIGHT('00000' || CAST(facility_id AS VARCHAR(6)), 6)::varchar AS facility_id,--Maintain 6 digit format with 0 at the front where needed to match other tables for merging.
		name,
		address,
		city,
		state,
		LEFT(zip, 5) AS zip, --Standardized zip codes
		CASE --Spelled out labels.
			WHEN rural_or_urban = 'R' THEN 'Rural'
			WHEN rural_or_urban = 'U' THEN 'Urban'
			ELSE 'UNKNOWN' END AS rural_or_urban,
		CASE --Verbose facility type from abbreviations.
			WHEN ccn_facility_type = 'STH' THEN 'Short-term Hospitals'
			WHEN ccn_facility_type = 'ORD' THEN 'Reserved for hospitals participating in ORD demonstration project'
			WHEN ccn_facility_type = 'MCMC' THEN 'Multiple Hospital Component in a Medical Complex'
			WHEN ccn_facility_type = 'FQHC' THEN 'Federally Qualified Health Centers'
			WHEN ccn_facility_type = 'ADH' THEN 'Alcohol/Drug Hospitals'
			WHEN ccn_facility_type = 'MAF' THEN 'Medical Assistance Facilities'
			WHEN ccn_facility_type = 'CAH' THEN 'Critical Access Hospitals'
			WHEN ccn_facility_type = 'CCMHC' THEN 'Community Mental Health Centers'
			WHEN ccn_facility_type = 'HOS' THEN 'Hospices'
			WHEN ccn_facility_type = 'RNMHC' THEN 'Religious Non-medical Health Care Institutions'
			WHEN ccn_facility_type = 'LTCH' THEN 'Long-Term Care Hospitals'
			WHEN ccn_facility_type = 'HBRDF' THEN 'Hospital-based Renal Dialysis Facilities'
			WHEN ccn_facility_type = 'IDRF' THEN 'Independent Renal Dialysis Facilities'
			WHEN ccn_facility_type = 'ISPRDF' THEN 'Independent Special Purpose Renal Dialysis Facility'
			WHEN ccn_facility_type = 'FTH' THEN 'Formerly Tuberculosis Hospitals'
			WHEN ccn_facility_type = 'RH' THEN 'Rehabilitation Hospitals'
			WHEN ccn_facility_type = 'HHA' THEN 'Home Health Agencies'
			WHEN ccn_facility_type = 'CCORF' THEN 'Comprehensive Outpatient Rehabilitation Facilities'
			WHEN ccn_facility_type = 'CH' THEN 'Children’s Hospitals'
			WHEN ccn_facility_type = 'RHC' THEN 'Rural Health Clinics'
			WHEN ccn_facility_type = 'HBRDF' THEN 'Hospital-based Satellite Renal Dialysis Facilities'
			WHEN ccn_facility_type = 'HBSRDF' THEN 'Hospital-based Special Purpose Renal Dialysis Facility'
			WHEN ccn_facility_type = 'PH' THEN 'Psychiatric Hospitals'
			WHEN ccn_facility_type = 'CORF' THEN 'Comprehensive Outpatient Rehabilitation Facilities'
			WHEN ccn_facility_type = 'CMHC' THEN 'Community Mental Health Centers'
			WHEN ccn_facility_type = 'CCORF' THEN 'Comprehensive Outpatient Rehabilitation Facilities'
			WHEN ccn_facility_type = 'CCMHC' THEN 'Community Mental Health Centers'
			WHEN ccn_facility_type = 'SNF' THEN 'Skilled Nursing Facilities'
			WHEN ccn_facility_type = 'OPTS' THEN 'Outpatient Physical Therapy Services'
			WHEN ccn_facility_type = 'NR' THEN 'Numbers Reserved'
			WHEN ccn_facility_type = 'CHHA' THEN 'Home Health Agencies'
			WHEN ccn_facility_type = 'HHA' THEN 'Home Health Agencies'
			WHEN ccn_facility_type = 'TC' THEN 'Transplant Centers'
			WHEN ccn_facility_type = 'RFU' THEN 'Reserved for Future Use'
			ELSE 'UNKNOWN' END AS facility_type,
		CASE --Explicit provider type labels.
			WHEN provider_type = '1' THEN 'General Short Term'
			WHEN provider_type = '2' THEN 'General Long Term'
			WHEN provider_type = '3' THEN 'Cancer'
			WHEN provider_type = '4' THEN 'Psychiatric'
			WHEN provider_type = '5' THEN 'Rehabilitation'
			WHEN provider_type = '6' THEN 'Religious Non-Medical Health Care'
			WHEN provider_type = '7' THEN 'Children'
			WHEN provider_type = '8' THEN 'Reserved for Future Use'
			WHEN provider_type = '9' THEN 'Other'
			WHEN provider_type = '10' THEN 'Extended Neoplastic Disease Care'
			WHEN provider_type = '11' THEN 'Indian Health Services'
			WHEN provider_type = '12' THEN 'Rural Emergency Hospital'
			ELSE 'UNKNOWN' END AS provider_type,
		CASE --Explicit control/ownership label.
			WHEN type_of_control = '1' THEN 'Voluntary Non-Profit - Church'
			WHEN type_of_control = '2' THEN 'Voluntary Non-Profit - Other'
			WHEN type_of_control = '3' THEN 'Proprietary - Individual'
			WHEN type_of_control = '4' THEN 'Proprietary - Corporation'
			WHEN type_of_control = '5' THEN 'Proprietary - Partnership'
			WHEN type_of_control = '6' THEN 'Proprietary - Other'
			WHEN type_of_control = '7' THEN 'Governmental - Federal'
			WHEN type_of_control = '8' THEN 'Governmental - City/County'
			WHEN type_of_control = '9' THEN 'Governmental - County'
			WHEN type_of_control = '10' THEN 'Governmental - State'
			WHEN type_of_control = '11' THEN 'Governmental - Hospital District'
			WHEN type_of_control = '12' THEN 'Governmental - City'
			WHEN type_of_control = '13' THEN 'Governmental - Other'
			ELSE 'UNKNOWN' END AS type_of_control,
		ROUND(total_discharges_for_adults_and_peds / (fiscal_year_end - fiscal_year_begin) * 364, 2) AS total_discharges_for_adults_and_peds, --To extrapolate and standardize reporting of shorter than annual periods.
		ROUND(total_costs / (fiscal_year_end - fiscal_year_begin) * 364, 2) AS total_costs,--Costs for care.
		ROUND(total_charges / (fiscal_year_end - fiscal_year_begin) * 364, 2) AS total_charges,--Charges for care.
		ROUND(COALESCE(cost_to_charge_ratio, (total_costs/total_charges)), 4) AS cost_to_charge_ratio,--Some records didn't have the cost ratio despite having the necessary info. Calculated manually to impute where needed.
		ROUND((total_charges - total_costs) / total_costs * 100, 2) AS charge_pct,--Markup as a percentage of costs for standardization. 0 being at cost.
		ROUND(net_patient_revenue / (fiscal_year_end - fiscal_year_begin) * 364, 2) AS net_patient_revenue,
		ROUND(less_operating_expense / (fiscal_year_end - fiscal_year_begin) * 364, 2) AS total_operating_expense,--Total operating expenses.
		ROUND(net_income_from_service_to_patients / (fiscal_year_end - fiscal_year_begin) * 364, 2) AS net_income_from_service_to_patients,--Patient revenue minus total operating expenses.
		ROUND(net_income_from_service_to_patients / net_patient_revenue * 100, 2) AS service_margin, --Standardized measure as a percentage of revenue from patients after operating costs. Positive number is profit.
		ROUND(net_income / (fiscal_year_end - fiscal_year_begin) * 364, 2) AS net_income --Includes other revenue such as sales or fundraising. Also includes "other" expenses such as non-operating expenses, interest, taxes, and depreciation.
	FROM 
		financials
	WHERE 
		rural_or_urban != 'NA'
	ORDER BY
		facility_id
	),
	ruca AS (
	--RUCA Code details for rural/urban context.
		SELECT 
			facility_id, 
			CASE --Combined redundant labels.
				WHEN ruca_desc = 'Secondary flow 30% to <50% to a larger urbanized area of 50,000 and greater' THEN 'Secondary flow 30% to <50% to a urbanized area of 50,000 and greater' 
				ELSE NULLIF(ruca_desc,'') END AS ruca_desc
		FROM 
			inpatient_details
		UNION 
		SELECT 
			facility_id, 
			CASE --Combined redundant labels.
				WHEN ruca_desc = 'Secondary flow 30% to <50% to a larger urbanized area of 50,000 and greater' THEN 'Secondary flow 30% to <50% to a urbanized area of 50,000 and greater' 
				ELSE NULLIF(ruca_desc,'') END AS ruca_desc
		FROM 
			outpatient_details
		ORDER BY 
			facility_id
	),
	mortality AS (
	--Isolating mortality rates per facility.
	SELECT 
		facility_id,
		measure_id,
		measure_name,
		compared_to_national AS mortality_compared_to_national,
		CASE --Handle missing values and cast as numeric.
			WHEN denominator ~ '^(-)?[0-9]+(\.[0-9]+)?$' THEN denominator::numeric
			ELSE NULL END AS mortality_denominator,
		CASE --Handle missing values and cast as numeric.
			WHEN score ~ '^(-)?[0-9]+(\.[0-9]+)?$' THEN score::numeric
			ELSE NULL END AS mortality_score
	FROM 
		complications_and_deaths
	WHERE
		measure_id = 'Hybrid_HWM'--Standardized hospital-wide mortality metric for all causes.
	),
	readmission AS (
	--Isolating readmission rates per facility.
	SELECT 
		facility_id,
		measure_id,
		measure_name,
		compared_to_national AS readmissions_compared_to_national,
		CASE --Handle missing values and cast as numeric.
			WHEN denominator ~ '^(-)?[0-9]+(\.[0-9]+)?$' THEN denominator::numeric
			ELSE NULL END AS readmission_denominator,
		CASE --Handle missing values and cast as numeric.
			WHEN score ~ '^(-)?[0-9]+(\.[0-9]+)?$' THEN score::numeric
			ELSE NULL END AS readmission_score
	FROM 
		unplanned_visits
	WHERE
		measure_id = 'Hybrid_HWR'--Standardized hospital-wide readmission metric for all causes.
	),
	rating AS (
	--Isolating patient satisfaction survey category scores and response rate and pivoting to one row per facility id.
	SELECT
	    id,
	    CAST(NULLIF(MAX(CASE WHEN question = 'Nurse communication - linear mean score' THEN
	        CASE WHEN linear_mean_value ~ '^(-)?[0-9]+(\.[0-9]+)?$' THEN linear_mean_value ELSE NULL END END), 'Not Available') AS INTEGER) AS nurse_communication,
	    CAST(NULLIF(MAX(CASE WHEN question = 'Doctor communication - linear mean score' THEN
	        CASE WHEN linear_mean_value ~ '^(-)?[0-9]+(\.[0-9]+)?$' THEN linear_mean_value ELSE NULL END END), 'Not Available') AS INTEGER) AS doctor_communication,
	    CAST(NULLIF(MAX(CASE WHEN question = 'Staff responsiveness - linear mean score' THEN
	        CASE WHEN linear_mean_value ~ '^(-)?[0-9]+(\.[0-9]+)?$' THEN linear_mean_value ELSE NULL END END), 'Not Available') AS INTEGER) AS staff_responsiveness,
	    CAST(NULLIF(MAX(CASE WHEN question = 'Communication about medicines - linear mean score' THEN
	        CASE WHEN linear_mean_value ~ '^(-)?[0-9]+(\.[0-9]+)?$' THEN linear_mean_value ELSE NULL END END), 'Not Available') AS INTEGER) AS communication_about_medicines,
	    CAST(NULLIF(MAX(CASE WHEN question = 'Discharge information - linear mean score' THEN
	        CASE WHEN linear_mean_value ~ '^(-)?[0-9]+(\.[0-9]+)?$' THEN linear_mean_value ELSE NULL END END), 'Not Available') AS INTEGER) AS discharge_information,
	    CAST(NULLIF(MAX(CASE WHEN question = 'Care transition - linear mean score' THEN
	        CASE WHEN linear_mean_value ~ '^(-)?[0-9]+(\.[0-9]+)?$' THEN linear_mean_value ELSE NULL END END), 'Not Available') AS INTEGER) AS care_transition,
	    CAST(NULLIF(MAX(CASE WHEN question = 'Cleanliness - linear mean score' THEN
	        CASE WHEN linear_mean_value ~ '^(-)?[0-9]+(\.[0-9]+)?$' THEN linear_mean_value ELSE NULL END END), 'Not Available') AS INTEGER) AS cleanliness,
	    CAST(NULLIF(MAX(CASE WHEN question = 'Quietness - linear mean score' THEN
	        CASE WHEN linear_mean_value ~ '^(-)?[0-9]+(\.[0-9]+)?$' THEN linear_mean_value ELSE NULL END END), 'Not Available') AS INTEGER) AS quietness,
	    CAST(NULLIF(MAX(CASE WHEN question = 'Overall hospital rating - linear mean score' THEN
	        CASE WHEN linear_mean_value ~ '^(-)?[0-9]+(\.[0-9]+)?$' THEN linear_mean_value ELSE NULL END END), 'Not Available') AS INTEGER) AS overall_hospital_rating,
	    CAST(NULLIF(MAX(CASE WHEN question = 'Recommend hospital - linear mean score' THEN
	        CASE WHEN linear_mean_value ~ '^(-)?[0-9]+(\.[0-9]+)?$' THEN linear_mean_value ELSE NULL END END), 'Not Available') AS INTEGER) AS recommend_hospital,
		CASE WHEN response_rate_pct ~ '^(-)?[0-9]+(\.[0-9]+)?$' THEN response_rate_pct ELSE NULL END AS response_rate_pct
	FROM 
		satisfaction
	GROUP BY 
		id, 
		response_rate_pct
	)
SELECT 
	f.facility_id,
	f.name,
	f.address,
	f.city,
	f.state,
	f.zip,
	rural_or_urban,
	facility_type,
	provider_type,
	type_of_control,
	total_discharges_for_adults_and_peds,
	total_costs,
	ROUND(total_costs / total_discharges_for_adults_and_peds, 2) AS costs_per_discharge,
	total_charges,
	ROUND(total_charges / total_discharges_for_adults_and_peds, 2) AS charges_per_discharge,
	cost_to_charge_ratio,
	charge_pct,
	net_patient_revenue,
	ROUND(net_patient_revenue / total_discharges_for_adults_and_peds, 2) AS revenue_per_discharge,
	total_operating_expense,
	net_income_from_service_to_patients,
	ROUND(net_income_from_service_to_patients / total_discharges_for_adults_and_peds, 2) AS net_income_from_service_per_discharge,
	service_margin,
	net_income,
	RANK() OVER (ORDER BY net_income DESC NULLS LAST) AS highest_net_income_rank,
	ruca_desc,
	mortality_compared_to_national,
	mortality_denominator,
	mortality_score,
	readmissions_compared_to_national,
	readmission_denominator,
	readmission_score,
	nurse_communication,
	doctor_communication,
	staff_responsiveness,
	communication_about_medicines,
	discharge_information,
	care_transition,
	cleanliness,
	quietness,
	overall_hospital_rating,
	recommend_hospital,
	response_rate_pct
FROM 
	finance AS f
LEFT JOIN
	ruca AS r USING(facility_id)
INNER JOIN
	mortality AS m USING(facility_id)
LEFT JOIN
	readmission AS re USING(facility_id)
LEFT JOIN
	rating AS ra ON f.facility_id = ra.id;
