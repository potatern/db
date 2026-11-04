-- units: coordinates/pitch/direction in degrees
-- dimensions/altitude/radius in metres
-- speed in metres per second
-- event timestamps store absolute instants (timestamptz)

BEGIN;

CREATE TABLE airport (
    airport_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    latitude numeric(10,7) NOT NULL,
    longitude numeric(11,7) NOT NULL,
    altitude numeric(10,2) NOT NULL,
    airspace_radius numeric(10,2) NOT NULL,
    city text NOT NULL,
    country text NOT NULL,
    name text NOT NULL,
    CONSTRAINT chk_airport_latitude CHECK (latitude BETWEEN -90 AND 90),
    CONSTRAINT chk_airport_longitude CHECK (longitude BETWEEN -180 AND 180),
    CONSTRAINT chk_airport_city CHECK (city = btrim(city) AND city <> ''),
    CONSTRAINT chk_airport_country CHECK (country = btrim(country) AND country <> ''),
    CONSTRAINT chk_airport_name CHECK (name = btrim(name) AND name <> ''),
    CONSTRAINT chk_airport_radius_positive CHECK (airspace_radius > 0)
);

CREATE TABLE airplane (
    airplane_id bigint NOT NULL PRIMARY KEY,
    airport_id bigint NOT NULL,
    hangar_number smallint,
    status_id bigint NOT NULL,
    width numeric(10,2) NOT NULL,
    length numeric(10,2) NOT NULL,
    height numeric(10,2) NOT NULL,
    CONSTRAINT chk_airplane_width CHECK (width > 0),
    CONSTRAINT chk_airplane_length CHECK (length > 0),
    CONSTRAINT chk_airplane_height CHECK (height > 0)
);

CREATE TYPE object_type AS ENUM (
    'line', 'flight_status', 'airplane', 'boarding_pass', 'employee'
);

CREATE TYPE airplane_states AS ENUM (
    'in flight', 'ready to takeoff', 'ready to land', 'broken', 'checking', 'waiting checking'
);

CREATE TABLE flight_status (
    status_id bigint NOT NULL PRIMARY KEY,
    status airplane_states NOT NULL
);

CREATE TABLE plane_positions (
    position_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    airplane_id bigint NOT NULL,
    latitude numeric(10,7) NOT NULL,
    longitude numeric(11,7) NOT NULL,
    altitude numeric(10,2) NOT NULL,
    pitch numeric(6,3) NOT NULL,
    direction numeric(6,3) NOT NULL,
    speed numeric(10,2) NOT NULL,
    time_utc timestamptz NOT NULL,
    CONSTRAINT chk_plane_positions_latitude CHECK (latitude BETWEEN -90 AND 90),
    CONSTRAINT chk_plane_positions_longitude CHECK (longitude BETWEEN -180 AND 180),
    CONSTRAINT chk_plane_positions_direction CHECK (direction >= 0 AND direction < 360),
    CONSTRAINT chk_plane_positions_pitch_range CHECK (pitch BETWEEN -90 AND 90),
    CONSTRAINT chk_plane_positions_speed_nonnegative CHECK (speed >= 0)
);

CREATE TABLE flight (
    flight_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    airplane_id bigint NOT NULL,
    employee_id bigint NOT NULL,
    takeoff_line_id bigint NOT NULL,
    planned_takeoff_time timestamptz NOT NULL,
    actual_takeoff_time timestamptz,
    planned_land_time timestamptz NOT NULL,
    actual_land_time timestamptz,
    CONSTRAINT chk_flight_planned_times CHECK (planned_land_time > planned_takeoff_time),
    CONSTRAINT chk_flight_actual_times CHECK (actual_land_time IS NULL OR (actual_takeoff_time IS NOT NULL AND actual_land_time > actual_takeoff_time))
);

CREATE TABLE employee (
    employee_id bigint NOT NULL PRIMARY KEY,
    position_id bigint NOT NULL,
    firstname text NOT NULL,
    lastname text NOT NULL,
    middle_name text,
    birthdate date NOT NULL,
    working_place text NOT NULL,
    contract_information text,
    CONSTRAINT chk_employee_firstname CHECK (firstname = btrim(firstname) AND firstname <> ''),
    CONSTRAINT chk_employee_lastname CHECK (lastname = btrim(lastname) AND lastname <> ''),
    CONSTRAINT chk_employee_middle_name CHECK (middle_name = btrim(middle_name) AND middle_name <> ''),
    CONSTRAINT chk_employee_working_place CHECK (working_place = btrim(working_place) AND working_place <> ''),
    CONSTRAINT chk_employee_contract_information CHECK (contract_information = btrim(contract_information) AND contract_information <> '')
);

