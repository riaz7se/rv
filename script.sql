-- Step 1: Create backup tables
CREATE TABLE TR_FORM_BACKUP AS SELECT * FROM TR_FORM;
CREATE TABLE TR_FIELD_VALUE_BACKUP AS SELECT * FROM TR_FIELD_VALUE;

-- Step 2: Identify the 2nd latest tr_form_seq for each dr_request_seq
WITH ranked_forms AS (
  SELECT 
    tr_form_seq,
    dr_request_seq,
    ROW_NUMBER() OVER (PARTITION BY dr_request_seq ORDER BY tr_form_seq DESC) as rn
  FROM TR_FORM
)
SELECT tr_form_seq
INTO temp_delete_list
FROM ranked_forms
WHERE rn = 2;

-- Step 3: Delete the identified rows from TR_FIELD_VALUE
DELETE FROM TR_FIELD_VALUE
WHERE tr_form_seq IN (SELECT tr_form_seq FROM temp_delete_list);

-- Step 4: Delete the identified rows from TR_FORM
DELETE FROM TR_FORM
WHERE tr_form_seq IN (SELECT tr_form_seq FROM temp_delete_list);

-- Clean up temporary table
DROP TABLE temp_delete_list;

-- Commit the changes
COMMIT;
