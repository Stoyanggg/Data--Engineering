
/*

This script performs the following operations:

1. Inserts data into the Employee_Dim table from the Employees.


2. Inserts data into the Department_Dim table from the departments table.
    - Generates surrogate_department_id using a hash function.

3. Inserts data into the Job_Dim table from the jobs table.
    - Generates surrogate_job_id using a hash function.
    - Categorizes jobs into 'Management', 'Technical/Professional', 'Clerical/Support', or 'Other'.

4. Inserts data into the Location_Dim table by joining LOCATIONS, COUNTRIES, and REGIONS tables.
    - Generates surrogate_location_id using a hash function.

5. Inserts data into the Employee_Salary_Fact table by joining Employee_Dim, Department_Dim, Job_Dim, Location_Dim, and Time_Dim tables.
    - Generates surrogate_fact_id using a hash function.
    - Calculates bonus and total_compensation.

*/



-- Populate EMPLOYEE_DIM

INSERT INTO EMPLOYEE_DIM(surrogate_employee_id,employee_id,full_name,hire_date,email,phone_number,manager_id,department_id,tenure_band)
SELECT 
DBMS_CRYPTO.HASH(UTL_RAW.CAST_TO_RAW(employee_id || first_name || last_name || hire_date || email || phone_number || manager_id || department_id),  2) as surrogate_employee_id,
EMPLOYEE_ID,
FIRST_NAME||' '||LAST_NAME as full_name,
HIRE_DATE as hire_date,
EMAIL || '@oracle.com' as email, 
'+359' || replace(PHONE_NUMBER,'.','') as phone_number ,
MANAGER_ID,
DEPARTMENT_ID,
CASE
    WHEN EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM HIRE_DATE) < 1 then 'Less than One'
    WHEN EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM HIRE_DATE) BETWEEN 1 and 3 then '1-3 years'
    WHEN EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM HIRE_DATE) BETWEEN 4 and 6 then '4-6 years'
    WHEN EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM HIRE_DATE) BETWEEN 7 and 10 then '7-10 years'
    ELSE '10+ years'
END AS tenure_band 
FROM EMPLOYEES;

COMMIT;


-- Populate Department_Dim

INSERT INTO  Department_Dim (surrogate_department_id,department_id, department_name,location_id,manager_id)
SELECT 
DBMS_CRYPTO.HASH(UTL_RAW.CAST_TO_RAW(department_id || department_name || location_id || manager_id), 2) as surrogate_department_id,
department_id,
department_name,
location_id,
manager_id 
FROM DEPARTMENTS;

COMMIT;


-- Populate Job_Dim

INSERT INTO Job_Dim(surrogate_job_id,job_id, job_title,min_salary, max_salary,job_category)
SELECT 
DBMS_CRYPTO.HASH(UTL_RAW.CAST_TO_RAW(job_id || job_title || min_salary || max_salary), 2) as surrogate_job_id,
job_id, job_title,MIN_SALARY, MAX_SALARY,
CASE  
    WHEN JOB_TITLE in ('Accounting Manager','Purchasing Manager','Sales Manager','Stock Manager','Administration Vice President',
    'Marketing Manager','Finance Manager','President') THEN 'Management'
    WHEN JOB_TITLE in ('Programmer','Public Accountant','Accountant','Public Relations Representative','Human Resources Representative',
    'Marketing Representative') THEN 'Technical/Professionan'
    WHEN JOB_TITLE in ('Administration Assistant', 'Purchasing Clerk','Shipping Clerk','Stock Clerk') THEN 'Clerical/Support'
    ELSE 'Other'
END AS job_category
FROM JOBS;

SELECT * from Job_Dim;

COMMIT;


--  Populate Location_Dim

INSERT INTO Location_Dim (surrogate_location_id,location_id ,street_address ,postal_code ,city ,state_province ,country_id ,country_name ,region_id ,region_name )
SELECT
DBMS_CRYPTO.HASH(UTL_RAW.CAST_TO_RAW(l.location_id || l.street_address || l.postal_code || l.city || l.state_province || c.country_id || c.country_name || r.region_id || r.region_name), 2) as surrogate_location_id,
l.location_id,
l.street_address,
l.postal_code,
l.city,
l.state_province,
l.country_id,
c.country_name,
r.region_id, 
r.region_name
FROM LOCATIONS l 
LEFT JOIN COUNTRIES c 
ON c.COUNTRY_ID = l.COUNTRY_ID
LEFT JOIN regions r 
ON r.region_id = c.region_id;

