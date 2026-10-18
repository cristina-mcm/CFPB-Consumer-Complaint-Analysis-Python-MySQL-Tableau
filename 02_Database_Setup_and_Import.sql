/*
Before running this script, replace
C:/path/to/CFPB_Banking_Project
with the local folder containing the CSV files created by
01_CFPB_API_Data_Extraction.ipynb.
*/

CREATE SCHEMA IF NOT EXISTS cfpb_banking_complaints;

USE cfpb_banking_complaints;

SELECT DATABASE();

# Creating the table complaints_raw

CREATE TABLE complaints_raw (
    raw_row_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    date_received_raw TEXT,
    product_raw TEXT,
    sub_product_raw TEXT,
    issue_raw TEXT,
    sub_issue_raw TEXT,
    company_public_response_raw TEXT,
    company_raw TEXT,
    state_raw TEXT,
    zip_code_raw TEXT,
    tags_raw TEXT,
    submitted_via_raw TEXT,
    date_sent_to_company_raw TEXT,
    company_response_raw TEXT,
    timely_response_raw TEXT,
    complaint_id_raw TEXT,
    source_file VARCHAR(255),
    imported_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (raw_row_id)
);

DESCRIBE complaints_raw;

# importing the data into the table complaints_raw 
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE
'C:/path/to/CFPB_Banking_Project/prepaid_card_2023.csv'
INTO TABLE complaints_raw
CHARACTER SET utf8mb4
FIELDS
    TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @date_received,
    @product,
    @sub_product,
    @issue,
    @sub_issue,
    @company_public_response,
    @company,
    @state,
    @zip_code,
    @tags,
    @submitted_via,
    @date_sent_to_company,
    @company_response,
    @timely_response,
    @complaint_id
)
SET
    date_received_raw = NULLIF(@date_received, ''),
    product_raw = NULLIF(@product, ''),
    sub_product_raw = NULLIF(@sub_product, ''),
    issue_raw = NULLIF(@issue, ''),
    sub_issue_raw = NULLIF(@sub_issue, ''),
    company_public_response_raw =
        NULLIF(@company_public_response, ''),
    company_raw = NULLIF(@company, ''),
    state_raw = NULLIF(@state, ''),
    zip_code_raw = NULLIF(@zip_code, ''),
    tags_raw = NULLIF(@tags, ''),
    submitted_via_raw = NULLIF(@submitted_via, ''),
    date_sent_to_company_raw =
        NULLIF(@date_sent_to_company, ''),
    company_response_raw =
        NULLIF(@company_response, ''),
    timely_response_raw =
        NULLIF(@timely_response, ''),
    complaint_id_raw =
        NULLIF(TRIM(TRAILING '\r' FROM @complaint_id), ''),
    source_file = 'prepaid_card_2023.csv';

LOAD DATA LOCAL INFILE 'C:/path/to/CFPB_Banking_Project/cards_legacy_2021.csv'
INTO TABLE complaints_raw
CHARACTER SET utf8mb4
FIELDS
    TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @date_received,
    @product,
    @sub_product,
    @issue,
    @sub_issue,
    @company_public_response,
    @company,
    @state,
    @zip_code,
    @tags,
    @submitted_via,
    @date_sent_to_company,
    @company_response,
    @timely_response,
    @complaint_id
)
SET
    date_received_raw = NULLIF(@date_received, ''),
    product_raw = NULLIF(@product, ''),
    sub_product_raw = NULLIF(@sub_product, ''),
    issue_raw = NULLIF(@issue, ''),
    sub_issue_raw = NULLIF(@sub_issue, ''),
    company_public_response_raw =
        NULLIF(@company_public_response, ''),
    company_raw = NULLIF(@company, ''),
    state_raw = NULLIF(@state, ''),
    zip_code_raw = NULLIF(@zip_code, ''),
    tags_raw = NULLIF(@tags, ''),
    submitted_via_raw = NULLIF(@submitted_via, ''),
    date_sent_to_company_raw =
        NULLIF(@date_sent_to_company, ''),
    company_response_raw =
        NULLIF(@company_response, ''),
    timely_response_raw =
        NULLIF(@timely_response, ''),
    complaint_id_raw =
        NULLIF(TRIM(TRAILING '\r' FROM @complaint_id), ''),
    source_file = 'cards_legacy_2021.csv';


LOAD DATA LOCAL INFILE 'C:/path/to/CFPB_Banking_Project/cards_legacy_2022.csv'
INTO TABLE complaints_raw
CHARACTER SET utf8mb4
FIELDS
    TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @date_received,
    @product,
    @sub_product,
    @issue,
    @sub_issue,
    @company_public_response,
    @company,
    @state,
    @zip_code,
    @tags,
    @submitted_via,
    @date_sent_to_company,
    @company_response,
    @timely_response,
    @complaint_id
)
SET
    date_received_raw = NULLIF(@date_received, ''),
    product_raw = NULLIF(@product, ''),
    sub_product_raw = NULLIF(@sub_product, ''),
    issue_raw = NULLIF(@issue, ''),
    sub_issue_raw = NULLIF(@sub_issue, ''),
    company_public_response_raw =
        NULLIF(@company_public_response, ''),
    company_raw = NULLIF(@company, ''),
    state_raw = NULLIF(@state, ''),
    zip_code_raw = NULLIF(@zip_code, ''),
    tags_raw = NULLIF(@tags, ''),
    submitted_via_raw = NULLIF(@submitted_via, ''),
    date_sent_to_company_raw =
        NULLIF(@date_sent_to_company, ''),
    company_response_raw =
        NULLIF(@company_response, ''),
    timely_response_raw =
        NULLIF(@timely_response, ''),
    complaint_id_raw =
        NULLIF(TRIM(TRAILING '\r' FROM @complaint_id), ''),
    source_file = 'cards_legacy_2022.csv';


