USE cfpb_banking_complaints;

-- Confirm the starting record count
SELECT COUNT(*) AS total_raw_rows
FROM complaints_raw;


-- Check complaint ID completeness and uniqueness
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT complaint_id_raw) AS distinct_complaint_ids,
    SUM(
        complaint_id_raw IS NULL
        OR TRIM(complaint_id_raw) = ''
    ) AS missing_complaint_ids
FROM complaints_raw;


-- Display duplicate complaint IDs, if any
SELECT
    complaint_id_raw,
    COUNT(*) AS occurrence_count
FROM complaints_raw
WHERE complaint_id_raw IS NOT NULL
  AND TRIM(complaint_id_raw) <> ''
GROUP BY complaint_id_raw
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC;


-- Check the date range
SELECT
    MIN(date_received_raw) AS earliest_date,
    MAX(date_received_raw) AS latest_date
FROM complaints_raw;


-- Review original product categories
SELECT
    product_raw,
    COUNT(*) AS complaint_count
FROM complaints_raw
GROUP BY product_raw
ORDER BY complaint_count DESC;


-- Review timely-response values
SELECT
    timely_response_raw,
    COUNT(*) AS complaint_count
FROM complaints_raw
GROUP BY timely_response_raw
ORDER BY complaint_count DESC;


-- Review company-response categories
SELECT
    company_response_raw,
    COUNT(*) AS complaint_count
FROM complaints_raw
GROUP BY company_response_raw
ORDER BY complaint_count DESC;

-- Confirm the duplicate source

-- Create a temporary table to store the duplicates

DROP TEMPORARY TABLE IF EXISTS duplicate_ids_temp;

CREATE TEMPORARY TABLE duplicate_ids_temp (
    complaint_id_raw VARCHAR(20) PRIMARY KEY
);

INSERT INTO duplicate_ids_temp (complaint_id_raw)
SELECT complaint_id_raw
FROM complaints_raw
GROUP BY complaint_id_raw
HAVING COUNT(*) > 1;

SELECT COUNT(*)
FROM duplicate_ids_temp;


-- Retrieve only the duplicate rows
DROP TEMPORARY TABLE IF EXISTS duplicate_rows_temp;

CREATE TEMPORARY TABLE duplicate_rows_temp AS
SELECT
    r.raw_row_id,
    r.complaint_id_raw,
    r.date_received_raw,
    r.product_raw,
    r.source_file
FROM complaints_raw AS r
INNER JOIN duplicate_ids_temp AS d
    ON r.complaint_id_raw = d.complaint_id_raw;
    
SELECT COUNT(*)
FROM duplicate_rows_temp;

-- Identify overlaping files

SELECT
    file_combination,
    COUNT(*) AS duplicate_complaints
FROM (
    SELECT
        complaint_id_raw,
        GROUP_CONCAT(
            DISTINCT source_file
            ORDER BY source_file
            SEPARATOR ' | '
        ) AS file_combination
    FROM duplicate_rows_temp
    GROUP BY complaint_id_raw
) AS combinations
GROUP BY file_combination
ORDER BY duplicate_complaints DESC;

-- Check the duplicate dates
SELECT
    LEFT(date_received_raw, 10) AS duplicate_date,
    COUNT(DISTINCT complaint_id_raw) AS duplicate_complaints
FROM duplicate_rows_temp
GROUP BY LEFT(date_received_raw, 10)
ORDER BY duplicate_date;

-- Every duplicate occurred on January 1
-- The API included the maximum boundary date, so January 1 appeared in both adjoining annual files.

-- Check if there are any 2026 records

SELECT
    source_file,
    COUNT(*) AS records_from_2026
FROM complaints_raw
WHERE LEFT(date_received_raw, 10) >= '2026-01-01'
GROUP BY source_file
ORDER BY source_file;

SELECT COUNT(*) AS total_records_from_2026
FROM complaints_raw
WHERE LEFT(date_received_raw, 10) >= '2026-01-01';

-- Check that timestamps can be converted