select * from Location_Dim;

COMMIT;


--  Populate Time_Dim

DECLARE
    v_start_date DATE := TO_DATE('01-01-1995', 'dd-MM-yyyy');  -- Start date, adjusted to cover the earliest date in the data
    v_end_date   DATE := TO_DATE('31-12-2018', 'dd-MM-yyyy');  -- End date, extended slightly beyond the latest date in the data
BEGIN
    FOR d IN (SELECT v_start_date + LEVEL - 1 AS current_date
              FROM DUAL
              CONNECT BY LEVEL <= (v_end_date - v_start_date + 1))
    LOOP
        INSERT INTO Time_Dim (
            surrogate_time_id,
            time_id,
            dates,
            year,
            quarter,
            month,
            week,
            day,
            day_of_week,
            fiscal_year,
            fiscal_quarter
        )
        VALUES (
            SYS_GUID(),  -- Generate a unique surrogate key
            TO_NUMBER(TO_CHAR(d.current_date, 'YYYYMMDD')),  -- Generate time_id in YYYYMMDD format
            d.current_date,  -- Date value
            TO_NUMBER(TO_CHAR(d.current_date, 'YYYY')),  -- Year value
            TO_NUMBER(TO_CHAR(d.current_date, 'Q')),  -- Quarter value
            TO_NUMBER(TO_CHAR(d.current_date, 'MM')),  -- Month value
            TO_NUMBER(TO_CHAR(d.current_date, 'IW')),  -- ISO week of year
            TO_NUMBER(TO_CHAR(d.current_date, 'DD')),  -- Day of the month
            TO_CHAR(d.current_date, 'Day', 'NLS_DATE_LANGUAGE=ENGLISH'),  -- Day of the week
            TO_NUMBER(TO_CHAR(d.current_date, 'YYYY')),  -- Fiscal year (assumed to align with calendar year)
            TO_NUMBER(TO_CHAR(d.current_date, 'Q'))  -- Fiscal quarter (assumed to align with calendar quarters)
        );
    END LOOP;

    COMMIT;
END;
/
SELECT * from Time_Dim;

COMMIT;


--  Populate Employee_Salary_Fact

INSERT INTO Employee_Salary_Fact (
    surrogate_fact_id,
    surrogate_employee_id,
    surrogate_department_id,
    surrogate_job_id,
    surrogate_time_id,
    surrogate_location_id,
    salary,
    bonus,
    total_compensation,
    effective_date
)
SELECT 
    DBMS_CRYPTO.HASH(UTL_RAW.CAST_TO_RAW(ed.surrogate_employee_id || dd.surrogate_department_id || jd.surrogate_job_id || ld.surrogate_location_id || td.surrogate_time_id), 2) AS surrogate_fact_id,
    ed.surrogate_employee_id,
    dd.surrogate_department_id,
    jd.surrogate_job_id,
    td.surrogate_time_id,
    ld.surrogate_location_id,
    e.salary,
    COALESCE (e.salary * e.COMMISSION_PCT, 0) AS bonus,
    e.salary + COALESCE (e.salary * e.COMMISSION_PCT, 0) AS total_compensation,
	COALESCE (jh.START_DATE, e.hire_date) AS effective_date
FROM hr.employees e
LEFT JOIN Employee_Dim ed
    ON e.employee_id = ed.employee_id
LEFT JOIN Department_Dim dd 
    ON e.department_id = dd.department_id
LEFT JOIN Job_Dim jd
    ON e.job_id = jd.job_id
LEFT JOIN Location_Dim ld
    ON dd.location_id = ld.location_id
LEFT JOIN hr.job_history jh 
    ON e.employee_id = jh.employee_id
LEFT JOIN Time_Dim td 
    ON to_number(to_char(COALESCE (jh.START_DATE, e.hire_date), 'YYYYMMDD')) = td.time_id;

COMMIT;