LOAD DATA LOCAL INFILE 'C:/path/to/CFPB_Banking_Project/cards_legacy_2023.csv'
INTO TABLE complaints_raw
CHARACTER SET utf8mb4
FIELDS
    TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @date_received,
    @product,
    @sub_product,
    @issue,
    @sub_issue,
    @company_public_response,
    @company,
    @state,
    @zip_code,
    @tags,
    @submitted_via,
    @date_sent_to_company,
    @company_response,
    @timely_response,
    @complaint_id
)
SET
    date_received_raw = NULLIF(@date_received, ''),
    product_raw = NULLIF(@product, ''),
    sub_product_raw = NULLIF(@sub_product, ''),
    issue_raw = NULLIF(@issue, ''),
    sub_issue_raw = NULLIF(@sub_issue, ''),
    company_public_response_raw =
        NULLIF(@company_public_response, ''),
    company_raw = NULLIF(@company, ''),
    state_raw = NULLIF(@state, ''),
    zip_code_raw = NULLIF(@zip_code, ''),
    tags_raw = NULLIF(@tags, ''),
    submitted_via_raw = NULLIF(@submitted_via, ''),
    date_sent_to_company_raw =
        NULLIF(@date_sent_to_company, ''),
    company_response_raw =
        NULLIF(@company_response, ''),
    timely_response_raw =
        NULLIF(@timely_response, ''),
    complaint_id_raw =
        NULLIF(TRIM(TRAILING '\r' FROM @complaint_id), ''),
    source_file = 'cards_legacy_2023.csv';


LOAD DATA LOCAL INFILE 'C:/path/to/CFPB_Banking_Project/checking_savings_2021.csv'
INTO TABLE complaints_raw
CHARACTER SET utf8mb4
FIELDS
    TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @date_received,
    @product,
    @sub_product,
    @issue,
    @sub_issue,
    @company_public_response,
    @company,
    @state,
    @zip_code,
    @tags,
    @submitted_via,
    @date_sent_to_company,
    @company_response,
    @timely_response,
    @complaint_id
)
SET
    date_received_raw = NULLIF(@date_received, ''),
    product_raw = NULLIF(@product, ''),
    sub_product_raw = NULLIF(@sub_product, ''),
    issue_raw = NULLIF(@issue, ''),
    sub_issue_raw = NULLIF(@sub_issue, ''),
    company_public_response_raw =
        NULLIF(@company_public_response, ''),
    company_raw = NULLIF(@company, ''),
    state_raw = NULLIF(@state, ''),
    zip_code_raw = NULLIF(@zip_code, ''),
    tags_raw = NULLIF(@tags, ''),
    submitted_via_raw = NULLIF(@submitted_via, ''),
    date_sent_to_company_raw =
        NULLIF(@date_sent_to_company, ''),
    company_response_raw =
        NULLIF(@company_response, ''),
    timely_response_raw =
        NULLIF(@timely_response, ''),
    complaint_id_raw =
        NULLIF(TRIM(TRAILING '\r' FROM @complaint_id), ''),
    source_file = 'checking_savings_2021.csv';


LOAD DATA LOCAL INFILE 'C:/path/to/CFPB_Banking_Project/checking_savings_2022.csv'
INTO TABLE complaints_raw
CHARACTER SET utf8mb4
FIELDS
    TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @date_received,
    @product,
    @sub_product,
    @issue,
    @sub_issue,
    @company_public_response,
    @company,
    @state,
    @zip_code,
    @tags,
    @submitted_via,
    @date_sent_to_company,
    @company_response,
    @timely_response,
    @complaint_id
)
SET
    date_received_raw = NULLIF(@date_received, ''),
    product_raw = NULLIF(@product, ''),
    sub_product_raw = NULLIF(@sub_product, ''),
    issue_raw = NULLIF(@issue, ''),
    sub_issue_raw = NULLIF(@sub_issue, ''),
    company_public_response_raw =
        NULLIF(@company_public_response, ''),
    company_raw = NULLIF(@company, ''),
    state_raw = NULLIF(@state, ''),
    zip_code_raw = NULLIF(@zip_code, ''),
    tags_raw = NULLIF(@tags, ''),
    submitted_via_raw = NULLIF(@submitted_via, ''),
    date_sent_to_company_raw =
        NULLIF(@date_sent_to_company, ''),
    company_response_raw =
        NULLIF(@company_response, ''),
    timely_response_raw =
        NULLIF(@timely_response, ''),
    complaint_id_raw =
        NULLIF(TRIM(TRAILING '\r' FROM @complaint_id), ''),
    source_file = 'checking_savings_2022.csv';


LOAD DATA LOCAL INFILE 'C:/path/to/CFPB_Banking_Project/checking_savings_2023.csv'
INTO TABLE complaints_raw
CHARACTER SET utf8mb4
FIELDS
    TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @date_received,
    @product,
    @sub_product,
    @issue,
    @sub_issue,
    @company_public_response,
    @company,
    @state,
    @zip_code,
    @tags,
    @submitted_via,
    @date_sent_to_company,
    @company_response,
    @timely_response,
    @complaint_id
)
SET
    date_received_raw = NULLIF(@date_received, ''),
    product_raw = NULLIF(@product, ''),
    sub_product_raw = NULLIF(@sub_product, ''),
    issue_raw = NULLIF(@issue, ''),
    sub_issue_raw = NULLIF(@sub_issue, ''),
    company_public_response_raw =
        NULLIF(@company_public_response, ''),
    company_raw = NULLIF(@company, ''),
    state_raw = NULLIF(@state, ''),
    zip_code_raw = NULLIF(@zip_code, ''),
    tags_raw = NULLIF(@tags, ''),
    submitted_via_raw = NULLIF(@submitted_via, ''),
    date_sent_to_company_raw =
        NULLIF(@date_sent_to_company, ''),
    company_response_raw =
        NULLIF(@company_response, ''),
    timely_response_raw =
        NULLIF(@timely_response, ''),
    complaint_id_raw =
        NULLIF(TRIM(TRAILING '\r' FROM @complaint_id), ''),
    source_file = 'checking_savings_2023.csv';


