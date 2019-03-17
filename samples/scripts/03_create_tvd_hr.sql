----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 02_create_tvd_hr.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2018.12.10
--  Revision..:  
--  Purpose...: Main script to create the TVD_HR schema
--  Notes.....:  
--  Reference.: SYS (or grant manually to a DBA)
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------

SET ECHO OFF
SET VERIFY OFF
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100 

SPOOL 02_create_tvd_hr.log

----------------------------------------------------------------------------
-- cleanup section 
DECLARE
vcount INTEGER :=0;
BEGIN
SELECT count(1) INTO vcount FROM dba_users WHERE username = 'TVD_HR';
IF vcount != 0 THEN
EXECUTE IMMEDIATE ('DROP USER tvd_hr CASCADE');
END IF;
END;
/

----------------------------------------------------------------------------
-- create user 
CREATE USER tvd_hr IDENTIFIED BY &pass;

ALTER USER tvd_hr DEFAULT TABLESPACE &tbs
    QUOTA UNLIMITED ON &tbs;

ALTER USER tvd_hr TEMPORARY TABLESPACE &ttbs;

GRANT CREATE SESSION, CREATE VIEW, ALTER SESSION, CREATE SEQUENCE TO tvd_hr;
GRANT CREATE SYNONYM, CREATE DATABASE LINK, RESOURCE , UNLIMITED TABLESPACE TO tvd_hr;

----------------------------------------------------------------------------
-- grants from sys schema
GRANT execute ON sys.dbms_stats TO tvd_hr;

----------------------------------------------------------------------------
-- create tvd_hr schema objects
ALTER SESSION SET CURRENT_SCHEMA=TVD_HR;

ALTER SESSION SET NLS_LANGUAGE=American;
ALTER SESSION SET NLS_TERRITORY=America;

----------------------------------------------------------------------------
-- create tables, sequences and constraint
----------------------------------------------------------------------------
-- Create the REGIONS table to hold region information for locations
-- TVD_HR.LOCATIONS table has a foreign key to this table.

Prompt ******  Creating REGIONS table ....
CREATE TABLE regions
    ( region_id      NUMBER 
       CONSTRAINT  region_id_nn NOT NULL 
    , region_name    VARCHAR2(25) 
    );

CREATE UNIQUE INDEX reg_id_pk
ON regions (region_id);

ALTER TABLE regions
ADD ( CONSTRAINT reg_id_pk
       		 PRIMARY KEY (region_id)
    ) ;

----------------------------------------------------------------------------
-- Create the COUNTRIES table to hold country information for customers
-- and company locations. 
-- TVD_HR.LOCATIONS has a foreign key to this table.

Prompt ******  Creating COUNTRIES table ....
CREATE TABLE countries 
    ( country_id      CHAR(2) 
       CONSTRAINT  country_id_nn NOT NULL 
    , country_name    VARCHAR2(40) 
    , region_id       NUMBER 
    , CONSTRAINT     country_c_id_pk 
        	     PRIMARY KEY (country_id) 
    ) 
    ORGANIZATION INDEX; 

ALTER TABLE countries
ADD ( CONSTRAINT countr_reg_fk
        	 FOREIGN KEY (region_id)
          	  REFERENCES regions(region_id) 
    ) ;

----------------------------------------------------------------------------
-- Create the LOCATIONS table to hold address information for company departments.
-- TVD_HR.DEPARTMENTS has a foreign key to this table.

Prompt ******  Creating LOCATIONS table ....
CREATE TABLE locations
    ( location_id    NUMBER(4)
    , street_address VARCHAR2(40)
    , postal_code    VARCHAR2(12)
    , city       VARCHAR2(30)
	CONSTRAINT     loc_city_nn  NOT NULL
    , state_province VARCHAR2(25)
    , country_id     CHAR(2)
    ) ;

CREATE UNIQUE INDEX loc_id_pk
ON locations (location_id) ;

ALTER TABLE locations
ADD ( CONSTRAINT loc_id_pk
       		 PRIMARY KEY (location_id)
    , CONSTRAINT loc_c_id_fk
       		 FOREIGN KEY (country_id)
        	  REFERENCES countries(country_id) 
    ) ;

-- Useful for any subsequent addition of rows to locations table
-- Starts with 3300
CREATE SEQUENCE locations_seq
 START WITH     3300
 INCREMENT BY   100
 MAXVALUE       9900
 NOCACHE
 NOCYCLE;