SELECT
    SUM(
        STR_TO_DATE(
            REPLACE(REPLACE(date_received_raw, 'T', ' '), 'Z', ''),
            '%Y-%m-%d %H:%i:%s.%f'
        ) IS NULL
    ) AS invalid_received_dates,

    SUM(
        NULLIF(TRIM(date_sent_to_company_raw), '') IS NOT NULL
        AND STR_TO_DATE(
            REPLACE(REPLACE(date_sent_to_company_raw, 'T', ' '), 'Z', ''),
            '%Y-%m-%d %H:%i:%s.%f'
        ) IS NULL
    ) AS invalid_sent_dates
FROM complaints_raw;

-- Create the clean table

DROP TABLE IF EXISTS complaints_clean;

CREATE TABLE complaints_clean (
    complaint_id BIGINT UNSIGNED NOT NULL,
    date_received DATETIME(3) NOT NULL,
    received_date DATE NOT NULL,
    received_year SMALLINT UNSIGNED NOT NULL,
    received_quarter TINYINT UNSIGNED NOT NULL,
    received_month TINYINT UNSIGNED NOT NULL,
    month_start_date DATE NOT NULL,

    product_group VARCHAR(100) NOT NULL,
    product_original VARCHAR(100) NOT NULL,
    sub_product VARCHAR(255),
    issue VARCHAR(255),
    sub_issue VARCHAR(255),

    company_public_response TEXT,
    company VARCHAR(255),
    state CHAR(2),
    zip_code VARCHAR(10),
    tags VARCHAR(100),
    submitted_via VARCHAR(50),

    date_sent_to_company DATETIME(3),
    company_response VARCHAR(100),
    timely_response VARCHAR(3),
    is_timely TINYINT(1),

    source_file VARCHAR(255),

    PRIMARY KEY (complaint_id)
);

-- Clean and insert the records

-- Remove an older copy of the loading procedure if one exists.
DROP PROCEDURE IF EXISTS load_clean_complaints;

-- Temporarily change the statement delimiter because the procedure
-- contains multiple SQL statements separated by semicolons.
DELIMITER $$