CREATE TABLE employee_position (
    position_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL UNIQUE,
    duties text,
    CONSTRAINT chk_employee_position_name CHECK (name = btrim(name) AND name <> ''),
    CONSTRAINT chk_employee_position_duties CHECK (duties = btrim(duties) AND duties <> '')
);

CREATE TABLE passenger (
    passenger_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    firstname text NOT NULL,
    lastname text NOT NULL,
    middle_name text,
    birthdate date NOT NULL,
    passport_data text NOT NULL,
    country text NOT NULL,
    CONSTRAINT chk_passenger_firstname CHECK (firstname = btrim(firstname) AND firstname <> ''),
    CONSTRAINT chk_passenger_lastname CHECK (lastname = btrim(lastname) AND lastname <> ''),
    CONSTRAINT chk_passenger_middle_name CHECK (middle_name = btrim(middle_name) AND middle_name <> ''),
    CONSTRAINT chk_passenger_passport_data CHECK (passport_data = btrim(passport_data) AND passport_data <> ''),
    CONSTRAINT chk_passenger_country CHECK (country = btrim(country) AND country <> '')
);

CREATE TYPE travel_class AS ENUM (
    'business', 'economy'
);

CREATE TABLE boarding_pass (
    ticket_id bigint NOT NULL PRIMARY KEY,
    passenger_id bigint NOT NULL,
    flight_id bigint NOT NULL,
    seat text NOT NULL,
    class travel_class NOT NULL,
    gate int,
    CONSTRAINT uq_boarding_pass_flight_seat UNIQUE (flight_id, seat),
    CONSTRAINT chk_boarding_pass_seat CHECK (seat = btrim(seat) AND seat <> ''),
    CONSTRAINT chk_boarding_pass_gate_positive CHECK (gate IS NULL OR gate > 0)
);

CREATE TABLE line (
    line_id bigint NOT NULL PRIMARY KEY,
    airport_id bigint NOT NULL,
    is_free boolean NOT NULL,
    latitude numeric(10,7) NOT NULL,
    longitude numeric(11,7) NOT NULL,
    altitude numeric(10,2) NOT NULL,
    width numeric(10,2) NOT NULL,
    length numeric(10,2) NOT NULL,
    direction numeric(6,3) NOT NULL,
    CONSTRAINT chk_line_latitude CHECK (latitude BETWEEN -90 AND 90),
    CONSTRAINT chk_line_longitude CHECK (longitude BETWEEN -180 AND 180),
    CONSTRAINT chk_line_width CHECK (width > 0),
    CONSTRAINT chk_line_length CHECK (length > 0),
    CONSTRAINT chk_line_direction CHECK (direction >= 0 AND direction < 360)
);

CREATE TABLE hangar (
    hangar_number smallint NOT NULL,
    airport_id bigint NOT NULL,
    width numeric(10,2) NOT NULL,
    length numeric(10,2) NOT NULL,
    height numeric(10,2) NOT NULL,
    latitude numeric(10,7) NOT NULL,
    longitude numeric(11,7) NOT NULL,
    CONSTRAINT pk_hangar PRIMARY KEY (airport_id, hangar_number),
    CONSTRAINT chk_hangar_width CHECK (width > 0),
    CONSTRAINT chk_hangar_length CHECK (length > 0),
    CONSTRAINT chk_hangar_height CHECK (height > 0),
    CONSTRAINT chk_hangar_latitude CHECK (latitude BETWEEN -90 AND 90),
    CONSTRAINT chk_hangar_longitude CHECK (longitude BETWEEN -180 AND 180),
    CONSTRAINT chk_hangar_number_positive CHECK (hangar_number > 0)
);

CREATE TABLE journal (
    journal_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    airport_id bigint,
    object_id bigint,
    action_time timestamptz NOT NULL,
    action_description text NOT NULL,
    CONSTRAINT chk_journal_action_description CHECK (action_description = btrim(action_description) AND action_description <> '')
);

