# sdg-education-employment-analytics

📘 SDG Education & Youth Employment Analytics Dashboard A full end‑to‑end data engineering and analytics project exploring global progress on SDG 4 (Quality Education) and SDG 8 (Youth Employment) using official UN datasets. The project integrates SQL Server, Power BI, and advanced DAX modeling to deliver a multi‑page interactive dashboard that reveals global trends, disparities, and 2030 target projections.

🌍 Project Summary This project transforms raw UN SDG data into a clean analytical model and visual narrative. It covers:

Data extraction from the UN SDG Data Portal
SQL‑based data cleaning, standardization, and star schema modeling
Power BI data modeling with 48+ DAX measures
A 5‑page interactive dashboard for global insights
Analytical storytelling around education outcomes and youth employment challenges The result is a polished, decision‑support dashboard suitable for policymakers, researchers, and development analysts.
📊 Indicators Analyzed SDG 4.1.1 — Minimum Proficiency Levels Tracks reading and mathematics proficiency among children and youth. Disaggregated by sex, education level, and skill type. SDG 8.6.1 — Youth NEET Rates Measures the percentage of youth aged 15–24 not in education, employment, or training. Disaggregated by sex and age group. Coverage: 182 countries, 2000–2023

🛠️ Data Engineering Workflow SQL Server Pipeline

Converted raw XLSX files to CSV for ingestion
Created staging tables for Goal 4 and Goal 8
Built a unified staging table with standardized categories
Cleaned and validated 27,000+ records
Implemented a star schema:
Dim_Country
Dim_Time
Dim_Indicator
Fact_SDG_Data
Applied quality filters (e.g., removing unreliable observations)
Final dataset: 23,487 fact rows Key SQL Concepts Used
Staging architecture
Data type standardization
Categorical normalization
Surrogate keys
Referential integrity
Performance‑optimized fact/dimension modeling
📈 Power BI Modeling & DAX Data Model A clean star schema imported directly from SQL Server. Transformations

Calculated columns for standardized labels
Data type corrections
Column visibility management DAX Measures (48+) Grouped into:
Gender gap calculations
Year‑over‑year change
Baseline comparisons
2030 projections
Country rankings
Gender parity indices
Normalized performance scoring These measures power the dashboard’s analytical depth.
🖥️ Dashboard Overview Page 1 — Home Navigation hub with high‑level context. Page 2 — Progress & Top Performers

24‑year trend lines
Gender gap evolution
Top 10 most improved countries Page 3 — Gender & Education Equity
Gender‑specific KPIs
Country comparisons by gender and education level Page 4 — Performance Quadrants
Scatter plot of performance vs improvement
2030 projection gauge
Country comparison table Page 5 — Country & Demographic Breakdown
Cumulative progress
Gender parity index
Country‑level demographic insights
🔍 Key Insights

Strong geographic disparities in both education and NEET outcomes
Persistent gender gaps in many regions
Many countries are not on track for 2030 targets
Education and employment indicators show strong interdependence
External shocks (economic, social) create volatility in youth employment
👥 Authors

NYM Narathota
MWRS De Silva
KAUS Perera
TKBS Kumarasinghe