LOAD DATA LOCAL INFILE 'C:/path/to/CFPB_Banking_Project/checking_savings_2024.csv'
INTO TABLE complaints_raw
CHARACTER SET utf8mb4
FIELDS
    TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @date_received,
    @product,
    @sub_product,
    @issue,
    @sub_issue,
    @company_public_response,
    @company,
    @state,
    @zip_code,
    @tags,
    @submitted_via,
    @date_sent_to_company,
    @company_response,
    @timely_response,
    @complaint_id
)
SET
    date_received_raw = NULLIF(@date_received, ''),
    product_raw = NULLIF(@product, ''),
    sub_product_raw = NULLIF(@sub_product, ''),
    issue_raw = NULLIF(@issue, ''),
    sub_issue_raw = NULLIF(@sub_issue, ''),
    company_public_response_raw =
        NULLIF(@company_public_response, ''),
    company_raw = NULLIF(@company, ''),
    state_raw = NULLIF(@state, ''),
    zip_code_raw = NULLIF(@zip_code, ''),
    tags_raw = NULLIF(@tags, ''),
    submitted_via_raw = NULLIF(@submitted_via, ''),
    date_sent_to_company_raw =
        NULLIF(@date_sent_to_company, ''),
    company_response_raw =
        NULLIF(@company_response, ''),
    timely_response_raw =
        NULLIF(@timely_response, ''),
    complaint_id_raw =
        NULLIF(TRIM(TRAILING '\r' FROM @complaint_id), ''),
    source_file = 'checking_savings_2024.csv';


LOAD DATA LOCAL INFILE 'C:/path/to/CFPB_Banking_Project/checking_savings_2025.csv'
INTO TABLE complaints_raw
CHARACTER SET utf8mb4
FIELDS
    TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @date_received,
    @product,
    @sub_product,
    @issue,
    @sub_issue,
    @company_public_response,
    @company,
    @state,
    @zip_code,
    @tags,
    @submitted_via,
    @date_sent_to_company,
    @company_response,
    @timely_response,
    @complaint_id
)
SET
    date_received_raw = NULLIF(@date_received, ''),
    product_raw = NULLIF(@product, ''),
    sub_product_raw = NULLIF(@sub_product, ''),
    issue_raw = NULLIF(@issue, ''),
    sub_issue_raw = NULLIF(@sub_issue, ''),
    company_public_response_raw =
        NULLIF(@company_public_response, ''),
    company_raw = NULLIF(@company, ''),
    state_raw = NULLIF(@state, ''),
    zip_code_raw = NULLIF(@zip_code, ''),
    tags_raw = NULLIF(@tags, ''),
    submitted_via_raw = NULLIF(@submitted_via, ''),
    date_sent_to_company_raw =
        NULLIF(@date_sent_to_company, ''),
    company_response_raw =
        NULLIF(@company_response, ''),
    timely_response_raw =
        NULLIF(@timely_response, ''),
    complaint_id_raw =
        NULLIF(TRIM(TRAILING '\r' FROM @complaint_id), ''),
    source_file = 'checking_savings_2025.csv';


LOAD DATA LOCAL INFILE 'C:/path/to/CFPB_Banking_Project/credit_card_2023.csv'
INTO TABLE complaints_raw
CHARACTER SET utf8mb4
FIELDS
    TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @date_received,
    @product,
    @sub_product,
    @issue,
    @sub_issue,
    @company_public_response,
    @company,
    @state,
    @zip_code,
    @tags,
    @submitted_via,
    @date_sent_to_company,
    @company_response,
    @timely_response,
    @complaint_id
)
SET
    date_received_raw = NULLIF(@date_received, ''),
    product_raw = NULLIF(@product, ''),
    sub_product_raw = NULLIF(@sub_product, ''),
    issue_raw = NULLIF(@issue, ''),
    sub_issue_raw = NULLIF(@sub_issue, ''),
    company_public_response_raw =
        NULLIF(@company_public_response, ''),
    company_raw = NULLIF(@company, ''),
    state_raw = NULLIF(@state, ''),
    zip_code_raw = NULLIF(@zip_code, ''),
    tags_raw = NULLIF(@tags, ''),
    submitted_via_raw = NULLIF(@submitted_via, ''),
    date_sent_to_company_raw =
        NULLIF(@date_sent_to_company, ''),
    company_response_raw =
        NULLIF(@company_response, ''),
    timely_response_raw =
        NULLIF(@timely_response, ''),
    complaint_id_raw =
        NULLIF(TRIM(TRAILING '\r' FROM @complaint_id), ''),
    source_file = 'credit_card_2023.csv';


