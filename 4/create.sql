-- CREATE TABLE name (
--     column_name data_type
--     column_restrictions,
--     ...
--     table_restriction
--     ...
-- )

-- TODO: 
-- check words translations correction
-- add FKs + check their usage
-- check ? marks
-- check enum usage
-- fix places where more than one PK

CREATE TABLE airport ( -- E1
    airport_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    latitude numeric(3,10) NOT NULL,
    longitude numeric(3,10) NOT NULL,
    altitude numeric(5,1) NOT NULL,
    airspace_radius numeric(5,1) NOT NULL,
    city text NOT NULL,
    country text NOT NULL,
    name text NOT NULL
);

CREATE TABLE airplane ( -- E2
    airplane_id bigint NOT NULL PRIMARY KEY,
    airport_id bigint NOT NULL,
    hangar_number smallint,
    status_id bigint NOT NULL,
    widght numeric(3,2) NOT NULL,
    lenght numeric(3,2) NOT NULL,
    hight numeric(2,2) NOT NULL
);

CREATE TYPE object_type AS ENUM (
    'line', 'flight_status', 'airplane', 'boarding_pass', 'employee'
);

CREATE TYPE airplane_states AS ENUM (
    'in flight', 'ready to takeoff', 'ready to land', 'broken??', 'checking', 'waiting checking'
);

CREATE TABLE flight_status ( -- E3
    status_id bigint NOT NULL PRIMARY KEY,
    status airplane_states,
);

CREATE TABLE plane_positions ( -- E4
    position_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    airplane_id bigint NOT NULL,
    latitude numeric(3,10) NOT NULL,
    longitude numeric(3,10) NOT NULL,
    altitude numeric(5,1) NOT NULL,
    tangage numeric(3,2) NOT NULL, -- ????!!!
    direction numeric(3,3) NOT NULL,
    speed numeric(3,2) NOT NULL,
    time_utc timestamp NOT NULL
);

CREATE TABLE flight ( -- E5
    flight_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    airplane_id bigint NOT NULL,
    employee_id bigint NOT NULL,
    takeoff_line??_id bigint NOT NULL,
    takeoff_time timestamp,
    land_time timestamp,
    planned_land_time timestamp,
    actual_land_time timestamp
);

CREATE TABLE employee ( -- E6
    employee_id bigint NOT NULL PRIMARY KEY,
    position_id bigint NOT NULL, -- ???
    firstname text NOT NULL,
    lastname text NOT NULL,
    otchestvo?? text,
    birthdate date NOT NULL,
    working_place text NOT NULL, -- ??
    informatoin text -- ??
);

CREATE TABLE employee_position ( -- E7 ??
    position_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL UNIQUE,
    list text -- ???
);

CREATE TABLE passanger ( -- E8
    passanger_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    firstname text NOT NULL,
    lastname text NOT NULL,
    othestvo??? text,
    birthdate date NOT NULL,
    passport_data text NOT NULL, --??
    country text NOT NULL -- ??
);

CREATE TYPE class AS ENUM (
    'business', 'poor'
);

CREATE TABLE boarding_pass ( -- E9 ticket??
    ticket_id bigint NOT NULL PRIMARY KEY, -- ??
    passanger_id bigint NOT NULL,
    flight_id bigint NOT NULL,
    seat text NOT NULL, -- int??
    class class NOT NULL,
    gate int -- ??
);

CREATE TABLE line ( -- E10
    line_id bigint NOT NULL PRIMARY KEY,
    airport_id bigint NOT NULL,
    is_free boolean NOT NULL,
    latitude numeric(3,10) NOT NULL, -- ??
    longitude numeric(3,10) NOT NULL, -- ??
    altitude numeric(5,1) NOT NULL, -- ??
    widght numeric(2,2) NOT NULL,
    lenght numeric(4,2) NOT NULL,
    direction numeric(3,3) NOT NULL
);

CREATE TABLE hangar ( -- E11
    hangar_number smallint NOT NULL UNIQUE PRIMARY KEY,
    airport_id bigint NOT NULL PRIMARY KEY,
    widght numeric(3,2) NOT NULL,
    lenght numeric(3,2) NOT NULL,
    hight numeric(2,2) NOT NULL,
    latitude numeric(3,10) NOT NULL, -- ??
    longitude numeric(3,10) NOT NULL -- ??
);

CREATE TABLE journal ( -- E12
    journal_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    airport_id bigint,
    object_id bigint,
    action_time timestamp NOT NULL,
    action_discription text NOT NULL
);

CREATE TABLE landing ( -- E13
    landing_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    flight_id bigint NOT NULL,
    line_id bigint,
    landing_time timestamp NOT NULL
);

CREATE TABLE airplane_master ( -- E14 ??
    mastering_id bigint GENERATED ALWAYS AS IDenTITY PRIMARY KEY, -- ??
    airplane_id bigint NOT NULL,
    employee_id bigint NOT NULL
);

CREATE TABLE journaling_object ( -- E15
    object_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    journal_id bigint NOT NULL,
    object_type object_type NOT NULL
);