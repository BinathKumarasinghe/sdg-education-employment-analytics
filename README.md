SDG Progress Analytics — Education & Youth Employment Indicators


📌 Overview

A complete end-to-end data analytics pipeline built on UN SDG data,
focused on SDG 4 (Quality Education) and SDG 8 (Decent Work & Economic Growth).
Covers SQL Server database architecture, star schema design, advanced DAX measures,
and a 5-page interactive Power BI dashboard tracking global progress from 2000 to 2023.


🗂️ Project Structure

- Database: SQL Server — SDG_Analytics_DB
- Staging Tables: RAW_Goal4 and RAW_Goal8 (combined ~27,000 raw records)
- Star Schema: Fact_SDG_Data linked to Dim_Country, Dim_Time and Dim_Indicator
- Dashboard: 5-page Power BI report with filters, tooltips and navigation buttons


✨ Key Features

- Unified staging table merging two heterogeneous UN SDG datasets
- Comprehensive data cleaning including NULL removal, sex standardization and age group mapping
- Star schema implementation with full referential integrity (23,487 final fact rows)
- 48 DAX measures across 6 categories: aggregations, temporal, predictive, equity, performance and ranking
- Power Query calculated columns for user-friendly categorical labels
- 5-page dashboard covering trends, gender equity, performance quadrants and country breakdowns


💡 Insights Uncovered

- Azerbaijan (+67), Gambia (+60) and Zimbabwe (+55) lead global SDG improvement rankings
- Female indicators averaged higher than male indicators (30.06 vs 24.17) globally
- Gender parity gap narrowed from ~10 points in 2000 to 7.5 points in 2023
- Pakistan shows a 500% parity gap with a GPI of ~6.2, among the most extreme globally
- Only 18.3% of countries are on track to meet SDG targets by 2030 at current rates
- COVID-19 (2020–2021) caused measurable disruption in both education and youth employment indicators


🛠️ Tools & Technologies

- Microsoft SQL Server and SSMS
- Power BI Desktop
- SQL (DDL, DML, Star Schema Design, Data Cleaning)
- DAX (48 measures including predictive and equity metrics)
- UN SDG Data Portal (https://unstats.un.org/sdgs/dataportal)


📦 Data Source

UN SDG Data Platform — publicly available via:
https://unstats.un.org/sdgs/dataportal

Indicators used:
4.1.1 — Percentage of children and youth reaching minimum proficiency levels
8.6.1 — Youth not in education, employment or training (NEET) rates