----------------------------------------------------------------------------
-- Create the DEPARTMENTS table to hold company department information.
-- TVD_HR.EMPLOYEES and TVD_HR.JOB_HISTORY have a foreign key to this table.

Prompt ******  Creating DEPARTMENTS table ....

CREATE TABLE departments
    ( department_id    NUMBER(4)
    , department_name  VARCHAR2(30)
	CONSTRAINT  dept_name_nn  NOT NULL
    , manager_id       NUMBER(6)
    , location_id      NUMBER(4)
    ) ;

CREATE UNIQUE INDEX dept_id_pk
ON departments (department_id) ;

ALTER TABLE departments
ADD ( CONSTRAINT dept_id_pk
       		 PRIMARY KEY (department_id)
    , CONSTRAINT dept_loc_fk
       		 FOREIGN KEY (location_id)
        	  REFERENCES locations (location_id)
     ) ;

-- Useful for any subsequent addition of rows to departments table
-- Starts with 100 
CREATE SEQUENCE departments_seq
 START WITH     100
 INCREMENT BY   10
 MAXVALUE       9990
 NOCACHE
 NOCYCLE;

----------------------------------------------------------------------------
-- Create the JOBS table to hold the different names of job roles within the company.
-- TVD_HR.EMPLOYEES has a foreign key to this table.

Prompt ******  Creating JOBS table ....
CREATE TABLE jobs
    ( job_id         VARCHAR2(10)
    , job_title      VARCHAR2(35)
	CONSTRAINT     job_title_nn  NOT NULL
    , min_salary     NUMBER(6)
    , max_salary     NUMBER(6)
    ) ;

CREATE UNIQUE INDEX job_id_pk 
ON jobs (job_id) ;

ALTER TABLE jobs
ADD ( CONSTRAINT job_id_pk
      		 PRIMARY KEY(job_id)
    ) ;

----------------------------------------------------------------------------
-- Create the EMPLOYEES table to hold the employee personnel 
-- information for the company.
-- TVD_HR.EMPLOYEES has a self referencing foreign key to this table.

Prompt ******  Creating EMPLOYEES table ....
CREATE TABLE employees
    ( employee_id    NUMBER(6)
    , first_name     VARCHAR2(20)
    , last_name      VARCHAR2(25)
	 CONSTRAINT     emp_last_name_nn  NOT NULL
    , email          VARCHAR2(50)
	CONSTRAINT     emp_email_nn  NOT NULL
    , phone_number   VARCHAR2(20)
    , hire_date      DATE
	CONSTRAINT     emp_hire_date_nn  NOT NULL
    , job_id         VARCHAR2(10)
	CONSTRAINT     emp_job_nn  NOT NULL
    , salary         NUMBER(8,2)
    , commission_pct NUMBER(2,2)
    , manager_id     NUMBER(6)
    , department_id  NUMBER(4)
    , CONSTRAINT     emp_salary_min
                     CHECK (salary > 0) 
    , CONSTRAINT     emp_email_uk
                     UNIQUE (email)
    ) ;

CREATE UNIQUE INDEX emp_emp_id_pk
ON employees (employee_id) ;

ALTER TABLE employees
ADD ( CONSTRAINT     emp_emp_id_pk
                     PRIMARY KEY (employee_id)
    , CONSTRAINT     emp_dept_fk
                     FOREIGN KEY (department_id)
                      REFERENCES departments
    , CONSTRAINT     emp_job_fk
                     FOREIGN KEY (job_id)
                      REFERENCES jobs (job_id)
    , CONSTRAINT     emp_manager_fk
                     FOREIGN KEY (manager_id)
                      REFERENCES employees
    ) ;

ALTER TABLE departments
ADD ( CONSTRAINT dept_mgr_fk
      		 FOREIGN KEY (manager_id)
      		  REFERENCES employees (employee_id)
    ) ;

-- Useful for any subsequent addition of rows to employees table
-- Starts with 207 
CREATE SEQUENCE employees_seq
 START WITH     207
 INCREMENT BY   1
 NOCACHE
 NOCYCLE;

----------------------------------------------------------------------------
-- Create the JOB_HISTORY table to hold the history of jobs that 
-- employees have held in the past.
-- TVD_HR.JOBS, TVD_HR_DEPARTMENTS, and TVD_HR.EMPLOYEES have a foreign key to this table.