-- Create a temporary stored procedure that processes one year at a time.
CREATE PROCEDURE load_clean_complaints()
BEGIN
    -- Begin with the first year included in the project.
    DECLARE v_year INT DEFAULT 2021;

    -- Repeat the cleaning and insertion process through 2025.
    -- Processing yearly batches prevents MySQL from attempting to
    -- sort and transform all 889,678 raw rows simultaneously.
    WHILE v_year <= 2025 DO

		INSERT INTO complaints_clean (
			complaint_id,
			date_received,
			received_date,
			received_year,
			received_quarter,
			received_month,
			month_start_date,
			product_group,
			product_original,
			sub_product,
			issue,
			sub_issue,
			company_public_response,
			company,
			state,
			zip_code,
			tags,
			submitted_via,
			date_sent_to_company,
			company_response,
			timely_response,
			is_timely,
			source_file
		)
		SELECT
			complaint_id,

			-- Retain the exact complaint-received timestamp.
			date_received,

			-- Create calendar fields for easier analysis and Tableau filtering.
			DATE(date_received),
			YEAR(date_received),
			QUARTER(date_received),
			MONTH(date_received),

			-- Standardize each date to the first day of its month.
			-- This field will be used for monthly trend charts.
			STR_TO_DATE(
				DATE_FORMAT(date_received, '%Y-%m-01'),
				'%Y-%m-%d'
			),

			-- Combine the seven original CFPB product names into
			-- the five product groups selected for this project.
			CASE
				WHEN product_original IN (
					'Credit card',
					'Prepaid card',
					'Credit card or prepaid card'
				)
					THEN 'Cards'

				WHEN product_original = 'Checking or savings account'
					THEN 'Checking and Savings'

				WHEN product_original =
					 'Money transfer, virtual currency, or money service'
					THEN 'Money Transfers and Digital Payments'

				WHEN product_original = 'Mortgage'
					THEN 'Mortgage'

				WHEN product_original = 'Vehicle loan or lease'
					THEN 'Vehicle Loans and Leases'

				ELSE 'Other'
			END,

			-- Preserve the original CFPB product name for traceability.
			product_original,

			-- Convert blank strings and the text 'None' into SQL NULL values.
			CASE
				WHEN TRIM(sub_product_raw) IN ('', 'None') THEN NULL
				ELSE TRIM(sub_product_raw)
			END,

			CASE
				WHEN TRIM(issue_raw) IN ('', 'None') THEN NULL
				ELSE TRIM(issue_raw)
			END,

			CASE
				WHEN TRIM(sub_issue_raw) IN ('', 'None') THEN NULL
				ELSE TRIM(sub_issue_raw)
			END,

			CASE
				WHEN TRIM(company_public_response_raw) IN ('', 'None') THEN NULL
				ELSE TRIM(company_public_response_raw)
			END,

			CASE
				WHEN TRIM(company_raw) IN ('', 'None') THEN NULL
				ELSE TRIM(company_raw)
			END,

			-- Convert missing states to NULL and standardize the
			-- United States Minor Outlying Islands to the code UM.
			CASE
				WHEN TRIM(state_raw) IN ('', 'None') THEN NULL
				WHEN TRIM(state_raw) = 'UNITED STATES MINOR OUTLYING ISLANDS'
					THEN 'UM'
				ELSE UPPER(TRIM(state_raw))
			END,

			-- Preserve ZIP codes as text so leading zeros are not removed.
			CASE
				WHEN TRIM(zip_code_raw) IN ('', 'None') THEN NULL
				ELSE TRIM(zip_code_raw)
			END,

			CASE
				WHEN TRIM(tags_raw) IN ('', 'None') THEN NULL
				ELSE TRIM(tags_raw)
			END,

			CASE
				WHEN TRIM(submitted_via_raw) IN ('', 'None') THEN NULL
				ELSE TRIM(submitted_via_raw)
			END,

			-- Retain the timestamp when CFPB sent the complaint to the company.
			date_sent_to_company,

			CASE
				WHEN TRIM(company_response_raw) IN ('', 'None') THEN NULL
				ELSE TRIM(company_response_raw)
			END,

			CASE
				WHEN TRIM(timely_response_raw) IN ('', 'None') THEN NULL
				ELSE TRIM(timely_response_raw)
			END,

			-- Convert the Yes/No timely-response field into a numeric flag.
			-- 1 = timely, 0 = not timely.
			CASE
				WHEN TRIM(timely_response_raw) = 'Yes' THEN 1
				WHEN TRIM(timely_response_raw) = 'No' THEN 0
				ELSE NULL
			END,

			-- Retain the original CSV filename for data lineage.
			source_file

		FROM (
			SELECT
				typed_data.*,

				-- Assign a sequence number to every copy of a complaint ID.
				-- The first imported copy receives 1; duplicate copies receive 2.
				ROW_NUMBER() OVER (
					PARTITION BY complaint_id
					ORDER BY raw_row_id
				) AS duplicate_rank

			FROM (
				SELECT
					raw_row_id,

					-- Convert the complaint ID to a numeric data type.
					CAST(complaint_id_raw AS UNSIGNED) AS complaint_id,

					-- Convert the CFPB ISO timestamp text into MySQL DATETIME.
					-- The original T separator and Z UTC indicator are removed.
					STR_TO_DATE(
						REPLACE(REPLACE(date_received_raw, 'T', ' '), 'Z', ''),
						'%Y-%m-%d %H:%i:%s.%f'
					) AS date_received,

					-- Convert the date-sent timestamp while allowing missing values.
					CASE
						WHEN TRIM(date_sent_to_company_raw) IN ('', 'None')
							THEN NULL
						ELSE STR_TO_DATE(
							REPLACE(
								REPLACE(date_sent_to_company_raw, 'T', ' '),
								'Z',
								''
							),
							'%Y-%m-%d %H:%i:%s.%f'
						)
					END AS date_sent_to_company,

					-- Trim unnecessary spaces from the original product name.
					TRIM(product_raw) AS product_original,

					sub_product_raw,
					issue_raw,
					sub_issue_raw,
					company_public_response_raw,
					company_raw,
					state_raw,
					zip_code_raw,
					tags_raw,
					submitted_via_raw,
					company_response_raw,
					timely_response_raw,
					source_file

				FROM complaints_raw

				-- Include only the calendar year currently being processed by the loop.
				-- This also prevents the 2026 boundary records from being included.
				WHERE LEFT(date_received_raw, 4) = CAST(v_year AS CHAR)
			) AS typed_data
		) AS ranked_data

		-- Retain only the first copy of every complaint ID.
		WHERE duplicate_rank = 1;

        -- Move to the next calendar year.
        SET v_year = v_year + 1;

    END WHILE;
