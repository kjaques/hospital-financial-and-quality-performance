
--Cleaning and prepping finance table which contains all financial info.
SELECT 
	facility_id,
	name,
	address,
	city,
	state,
	LEFT(zip, 5) AS zip, --Standardized zip codes
	CASE --Spelled out labels.
		WHEN rural_or_urban = 'R' THEN 'Rural'
		WHEN rural_or_urban = 'U' THEN 'Urban'
		ELSE 'Unknown' END AS rural_or_urban,
	CASE --Verbose facility from abbreviations.
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
	total_costs::money,
	total_charges::money,
	ROUND(COALESCE(cost_to_charge_ratio, (total_costs/total_charges)), 4) AS cost_to_charge_ratio, --Some records didn't have the cost ratio despite having the necessary info. Calculated manually where needed.
	ROUND(total_charges / total_costs * 100, 2) AS charge_pct, 
	net_income::money,
	ROUND(net_income_from_service_to_patients / net_patient_revenue * 100, 2) AS service_margin
FROM 
	finance AS f
WHERE 
	rural_or_urban != 'NA'
ORDER BY
	net_income DESC;


--RUCA Code details for rural/urban context.
WITH details AS (
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
)
SELECT DISTINCT ruca_desc
FROM details
ORDER BY ruca_desc;


--Isolating mortality rates per facility.
SELECT 
	facility_id,
	measure_id,
	measure_name,
	compared_to_national,
	CASE --Handle missing values and cast as numeric.
		WHEN denominator ~ '^(-)?[0-9]+(\.[0-9]+)?$' THEN denominator::numeric
		ELSE NULL END AS denominator,
	CASE --Handle missing values and cast as numeric.
		WHEN score ~ '^(-)?[0-9]+(\.[0-9]+)?$' THEN score::numeric
		ELSE NULL END AS score
FROM 
	complications_and_deaths
WHERE
	measure_id = 'Hybrid_HWM';


--Isolating readmission rates per facility.
SELECT 
	facility_id,
	measure_id,
	measure_name,
	compared_to_national,
	CASE --Handle missing values and cast as numeric.
		WHEN denominator ~ '^(-)?[0-9]+(\.[0-9]+)?$' THEN denominator::numeric
		ELSE NULL END AS denominator,
	CASE --Handle missing values and cast as numeric.
		WHEN score ~ '^(-)?[0-9]+(\.[0-9]+)?$' THEN score::numeric
		ELSE NULL END AS score,
	CASE --Handle missing values and cast as numeric.
		WHEN number_of_patients ~ '^(-)?[0-9]+(\.[0-9]+)?$' THEN number_of_patients::numeric
		ELSE NULL END AS number_of_patients,
	CASE --Handle missing values and cast as numeric.
		WHEN number_of_patients_returned ~ '^(-)?[0-9]+(\.[0-9]+)?$' THEN number_of_patients_returned::numeric
		ELSE NULL END AS number_of_patients_returned
FROM 
	unplanned_visits
WHERE
	measure_id = 'Hybrid_HWR';


--Isolating patient satisfaction survey category scores and response rate and pivoting to one row per id.
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
	response_rate_pct;