Prompt ******  Creating JOB_HISTORY table ....
CREATE TABLE job_history
    ( employee_id   NUMBER(6)
	 CONSTRAINT    jhist_employee_nn  NOT NULL
    , start_date    DATE
	CONSTRAINT    jhist_start_date_nn  NOT NULL
    , end_date      DATE
	CONSTRAINT    jhist_end_date_nn  NOT NULL
    , job_id        VARCHAR2(10)
	CONSTRAINT    jhist_job_nn  NOT NULL
    , department_id NUMBER(4)
    , CONSTRAINT    jhist_date_interval
                    CHECK (end_date > start_date)
    ) ;

CREATE UNIQUE INDEX jhist_emp_id_st_date_pk 
ON job_history (employee_id, start_date) ;

ALTER TABLE job_history
ADD ( CONSTRAINT jhist_emp_id_st_date_pk
      PRIMARY KEY (employee_id, start_date)
    , CONSTRAINT     jhist_job_fk
                     FOREIGN KEY (job_id)
                     REFERENCES jobs
    , CONSTRAINT     jhist_emp_fk
                     FOREIGN KEY (employee_id)
                     REFERENCES employees
    , CONSTRAINT     jhist_dept_fk
                     FOREIGN KEY (department_id)
                     REFERENCES departments
    ) ;

----------------------------------------------------------------------------
-- Create the EMP_DETAILS_VIEW that joins the employees, jobs, 
-- departments, jobs, countries, and locations table to provide details
-- about employees.

Prompt ******  Creating EMP_DETAILS_VIEW view ...

CREATE OR REPLACE VIEW emp_details_view
  (employee_id,
   job_id,
   manager_id,
   department_id,
   location_id,
   country_id,
   first_name,
   last_name,
   salary,
   commission_pct,
   department_name,
   job_title,
   city,
   state_province,
   country_name,
   region_name)
AS SELECT
  e.employee_id, 
  e.job_id, 
  e.manager_id, 
  e.department_id,
  d.location_id,
  l.country_id,
  e.first_name,
  e.last_name,
  e.salary,
  e.commission_pct,
  d.department_name,
  j.job_title,
  l.city,
  l.state_province,
  c.country_name,
  r.region_name
FROM
  employees e,
  departments d,
  jobs j,
  locations l,
  countries c,
  regions r
WHERE e.department_id = d.department_id
  AND d.location_id = l.location_id
  AND l.country_id = c.country_id
  AND c.region_id = r.region_id
  AND j.job_id = e.job_id 
WITH READ ONLY;

COMMIT;

----------------------------------------------------------------------------
-- populate tables
SET VERIFY OFF
ALTER SESSION SET NLS_LANGUAGE=American; 

----------------------------------------------------------------------------
-- insert data into the REGIONS table

Prompt ******  Populating REGIONS table ....
INSERT INTO regions VALUES ( 1, 'Europe' );
INSERT INTO regions VALUES ( 2, 'Americas' );
INSERT INTO regions VALUES ( 3, 'Asia' );
INSERT INTO regions VALUES ( 4, 'Middle East and Africa' );

----------------------------------------------------------------------------
-- insert data into the COUNTRIES table

Prompt ******  Populating COUNTIRES table ....
INSERT INTO countries VALUES ( 'IT', 'Italy'                    , 1 );
INSERT INTO countries VALUES ( 'JP', 'Japan'                    , 3 );
INSERT INTO countries VALUES ( 'US', 'United States of America' , 2 );
INSERT INTO countries VALUES ( 'CA', 'Canada'                   , 2 );
INSERT INTO countries VALUES ( 'CN', 'China'                    , 3 );
INSERT INTO countries VALUES ( 'IN', 'India'                    , 3 );
INSERT INTO countries VALUES ( 'AU', 'Australia'                , 3 );
INSERT INTO countries VALUES ( 'ZW', 'Zimbabwe'                 , 4 );
INSERT INTO countries VALUES ( 'SG', 'Singapore'                , 3 );
INSERT INTO countries VALUES ( 'UK', 'United Kingdom'           , 1 );
INSERT INTO countries VALUES ( 'FR', 'France'                   , 1 );
INSERT INTO countries VALUES ( 'DE', 'Germany'                  , 1 );
INSERT INTO countries VALUES ( 'ZM', 'Zambia'                   , 4 );
INSERT INTO countries VALUES ( 'EG', 'Egypt'                    , 4 );
INSERT INTO countries VALUES ( 'BR', 'Brazil'                   , 2 );
INSERT INTO countries VALUES ( 'CH', 'Switzerland'              , 1 );
INSERT INTO countries VALUES ( 'NL', 'Netherlands'              , 1 );
INSERT INTO countries VALUES ( 'MX', 'Mexico'                   , 2 );
INSERT INTO countries VALUES ( 'KW', 'Kuwait'                   , 4 );
INSERT INTO countries VALUES ( 'IL', 'Israel'                   , 4 );
INSERT INTO countries VALUES ( 'DK', 'Denmark'                  , 1 );
INSERT INTO countries VALUES ( 'ML', 'Malaysia'                 , 3 );
INSERT INTO countries VALUES ( 'NG', 'Nigeria'                  , 4 );
INSERT INTO countries VALUES ( 'AR', 'Argentina'                , 2 );
INSERT INTO countries VALUES ( 'BE', 'Belgium'                  , 1 );

