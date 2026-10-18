/*
CFPB BANKING COMPLAINTS: EXPLORATORY DATA ANALYSIS
==================================================

BUSINESS PROBLEM

A banking compliance or customer-experience team needs to understand
where consumer complaint activity is increasing and which products,
issues, companies, and geographic areas may warrant further review.

PRIMARY ANALYSIS QUESTION

How did consumer complaint patterns across major banking products
change from 2021 through 2025, and which products, issues, companies,
and geographic areas warrant the greatest attention based on complaint
volume, growth, response timeliness, and resolution outcomes?

SUPPORTING QUESTIONS

1. How did total complaint volume change between 2021 and 2025?

2. Which product groups experienced the largest complaint volumes
   and the strongest growth?

3. Which issues and sub-issues were the most frequently reported
   within each product group?

4. Which companies received the largest numbers of complaints, and
   how did their complaint volumes change over time?

5. How were complaints distributed geographically?

6. How did timely-response rates and company-response outcomes vary
   by product, company, and year?

7. Did complaints tagged for older consumers or servicemembers show
   different product, issue, or response patterns?

PROJECT SCOPE

The analysis contains 888,691 unique CFPB complaints received between
January 1, 2021 and December 31, 2025. It covers five standardized
product groups:

- Cards
- Checking and Savings
- Money Transfers and Digital Payments
- Mortgage
- Vehicle Loans and Leases

IMPORTANT LIMITATION

Complaint counts do not measure a company's complaint rate because
the dataset does not include the number of customers, accounts, or
transactions for each company. Large companies may have more complaints
partly because they serve more consumers. Company results should therefore
be interpreted as complaint volume and response patterns, not as a
definitive ranking of company quality.
*/

USE cfpb_banking_complaints;


/*
1: DATASET OVERVIEW
---------------------------

Confirm the analytical scope and calculate the number of distinct
products, companies, states, and complaint issues represented.
*/

SELECT
    COUNT(*) AS total_complaints,
    COUNT(DISTINCT product_group) AS product_groups,
    COUNT(DISTINCT company) AS companies,
    COUNT(DISTINCT state) AS geographic_codes,
    COUNT(DISTINCT issue) AS issues,
    MIN(received_date) AS earliest_date,
    MAX(received_date) AS latest_date
FROM complaints_clean;


/*
GEOGRAPHIC CODE REVIEW
----------------------

Display every geographic code and classify it as a state,
District of Columbia, territory, military postal region,
or freely associated state.
*/

SELECT
    state,

    CASE
        WHEN state = 'DC'
            THEN 'District of Columbia'

        WHEN state IN ('AA', 'AE', 'AP')
            THEN 'Military postal region'

        WHEN state IN ('AS', 'GU', 'MP', 'PR', 'VI', 'UM')
            THEN 'US territory'

        WHEN state IN ('FM', 'MH', 'PW')
            THEN 'Freely associated state'

        ELSE 'US state'
    END AS geography_type,

    COUNT(*) AS complaint_count

FROM complaints_clean
WHERE state IS NOT NULL
GROUP BY state, geography_type
ORDER BY geography_type, state;


/*
2A: ANNUAL COMPLAINT TRENDS
----------------------------------

Calculate annual complaint volume, each year's share of the complete
dataset, and the year-over-year percentage change.

LAG retrieves the complaint count from the previous year.
The first year has no prior year, so its growth rate will be NULL.
*/

WITH annual_complaints AS (
    SELECT
        received_year,
        COUNT(*) AS complaint_count
    FROM complaints_clean
    GROUP BY received_year
),

annual_with_previous AS (
    SELECT
        received_year,
        complaint_count,

        -- Retrieve the preceding year's complaint count.
        LAG(complaint_count) OVER (
            ORDER BY received_year
        ) AS previous_year_count

    FROM annual_complaints
)

SELECT
    received_year,
    complaint_count,

    -- Calculate each year's percentage of all complaints.
    ROUND(
        100.0 * complaint_count
        / SUM(complaint_count) OVER (),
        2
    ) AS percentage_of_total,

    previous_year_count,

    -- Calculate year-over-year growth relative to the previous year.
    ROUND(
        100.0 * (complaint_count - previous_year_count)
        / previous_year_count,
        2
    ) AS year_over_year_change_pct