LOAD DATA LOCAL INFILE 'C:/path/to/CFPB_Banking_Project/credit_card_2024.csv'
INTO TABLE complaints_raw
CHARACTER SET utf8mb4
FIELDS
    TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @date_received,
    @product,
    @sub_product,
    @issue,
    @sub_issue,
    @company_public_response,
    @company,
    @state,
    @zip_code,
    @tags,
    @submitted_via,
    @date_sent_to_company,
    @company_response,
    @timely_response,
    @complaint_id
)
SET
    date_received_raw = NULLIF(@date_received, ''),
    product_raw = NULLIF(@product, ''),
    sub_product_raw = NULLIF(@sub_product, ''),
    issue_raw = NULLIF(@issue, ''),
    sub_issue_raw = NULLIF(@sub_issue, ''),
    company_public_response_raw =
        NULLIF(@company_public_response, ''),
    company_raw = NULLIF(@company, ''),
    state_raw = NULLIF(@state, ''),
    zip_code_raw = NULLIF(@zip_code, ''),
    tags_raw = NULLIF(@tags, ''),
    submitted_via_raw = NULLIF(@submitted_via, ''),
    date_sent_to_company_raw =
        NULLIF(@date_sent_to_company, ''),
    company_response_raw =
        NULLIF(@company_response, ''),
    timely_response_raw =
        NULLIF(@timely_response, ''),
    complaint_id_raw =
        NULLIF(TRIM(TRAILING '\r' FROM @complaint_id), ''),
    source_file = 'credit_card_2024.csv';


LOAD DATA LOCAL INFILE 'C:/path/to/CFPB_Banking_Project/credit_card_2025.csv'
INTO TABLE complaints_raw
CHARACTER SET utf8mb4
FIELDS
    TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @date_received,
    @product,
    @sub_product,
    @issue,
    @sub_issue,
    @company_public_response,
    @company,
    @state,
    @zip_code,
    @tags,
    @submitted_via,
    @date_sent_to_company,
    @company_response,
    @timely_response,
    @complaint_id
)
SET
    date_received_raw = NULLIF(@date_received, ''),
    product_raw = NULLIF(@product, ''),
    sub_product_raw = NULLIF(@sub_product, ''),
    issue_raw = NULLIF(@issue, ''),
    sub_issue_raw = NULLIF(@sub_issue, ''),
    company_public_response_raw =
        NULLIF(@company_public_response, ''),
    company_raw = NULLIF(@company, ''),
    state_raw = NULLIF(@state, ''),
    zip_code_raw = NULLIF(@zip_code, ''),
    tags_raw = NULLIF(@tags, ''),
    submitted_via_raw = NULLIF(@submitted_via, ''),
    date_sent_to_company_raw =
        NULLIF(@date_sent_to_company, ''),
    company_response_raw =
        NULLIF(@company_response, ''),
    timely_response_raw =
        NULLIF(@timely_response, ''),
    complaint_id_raw =
        NULLIF(TRIM(TRAILING '\r' FROM @complaint_id), ''),
    source_file = 'credit_card_2025.csv';


LOAD DATA LOCAL INFILE 'C:/path/to/CFPB_Banking_Project/money_transfers_2021.csv'
INTO TABLE complaints_raw
CHARACTER SET utf8mb4
FIELDS
    TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @date_received,
    @product,
    @sub_product,
    @issue,
    @sub_issue,
    @company_public_response,
    @company,
    @state,
    @zip_code,
    @tags,
    @submitted_via,
    @date_sent_to_company,
    @company_response,
    @timely_response,
    @complaint_id
)
SET
    date_received_raw = NULLIF(@date_received, ''),
    product_raw = NULLIF(@product, ''),
    sub_product_raw = NULLIF(@sub_product, ''),
    issue_raw = NULLIF(@issue, ''),
    sub_issue_raw = NULLIF(@sub_issue, ''),
    company_public_response_raw =
        NULLIF(@company_public_response, ''),
    company_raw = NULLIF(@company, ''),
    state_raw = NULLIF(@state, ''),
    zip_code_raw = NULLIF(@zip_code, ''),
    tags_raw = NULLIF(@tags, ''),
    submitted_via_raw = NULLIF(@submitted_via, ''),
    date_sent_to_company_raw =
        NULLIF(@date_sent_to_company, ''),
    company_response_raw =
        NULLIF(@company_response, ''),
    timely_response_raw =
        NULLIF(@timely_response, ''),
    complaint_id_raw =
        NULLIF(TRIM(TRAILING '\r' FROM @complaint_id), ''),
    source_file = 'money_transfers_2021.csv';


LOAD DATA LOCAL INFILE 'C:/path/to/CFPB_Banking_Project/money_transfers_2022.csv'
INTO TABLE complaints_raw
CHARACTER SET utf8mb4
FIELDS
    TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @date_received,
    @product,
    @sub_product,
    @issue,
    @sub_issue,
    @company_public_response,
    @company,
    @state,
    @zip_code,
    @tags,
    @submitted_via,
    @date_sent_to_company,
    @company_response,
    @timely_response,
    @complaint_id
)
SET
    date_received_raw = NULLIF(@date_received, ''),
    product_raw = NULLIF(@product, ''),
    sub_product_raw = NULLIF(@sub_product, ''),
    issue_raw = NULLIF(@issue, ''),
    sub_issue_raw = NULLIF(@sub_issue, ''),
    company_public_response_raw =
        NULLIF(@company_public_response, ''),
    company_raw = NULLIF(@company, ''),
    state_raw = NULLIF(@state, ''),
    zip_code_raw = NULLIF(@zip_code, ''),
    tags_raw = NULLIF(@tags, ''),
    submitted_via_raw = NULLIF(@submitted_via, ''),
    date_sent_to_company_raw =
        NULLIF(@date_sent_to_company, ''),
    company_response_raw =
        NULLIF(@company_response, ''),
    timely_response_raw =
        NULLIF(@timely_response, ''),
    complaint_id_raw =
        NULLIF(TRIM(TRAILING '\r' FROM @complaint_id), ''),
    source_file = 'money_transfers_2022.csv';