----------------------------------------------------------------------------
-- insert data into the LOCATIONS table

Prompt ******  Populating LOCATIONS table ....
INSERT INTO locations VALUES ( 1000 , '1297 Via Cola di Rie', '00989', 'Roma', NULL, 'IT');
INSERT INTO locations VALUES ( 1100 , '93091 Calle della Testa' , '10934' , 'Venice' , NULL , 'IT');
INSERT INTO locations VALUES ( 1200 , '2017 Shinjuku-ku' , '1689' , 'Tokyo' , 'Tokyo Prefecture' , 'JP');
INSERT INTO locations VALUES ( 1300 , '9450 Kamiya-cho' , '6823' , 'Hiroshima' , NULL , 'JP');
INSERT INTO locations VALUES ( 1400 , '2014 Jabberwocky Rd' , '26192' , 'Southlake' , 'Texas' , 'US');
INSERT INTO locations VALUES ( 1500 , '2011 Interiors Blvd' , '99236' , 'South San Francisco' , 'California' , 'US');
INSERT INTO locations VALUES ( 1600 , '2007 Zagora St' , '50090' , 'South Brunswick' , 'New Jersey' , 'US');
INSERT INTO locations VALUES ( 1700 , '2004 Charade Rd' , '98199' , 'Seattle' , 'Washington' , 'US');
INSERT INTO locations VALUES ( 1800 , '147 Spadina Ave' , 'M5V 2L7' , 'Toronto' , 'Ontario' , 'CA');
INSERT INTO locations VALUES ( 1900 , '6092 Boxwood St' , 'YSW 9T2' , 'Whitehorse' , 'Yukon' , 'CA');
INSERT INTO locations VALUES ( 2000 , '40-5-12 Laogianggen' , '190518' , 'Beijing' , NULL , 'CN');
INSERT INTO locations VALUES ( 2100 , '1298 Vileparle (E)' , '490231' , 'Bombay' , 'Maharashtra' , 'IN'); 
INSERT INTO locations VALUES ( 2200 , '12-98 Victoria Street' , '2901' , 'Sydney' , 'New South Wales' , 'AU'); 
INSERT INTO locations VALUES ( 2300 , '198 Clementi North' , '540198' , 'Singapore' , NULL , 'SG');
INSERT INTO locations VALUES ( 2400 , '8204 Arthur St' , NULL , 'London' , NULL , 'UK');
INSERT INTO locations VALUES ( 2500 , 'Magdalen Centre, The Oxford Science Park' , 'OX9 9ZB' , 'Oxford' , 'Oxford' , 'UK');
INSERT INTO locations VALUES ( 2600 , '9702 Chester Road' , '09629850293' , 'Stretford' , 'Manchester' , 'UK');
INSERT INTO locations VALUES ( 2700 , 'Schwanthalerstr. 7031' , '80925' , 'Munich' , 'Bavaria' , 'DE');
INSERT INTO locations VALUES ( 2800 , 'Rua Frei Caneca 1360 ' , '01307-002' , 'Sao Paulo' , 'Sao Paulo' , 'BR');
INSERT INTO locations VALUES ( 2900 , '20 Rue des Corps-Saints' , '1730' , 'Geneva' , 'Geneve' , 'CH');
INSERT INTO locations VALUES ( 3000 , 'Murtenstrasse 921' , '3095' , 'Bern' , 'BE' , 'CH');
INSERT INTO locations VALUES ( 3100 , 'Pieter Breughelstraat 837' , '3029SK' , 'Utrecht' , 'Utrecht' , 'NL');
INSERT INTO locations VALUES ( 3200 , 'Mariano Escobedo 9991' , '11932' , 'Mexico City' , 'Distrito Federal,' , 'MX');

