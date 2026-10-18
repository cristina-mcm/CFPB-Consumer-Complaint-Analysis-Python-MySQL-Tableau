/*
JANUARY 2025 INVESTIGATION: PRODUCT CONTRIBUTION
------------------------------------------------

Compare complaints by product for December 2024, January 2025,
and February 2025 to determine which product caused the spike.
*/

SELECT
    month_start_date,
    product_group,
    COUNT(*) AS complaint_count
FROM complaints_clean
WHERE month_start_date BETWEEN '2024-12-01' AND '2025-02-01'
GROUP BY
    month_start_date,
    product_group
ORDER BY
    month_start_date,
    complaint_count DESC;

/*
JANUARY 2025 INVESTIGATION: DAILY VOLUME
----------------------------------------

Identify whether the spike occurred throughout January or was
concentrated on one or more specific dates.
*/

SELECT
    received_date,
    COUNT(*) AS complaint_count
FROM complaints_clean
WHERE received_date >= '2025-01-01'
  AND received_date <  '2025-02-01'
GROUP BY received_date
ORDER BY complaint_count DESC
LIMIT 15;

/*
Determine if the high volume concentration is the
same in December and February.
*/

SELECT
    received_date,
    COUNT(*) AS complaint_count
FROM complaints_clean
WHERE received_date >= '2024-12-01'
  AND received_date <  '2025-01-01'
GROUP BY received_date
ORDER BY complaint_count DESC
LIMIT 15;

SELECT
    received_date,
    COUNT(*) AS complaint_count
FROM complaints_clean
WHERE received_date >= '2025-02-01'
  AND received_date <  '2025-03-01'
GROUP BY received_date
ORDER BY complaint_count DESC
LIMIT 15;

/*
JANUARY 2025 INVESTIGATION: LEADING ISSUES
------------------------------------------

Identify the product and issue combinations responsible for
the largest numbers of January complaints.
*/

SELECT
    product_group,
    issue,
    COUNT(*) AS complaint_count
FROM complaints_clean
WHERE month_start_date = '2025-01-01'
GROUP BY
    product_group,
    issue
ORDER BY complaint_count DESC
LIMIT 15;

-- Compare to January 2024

SELECT
    product_group,
    issue,
    COUNT(*) AS complaint_count
FROM complaints_clean
WHERE month_start_date = '2024-01-01'
GROUP BY
    product_group,
    issue
ORDER BY complaint_count DESC
LIMIT 15;
    
/*
JANUARY 2025 ANOMALY: COMPANY CONCENTRATION
--------------------------------------------

Identify which companies received the January complaints classified
as money-transfer "Other transaction problem."

The percentage shows each company's share of the anomaly.
*/

WITH company_counts AS (
    SELECT
        company,
        COUNT(*) AS complaint_count
    FROM complaints_clean
    WHERE month_start_date = '2025-01-01'
      AND product_group = 'Money Transfers and Digital Payments'
      AND issue = 'Other transaction problem'
    GROUP BY company
)

SELECT
    company,
    complaint_count,

    ROUND(
        100.0 * complaint_count
        / SUM(complaint_count) OVER (),
        2
    ) AS percentage_of_anomaly

FROM company_counts
ORDER BY complaint_count DESC
LIMIT 10;

/*
JANUARY 2025 ANOMALY: FINDING
-----------------------------

The January 2025 spike was concentrated in 42,521 complaints classified
as Money Transfers and Digital Payments / Other transaction problem.

Block, Inc., which operates Cash App, accounted for 65.05% of these
complaints. Early Warning Services, which operates the Zelle network,
accounted for 33.30%. Together, they represented 98.35% of the anomaly.

External research and CFPB reporting indicate that the spike followed
CFPB enforcement announcements involving payment platforms and an online
wave of template-based complaints. The records remain in the analysis
because they are unique, officially published complaint records, but the
spike is treated as an anomaly when interpreting 2025 growth.
*/