LOAD DATA LOCAL INFILE 'C:/path/to/CFPB_Banking_Project/money_transfers_2023.csv'
INTO TABLE complaints_raw
CHARACTER SET utf8mb4
FIELDS
    TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @date_received,
    @product,
    @sub_product,
    @issue,
    @sub_issue,
    @company_public_response,
    @company,
    @state,
    @zip_code,
    @tags,
    @submitted_via,
    @date_sent_to_company,
    @company_response,
    @timely_response,
    @complaint_id
)
SET
    date_received_raw = NULLIF(@date_received, ''),
    product_raw = NULLIF(@product, ''),
    sub_product_raw = NULLIF(@sub_product, ''),
    issue_raw = NULLIF(@issue, ''),
    sub_issue_raw = NULLIF(@sub_issue, ''),
    company_public_response_raw =
        NULLIF(@company_public_response, ''),
    company_raw = NULLIF(@company, ''),
    state_raw = NULLIF(@state, ''),
    zip_code_raw = NULLIF(@zip_code, ''),
    tags_raw = NULLIF(@tags, ''),
    submitted_via_raw = NULLIF(@submitted_via, ''),
    date_sent_to_company_raw =
        NULLIF(@date_sent_to_company, ''),
    company_response_raw =
        NULLIF(@company_response, ''),
    timely_response_raw =
        NULLIF(@timely_response, ''),
    complaint_id_raw =
        NULLIF(TRIM(TRAILING '\r' FROM @complaint_id), ''),
    source_file = 'money_transfers_2023.csv';


LOAD DATA LOCAL INFILE 'C:/path/to/CFPB_Banking_Project/money_transfers_2024.csv'
INTO TABLE complaints_raw
CHARACTER SET utf8mb4
FIELDS
    TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @date_received,
    @product,
    @sub_product,
    @issue,
    @sub_issue,
    @company_public_response,
    @company,
    @state,
    @zip_code,
    @tags,
    @submitted_via,
    @date_sent_to_company,
    @company_response,
    @timely_response,
    @complaint_id
)
SET
    date_received_raw = NULLIF(@date_received, ''),
    product_raw = NULLIF(@product, ''),
    sub_product_raw = NULLIF(@sub_product, ''),
    issue_raw = NULLIF(@issue, ''),
    sub_issue_raw = NULLIF(@sub_issue, ''),
    company_public_response_raw =
        NULLIF(@company_public_response, ''),
    company_raw = NULLIF(@company, ''),
    state_raw = NULLIF(@state, ''),
    zip_code_raw = NULLIF(@zip_code, ''),
    tags_raw = NULLIF(@tags, ''),
    submitted_via_raw = NULLIF(@submitted_via, ''),
    date_sent_to_company_raw =
        NULLIF(@date_sent_to_company, ''),
    company_response_raw =
        NULLIF(@company_response, ''),
    timely_response_raw =
        NULLIF(@timely_response, ''),
    complaint_id_raw =
        NULLIF(TRIM(TRAILING '\r' FROM @complaint_id), ''),
    source_file = 'money_transfers_2024.csv';


LOAD DATA LOCAL INFILE 'C:/path/to/CFPB_Banking_Project/money_transfers_2025.csv'
INTO TABLE complaints_raw
CHARACTER SET utf8mb4
FIELDS
    TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @date_received,
    @product,
    @sub_product,
    @issue,
    @sub_issue,
    @company_public_response,
    @company,
    @state,
    @zip_code,
    @tags,
    @submitted_via,
    @date_sent_to_company,
    @company_response,
    @timely_response,
    @complaint_id
)
SET
    date_received_raw = NULLIF(@date_received, ''),
    product_raw = NULLIF(@product, ''),
    sub_product_raw = NULLIF(@sub_product, ''),
    issue_raw = NULLIF(@issue, ''),
    sub_issue_raw = NULLIF(@sub_issue, ''),
    company_public_response_raw =
        NULLIF(@company_public_response, ''),
    company_raw = NULLIF(@company, ''),
    state_raw = NULLIF(@state, ''),
    zip_code_raw = NULLIF(@zip_code, ''),
    tags_raw = NULLIF(@tags, ''),
    submitted_via_raw = NULLIF(@submitted_via, ''),
    date_sent_to_company_raw =
        NULLIF(@date_sent_to_company, ''),
    company_response_raw =
        NULLIF(@company_response, ''),
    timely_response_raw =
        NULLIF(@timely_response, ''),
    complaint_id_raw =
        NULLIF(TRIM(TRAILING '\r' FROM @complaint_id), ''),
    source_file = 'money_transfers_2025.csv';


LOAD DATA LOCAL INFILE 'C:/path/to/CFPB_Banking_Project/mortgage_2021.csv'
INTO TABLE complaints_raw
CHARACTER SET utf8mb4
FIELDS
    TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @date_received,
    @product,
    @sub_product,
    @issue,
    @sub_issue,
    @company_public_response,
    @company,
    @state,
    @zip_code,
    @tags,
    @submitted_via,
    @date_sent_to_company,
    @company_response,
    @timely_response,
    @complaint_id
)
SET
    date_received_raw = NULLIF(@date_received, ''),
    product_raw = NULLIF(@product, ''),
    sub_product_raw = NULLIF(@sub_product, ''),
    issue_raw = NULLIF(@issue, ''),
    sub_issue_raw = NULLIF(@sub_issue, ''),
    company_public_response_raw =
        NULLIF(@company_public_response, ''),
    company_raw = NULLIF(@company, ''),
    state_raw = NULLIF(@state, ''),
    zip_code_raw = NULLIF(@zip_code, ''),
    tags_raw = NULLIF(@tags, ''),
    submitted_via_raw = NULLIF(@submitted_via, ''),
    date_sent_to_company_raw =
        NULLIF(@date_sent_to_company, ''),
    company_response_raw =
        NULLIF(@company_response, ''),
    timely_response_raw =
        NULLIF(@timely_response, ''),
    complaint_id_raw =
        NULLIF(TRIM(TRAILING '\r' FROM @complaint_id), ''),
    source_file = 'mortgage_2021.csv';


