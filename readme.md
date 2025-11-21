# The Price of Premium: An Analysis of Hospital Markups and Quality

## Table of Contents
* [Motivation](#motivation)
* [Questions](#questions)
* [Normalizing the Data](#normaling-the-data)
* [Problems and Challenges](#problems-and-challenges)
* [Technologies Used](#technologies-used)
* [Sources](#sources)

## Motivation:
Healthcare spending accounts for nearly 20% of the U.S. GDP, yet hospitals vary widely in financial metrics and quality outcomes. Understanding how costs and charges align or fail to align with patient care quality is essential for policymakers, hospital administrators, and the public. This project allows me to bridge financial and operational data with quality outcomes, showcasing my ability to integrate complex datasets into actionable insights while exploring a topic of importance to health informatics and expanding on my background in public health research.

## Questions:
1) Are hospitals with higher costs, charges, and/or markups more likely to achieve lower readmission and mortality rates?
2) Are hospital size and type (critical access, rural vs. urban, etc) related to the costs and quality outcomes?
3) How do patient satisfaction scores relate to financial measures, hospital categories, and clinical quality metrics?

## Acquiring and Normalizing the Data
All datasets are from the Centers for Medicare and Medicaid Services. It required integration of multiple datasets and substantial data cleaning including formatting, labeling, data type conversions, and standardization. For example, some facilities were reporting less than annual numbers which needed to be extrapolated for comparison; to compare large and small hospitals, "per discharge" metrics and markup percentages were created. 

## Problems and Challenges 
- **Scope**: There was a great deal of data for a wide variety of healthcare facilities in the datasets. While some of the other details would be useful for future analysis, I concluded that in the interest of time and conciseness it was best for this project to specifically focus on inpatient and outpatient hospital facilities as well as costs, charges, and markups which center around patient care rather than other types of costs and revenue. 
- **SQL Database**: Creation of the database and importing the datasets to tables were timeconsuming. One of the original datasets had over 100 columns, and while I was able to pull a more relevant subset, there were many blank strings which had to be manually nulled and have their columns converted after import. 
- **Missing values**: For analysis, I began to impute missing quality values with group-wise medians after initial findings with an understanding of which qualitative categories affected these values. However, the main analyses were correlations and regressions, and as such, the findings would be particularly sensitive to bias of these relationships. With this in mind, I decided it was best to keep the missing quality values and exclude them from certain analyses. 

## Technologies Used
1) **SQL** - Data cleaning and integration
2) **Python** - Data labeling, analysis, statistical modeling, and visualization
3) **Powerpoint** - Slide deck to present findings, visualizations, and narrative
4) **Tableau** - Interactive dashboards to further visualize findings and allow exploration of details
5) **Git** - Version control 

## Data Sources

1) [CMS Patient Survey (HCAHPS)](https://data.cms.gov/provider-data/dataset/dgck-syfz): Patient Satisfaction.
2) [CMS Hospital Provider Cost Report](https://data.cms.gov/provider-compliance/cost-report/hospital-provider-cost-report): Financial performance.
3) [CMS Unplanned Hospital Visits](https://data.cms.gov/provider-data/dataset/632h-zaca): Readmissions.
4) [CMS Complications and Deaths - by Hospital](https://data.cms.gov/provider-data/dataset/ynj2-r877): Mortality.
5) CMS Medicare [Inpatient](https://data.cms.gov/provider-summary-by-type-of-service/medicare-inpatient-hospitals/medicare-inpatient-hospitals-by-provider) and [Outpatient](https://data.cms.gov/provider-summary-by-type-of-service/medicare-outpatient-hospitals/medicare-outpatient-hospitals-by-provider-and-service) Hospitals - by Provider: Hospital type and size details.