FROM annual_with_previous
ORDER BY received_year;

/*
2B: MONTHLY COMPLAINT TRENDS
-----------------------------------

Calculate complaint volume by month and a three-month moving average.

The moving average smooths short-term fluctuations and makes the
underlying trend easier to identify.
*/

WITH monthly_complaints AS (
    SELECT
        month_start_date,
        COUNT(*) AS complaint_count
    FROM complaints_clean
    GROUP BY month_start_date
)

SELECT
    month_start_date,
    complaint_count,

    -- Average the current month and the previous two months.
    -- The first two rows use only the months available at that point.
    ROUND(
        AVG(complaint_count) OVER (
            ORDER BY month_start_date
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        0
    ) AS three_month_moving_average

FROM monthly_complaints
ORDER BY month_start_date;

/*
2C: HIGHEST-VOLUME MONTHS
--------------------------------

Identify the ten months with the largest complaint volumes.
This helps locate unusual increases that require further investigation.
*/

WITH monthly_complaints AS (
    SELECT
        month_start_date,
        COUNT(*) AS complaint_count
    FROM complaints_clean
    GROUP BY month_start_date
),

ranked_months AS (
    SELECT
        month_start_date,
        complaint_count,

        -- Rank months from the highest to the lowest complaint volume.
        DENSE_RANK() OVER (
            ORDER BY complaint_count DESC
        ) AS volume_rank

    FROM monthly_complaints
)

SELECT
    volume_rank,
    month_start_date,
    complaint_count
FROM ranked_months
ORDER BY volume_rank, month_start_date
LIMIT 10;



/*
3A: OVERALL PRODUCT DISTRIBUTION
---------------------------------------

Calculate the number and percentage of complaints belonging to each
of the five standardized product groups.
*/

SELECT
    product_group,
    COUNT(*) AS complaint_count,

    -- Calculate each product group's share of the complete dataset.
    ROUND(
        100.0 * COUNT(*)
        / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_total

FROM complaints_clean
GROUP BY product_group
ORDER BY complaint_count DESC;

/*
3B: ANNUAL PRODUCT TRENDS
--------------------------------

Calculate annual complaint volume, annual market share within this
dataset, and year-over-year change for each product group.

LAG compares each product with its own result from the previous year.
*/

WITH annual_product_complaints AS (
    SELECT
        received_year,
        product_group,
        COUNT(*) AS complaint_count
    FROM complaints_clean
    GROUP BY
        received_year,
        product_group
),

product_with_previous AS (
    SELECT
        received_year,
        product_group,
        complaint_count,

        -- Retrieve the preceding year's count for the same product.
        LAG(complaint_count) OVER (
            PARTITION BY product_group
            ORDER BY received_year
        ) AS previous_year_count

    FROM annual_product_complaints
)

SELECT
    received_year,
    product_group,
    complaint_count,

    -- Calculate the product's share of complaints within that year.
    ROUND(
        100.0 * complaint_count
        / SUM(complaint_count) OVER (
            PARTITION BY received_year
        ),
        2
    ) AS percentage_within_year,

    previous_year_count,

    -- Calculate year-over-year change for the same product.
    ROUND(
        100.0 * (complaint_count - previous_year_count)
        / previous_year_count,
        2
    ) AS year_over_year_change_pct

FROM product_with_previous
ORDER BY
    received_year,
    complaint_count DESC;

/*
4: LEADING ISSUES BY PRODUCT
------------------------------------

Identify the five most frequently reported issues within each product
group. Issues are ranked separately because CFPB issue categories differ
among financial products.

The percentage shows how much of the product's total complaint volume
is represented by each issue.
*/

WITH issue_counts AS (
    SELECT
        product_group,
        issue,
        COUNT(*) AS complaint_count
    FROM complaints_clean
    WHERE issue IS NOT NULL
    GROUP BY
        product_group,
        issue
),

product_totals AS (
    SELECT
        product_group,
        COUNT(*) AS product_total
    FROM complaints_clean
    GROUP BY product_group
),

ranked_issues AS (
    SELECT
        product_group,
        issue,
        complaint_count,

        -- Rank issues separately within each product group.
        DENSE_RANK() OVER (
            PARTITION BY product_group
            ORDER BY complaint_count DESC
        ) AS issue_rank

    FROM issue_counts
)

SELECT
    ranked_issues.product_group,
    ranked_issues.issue_rank,
    ranked_issues.issue,
    ranked_issues.complaint_count,

    -- Calculate the issue's share of all complaints for that product.
    ROUND(
        100.0 * ranked_issues.complaint_count
        / product_totals.product_total,
        2
    ) AS percentage_of_product

FROM ranked_issues

INNER JOIN product_totals
    ON ranked_issues.product_group = product_totals.product_group

WHERE ranked_issues.issue_rank <= 5

ORDER BY
    ranked_issues.product_group,
    ranked_issues.issue_rank;
    
/*
ISSUE DISTRIBUTION FINDINGS
---------------------------

Checking and Savings complaints were highly concentrated in account
management, which represented 57.05% of the product's complaints.

Half of Mortgage complaints involved trouble during the payment process,
while another 23.95% involved consumers struggling to make payments.

Money Transfers and Digital Payments complaints were primarily associated
with transaction problems and fraud. The documented January 2025 anomaly
contributed substantially to the Other transaction problem category.

Vehicle complaints were distributed among loan management, repossession,
end-of-loan problems, obtaining financing, and payment difficulty.

Card complaints had the broadest issue distribution. The five largest
issues represented 60.99% of card complaints, indicating that no single
problem dominated this product group.
*/

/*
5: LEADING SUB-ISSUES BY PRODUCT
----------------------------------------

Identify the five leading sub-issues for products with available
sub-issue data.

Money Transfers and Digital Payments will not appear because all
money-transfer complaints have NULL sub-issues in this dataset.

Mortgage also has substantial missing sub-issue data, so two percentages
are shown:

1. Percentage of complaints with an available sub-issue.
2. Percentage of all complaints within the product.
*/

WITH sub_issue_counts AS (
    SELECT
        product_group,
        sub_issue,
        COUNT(*) AS complaint_count
    FROM complaints_clean
    WHERE sub_issue IS NOT NULL
    GROUP BY
        product_group,
        sub_issue
),

available_sub_issue_totals AS (
    SELECT
        product_group,
        COUNT(*) AS available_sub_issue_total
    FROM complaints_clean
    WHERE sub_issue IS NOT NULL
    GROUP BY product_group
),

product_totals AS (
    SELECT
        product_group,
        COUNT(*) AS product_total
    FROM complaints_clean
    GROUP BY product_group
),

ranked_sub_issues AS (
    SELECT
        product_group,
        sub_issue,
        complaint_count,

        -- Rank sub-issues separately within each product.
        DENSE_RANK() OVER (
            PARTITION BY product_group
            ORDER BY complaint_count DESC
        ) AS sub_issue_rank

    FROM sub_issue_counts
)

SELECT
    ranked_sub_issues.product_group,
    ranked_sub_issues.sub_issue_rank,
    ranked_sub_issues.sub_issue,
    ranked_sub_issues.complaint_count,

    -- Percentage among complaints where a sub-issue was recorded.
    ROUND(
        100.0 * ranked_sub_issues.complaint_count
        / available_sub_issue_totals.available_sub_issue_total,
        2
    ) AS percentage_of_available_sub_issues,

    -- Percentage among all complaints in the product group.
    ROUND(
        100.0 * ranked_sub_issues.complaint_count
        / product_totals.product_total,
        2
    ) AS percentage_of_product

FROM ranked_sub_issues

INNER JOIN available_sub_issue_totals
    ON ranked_sub_issues.product_group =
       available_sub_issue_totals.product_group

INNER JOIN product_totals
    ON ranked_sub_issues.product_group =
       product_totals.product_group

WHERE ranked_sub_issues.sub_issue_rank <= 5

ORDER BY
    ranked_sub_issues.product_group,
    ranked_sub_issues.sub_issue_rank;
    
/*
INTERPRETATION

The sub-issue analysis provides more specific information about the
problems consumers experienced within each product group.

Key findings:
1. Card complaints frequently involved unresolved purchase disputes,
   incorrect account information, and unauthorized card purchases.

2. Checking and savings complaints frequently involved deposits and
   withdrawals, debit or ATM cards, and unauthorized transactions.

3. Mortgage sub-issues frequently involved escrow, taxes, insurance,
   payment processing, and difficulties communicating with servicers.
   However, more than half of mortgage complaints did not contain a
   sub-issue, so mortgage sub-issue results must be interpreted cautiously.

4. Vehicle loan and lease complaints frequently involved billing,
   obtaining a title after paying off a loan, and balances remaining
   after repossession.

5. Money Transfers and Digital Payments does not appear in this analysis
   because all complaints in that product group have a NULL sub-issue.
   Its problems must therefore be analyzed using the broader issue field.

The percentage among known sub-issues excludes complaints where sub_issue
is NULL. The percentage of product includes every complaint in the product
group and is therefore the more conservative measure.
*/

/*
   6: LEADING COMPANIES AND ANNUAL COMPLAINT TRENDS
	-------------------------------------------

   SUPPORTING QUESTION:
   Which companies received the largest numbers of complaints,
   and how did their complaint volumes change over time?

   PURPOSE:
   Identify the ten highest-volume companies within each product
   group and compare their complaint volumes from 2021 to 2025.

   IMPORTANT LIMITATION:
   These are raw complaint counts, not complaint rates. Larger
   companies may receive more complaints because they serve more
   customers.
   */

WITH company_year_counts AS (

    -- Calculate total and annual complaint counts for each company.
    SELECT
        product_group,
        company,
        COUNT(*) AS total_complaints,

        SUM(CASE WHEN received_year = 2021 THEN 1 ELSE 0 END)
            AS complaints_2021,

        SUM(CASE WHEN received_year = 2022 THEN 1 ELSE 0 END)
            AS complaints_2022,

        SUM(CASE WHEN received_year = 2023 THEN 1 ELSE 0 END)
            AS complaints_2023,

        SUM(CASE WHEN received_year = 2024 THEN 1 ELSE 0 END)
            AS complaints_2024,

        SUM(CASE WHEN received_year = 2025 THEN 1 ELSE 0 END)
            AS complaints_2025

    FROM complaints_clean
    GROUP BY
        product_group,
        company
),

ranked_companies AS (

    -- Rank companies by their total 2021–2025 complaint volume.
    SELECT
        *,

        DENSE_RANK() OVER (
            PARTITION BY product_group
            ORDER BY total_complaints DESC
        ) AS company_rank,

        -- Calculate the company's share of complaints within
        -- its product group.
        ROUND(
            100.0 * total_complaints /
            SUM(total_complaints) OVER (
                PARTITION BY product_group
            ),
            2
        ) AS percentage_of_product_complaints

    FROM company_year_counts
)

SELECT
    product_group,
    company_rank,
    company,
    total_complaints,
    percentage_of_product_complaints,
    complaints_2021,
    complaints_2022,
    complaints_2023,
    complaints_2024,
    complaints_2025,

    -- Calculate the numerical change between 2021 and 2025.
    complaints_2025 - complaints_2021 AS absolute_change_2021_2025,

    -- Calculate percentage growth only when the company had
    -- complaints in 2021. A zero starting value cannot be used
    -- as the denominator of a percentage-change calculation.
    CASE
        WHEN complaints_2021 = 0 THEN NULL
        ELSE ROUND(
            100.0 * (complaints_2025 - complaints_2021) /
            complaints_2021,
            2
        )
    END AS percentage_change_2021_2025

FROM ranked_companies
WHERE company_rank <= 10
ORDER BY
    product_group,
    company_rank;
    
/*
INTERPRETATION

Complaint growth varied considerably among the leading companies.

For Cards, Capital One had the largest total volume. All ten leading
companies recorded more complaints in 2025 than in 2021. Synchrony and
American Express grew faster than several other major card companies.

Equifax, TransUnion, and Experian showed extremely large percentage
increases because their card-related complaint counts started from very
small 2021 values and increased sharply beginning in 2023. Changes in the
CFPB card complaint taxonomy may have contributed to this pattern.

For Checking and Savings, Wells Fargo had the largest total complaint
volume. Navy Federal, Capital One, and Chime recorded especially large
2025 increases and may warrant further operational review.

For Money Transfers and Digital Payments, Block and Early Warning
Services showed exceptionally large increases. These results were heavily
influenced by the January 2025 complaint anomaly and should not be treated
as ordinary long-term growth. Coinbase was the only leading company in
this product with fewer complaints in 2025 than in 2021.

Mortgage trends were mixed. Shellpoint and Freedom Mortgage increased,
while Wells Fargo, Select Portfolio Servicing, Bank of America, LoanCare,
and JPMorgan Chase recorded fewer complaints in 2025 than in 2021.

Most leading vehicle-finance companies experienced considerable growth.
Santander had no qualifying complaints in 2021, so its 2021–2025
percentage change could not be calculated.

These results identify changes in raw complaint volume. They do not
measure complaint rates because company customer and account totals are
not available.
*/

/*
   7: RESPONSE OUTCOMES BY LEADING COMPANY AND YEAR
   --------------------------------------------

   PURPOSE:
   Compare annual response outcomes for the five highest-volume
   companies within each product group.

   PERFORMANCE:
   The large complaint table is aggregated first. All later
   calculations operate on the much smaller company-year summary.
    */

WITH company_year_metrics AS (

    -- Scan the clean table once and reduce it to one row for each
    -- company, product group, and year.
    SELECT
        product_group,
        company,
        received_year,
        COUNT(*) AS complaint_count,

        SUM(
            CASE WHEN is_timely = 1 THEN 1 ELSE 0 END
        ) AS timely_response_count,

        SUM(
            CASE
                WHEN company_response = 'Closed with monetary relief'
                THEN 1 ELSE 0
            END
        ) AS monetary_relief_count,

        SUM(
            CASE
                WHEN company_response =
                     'Closed with non-monetary relief'
                THEN 1 ELSE 0
            END
        ) AS non_monetary_relief_count,

        SUM(
            CASE
                WHEN company_response = 'Closed with explanation'
                THEN 1 ELSE 0
            END
        ) AS explanation_count

    FROM complaints_clean

    GROUP BY
        product_group,
        company,
        received_year
),

company_totals AS (

    -- Add the five annual complaint counts to obtain each company's
    -- total complaint volume across the complete project period.
    SELECT
        product_group,
        company,
        SUM(complaint_count) AS total_complaints

    FROM company_year_metrics

    GROUP BY
        product_group,
        company
),

ranked_companies AS (

    -- Rank companies separately within each product group.
    SELECT
        product_group,
        company,
        total_complaints,

        DENSE_RANK() OVER (
            PARTITION BY product_group
            ORDER BY total_complaints DESC
        ) AS company_rank

    FROM company_totals
)

SELECT
    m.product_group,
    r.company_rank,
    m.company,
    m.received_year,
    m.complaint_count,

    -- Calculate annual timely-response percentage.
    ROUND(
        100.0 * m.timely_response_count / m.complaint_count,
        2
    ) AS timely_response_percentage,

    -- Calculate annual monetary-relief percentage.
    ROUND(
        100.0 * m.monetary_relief_count / m.complaint_count,
        2
    ) AS monetary_relief_percentage,

    -- Calculate annual non-monetary-relief percentage.
    ROUND(
        100.0 * m.non_monetary_relief_count / m.complaint_count,
        2
    ) AS non_monetary_relief_percentage,

    -- Calculate annual explanation percentage.
    ROUND(
        100.0 * m.explanation_count / m.complaint_count,
        2
    ) AS explanation_percentage

FROM company_year_metrics AS m

INNER JOIN ranked_companies AS r
    ON m.product_group = r.product_group
   AND m.company = r.company

-- Five companies per product are sufficient for this detailed
-- annual comparison. Section 6 still reports the leading ten.
WHERE r.company_rank <= 5

ORDER BY
    m.product_group,
    r.company_rank,
    m.received_year;

/*
INTERPRETATION

Timely-response percentages remained consistently high for most leading
companies and generally provided little differentiation between them.

Bank of America's Checking and Savings timely-response percentage was a
notable exception early in the period, but it improved from 92.26% in
2021 to 99.63% in 2025.

Card resolution outcomes varied considerably. Citibank's total relief
increased from 27.55% in 2021 to 52.52% in 2025. By contrast, Synchrony's
total relief decreased from 35.97% to 23.30%. American Express reached
36.99% in 2024 before decreasing to 27.39% in 2025.

Within Checking and Savings, Navy Federal and Capital One experienced
large increases in 2025 complaint volume accompanied by sharp decreases
in relief percentages. Navy Federal's total relief decreased from 30.04%
in 2024 to 8.24% in 2025, while Capital One decreased from 20.45% to
3.88%. Most of these 2025 complaints were closed with explanations.

Block and Early Warning Services consistently closed nearly all
Money Transfer and Digital Payment complaints with explanations. Their
2025 results were also heavily influenced by the January 2025 anomaly.
PayPal reported a substantially larger proportion of relief outcomes than
the other leading companies in this product group.

Mortgage complaints were overwhelmingly closed with explanations.
Mr. Cooper and Select Portfolio Servicing reported almost no monetary or
non-monetary relief, while Wells Fargo reported somewhat more relief than
the other leading mortgage companies.

Vehicle-loan outcomes varied by company. Santander's non-monetary-relief
percentage increased to 28.28% in 2025, while Westlake reported that all
complaints were closed with explanations.
*/

/*
   8. Geographic Distribution
   ---------------------------

   PURPOSE:
   Measure complaint volume across the 50 U.S. states and
   Washington, D.C., for use in the Tableau map.
   */

WITH state_complaint_counts AS (

    -- Count complaints within each of the 50 states and Washington, D.C.
    SELECT
        state,
        COUNT(*) AS complaint_count
    FROM complaints_clean

    WHERE state IN (
        'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA',
        'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD',
        'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ',
        'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC',
        'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY',
        'DC'
    )

    GROUP BY state
)

SELECT
    -- Rank states from the largest to the smallest complaint volume.
    DENSE_RANK() OVER (
        ORDER BY complaint_count DESC
    ) AS state_rank,

    state,
    complaint_count,

    -- Calculate each state's share of complaints included in this map.
    ROUND(
        100.0 * complaint_count /
        SUM(complaint_count) OVER (),
        2
    ) AS percentage_of_mapped_complaints

FROM state_complaint_counts
ORDER BY complaint_count DESC;

/*
INTERPRETATION

As expected, the largest complaint totals generally come from highly populated states.
California, Texas, Florida, and New York recorded the largest numbers of
complaints and together accounted for approximately 39.86% of complaints
included in the state map.

The ten highest-volume states accounted for approximately 63.10% of
mapped complaints.
*/

/*
   9: RESPONSE OUTCOMES BY PRODUCT AND YEAR
   --------------------------------------------

   PURPOSE:
   Determine whether timely-response and resolution outcomes
   changed over time within each product group.
 */

SELECT
    received_year,
    product_group,
    COUNT(*) AS complaint_count,

    -- Percentage receiving a timely response.
    ROUND(
        100.0 * SUM(
            CASE WHEN is_timely = 1 THEN 1 ELSE 0 END
        ) / COUNT(*),
        2
    ) AS timely_response_percentage,

    -- Percentage receiving monetary relief.
    ROUND(
        100.0 * SUM(
            CASE
                WHEN company_response = 'Closed with monetary relief'
                THEN 1 ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS monetary_relief_percentage,

    -- Percentage receiving non-monetary relief.
    ROUND(
        100.0 * SUM(
            CASE
                WHEN company_response =
                     'Closed with non-monetary relief'
                THEN 1 ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS non_monetary_relief_percentage,

    -- Percentage receiving either form of reported relief.
    ROUND(
        100.0 * SUM(
            CASE
                WHEN company_response IN (
                    'Closed with monetary relief',
                    'Closed with non-monetary relief'
                )
                THEN 1 ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS total_relief_percentage,

    -- Percentage closed with an explanation.
    ROUND(
        100.0 * SUM(
            CASE
                WHEN company_response = 'Closed with explanation'
                THEN 1 ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS explanation_percentage

FROM complaints_clean

GROUP BY
    received_year,
    product_group

ORDER BY
    received_year,
    product_group;

/*
SECTION 9 INTERPRETATION

Timely-response percentages remained consistently high across products
and years, generally ranging between approximately 98% and 99%.

Cards had the highest reported relief percentages in every year. Total
card relief increased from 27.55% in 2021 to 38.43% in 2024 before
declining to 32.46% in 2025.

Checking and Savings relief remained near 20% through 2024 but decreased
to 15.42% in 2025.

Money Transfers and Digital Payments showed the largest decrease in
reported relief, falling from 17.28% in 2021 to 3.94% in 2025. The 2025
result was strongly influenced by the January anomaly, whose complaints
were overwhelmingly closed with explanations.

Mortgage consistently had low reported relief and high explanation
percentages. Total relief decreased from 7.51% in 2021 to 4.44% in 2025.

Vehicle Loans and Leases remained comparatively stable, with total relief
ranging from 7.68% to 9.81%.

Response timeliness changed relatively little, while resolution outcomes
varied meaningfully by product and year. Reported outcomes do not measure
consumer satisfaction.
*/

/*
   10A: TAGGED CONSUMERS BY PRODUCT AND RESPONSE OUTCOME
   -----------------------------------------------------

   PURPOSE:
   Determine whether complaints tagged for Older Americans or
   servicemembers show different product and response patterns.

   Only complaints containing a recorded CFPB tag are included.
*/

WITH tagged_product_metrics AS (

    -- Calculate product volume and outcomes for each tag category.
    SELECT
        tags AS tag_category,
        product_group,
        COUNT(*) AS complaint_count,

        SUM(
            CASE WHEN is_timely = 1 THEN 1 ELSE 0 END
        ) AS timely_response_count,

        SUM(
            CASE
                WHEN company_response IN (
                    'Closed with monetary relief',
                    'Closed with non-monetary relief'
                )
                THEN 1 ELSE 0
            END
        ) AS relief_count,

        SUM(
            CASE
                WHEN company_response = 'Closed with explanation'
                THEN 1 ELSE 0
            END
        ) AS explanation_count

    FROM complaints_clean

    -- Exclude complaints for which no tag was recorded.
    WHERE tags IS NOT NULL

    GROUP BY
        tags,
        product_group
)

SELECT
    tag_category,
    product_group,
    complaint_count,

    -- Product's percentage of all complaints in the tag category.
    ROUND(
        100.0 * complaint_count /
        SUM(complaint_count) OVER (
            PARTITION BY tag_category
        ),
        2
    ) AS percentage_within_tag,

    ROUND(
        100.0 * timely_response_count / complaint_count,
        2
    ) AS timely_response_percentage,

    ROUND(
        100.0 * relief_count / complaint_count,
        2
    ) AS total_relief_percentage,

    ROUND(
        100.0 * explanation_count / complaint_count,
        2
    ) AS explanation_percentage

FROM tagged_product_metrics

ORDER BY
    tag_category,
    complaint_count DESC;
    
/*
INTERPRETATION

Product patterns differed among the recorded consumer tag categories.

Cards were the largest category for Older Americans, accounting for
35.94% of their tagged complaints. Checking and Savings ranked second
at 28.19%, followed by Mortgage at 21.69%.

Checking and Savings was the leading product among servicemembers at
29.21%, narrowly exceeding Cards at 28.27%. Vehicle Loans and Leases
represented 9.57% of servicemember complaints, compared with only 3.92%
among Older Americans.

Consumers containing both the Older American and Servicemember tags had
the strongest mortgage concentration. Mortgage represented 25.71% of
their complaints.

Mortgage was more strongly represented in all three tagged categories
than in the complete dataset, where it represented 13.37% of complaints.
Money Transfers and Digital Payments was less strongly represented among
all three tagged groups than in the complete dataset.

Timely-response percentages remained high across every tagged group and
product combination, generally ranging from approximately 98% to 99%.

Resolution outcomes appeared to be influenced more strongly by product
than by tag category. Cards had the highest relief percentages within
each tagged group, while Mortgage had the lowest. For example, total card
relief ranged from 28.44% to 35.08%, compared with approximately 4.75%
to 5.30% for Mortgage.

These findings indicate that tagged consumers had different product and
issue patterns, particularly stronger mortgage representation.
*/
    
/*
   10B: LEADING ISSUES AMONG TAGGED CONSUMERS
   --------------------------------------------

   PURPOSE:
   Identify the five most frequent product-and-issue combinations
   for each recorded consumer tag category.
*/

WITH tagged_issue_counts AS (

    -- Count complaints by tag, product, and issue.
    SELECT
        tags AS tag_category,
        product_group,
        issue,
        COUNT(*) AS complaint_count

    FROM complaints_clean

    WHERE tags IS NOT NULL
      AND issue IS NOT NULL

    GROUP BY
        tags,
        product_group,
        issue
),

ranked_tagged_issues AS (

    -- Rank product-and-issue combinations within each tag category.
    SELECT
        tag_category,
        product_group,
        issue,
        complaint_count,

        ROUND(
            100.0 * complaint_count /
            SUM(complaint_count) OVER (
                PARTITION BY tag_category
            ),
            2
        ) AS percentage_within_tag,

        DENSE_RANK() OVER (
            PARTITION BY tag_category
            ORDER BY complaint_count DESC
        ) AS issue_rank

    FROM tagged_issue_counts
)

SELECT
    tag_category,
    issue_rank,
    product_group,
    issue,
    complaint_count,
    percentage_within_tag

FROM ranked_tagged_issues

WHERE issue_rank <= 5

ORDER BY
    tag_category,
    issue_rank,
    product_group;
    
    
/*
INTERPRETATION

Managing a checking or savings account was the leading issue for all
three recorded tag categories. It represented 18.28% of Older American
complaints, 17.74% of complaints containing both tags, and 14.92% of
servicemember complaints.

Card purchase disputes were also prominent, particularly among Older
Americans, where they represented 12.02% of tagged complaints.

Mortgage problems appeared frequently among servicemembers and consumers
with both tags. Trouble during the mortgage payment process was the
second-largest issue for both groups. Struggling to pay a mortgage was
also among their five leading issues.

Problems caused by low account funds appeared among the leading issues
for servicemembers, while card fees or interest appeared among the
leading issues for Older Americans.

These findings identify recurring issues within the recorded tag groups.
Because CFPB tags are incomplete, they should not be interpreted as full
demographic estimates.
*/

/* 
   11: SUBMISSION CHANNELS BY PRODUCT GROUP
   ----------------------------------------

   PURPOSE:
   Examine how consumers submitted complaints for each product.
*/

WITH channel_counts AS (

    -- Count complaints for every submission channel
    -- within each product group.
    SELECT
        product_group,
        submitted_via,
        COUNT(*) AS complaint_count
    FROM complaints_clean
    GROUP BY
        product_group,
        submitted_via
)

SELECT
    product_group,
    submitted_via,
    complaint_count,

    -- Calculate each channel's percentage within its product group.
    ROUND(
        100.0 * complaint_count /
        SUM(complaint_count) OVER (
            PARTITION BY product_group
        ),
        2
    ) AS percentage_within_product

FROM channel_counts
ORDER BY
    product_group,
    complaint_count DESC;
    
/*
INTERPRETATION

Web was the dominant submission channel for every product group, ranging
from 81.10% of Checking and Savings complaints to 95.08% of Money
Transfers and Digital Payments complaints.

The exceptionally high Web percentage for Money Transfers and Digital
Payments was partly influenced by the January 2025 complaint anomaly,
which was heavily concentrated in Web submissions.

Checking and Savings had the highest Referral percentage at 10.47%.

Mortgage had the highest Phone percentage at 8.68% and the highest Postal
Mail percentage at 1.43%.

Fax submissions were negligible across all five product groups.
*/