LOAD DATA LOCAL INFILE 'C:/path/to/CFPB_Banking_Project/mortgage_2022.csv'
INTO TABLE complaints_raw
CHARACTER SET utf8mb4
FIELDS
    TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @date_received,
    @product,
    @sub_product,
    @issue,
    @sub_issue,
    @company_public_response,
    @company,
    @state,
    @zip_code,
    @tags,
    @submitted_via,
    @date_sent_to_company,
    @company_response,
    @timely_response,
    @complaint_id
)
SET
    date_received_raw = NULLIF(@date_received, ''),
    product_raw = NULLIF(@product, ''),
    sub_product_raw = NULLIF(@sub_product, ''),
    issue_raw = NULLIF(@issue, ''),
    sub_issue_raw = NULLIF(@sub_issue, ''),
    company_public_response_raw =
        NULLIF(@company_public_response, ''),
    company_raw = NULLIF(@company, ''),
    state_raw = NULLIF(@state, ''),
    zip_code_raw = NULLIF(@zip_code, ''),
    tags_raw = NULLIF(@tags, ''),
    submitted_via_raw = NULLIF(@submitted_via, ''),
    date_sent_to_company_raw =
        NULLIF(@date_sent_to_company, ''),
    company_response_raw =
        NULLIF(@company_response, ''),
    timely_response_raw =
        NULLIF(@timely_response, ''),
    complaint_id_raw =
        NULLIF(TRIM(TRAILING '\r' FROM @complaint_id), ''),
    source_file = 'mortgage_2022.csv';


LOAD DATA LOCAL INFILE 'C:/path/to/CFPB_Banking_Project/mortgage_2023.csv'
INTO TABLE complaints_raw
CHARACTER SET utf8mb4
FIELDS
    TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @date_received,
    @product,
    @sub_product,
    @issue,
    @sub_issue,
    @company_public_response,
    @company,
    @state,
    @zip_code,
    @tags,
    @submitted_via,
    @date_sent_to_company,
    @company_response,
    @timely_response,
    @complaint_id
)
SET
    date_received_raw = NULLIF(@date_received, ''),
    product_raw = NULLIF(@product, ''),
    sub_product_raw = NULLIF(@sub_product, ''),
    issue_raw = NULLIF(@issue, ''),
    sub_issue_raw = NULLIF(@sub_issue, ''),
    company_public_response_raw =
        NULLIF(@company_public_response, ''),
    company_raw = NULLIF(@company, ''),
    state_raw = NULLIF(@state, ''),
    zip_code_raw = NULLIF(@zip_code, ''),
    tags_raw = NULLIF(@tags, ''),
    submitted_via_raw = NULLIF(@submitted_via, ''),
    date_sent_to_company_raw =
        NULLIF(@date_sent_to_company, ''),
    company_response_raw =
        NULLIF(@company_response, ''),
    timely_response_raw =
        NULLIF(@timely_response, ''),
    complaint_id_raw =
        NULLIF(TRIM(TRAILING '\r' FROM @complaint_id), ''),
    source_file = 'mortgage_2023.csv';


LOAD DATA LOCAL INFILE 'C:/path/to/CFPB_Banking_Project/mortgage_2024.csv'
INTO TABLE complaints_raw
CHARACTER SET utf8mb4
FIELDS
    TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @date_received,
    @product,
    @sub_product,
    @issue,
    @sub_issue,
    @company_public_response,
    @company,
    @state,
    @zip_code,
    @tags,
    @submitted_via,
    @date_sent_to_company,
    @company_response,
    @timely_response,
    @complaint_id
)
SET
    date_received_raw = NULLIF(@date_received, ''),
    product_raw = NULLIF(@product, ''),
    sub_product_raw = NULLIF(@sub_product, ''),
    issue_raw = NULLIF(@issue, ''),
    sub_issue_raw = NULLIF(@sub_issue, ''),
    company_public_response_raw =
        NULLIF(@company_public_response, ''),
    company_raw = NULLIF(@company, ''),
    state_raw = NULLIF(@state, ''),
    zip_code_raw = NULLIF(@zip_code, ''),
    tags_raw = NULLIF(@tags, ''),
    submitted_via_raw = NULLIF(@submitted_via, ''),
    date_sent_to_company_raw =
        NULLIF(@date_sent_to_company, ''),
    company_response_raw =
        NULLIF(@company_response, ''),
    timely_response_raw =
        NULLIF(@timely_response, ''),
    complaint_id_raw =
        NULLIF(TRIM(TRAILING '\r' FROM @complaint_id), ''),
    source_file = 'mortgage_2024.csv';


LOAD DATA LOCAL INFILE 'C:/path/to/CFPB_Banking_Project/mortgage_2025.csv'
INTO TABLE complaints_raw
CHARACTER SET utf8mb4
FIELDS
    TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @date_received,
    @product,
    @sub_product,
    @issue,
    @sub_issue,
    @company_public_response,
    @company,
    @state,
    @zip_code,
    @tags,
    @submitted_via,
    @date_sent_to_company,
    @company_response,
    @timely_response,
    @complaint_id
)
SET
    date_received_raw = NULLIF(@date_received, ''),
    product_raw = NULLIF(@product, ''),
    sub_product_raw = NULLIF(@sub_product, ''),
    issue_raw = NULLIF(@issue, ''),
    sub_issue_raw = NULLIF(@sub_issue, ''),
    company_public_response_raw =
        NULLIF(@company_public_response, ''),
    company_raw = NULLIF(@company, ''),
    state_raw = NULLIF(@state, ''),
    zip_code_raw = NULLIF(@zip_code, ''),
    tags_raw = NULLIF(@tags, ''),
    submitted_via_raw = NULLIF(@submitted_via, ''),
    date_sent_to_company_raw =
        NULLIF(@date_sent_to_company, ''),
    company_response_raw =
        NULLIF(@company_response, ''),
    timely_response_raw =
        NULLIF(@timely_response, ''),
    complaint_id_raw =
        NULLIF(TRIM(TRAILING '\r' FROM @complaint_id), ''),
    source_file = 'mortgage_2025.csv';


