/*

This script creates and populates dimension and fact tables for an HR database, along with views to simplify data retrieval.

Tables:
1. Employee_Dim: Stores employee details.
    - surrogate_employee_id: Unique identifier for each employee.
    - employee_id: Original employee ID.
    - full_name: Full name of the employee.
    - hire_date: Date of hiring.
    - email: Employee's email.
    - phone_number: Employee's phone number.
    - manager_id: Manager's ID.
    - department_id: Department ID.
    - tenure_band: Tenure band of the employee.

2. Department_Dim: Stores department details.
    - surrogate_department_id: Unique identifier for each department.
    - department_id: Original department ID.
    - department_name: Name of the department.
    - location_id: Location ID.
    - manager_id: Manager's ID.

3. Job_Dim: Stores job details.
    - surrogate_job_id: Unique identifier for each job.
    - job_id: Original job ID.
    - job_title: Title of the job.
    - min_salary: Minimum salary for the job.
    - max_salary: Maximum salary for the job.
    - job_category: Category of the job.


4. Location_Dim: Stores location details.
    - surrogate_location_id: Unique identifier for each location.
    - location_id: Original location ID.
    - street_address: Street address.
    - postal_code: Postal code.
    - city: City name.
    - state_province: State or province.
    - country_id: Country ID.
    - country_name: Country name.
    - region_id: Region ID.
    - region_name: Region name.

5. Time_Dim: Stores time details.
    - surrogate_time_id: Unique identifier for each time entry.
    - time_id: Time ID in YYYYMMDD format.
    - dates: Date value.
    - year: Year value.
    - quarter: Quarter value.
    - month: Month value.
    - week: ISO week of the year.
    - day: Day of the month.
    - day_of_week: Day of the week.
    - fiscal_year: Fiscal year.
    - fiscal_quarter: Fiscal quarter.

6. Employee_Salary_Fact: Stores employee salary details.
    - surrogate_fact_id: Unique identifier for each fact entry.
    - surrogate_employee_id: Foreign key to Employee_Dim.
    - surrogate_department_id: Foreign key to Department_Dim.
    - surrogate_job_id: Foreign key to Job_Dim.
    - surrogate_time_id: Foreign key to Time_Dim.
    - surrogate_location_id: Foreign key to Location_Dim.
    - salary: Employee's salary.
    - bonus: Bonus amount.
    - total_compensation: Total compensation (salary + bonus).
    - effective_date: Effective date of the record.

*/



-- Create Employee Dimension Table

CREATE TABLE Employee_Dim (surrogate_employee_id  RAW(16) PRIMARY KEY , 
employee_id NUMBER,
full_name VARCHAR2(252),
hire_date date,
email VARCHAR2(252),
phone_number VARCHAR2(252),
manager_id NUMBER,
department_id NUMBER,
tenure_band VARCHAR2(252) 
);

SELECT *from Employee_Dim;


-- Create Department Dimension Table


CREATE TABLE Department_Dim (surrogate_department_id RAW(16) PRIMARY KEY,
department_id NUMBER,
department_name VARCHAR2(252),
location_id NUMBER,
manager_id NUMBER);

SELECT * FROM Department_Dim;


-- Create Job Dimension Table

CREATE TABLE Job_Dim(
surrogate_job_id RAW(16) PRIMARY KEY,
job_id VARCHAR2(252),
job_title VARCHAR2(252),
min_salary NUMBER,
max_salary NUMBER ,
job_category VARCHAR2(252)
);



-- Create Location Dimension Table
CREATE TABLE Location_Dim(
surrogate_location_id RAW(16) PRIMARY KEY,
location_id NUMBER ,
street_address VARCHAR2(252),
postal_code VARCHAR2(252),
city VARCHAR2(252),
state_province VARCHAR2(252),
country_id CHAR(2),
country_name VARCHAR2(252),
region_id NUMBER,
region_name VARCHAR2(252)
);



-- Create Time Dimension Table

CREATE TABLE Time_Dim (
    surrogate_time_id   RAW(16) PRIMARY KEY,  
    time_id             NUMBER,  
    dates                DATE,  
    year                NUMBER, 
    quarter             NUMBER,  
    month               NUMBER, 
    week                NUMBER, 
    day                 NUMBER,  
    day_of_week         VARCHAR2(10), 
    fiscal_year         NUMBER, 
    fiscal_quarter      NUMBER  
);


-- Create Fact Table

CREATE TABLE Employee_Salary_Fact(

surrogate_fact_id RAW(16) PRIMARY KEY , 
surrogate_employee_id RAW(16) ,
surrogate_department_id RAW(16) ,
surrogate_job_id RAW(16) , 
surrogate_time_id RAW(16) ,
surrogate_location_id RAW(16) ,
salary number ,
bonus number ,
total_compensation number,
effective_date date,

FOREIGN KEY (surrogate_employee_id) REFERENCES Employee_Dim(surrogate_employee_id),
    FOREIGN KEY (surrogate_department_id) REFERENCES Department_Dim(surrogate_department_id),
    FOREIGN KEY (surrogate_job_id) REFERENCES Job_Dim(surrogate_job_id),
    FOREIGN KEY (surrogate_time_id) REFERENCES Time_Dim(surrogate_time_id),
FOREIGN KEY (surrogate_location_id) REFERENCES Location_Dim(surrogate_location_id));

