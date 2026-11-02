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
-- check syntax
-- check constraints

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

    CONSTRAINT fk_airplane_object
        FOREIGN KEY (airplane_id)
        REFERENCES journaling_object(object_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_airplane_airport
        FOREIGN KEY (airport_id)
        REFERENCES airport(airport_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_airplane_object -- ???
        FOREIGN KEY (airport_id)
        REFERENCES hangar(airport_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAiNT fk_airplane_hangar
        FOREIGN KEY (hangar_number)
        REFERENCES hangar(hangar_number)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_airplane_status
        FOREIGN KEY (status_id)
        REFERENCES flight_status(status_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
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
    CONSTRAINT fk_status_object
        FOREIGN KEY (status_id)
        REFERENCES journaling_object(object_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
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
    time_utc timestamp NOT NULL,
    CONSTRAINT fk_position_airplane
        FOREIGN KEY (airplane_id)
        REFERENCES airplane(airplane_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE flight ( -- E5
    flight_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    airplane_id bigint NOT NULL,
    employee_id bigint NOT NULL,
    takeoff_line_id bigint NOT NULL,
    takeoff_time timestamp,
    land_time timestamp,
    planned_land_time timestamp,
    actual_land_time timestamp,
    CONSTRAINT fk_flight_airplane
        FOREIGN KEY (airplane_id)
        REFERENCES airplane(airplane_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_flight_employee
        FOREIGN KEY (employee_id)
        REFERENCES employee(employee_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_flight_line
        FOREIGN KEY (takeoff_line_id)
        REFERENCES line(line_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE employee ( -- E6
    employee_id bigint NOT NULL PRIMARY KEY,
    position_id bigint NOT NULL, -- ???
    firstname text NOT NULL,
    lastname text NOT NULL,
    otchestvo?? text,
    birthdate date NOT NULL,
    working_place text NOT NULL, -- ??
    informatoin text, -- ??
    CONSTRAINT fk_employee_object
        FOREIGN KEY (employee_id)
        REFERENCES journaling_object(object_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_employee_position
        FOREIGN KEY (position_id)
        REFERENCES employee_position(position_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
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
    gate int, -- ??
    CONSTRAINT fk_ticket_object
        FOREIGN KEY (ticket_id)
        REFERENCES journaling_object(object_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_ticket_passanger
        FOREIGN KEY (passanger_id)
        REFERENCES passanger(passanger_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_ticket_flight
        FOREIGN KEY (flight_id)
        REFERENCES flight(flight_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
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
    direction numeric(3,3) NOT NULL,
    CONSTRAINT fk_line_object
        FOREIGN KEY (line_id)
        REFERENCES journaling_object(object_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_line_airport
        FOREIGN KEY (airport_id)
        REFERENCES airport(airport_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE hangar ( -- E11
    hangar_number smallint NOT NULL UNIQUE PRIMARY KEY,
    airport_id bigint NOT NULL PRIMARY KEY,
    widght numeric(3,2) NOT NULL,
    lenght numeric(3,2) NOT NULL,
    hight numeric(2,2) NOT NULL,
    latitude numeric(3,10) NOT NULL, -- ??
    longitude numeric(3,10) NOT NULL, -- ??
    CONSTRAINT fk_hangar_airport
        FOREIGN KEY (airport_id)
        REFERENCES airport(airport_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE journal ( -- E12
    journal_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    airport_id bigint,
    object_id bigint,
    action_time timestamp NOT NULL,
    action_discription text NOT NULL,
    CONSTRAINT fk_journal_airport
        FOREIGN KEY (airport_id)
        REFERENCES airport(airport_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_journal_object
        FOREIGN KEY (object_id)
        REFERENCES journaling_object(object_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE landing ( -- E13
    landing_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    flight_id bigint NOT NULL,
    line_id bigint,
    landing_time timestamp NOT NULL,
    CONSTRAINT fk_landing_flight
        FOREIGN KEY (flight_id)
        REFERENCES flight(flight_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_landing_line
        FOREIGN KEY (line_id)
        REFERENCES line(line_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE airplane_master ( -- E14 ??
    mastering_id bigint GENERATED ALWAYS AS IDenTITY PRIMARY KEY, -- ??
    airplane_id bigint NOT NULL,
    employee_id bigint NOT NULL,
    CONSTRAINT fk_master_airplane
        FOREIGN KEY (airplane_id)
        REFERENCES airplane(airplane_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_master_employee
        FOREIGN KEY (employee_id)
        REFERENCES employee(employee_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE journaling_object ( -- E15
    object_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    journal_id bigint NOT NULL,
    object_type object_type NOT NULL,
    CONSTRAINT fk_object_journal
        FOREIGN KEY (journal_id)
        REFERENCES journal(journal_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);