LOAD DATA LOCAL INFILE 'C:/path/to/CFPB_Banking_Project/prepaid_card_2024.csv'
INTO TABLE complaints_raw
CHARACTER SET utf8mb4
FIELDS
    TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @date_received,
    @product,
    @sub_product,
    @issue,
    @sub_issue,
    @company_public_response,
    @company,
    @state,
    @zip_code,
    @tags,
    @submitted_via,
    @date_sent_to_company,
    @company_response,
    @timely_response,
    @complaint_id
)
SET
    date_received_raw = NULLIF(@date_received, ''),
    product_raw = NULLIF(@product, ''),
    sub_product_raw = NULLIF(@sub_product, ''),
    issue_raw = NULLIF(@issue, ''),
    sub_issue_raw = NULLIF(@sub_issue, ''),
    company_public_response_raw =
        NULLIF(@company_public_response, ''),
    company_raw = NULLIF(@company, ''),
    state_raw = NULLIF(@state, ''),
    zip_code_raw = NULLIF(@zip_code, ''),
    tags_raw = NULLIF(@tags, ''),
    submitted_via_raw = NULLIF(@submitted_via, ''),
    date_sent_to_company_raw =
        NULLIF(@date_sent_to_company, ''),
    company_response_raw =
        NULLIF(@company_response, ''),
    timely_response_raw =
        NULLIF(@timely_response, ''),
    complaint_id_raw =
        NULLIF(TRIM(TRAILING '\r' FROM @complaint_id), ''),
    source_file = 'prepaid_card_2024.csv';


LOAD DATA LOCAL INFILE 'C:/path/to/CFPB_Banking_Project/prepaid_card_2025.csv'
INTO TABLE complaints_raw
CHARACTER SET utf8mb4
FIELDS
    TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @date_received,
    @product,
    @sub_product,
    @issue,
    @sub_issue,
    @company_public_response,
    @company,
    @state,
    @zip_code,
    @tags,
    @submitted_via,
    @date_sent_to_company,
    @company_response,
    @timely_response,
    @complaint_id
)
SET
    date_received_raw = NULLIF(@date_received, ''),
    product_raw = NULLIF(@product, ''),
    sub_product_raw = NULLIF(@sub_product, ''),
    issue_raw = NULLIF(@issue, ''),
    sub_issue_raw = NULLIF(@sub_issue, ''),
    company_public_response_raw =
        NULLIF(@company_public_response, ''),
    company_raw = NULLIF(@company, ''),
    state_raw = NULLIF(@state, ''),
    zip_code_raw = NULLIF(@zip_code, ''),
    tags_raw = NULLIF(@tags, ''),
    submitted_via_raw = NULLIF(@submitted_via, ''),
    date_sent_to_company_raw =
        NULLIF(@date_sent_to_company, ''),
    company_response_raw =
        NULLIF(@company_response, ''),
    timely_response_raw =
        NULLIF(@timely_response, ''),
    complaint_id_raw =
        NULLIF(TRIM(TRAILING '\r' FROM @complaint_id), ''),
    source_file = 'prepaid_card_2025.csv';


LOAD DATA LOCAL INFILE 'C:/path/to/CFPB_Banking_Project/vehicle_loans_2021.csv'
INTO TABLE complaints_raw
CHARACTER SET utf8mb4
FIELDS
    TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @date_received,
    @product,
    @sub_product,
    @issue,
    @sub_issue,
    @company_public_response,
    @company,
    @state,
    @zip_code,
    @tags,
    @submitted_via,
    @date_sent_to_company,
    @company_response,
    @timely_response,
    @complaint_id
)
SET
    date_received_raw = NULLIF(@date_received, ''),
    product_raw = NULLIF(@product, ''),
    sub_product_raw = NULLIF(@sub_product, ''),
    issue_raw = NULLIF(@issue, ''),
    sub_issue_raw = NULLIF(@sub_issue, ''),
    company_public_response_raw =
        NULLIF(@company_public_response, ''),
    company_raw = NULLIF(@company, ''),
    state_raw = NULLIF(@state, ''),
    zip_code_raw = NULLIF(@zip_code, ''),
    tags_raw = NULLIF(@tags, ''),
    submitted_via_raw = NULLIF(@submitted_via, ''),
    date_sent_to_company_raw =
        NULLIF(@date_sent_to_company, ''),
    company_response_raw =
        NULLIF(@company_response, ''),
    timely_response_raw =
        NULLIF(@timely_response, ''),
    complaint_id_raw =
        NULLIF(TRIM(TRAILING '\r' FROM @complaint_id), ''),
    source_file = 'vehicle_loans_2021.csv';


LOAD DATA LOCAL INFILE 'C:/path/to/CFPB_Banking_Project/vehicle_loans_2022.csv'
INTO TABLE complaints_raw
CHARACTER SET utf8mb4
FIELDS
    TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @date_received,
    @product,
    @sub_product,
    @issue,
    @sub_issue,
    @company_public_response,
    @company,
    @state,
    @zip_code,
    @tags,
    @submitted_via,
    @date_sent_to_company,
    @company_response,
    @timely_response,
    @complaint_id
)
SET
    date_received_raw = NULLIF(@date_received, ''),
    product_raw = NULLIF(@product, ''),
    sub_product_raw = NULLIF(@sub_product, ''),
    issue_raw = NULLIF(@issue, ''),
    sub_issue_raw = NULLIF(@sub_issue, ''),
    company_public_response_raw =
        NULLIF(@company_public_response, ''),
    company_raw = NULLIF(@company, ''),
    state_raw = NULLIF(@state, ''),
    zip_code_raw = NULLIF(@zip_code, ''),
    tags_raw = NULLIF(@tags, ''),
    submitted_via_raw = NULLIF(@submitted_via, ''),
    date_sent_to_company_raw =
        NULLIF(@date_sent_to_company, ''),
    company_response_raw =
        NULLIF(@company_response, ''),
    timely_response_raw =
        NULLIF(@timely_response, ''),
    complaint_id_raw =
        NULLIF(TRIM(TRAILING '\r' FROM @complaint_id), ''),
    source_file = 'vehicle_loans_2022.csv';