----------------------------------------------------------------------------
-- insert data into the DEPARTMENTS table

Prompt ******  Populating DEPARTMENTS table ....

-- disable integrity constraint to EMPLOYEES to load data
ALTER TABLE departments 
  DISABLE CONSTRAINT dept_mgr_fk;

INSERT INTO departments VALUES ( 10, 'Senior Management'        , 100, 3000);
INSERT INTO departments VALUES ( 20, 'Accounting'               , 200, 3000);
INSERT INTO departments VALUES ( 30, 'Research'                 , 300, 3000);
INSERT INTO departments VALUES ( 40, 'Sales'                    , 400, 3000);
INSERT INTO departments VALUES ( 50, 'Operations'               , 500, 3000);
INSERT INTO departments VALUES ( 60 , 'Information Technology'  , 600, 3000);
INSERT INTO departments VALUES ( 61 , 'IT Support'              , NULL, 3000);
INSERT INTO departments VALUES ( 62 , 'IT Helpdesk'             , NULL, 3000);
INSERT INTO departments VALUES ( 70 , 'Human Resources'         , 700, 3000);

----------------------------------------------------------------------------
-- insert data into the JOBS table

Prompt ******  Populating JOBS table ....

INSERT INTO jobs VALUES ( 'SM_PRES',    'President', 20080, 40000);
INSERT INTO jobs VALUES ( 'AC_MGR',     'Accounting Manager', 8200, 16000);
INSERT INTO jobs VALUES ( 'AC_CLERK',   'Accounting Clerk', 4200, 9000);
INSERT INTO jobs VALUES ( 'RD_MGR',     'Research Manager', 8000, 15000);
INSERT INTO jobs VALUES ( 'RD_CLERK',   'Research Clerk', 4000, 9000);
INSERT INTO jobs VALUES ( 'RD_ENG',     'Research Engineer', 4000, 10000);
INSERT INTO jobs VALUES ( 'SA_MGR',     'Sales Manager', 10000, 20080);
INSERT INTO jobs VALUES ( 'SA_REP',     'Sales Representative', 6000, 12008);
INSERT INTO jobs VALUES ( 'OP_MGR',     'Operation Manager', 6000, 10000);
INSERT INTO jobs VALUES ( 'OP_AGENT',   'Agent', 4000, 10000);
INSERT INTO jobs VALUES ( 'IT_MGR',     'IT Manager', 6000, 10000);
INSERT INTO jobs VALUES ( 'IT_DEV',     'IT Developer', 4000, 10000);
INSERT INTO jobs VALUES ( 'IT_ADM',     'IT Administrator', 4000, 10000);
INSERT INTO jobs VALUES ( 'HR_MGR',     'Human Resources Manager', 6000, 10000);
INSERT INTO jobs VALUES ( 'HR_REP',     'Human Resources Representative', 4000, 9000);