CREATE TABLE landing (
    landing_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    flight_id bigint NOT NULL,
    line_id bigint,
    landing_time timestamptz NOT NULL
);

CREATE TABLE airplane_master (
    assignment_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    airplane_id bigint NOT NULL,
    employee_id bigint NOT NULL,
    started_at timestamptz NOT NULL,
    ended_at timestamptz,
    CONSTRAINT chk_airplane_master_assignment_times CHECK (ended_at IS NULL OR ended_at > started_at)
);

CREATE TABLE journaling_object (
    object_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    journal_id bigint NOT NULL,
    object_type object_type NOT NULL
);


ALTER TABLE airplane
    ADD CONSTRAINT fk_airplane_object FOREIGN KEY (airplane_id)
    REFERENCES journaling_object(object_id)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE airplane
    ADD CONSTRAINT fk_airplane_airport FOREIGN KEY (airport_id)
    REFERENCES airport(airport_id)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE airplane
    ADD CONSTRAINT fk_airplane_hangar FOREIGN KEY (airport_id, hangar_number)
    REFERENCES hangar(airport_id, hangar_number)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE airplane
    ADD CONSTRAINT fk_airplane_status FOREIGN KEY (status_id)
    REFERENCES flight_status(status_id)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE flight_status
    ADD CONSTRAINT fk_status_object FOREIGN KEY (status_id)
    REFERENCES journaling_object(object_id)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE plane_positions
    ADD CONSTRAINT fk_position_airplane FOREIGN KEY (airplane_id)
    REFERENCES airplane(airplane_id)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE flight
    ADD CONSTRAINT fk_flight_airplane FOREIGN KEY (airplane_id)
    REFERENCES airplane(airplane_id)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE flight
    ADD CONSTRAINT fk_flight_employee FOREIGN KEY (employee_id)
    REFERENCES employee(employee_id)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE flight
    ADD CONSTRAINT fk_flight_line FOREIGN KEY (takeoff_line_id)
    REFERENCES line(line_id)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE employee
    ADD CONSTRAINT fk_employee_object FOREIGN KEY (employee_id)
    REFERENCES journaling_object(object_id)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE employee
    ADD CONSTRAINT fk_employee_position FOREIGN KEY (position_id)
    REFERENCES employee_position(position_id)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE boarding_pass
    ADD CONSTRAINT fk_ticket_object FOREIGN KEY (ticket_id)
    REFERENCES journaling_object(object_id)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE boarding_pass
    ADD CONSTRAINT fk_ticket_passenger FOREIGN KEY (passenger_id)
    REFERENCES passenger(passenger_id)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE boarding_pass
    ADD CONSTRAINT fk_ticket_flight FOREIGN KEY (flight_id)
    REFERENCES flight(flight_id)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE line
    ADD CONSTRAINT fk_line_object FOREIGN KEY (line_id)
    REFERENCES journaling_object(object_id)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE line
    ADD CONSTRAINT fk_line_airport FOREIGN KEY (airport_id)
    REFERENCES airport(airport_id)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE hangar
    ADD CONSTRAINT fk_hangar_airport FOREIGN KEY (airport_id)
    REFERENCES airport(airport_id)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE journal
    ADD CONSTRAINT fk_journal_airport FOREIGN KEY (airport_id)
    REFERENCES airport(airport_id)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE journal
    ADD CONSTRAINT fk_journal_object FOREIGN KEY (object_id)
    REFERENCES journaling_object(object_id)
    ON DELETE RESTRICT ON UPDATE CASCADE DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE landing
    ADD CONSTRAINT fk_landing_flight FOREIGN KEY (flight_id)
    REFERENCES flight(flight_id)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE landing
    ADD CONSTRAINT fk_landing_line FOREIGN KEY (line_id)
    REFERENCES line(line_id)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE airplane_master
    ADD CONSTRAINT fk_master_airplane FOREIGN KEY (airplane_id)
    REFERENCES airplane(airplane_id)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE airplane_master
    ADD CONSTRAINT fk_master_employee FOREIGN KEY (employee_id)
    REFERENCES employee(employee_id)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE journaling_object
    ADD CONSTRAINT fk_object_journal FOREIGN KEY (journal_id)
    REFERENCES journal(journal_id)
    ON DELETE RESTRICT ON UPDATE CASCADE;

COMMIT;