LOAD DATA LOCAL INFILE 'C:/path/to/CFPB_Banking_Project/vehicle_loans_2023.csv'
INTO TABLE complaints_raw
CHARACTER SET utf8mb4
FIELDS
    TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @date_received,
    @product,
    @sub_product,
    @issue,
    @sub_issue,
    @company_public_response,
    @company,
    @state,
    @zip_code,
    @tags,
    @submitted_via,
    @date_sent_to_company,
    @company_response,
    @timely_response,
    @complaint_id
)
SET
    date_received_raw = NULLIF(@date_received, ''),
    product_raw = NULLIF(@product, ''),
    sub_product_raw = NULLIF(@sub_product, ''),
    issue_raw = NULLIF(@issue, ''),
    sub_issue_raw = NULLIF(@sub_issue, ''),
    company_public_response_raw =
        NULLIF(@company_public_response, ''),
    company_raw = NULLIF(@company, ''),
    state_raw = NULLIF(@state, ''),
    zip_code_raw = NULLIF(@zip_code, ''),
    tags_raw = NULLIF(@tags, ''),
    submitted_via_raw = NULLIF(@submitted_via, ''),
    date_sent_to_company_raw =
        NULLIF(@date_sent_to_company, ''),
    company_response_raw =
        NULLIF(@company_response, ''),
    timely_response_raw =
        NULLIF(@timely_response, ''),
    complaint_id_raw =
        NULLIF(TRIM(TRAILING '\r' FROM @complaint_id), ''),
    source_file = 'vehicle_loans_2023.csv';


LOAD DATA LOCAL INFILE 'C:/path/to/CFPB_Banking_Project/vehicle_loans_2024.csv'
INTO TABLE complaints_raw
CHARACTER SET utf8mb4
FIELDS
    TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @date_received,
    @product,
    @sub_product,
    @issue,
    @sub_issue,
    @company_public_response,
    @company,
    @state,
    @zip_code,
    @tags,
    @submitted_via,
    @date_sent_to_company,
    @company_response,
    @timely_response,
    @complaint_id
)
SET
    date_received_raw = NULLIF(@date_received, ''),
    product_raw = NULLIF(@product, ''),
    sub_product_raw = NULLIF(@sub_product, ''),
    issue_raw = NULLIF(@issue, ''),
    sub_issue_raw = NULLIF(@sub_issue, ''),
    company_public_response_raw =
        NULLIF(@company_public_response, ''),
    company_raw = NULLIF(@company, ''),
    state_raw = NULLIF(@state, ''),
    zip_code_raw = NULLIF(@zip_code, ''),
    tags_raw = NULLIF(@tags, ''),
    submitted_via_raw = NULLIF(@submitted_via, ''),
    date_sent_to_company_raw =
        NULLIF(@date_sent_to_company, ''),
    company_response_raw =
        NULLIF(@company_response, ''),
    timely_response_raw =
        NULLIF(@timely_response, ''),
    complaint_id_raw =
        NULLIF(TRIM(TRAILING '\r' FROM @complaint_id), ''),
    source_file = 'vehicle_loans_2024.csv';


LOAD DATA LOCAL INFILE 'C:/path/to/CFPB_Banking_Project/vehicle_loans_2025.csv'
INTO TABLE complaints_raw
CHARACTER SET utf8mb4
FIELDS
    TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @date_received,
    @product,
    @sub_product,
    @issue,
    @sub_issue,
    @company_public_response,
    @company,
    @state,
    @zip_code,
    @tags,
    @submitted_via,
    @date_sent_to_company,
    @company_response,
    @timely_response,
    @complaint_id
)
SET
    date_received_raw = NULLIF(@date_received, ''),
    product_raw = NULLIF(@product, ''),
    sub_product_raw = NULLIF(@sub_product, ''),
    issue_raw = NULLIF(@issue, ''),
    sub_issue_raw = NULLIF(@sub_issue, ''),
    company_public_response_raw =
        NULLIF(@company_public_response, ''),
    company_raw = NULLIF(@company, ''),
    state_raw = NULLIF(@state, ''),
    zip_code_raw = NULLIF(@zip_code, ''),
    tags_raw = NULLIF(@tags, ''),
    submitted_via_raw = NULLIF(@submitted_via, ''),
    date_sent_to_company_raw =
        NULLIF(@date_sent_to_company, ''),
    company_response_raw =
        NULLIF(@company_response, ''),
    timely_response_raw =
        NULLIF(@timely_response, ''),
    complaint_id_raw =
        NULLIF(TRIM(TRAILING '\r' FROM @complaint_id), ''),
    source_file = 'vehicle_loans_2025.csv';

SET GLOBAL local_infile = 0;

-- Validate total imported records
SELECT COUNT(*) AS total_rows
FROM complaints_raw;

-- Validate number of source files
SELECT COUNT(DISTINCT source_file) AS file_count
FROM complaints_raw;

-- Validate the number of records imported from each file
SELECT
    source_file,
    COUNT(*) AS row_count
FROM complaints_raw
GROUP BY source_file
ORDER BY source_file;