----------------------------------------------------------------------------
-- insert data into the EMPLOYEES table
Prompt ******  Populating EMPLOYEES table ....
INSERT INTO employees VALUES ( 100, 'Ben',      'King',         'ben.king@trivadislabs.com',            '515.123.4567', TO_DATE('17.06.03', 'dd-MM-yyyy'),      'SM_PRES',      24000, NULL, NULL, 10);
INSERT INTO employees VALUES ( 200, 'Jim',      'Clark',        'jim.clark@trivadislabs.com',           '515.123.4568', TO_DATE('21.09.05', 'dd-MM-yyyy'),      'AC_MGR',       17000, NULL, 100, 20);
INSERT INTO employees VALUES ( 201, 'John',     'Miller',       'john.miller@trivadislabs.com',         '515.123.4569', TO_DATE('13.01.01', 'dd-MM-yyyy'),      'AC_CLERK',     17000, NULL, 200, 20);
INSERT INTO employees VALUES ( 300, 'Ernst',    'Blofeld',      'ernst.blofeld@trivadislabs.com',       '590.423.4567', TO_DATE('03.01.06', 'dd-MM-yyyy'),      'RD_MGR',       9000, NULL, 100, 30);
INSERT INTO employees VALUES ( 301, 'Ford',     'Prefect',      'ford.prefect@trivadislabs.com',          '590.423.4568', TO_DATE('21.05.07', 'dd-MM-yyyy'),      'RD_CLERK',     6000, NULL, 300, 30);
INSERT INTO employees VALUES ( 302, 'Douglas',  'Adams',        'douglas.adams@trivadislabs.com',       '590.423.4569', TO_DATE('25.06.05', 'dd-MM-yyyy'),      'RD_CLERK',     4800, NULL, 300, 30);
INSERT INTO employees VALUES ( 303, 'Paul',     'Smith',        'paul.smith@trivadislabs.com',          '590.423.4560', TO_DATE('05.02.06', 'dd-MM-yyyy'),      'RD_ENG',       4800, NULL, 300, 30);
INSERT INTO employees VALUES ( 304, 'James',    'Scott',        'james.scott@trivadislabs.com',         '590.423.5567', TO_DATE('07.02.07', 'dd-MM-yyyy'),      'RD_ENG',       4200, NULL, 300, 30);
INSERT INTO employees VALUES ( 400, 'Eve',      'Moneypenny',   'eve.moneypenny@trivadislabs.com',      '515.124.4569', TO_DATE('17.08.02', 'dd-MM-yyyy'),      'SA_MGR',       12008, 0.3, 100, 40);
INSERT INTO employees VALUES ( 401, 'Paul',     'Ward',         'paul.ward@trivadislabs.com',           '515.124.4169', TO_DATE('16.08.02', 'dd-MM-yyyy'),      'SA_REP',       9000, 0.3, 400, 40);
INSERT INTO employees VALUES ( 402, 'Arthur',   'Dent',         'arthur.dent@trivadislabs.com',         '515.124.4269', TO_DATE('28.09.05', 'dd-MM-yyyy'),      'SA_REP',       8200, 0.3, 400, 40);
INSERT INTO employees VALUES ( 403, 'Monica',   'Blake',        'monica.blake@trivadislabs.com',        '515.124.4369', TO_DATE('30.09.05', 'dd-MM-yyyy'),      'SA_REP',       7700, 0.2, 400, 40);
INSERT INTO employees VALUES ( 500, 'Felix',    'Leitner',      'felix.leitner@trivadislabs.com',       '515.124.4567', TO_DATE('07.12.07', 'dd-MM-yyyy'),      'OP_MGR',       6900, NULL, 100, 50);
INSERT INTO employees VALUES ( 501, 'Andy',     'Renton',       'andy.renton@trivadislabs.com',         '515.127.4561', TO_DATE('07.12.02', 'dd-MM-yyyy'),      'OP_AGENT',     11000, NULL, 500, 50);
INSERT INTO employees VALUES ( 502, 'Jason',    'Walters',      'jason .walters@trivadislabs.com',      '515.127.4562', TO_DATE('18.05.03', 'dd-MM-yyyy'),      'OP_AGENT',     3100, NULL, 500, 50);
INSERT INTO employees VALUES ( 503, 'James',    'Bond',         'james.bond@trivadislabs.com',          '515.127.4563', TO_DATE('24.12.05', 'dd-MM-yyyy'),      'OP_AGENT',     2900, NULL, 500, 50);
INSERT INTO employees VALUES ( 600, 'Ian',      'Fleming',      'ian.fleming@trivadislabs.com',         '515.127.4564', TO_DATE('24.07.05', 'dd-MM-yyyy'),      'IT_MGR',       2800, NULL, 100, 60);
INSERT INTO employees VALUES ( 601, 'John',     'Gartner',      'john.gartner@trivadislabs.com',        '515.127.4565', TO_DATE('15.11.06', 'dd-MM-yyyy'),      'IT_DEV',       2600, NULL, 600, 60);
INSERT INTO employees VALUES ( 602, 'Eugen',    'Tanner',       'eugen.tanner@trivadislabs.com',        '515.127.4566', TO_DATE('10.08.07', 'dd-MM-yyyy'),      'IT_ADM',       2500, NULL, 600, 60);
INSERT INTO employees VALUES ( 700, 'Honey',    'Rider',        'honey.rider@trivadislabs.com',         '650.123.1234', TO_DATE('18.07.04', 'dd-MM-yyyy'),      'HR_MGR',       8000, NULL, 100, 70);
INSERT INTO employees VALUES ( 701, 'Vesper',   'Lynd',         'vesper.lynd@trivadislabs.com',         '650.123.2234', TO_DATE('10.04.05', 'dd-MM-yyyy'),      'HR_REP',       8200, NULL, 700, 70);

-- enable integrity constraint to DEPARTMENTS
ALTER TABLE departments ENABLE CONSTRAINT dept_mgr_fk;

COMMIT;

----------------------------------------------------------------------------
-- create indexes
CREATE INDEX emp_department_ix
       ON employees (department_id);