END$$

-- Restore the normal MySQL statement delimiter.
DELIMITER ;

-- Execute the procedure to clean and insert 2021 through 2025.
CALL load_clean_complaints();

-- Remove the procedure after loading because it is no longer needed.
-- The complaints_clean table and its data are not removed.
DROP PROCEDURE load_clean_complaints;

-- Check if the number of rows is correct
SELECT COUNT(*) AS clean_rows
FROM complaints_clean;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT complaint_id) AS distinct_complaint_ids,
    MIN(date_received) AS earliest_date,
    MAX(date_received) AS latest_date
FROM complaints_clean;


Select * from complaints_clean
Limit 10;

-- Missing value assessment
USE cfpb_banking_complaints;

-- Count missing values in each nullable column.
-- Missing values are not automatically errors.
-- Some fields, such as tags and public responses, are optional by design.
WITH missing_summary AS (
    SELECT
        COUNT(*) AS total_rows,

        SUM(sub_product IS NULL) AS sub_product_missing,
        SUM(issue IS NULL) AS issue_missing,
        SUM(sub_issue IS NULL) AS sub_issue_missing,
        SUM(company_public_response IS NULL) AS public_response_missing,
        SUM(company IS NULL) AS company_missing,
        SUM(state IS NULL) AS state_missing,
        SUM(zip_code IS NULL) AS zip_code_missing,
        SUM(tags IS NULL) AS tags_missing,
        SUM(submitted_via IS NULL) AS submitted_via_missing,
        SUM(date_sent_to_company IS NULL) AS date_sent_missing,
        SUM(company_response IS NULL) AS company_response_missing,
        SUM(timely_response IS NULL) AS timely_response_missing

    FROM complaints_clean
)

-- Display one row per column, including the missing count
-- and the percentage of the clean dataset that is missing.
SELECT
    'sub_product' AS column_name,
    sub_product_missing AS missing_count,
    ROUND(100.0 * sub_product_missing / total_rows, 2)
        AS missing_percentage
FROM missing_summary

UNION ALL

SELECT
    'issue',
    issue_missing,
    ROUND(100.0 * issue_missing / total_rows, 2)
FROM missing_summary

UNION ALL

SELECT
    'sub_issue',
    sub_issue_missing,
    ROUND(100.0 * sub_issue_missing / total_rows, 2)
FROM missing_summary

UNION ALL

SELECT
    'company_public_response',
    public_response_missing,
    ROUND(100.0 * public_response_missing / total_rows, 2)
FROM missing_summary

UNION ALL

SELECT
    'company',
    company_missing,
    ROUND(100.0 * company_missing / total_rows, 2)
FROM missing_summary

UNION ALL

SELECT
    'state',
    state_missing,
    ROUND(100.0 * state_missing / total_rows, 2)
FROM missing_summary

UNION ALL

SELECT
    'zip_code',
    zip_code_missing,
    ROUND(100.0 * zip_code_missing / total_rows, 2)
FROM missing_summary

UNION ALL

SELECT
    'tags',
    tags_missing,
    ROUND(100.0 * tags_missing / total_rows, 2)
FROM missing_summary

UNION ALL

SELECT
    'submitted_via',
    submitted_via_missing,
    ROUND(100.0 * submitted_via_missing / total_rows, 2)
FROM missing_summary

UNION ALL

