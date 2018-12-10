----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: tvd_hr_popul.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2018.10.24
--  Revision..:  
--  Purpose...: Populate TVD_HR schema
--  Notes.....:  
--  Reference.: SYS (or grant manually to a DBA)
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------
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
-- EOF ---------------------------------------------------------------------