/*
ANOMALY RESPONSE COMPARISON
---------------------------

Compare company-reported outcomes for the January anomaly with all
other money-transfer complaints in the project.

This determines whether the anomaly had a meaningfully different
resolution pattern.
*/

WITH money_transfer_groups AS (
    SELECT
        CASE
            WHEN month_start_date = '2025-01-01'
             AND issue = 'Other transaction problem'
                THEN 'January 2025 anomaly'
            ELSE 'Other money-transfer complaints'
        END AS complaint_group,

        company_response

    FROM complaints_clean
    WHERE product_group = 'Money Transfers and Digital Payments'
)

SELECT
    complaint_group,
    COUNT(*) AS complaint_count,

    -- Count complaints closed with monetary relief.
    SUM(
        company_response = 'Closed with monetary relief'
    ) AS monetary_relief_count,

    -- Calculate the monetary-relief percentage.
    ROUND(
        100.0 * SUM(
            company_response = 'Closed with monetary relief'
        ) / COUNT(*),
        2
    ) AS monetary_relief_percentage,

    -- Calculate the percentage closed only with an explanation.
    ROUND(
        100.0 * SUM(
            company_response = 'Closed with explanation'
        ) / COUNT(*),
        2
    ) AS explanation_percentage

FROM money_transfer_groups
GROUP BY complaint_group
ORDER BY complaint_group;

/*
ANNUAL SENSITIVITY ANALYSIS
---------------------------

Compare annual complaint volume before and after excluding the specific
January 2025 money-transfer anomaly.

The adjusted count is used only as a sensitivity test. No records are
deleted from complaints_clean.
*/

WITH annual_sensitivity AS (
    SELECT
        received_year,
        COUNT(*) AS reported_complaints,

        -- Count records belonging to the identified anomaly.
        SUM(
            CASE
                WHEN month_start_date = '2025-01-01'
                 AND product_group =
                     'Money Transfers and Digital Payments'
                 AND issue = 'Other transaction problem'
                    THEN 1
                ELSE 0
            END
        ) AS anomaly_complaints,

        -- Exclude the anomaly only for this comparison.
        SUM(
            CASE
                WHEN month_start_date = '2025-01-01'
                 AND product_group =
                     'Money Transfers and Digital Payments'
                 AND issue = 'Other transaction problem'
                    THEN 0
                ELSE 1
            END
        ) AS adjusted_complaints

    FROM complaints_clean
    GROUP BY received_year
),

annual_with_previous AS (
    SELECT
        received_year,
        reported_complaints,
        anomaly_complaints,
        adjusted_complaints,

        LAG(adjusted_complaints) OVER (
            ORDER BY received_year
        ) AS previous_adjusted_count

    FROM annual_sensitivity
)

SELECT
    received_year,
    reported_complaints,
    anomaly_complaints,
    adjusted_complaints,

    -- Calculate annual growth after excluding the anomaly.
    ROUND(
        100.0 * (
            adjusted_complaints - previous_adjusted_count
        ) / previous_adjusted_count,
        2
    ) AS adjusted_year_over_year_change_pct

FROM annual_with_previous
ORDER BY received_year;

/*
SENSITIVITY ANALYSIS: INTERPRETATION
------------------------------------

The January 2025 anomaly accounted for 42,521 complaints and approximately
34% of the total increase between 2024 and 2025.

Reported complaint volume increased 66.46% in 2025. After temporarily
excluding the anomaly, the adjusted increase remained 43.69%.

The broader upward trend is therefore not entirely explained by the
January anomaly, although the anomaly substantially increased the
reported 2025 growth rate.

Only 0.14% of the anomalous complaints were closed with monetary relief,
compared with 7.27% of other money-transfer complaints. This indicates
that filing complaints during the January surge rarely resulted in
company-reported monetary compensation through the complaint process.
*/