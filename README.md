# CFPB Consumer Complaint Analysis

## Overview

This end-to-end project analyzes 888,691 consumer complaints submitted to the Consumer Financial Protection Bureau (CFPB) from 2021 through 2025. The analysis focuses on five banking product groups: Cards, Checking and Savings, Money Transfers and Digital Payments, Mortgage, and Vehicle Loans and Leases.

Python was used to retrieve and prepare the data, MySQL was used for cleaning and analysis, and Tableau was used to create two interactive dashboards.

## Business Problem

A compliance or customer-experience team needs to determine where complaint volume, recurring consumer problems, company-level changes, and response outcomes require the greatest attention. The project converts a large public complaint dataset into product, company, geographic, and consumer-tag insights that can support prioritization.

## Business Questions

1. How did complaint volume change from 2021 through 2025?
2. Which banking products generated the most complaints and the strongest growth?
3. Which issues and sub-issues appeared most frequently within each product group?
4. Which companies received the most complaints, and how did their volume change?
5. How were complaints distributed geographically?
6. How did response timeliness and reported resolution outcomes vary?
7. Did complaints carrying CFPB consumer tags show different product or outcome patterns?

## Tools and Techniques

- **Python:** API requests, recursive date-range splitting, CSV validation, chunked exports, and Tableau data preparation
- **MySQL:** schema creation, bulk imports, data cleaning, common table expressions, window functions, ranking, conditional aggregation, and sensitivity analysis
- **Tableau:** interactive filters, KPI cards, stacked bars, line charts, a filled map, a heatmap, and response-outcome visualizations

## Workflow

1. Retrieved filtered complaint data from the CFPB API and validated downloaded row counts.
2. Imported the annual product files into a raw MySQL staging table.
3. Standardized dates, product groups, text fields, and response indicators; removed duplicate complaint IDs.
4. Explored annual, product, issue, company, geographic, response, tag, and submission-channel patterns.
5. Investigated the January 2025 money-transfer anomaly and performed a sensitivity analysis.
6. Exported the cleaned MySQL table and prepared a smaller complaint-level CSV for Tableau.
7. Created two interactive Tableau dashboards for overview and company/compliance analysis.

## Interactive Dashboard

[View the Tableau Public dashboard](https://public.tableau.com/app/profile/cristina.mcm/viz/07_Tableau_Dashboard/ComplaintOverview)

The published workbook contains two dashboards:

- **Consumer Complaint Overview** – complaint volume, product trends, geographic distribution, and leading issues
- **Company and Compliance Detail** – leading-company trends, reported relief outcomes, tagged-consumer patterns, and submission channels

## Key Findings

- Complaint volume increased from 109,624 in 2021 to 310,760 in 2025, representing 183.48% growth.
- A January 2025 concentration included 42,521 Money Transfers and Digital Payments complaints classified as **Other transaction problem**. Block and Early Warning Services accounted for 98.35% of this concentration.
- The broader upward trend remained after the anomaly was temporarily excluded: adjusted complaint volume still increased 43.69% in 2025.
- Product issues differed substantially. Checking and Savings complaints centered on account management, Mortgage complaints frequently involved payment difficulties, and Card complaints had a wider distribution of recurring problems.
- Leading companies included Capital One for Cards, Wells Fargo for Checking and Savings, Block for Money Transfers and Digital Payments, Shellpoint for Mortgage, and Ally for Vehicle Loans and Leases.
- California, Texas, Florida, and New York represented 39.86% of mapped complaints. These are raw totals and are not adjusted for state population.
- Timely-response percentages generally remained near 98–99%, while reported relief outcomes varied considerably more across products and companies.
- CFPB consumer-tag patterns differed by product, but tag coverage is incomplete and should not be interpreted as comprehensive demographic information.

## Data Considerations

- Complaint totals measure records published by the CFPB; they do not directly measure company quality, customer satisfaction, market share, or individual consumer risk.
- Geographic results use raw complaint volume rather than population-adjusted complaint rates.
- A missing consumer tag means that no tag was recorded, not that the consumer did not belong to the corresponding group.
- The January 2025 anomaly remains in the primary analysis because the complaints are unique published records. A separate sensitivity analysis evaluates its influence on growth.
- The source and cleaned CSV files are excluded from this repository because of their size. The extraction notebook documents how the source files were obtained.

## Repository Contents

- `01_CFPB_API_Data_Extraction.ipynb` – retrieves annual product data through the CFPB API, splits large requests, and validates downloaded row counts.
- `02_Database_Setup_and_Import.sql` – creates the MySQL schema and raw staging table and imports the extracted CSV files.
- `03_Data_Cleaning.sql` – validates, standardizes, deduplicates, and transforms the raw complaint records.
- `04_Exploratory_Data_Analysis.sql` – answers the primary business questions using MySQL.
- `04A_January_2025_Anomaly_Investigation.sql` – investigates the January spike and performs an adjusted-growth sensitivity analysis.
- `05_Export_Clean_Data.ipynb` – exports the cleaned MySQL table to CSV in memory-efficient chunks.
- `06_Tableau_Data_Preparation.ipynb` – selects and validates the complaint-level fields used in Tableau.

## Data Source

Consumer Financial Protection Bureau, [Consumer Complaint Database](https://www.consumerfinance.gov/data-research/consumer-complaints/).