CREATE INDEX emp_job_ix
       ON employees (job_id);

CREATE INDEX emp_manager_ix
       ON employees (manager_id);

CREATE INDEX emp_name_ix
       ON employees (last_name, first_name);

CREATE INDEX dept_location_ix
       ON departments (location_id);

CREATE INDEX jhist_job_ix
       ON job_history (job_id);

CREATE INDEX jhist_employee_ix
       ON job_history (employee_id);

CREATE INDEX jhist_department_ix
       ON job_history (department_id);

CREATE INDEX loc_city_ix
       ON locations (city);

CREATE INDEX loc_state_province_ix	
       ON locations (state_province);

CREATE INDEX loc_country_ix
       ON locations (country_id);

COMMIT;

----------------------------------------------------------------------------
-- create procedural objects
----------------------------------------------------------------------------
-- procedure and statement trigger to allow dmls during business hours:
CREATE OR REPLACE PROCEDURE secure_dml
IS
BEGIN
  IF TO_CHAR (SYSDATE, 'HH24:MI') NOT BETWEEN '08:00' AND '18:00'
        OR TO_CHAR (SYSDATE, 'DY') IN ('SAT', 'SUN') THEN
	RAISE_APPLICATION_ERROR (-20205, 
		'You may only make changes during normal office hours');
  END IF;
END secure_dml;
/

CREATE OR REPLACE TRIGGER secure_employees
  BEFORE INSERT OR UPDATE OR DELETE ON employees
BEGIN
  secure_dml;
END secure_employees;
/

ALTER TRIGGER secure_employees DISABLE;

----------------------------------------------------------------------------
-- procedure to add a row to the JOB_HISTORY table and row trigger 
-- to call the procedure when data is updated in the job_id or 
-- department_id columns in the EMPLOYEES table:
CREATE OR REPLACE PROCEDURE add_job_history
  (  p_emp_id          job_history.employee_id%type
   , p_start_date      job_history.start_date%type
   , p_end_date        job_history.end_date%type
   , p_job_id          job_history.job_id%type
   , p_department_id   job_history.department_id%type 
   )
IS
BEGIN
  INSERT INTO job_history (employee_id, start_date, end_date, 
                           job_id, department_id)
    VALUES(p_emp_id, p_start_date, p_end_date, p_job_id, p_department_id);
END add_job_history;
/

CREATE OR REPLACE TRIGGER update_job_history
  AFTER UPDATE OF job_id, department_id ON employees
  FOR EACH ROW
BEGIN
  add_job_history(:old.employee_id, :old.hire_date, sysdate, 
                  :old.job_id, :old.department_id);
END;
/

COMMIT;

----------------------------------------------------------------------------
-- add comments to tables and columns
COMMENT ON TABLE regions 
IS 'Regions table that contains region numbers and names. Contains 4 rows; references with the Countries table.'

COMMENT ON COLUMN regions.region_id
IS 'Primary key of regions table.'

COMMENT ON COLUMN regions.region_name
IS 'Names of regions. Locations are in the countries of these regions.'

COMMENT ON TABLE locations
IS 'Locations table that contains specific address of a specific office,
warehouse, and/or production site of a company. Does not store addresses /
locations of customers. Contains 23 rows; references with the
departments and countries tables. ';

COMMENT ON COLUMN locations.location_id
IS 'Primary key of locations table';

COMMENT ON COLUMN locations.street_address
IS 'Street address of an office, warehouse, or production site of a company.
Contains building number and street name';

COMMENT ON COLUMN locations.postal_code
IS 'Postal code of the location of an office, warehouse, or production site 
of a company. ';

COMMENT ON COLUMN locations.city
IS 'A not null column that shows city where an office, warehouse, or 
production site of a company is located. ';

COMMENT ON COLUMN locations.state_province
IS 'State or Province where an office, warehouse, or production site of a 
company is located.';

COMMENT ON COLUMN locations.country_id
IS 'Country where an office, warehouse, or production site of a company is
located. Foreign key to country_id column of the countries table.';

----------------------------------------------------------------------------
COMMENT ON TABLE departments
IS 'Departments table that shows details of departments where employees 
work. Contains 27 rows; references with locations, employees, and job_history tables.';

COMMENT ON COLUMN departments.department_id
IS 'Primary key column of departments table.';

COMMENT ON COLUMN departments.department_name
IS 'A not null column that shows name of a department. Administration, 
Marketing, Purchasing, Human Resources, Shipping, IT, Executive, Public 
Relations, Sales, Finance, and Accounting. ';