SELECT
    'date_sent_to_company',
    date_sent_missing,
    ROUND(100.0 * date_sent_missing / total_rows, 2)
FROM missing_summary

UNION ALL

SELECT
    'company_response',
    company_response_missing,
    ROUND(100.0 * company_response_missing / total_rows, 2)
FROM missing_summary

UNION ALL

SELECT
    'timely_response',
    timely_response_missing,
    ROUND(100.0 * timely_response_missing / total_rows, 2)
FROM missing_summary

-- Show the columns with the highest missing percentages first.
ORDER BY missing_percentage DESC;

-- State Validation

-- Display the number of complaints for every available state code.
-- This allows us to review the geographic categories in the dataset.
SELECT
    state,
    COUNT(*) AS complaint_count
FROM complaints_clean
GROUP BY state
ORDER BY state;

-- Check for unorganized code

-- Identify non-null state codes that are not recognized US postal,
-- territorial, military, or freely associated state abbreviations.
-- A result of zero rows means all available codes passed this check.
SELECT
    state,
    COUNT(*) AS complaint_count
FROM complaints_clean
WHERE state IS NOT NULL
  AND FIND_IN_SET(
        state,
        'AL,AK,AZ,AR,CA,CO,CT,DE,FL,GA,HI,ID,IL,IN,IA,KS,KY,LA,ME,MD,MA,MI,MN,MS,MO,MT,NE,NV,NH,NJ,NM,NY,NC,ND,OH,OK,OR,PA,RI,SC,SD,TN,TX,UT,VT,VA,WA,WV,WI,WY,DC,AS,GU,MP,PR,VI,UM,AA,AE,AP,FM,MH,PW'
      ) = 0
GROUP BY state
ORDER BY complaint_count DESC;

-- ZIP-code validation

-- Find ZIP-code values that do not match either expected format:
-- five digits, such as 75001, or masked format, such as 750XX.
SELECT
    zip_code,
    COUNT(*) AS complaint_count
FROM complaints_clean
WHERE zip_code IS NOT NULL
  AND zip_code NOT REGEXP '^([0-9]{5}|[0-9]{3}XX)$'
GROUP BY zip_code
ORDER BY complaint_count DESC
LIMIT 50;

-- Clean the ZIP-code placeholders

-- Temporarily disable safe-update mode so the invalid ZIP-code
-- placeholders can be updated using a column that is not a key.
SET SQL_SAFE_UPDATES = 0;

-- Convert fully masked or malformed ZIP codes to SQL NULL.
-- The original values remain available in complaints_raw.
-- We do not guess or manufacture replacement ZIP codes.
UPDATE complaints_clean
SET zip_code = NULL
WHERE zip_code = 'XXXXX'
   OR zip_code NOT REGEXP '^([0-9]{5}|[0-9]{3}XX)$';

-- Restore safe-update protection for the remainder of the session.
SET SQL_SAFE_UPDATES = 1;

-- Confirm that no non-null ZIP codes have an invalid format.
SELECT
    zip_code,
    COUNT(*) AS complaint_count
FROM complaints_clean
WHERE zip_code IS NOT NULL
  AND zip_code NOT REGEXP '^([0-9]{5}|[0-9]{3}XX)$'
GROUP BY zip_code; -- Result: zero rows

-- Confirm the final number and percentage of missing ZIP codes.
SELECT
    SUM(zip_code IS NULL) AS missing_zip_codes,
    ROUND(
        100.0 * SUM(zip_code IS NULL) / COUNT(*),
        2
    ) AS missing_percentage
FROM complaints_clean;
-- missing count: 20,129, approximately 2.27%.

-- Review the available consumer tags.
-- NULL is displayed as a readable category without changing the stored data.
SELECT
    COALESCE(tags, 'No tag recorded') AS tag_category,
    COUNT(*) AS complaint_count
FROM complaints_clean
GROUP BY tags
ORDER BY complaint_count DESC;

-- Review company public-response categories.
-- A missing public response is displayed as its own category.
SELECT
    COALESCE(
        company_public_response,
        'No public response recorded'
    ) AS public_response_category,
    COUNT(*) AS complaint_count
