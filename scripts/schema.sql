CREATE TABLE seasons(
  year NUMBER(11) NOT NULL,
  url VARCHAR2(255) NOT NULL,
  CONSTRAINT seasons_uk UNIQUE (url),
  CONSTRAINT seasons_pk PRIMARY KEY (year)
);

CREATE TABLE circuits(
  circuit_id NUMBER(11) NOT NULL,
  name VARCHAR2(255) NOT NULL,
  location VARCHAR2(255) DEFAULT NULL,
  country VARCHAR2(255) DEFAULT NULL,
  url VARCHAR2(255) NOT NULL,
  CONSTRAINT circuits_uk UNIQUE (url),
  CONSTRAINT circuits_pk PRIMARY KEY (circuit_id)
);

CREATE TABLE races(
  race_id NUMBER(11) NOT NULL,
  race_year NUMBER(11) NOT NULL,
  circuit_id NUMBER(11) NOT NULL,
  race_name VARCHAR2(255) NOT NULL,
  race_date DATE NOT NULL,
  url VARCHAR2(255) DEFAULT NULL,
  CONSTRAINT races_uk UNIQUE (url),
  CONSTRAINT races_pk PRIMARY KEY (race_id)
);

CREATE TABLE drivers(
  driver_id NUMBER(11) NOT NULL,
  driver_number NUMBER(11),
  first_name VARCHAR2(255) NOT NULL,
  last_name VARCHAR2(255) NOT NULL,
  date_born DATE DEFAULT NULL,
  nationality VARCHAR2(255) DEFAULT NULL,
  url VARCHAR2(255) DEFAULT NULL,
  CONSTRAINT drivers_uk UNIQUE (url),
  CONSTRAINT drivers_pk UNIQUE (driver_id)
);

CREATE TABLE constructors(
  constructor_id NUMBER(11) NOT NULL,
  name VARCHAR2(255) NOT NULL,
  nationality VARCHAR2(255) DEFAULT NULL,
  url VARCHAR2(255) NOT NULL,
  CONSTRAINT constructors_uk UNIQUE (url),
  CONSTRAINT constructors_pk UNIQUE (constructor_id)
);

CREATE TABLE status(
  status_id NUMBER(11) NOT NULL,
  status VARCHAR2(255) NOT NULL,
  CONSTRAINT status_pk PRIMARY KEY (status_id)
);

CREATE TABLE results(
  result_id NUMBER(11) NOT NULL,
  race_id NUMBER(11) NOT NULL,
  driver_id NUMBER(11) NOT NULL,
  constructor_id NUMBER(11) NOT NULL,
  grid_position NUMBER(11) NOT NULL,
  position NUMBER(11) DEFAULT NULL,
  position_text VARCHAR2(255) DEFAULT NULL,
  points NUMBER(4, 2) DEFAULT 0,
  laps NUMBER(11) DEFAULT 0,
  time VARCHAR2(255) DEFAULT NULL,
  status_id NUMBER(11) NOT NULL,
  CONSTRAINT results_pk PRIMARY KEY (result_id)
);

CREATE TABLE qualifying(
  qualify_id NUMBER(11) NOT NULL,
  race_id NUMBER(11) NOT NULL,
  driver_id NUMBER(11) NOT NULL,
  constructor_id NUMBER(11) NOT NULL,
  position NUMBER(11) DEFAULT NULL,
  q1 VARCHAR2(255) DEFAULT NULL,
  q2 VARCHAR2(255) DEFAULT NULL,
  q3 VARCHAR2(255) DEFAULT NULL,
  CONSTRAINT qualifying_pk PRIMARY KEY (qualify_id)
);

CREATE TABLE pit_stops(
  race_id NUMBER(11) NOT NULL,
  driver_id NUMBER(11) NOT NULL,
  stop NUMBER(11) NOT NULL,
  lap NUMBER(11) DEFAULT NULL,
  time VARCHAR2(255) DEFAULT NULL,
  duration VARCHAR2(255) DEFAULT NULL,
  CONSTRAINT pit_stops_pk PRIMARY KEY (race_id, driver_id, stop)
);