COMMENT ON COLUMN departments.manager_id
IS 'Manager_id of a department. Foreign key to employee_id column of employees table. The manager_id column of the employee table references this column.';

COMMENT ON COLUMN departments.location_id
IS 'Location id where a department is located. Foreign key to location_id column of locations table.';

----------------------------------------------------------------------------
COMMENT ON TABLE job_history
IS 'Table that stores job history of the employees. If an employee 
changes departments within the job or changes jobs within the department, 
new rows get inserted into this table with old job information of the 
employee. Contains a complex primary key: employee_id+start_date.
Contains 25 rows. References with jobs, employees, and departments tables.';

COMMENT ON COLUMN job_history.employee_id
IS 'A not null column in the complex primary key employee_id+start_date.
Foreign key to employee_id column of the employee table';

COMMENT ON COLUMN job_history.start_date
IS 'A not null column in the complex primary key employee_id+start_date. 
Must be less than the end_date of the job_history table. (enforced by 
constraint jhist_date_interval)';

COMMENT ON COLUMN job_history.end_date
IS 'Last day of the employee in this job role. A not null column. Must be 
greater than the start_date of the job_history table. 
(enforced by constraint jhist_date_interval)';

COMMENT ON COLUMN job_history.job_id
IS 'Job role in which the employee worked in the past; foreign key to 
job_id column in the jobs table. A not null column.';

COMMENT ON COLUMN job_history.department_id
IS 'Department id in which the employee worked in the past; foreign key to deparment_id column in the departments table';

----------------------------------------------------------------------------
COMMENT ON TABLE countries
IS 'country table. Contains 25 rows. References with locations table.';

COMMENT ON COLUMN countries.country_id
IS 'Primary key of countries table.';

COMMENT ON COLUMN countries.country_name
IS 'Country name';

COMMENT ON COLUMN countries.region_id
IS 'Region ID for the country. Foreign key to region_id column in the departments table.';

----------------------------------------------------------------------------
COMMENT ON TABLE jobs
IS 'jobs table with job titles and salary ranges. Contains 19 rows.
References with employees and job_history table.';

COMMENT ON COLUMN jobs.job_id
IS 'Primary key of jobs table.';

COMMENT ON COLUMN jobs.job_title
IS 'A not null column that shows job title, e.g. AD_VP, FI_ACCOUNTANT';

COMMENT ON COLUMN jobs.min_salary
IS 'Minimum salary for a job title.';

COMMENT ON COLUMN jobs.max_salary
IS 'Maximum salary for a job title';

----------------------------------------------------------------------------
COMMENT ON TABLE employees
IS 'employees table. Contains 107 rows. References with departments, 
jobs, job_history tables. Contains a self reference.';

COMMENT ON COLUMN employees.employee_id
IS 'Primary key of employees table.';

COMMENT ON COLUMN employees.first_name
IS 'First name of the employee. A not null column.';

COMMENT ON COLUMN employees.last_name
IS 'Last name of the employee. A not null column.';

COMMENT ON COLUMN employees.email
IS 'Email id of the employee';

COMMENT ON COLUMN employees.phone_number
IS 'Phone number of the employee; includes country code and area code';

COMMENT ON COLUMN employees.hire_date
IS 'Date when the employee started on this job. A not null column.';

COMMENT ON COLUMN employees.job_id
IS 'Current job of the employee; foreign key to job_id column of the 
jobs table. A not null column.';

COMMENT ON COLUMN employees.salary
IS 'Monthly salary of the employee. Must be greater 
than zero (enforced by constraint emp_salary_min)';

COMMENT ON COLUMN employees.commission_pct
IS 'Commission percentage of the employee; Only employees in sales 
department elgible for commission percentage';

COMMENT ON COLUMN employees.manager_id
IS 'Manager id of the employee; has same domain as manager_id in 
departments table. Foreign key to employee_id column of employees table.
(useful for reflexive joins and CONNECT BY query)';

COMMENT ON COLUMN employees.department_id
IS 'Department id where employee works; foreign key to department_id 
column of the departments table';

COMMIT;

----------------------------------------------------------------------------
-- gather schema statistics
EXECUTE dbms_stats.gather_schema_stats( -
        'TVD_HR'                        ,       -
        granularity => 'ALL'            ,       -
        cascade => TRUE                 ,       -
        block_sample => TRUE            );

spool off
exit
-- EOF ---------------------------------------------------------------------