FROM complaints_clean
GROUP BY company_public_response
ORDER BY complaint_count DESC;

-- Examine whether missing sub-issues are concentrated in certain products.
SELECT
    product_group,
    COUNT(*) AS total_complaints,
    SUM(sub_issue IS NULL) AS missing_sub_issues,
    ROUND(
        100.0 * SUM(sub_issue IS NULL) / COUNT(*),
        2
    ) AS missing_percentage
FROM complaints_clean
GROUP BY product_group
ORDER BY missing_percentage DESC;


-- Category consistency

-- Confirm that the clean table contains only the five
-- analytical product groups selected for this project.
SELECT
    product_group,
    COUNT(*) AS complaint_count
FROM complaints_clean
GROUP BY product_group
ORDER BY complaint_count DESC;

-- Confirm how each original CFPB product name was assigned
-- to one of our five standardized product groups.
SELECT
    product_original,
    product_group,
    COUNT(*) AS complaint_count
FROM complaints_clean
GROUP BY
    product_original,
    product_group
ORDER BY
    product_group,
    complaint_count DESC;
    
-- Confirm that the original Yes/No response category agrees
-- with the numeric is_timely field created during cleaning.
-- Expected combinations are Yes/1 and No/0.
SELECT
    timely_response,
    is_timely,
    COUNT(*) AS complaint_count
FROM complaints_clean
GROUP BY
    timely_response,
    is_timely
ORDER BY complaint_count DESC;

-- Review all company-response categories and their frequencies.
SELECT
    company_response,
    COUNT(*) AS complaint_count
FROM complaints_clean
GROUP BY company_response
ORDER BY complaint_count DESC;

-- Review all complaint-submission methods and their frequencies.
SELECT
    submitted_via,
    COUNT(*) AS complaint_count
FROM complaints_clean
GROUP BY submitted_via
ORDER BY complaint_count DESC;

-- Data consistency

-- Check for missing sent dates and records where the complaint
-- appears to have been sent before CFPB received it.
-- We will inspect any unusual records rather than deleting them.
SELECT
    SUM(date_sent_to_company IS NULL) AS missing_sent_dates,
    SUM(date_sent_to_company < date_received) AS sent_before_received
FROM complaints_clean;

-- Cleaning findings:
--
-- 1. Tags are optional CFPB classifications. Approximately 83% of
--    complaints have no recorded tag. Untagged records are retained
--    because missing tags do not make the complaints invalid.
--
-- 2. Company public responses are missing for approximately 58% of
--    complaints. These records are retained because a public response
--    is optional and differs from the company's response to the consumer.
--
-- 3. Missing sub-issues are related to CFPB product taxonomy.
--    Money-transfer complaints do not contain sub-issues, while most
--    card, checking, and vehicle complaints do. Issue is therefore used
--    for comparisons across products, while sub-issue is used only for
--    detailed product-specific analysis.
--
-- 4. Complaints with missing states are retained for national analysis.
--    Only state-level analyses and Tableau maps will exclude null states.
--
-- 5. Invalid and fully masked ZIP codes were converted to SQL NULL.
--    No ZIP values were guessed or imputed.

-- Add indexes

-- Speed up annual, monthly, and date-range analysis.
CREATE INDEX idx_complaints_received_date
ON complaints_clean (received_date);

-- Speed up comparisons of products across time periods.
CREATE INDEX idx_complaints_product_date
ON complaints_clean (product_group, received_date);

-- Speed up state filters and geographic analysis.
CREATE INDEX idx_complaints_state
ON complaints_clean (state);

-- Speed up company-level filtering and comparisons.
CREATE INDEX idx_complaints_company
ON complaints_clean (company);

-- Verify

-- Display the primary key and newly created analytical indexes.
SHOW INDEX FROM complaints_clean;

-- Refresh the optimizer statistics after loading the clean data
-- and creating indexes. This helps MySQL choose efficient query plans.
-- Cardinality values may still remain approximate.
ANALYZE TABLE complaints_clean;