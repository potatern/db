BEGIN;
SET LOCAL TIME ZONE 'UTC';

DO $load$
DECLARE
    airport_ids bigint[];
    employee_position_ids bigint[];
    journaling_object_ids bigint[];
    flight_ids bigint[];
    passenger_ids bigint[];
BEGIN
    LOCK TABLE airport, employee_position, hangar, journaling_object, journal, flight_status, airplane, employee, line, flight, passenger, boarding_pass, landing, airplane_master, plane_positions IN EXCLUSIVE MODE;
    IF EXISTS (SELECT 1 FROM airport) THEN
        RAISE EXCEPTION 'Table must be empty: airport';
    END IF;
    IF EXISTS (SELECT 1 FROM employee_position) THEN
        RAISE EXCEPTION 'Table must be empty: employee_position';
    END IF;
    IF EXISTS (SELECT 1 FROM hangar) THEN
        RAISE EXCEPTION 'Table must be empty: hangar';
    END IF;
    IF EXISTS (SELECT 1 FROM journaling_object) THEN
        RAISE EXCEPTION 'Table must be empty: journaling_object';
    END IF;
    IF EXISTS (SELECT 1 FROM journal) THEN
        RAISE EXCEPTION 'Table must be empty: journal';
    END IF;
    IF EXISTS (SELECT 1 FROM flight_status) THEN
        RAISE EXCEPTION 'Table must be empty: flight_status';
    END IF;
    IF EXISTS (SELECT 1 FROM airplane) THEN
        RAISE EXCEPTION 'Table must be empty: airplane';
    END IF;
    IF EXISTS (SELECT 1 FROM employee) THEN
        RAISE EXCEPTION 'Table must be empty: employee';
    END IF;
    IF EXISTS (SELECT 1 FROM line) THEN
        RAISE EXCEPTION 'Table must be empty: line';
    END IF;
    IF EXISTS (SELECT 1 FROM flight) THEN
        RAISE EXCEPTION 'Table must be empty: flight';
    END IF;
    IF EXISTS (SELECT 1 FROM passenger) THEN
        RAISE EXCEPTION 'Table must be empty: passenger';
    END IF;
    IF EXISTS (SELECT 1 FROM boarding_pass) THEN
        RAISE EXCEPTION 'Table must be empty: boarding_pass';
    END IF;
    IF EXISTS (SELECT 1 FROM landing) THEN
        RAISE EXCEPTION 'Table must be empty: landing';
    END IF;
    IF EXISTS (SELECT 1 FROM airplane_master) THEN
        RAISE EXCEPTION 'Table must be empty: airplane_master';
    END IF;
    IF EXISTS (SELECT 1 FROM plane_positions) THEN
        RAISE EXCEPTION 'Table must be empty: plane_positions';
    END IF;





-- -----------------------------------------------------------------------

    INSERT INTO airport (latitude, longitude, altitude, airspace_radius, city, country, name) VALUES
        (55, 37, 150, 30000, 'Severny', 'Testland', 'North Airport');
    airport_ids[1] := currval(pg_get_serial_sequence('airport', 'airport_id'));

    INSERT INTO airport (latitude, longitude, altitude, airspace_radius, city, country, name) VALUES
        (56, 38, 180, 30000, 'Ozerny', 'Testland', 'Lake Airport');
    airport_ids[2] := currval(pg_get_serial_sequence('airport', 'airport_id'));

    INSERT INTO airport (latitude, longitude, altitude, airspace_radius, city, country, name) VALUES
        (54, 36, 120, 25000, 'Lesnoy', 'Testland', 'Forest Airport');
    airport_ids[3] := currval(pg_get_serial_sequence('airport', 'airport_id'));

    INSERT INTO employee_position (name, duties) VALUES
        ('pilot', 'Operate aircraft and follow dispatcher instructions');
    employee_position_ids[1] := currval(pg_get_serial_sequence('employee_position', 'position_id'));

    INSERT INTO employee_position (name, duties) VALUES
        ('dispatcher', 'Coordinate aircraft and assign airport resources');
    employee_position_ids[2] := currval(pg_get_serial_sequence('employee_position', 'position_id'));

    INSERT INTO employee_position (name, duties) VALUES
        ('mechanic', 'Inspect aircraft and record inspection results');
    employee_position_ids[3] := currval(pg_get_serial_sequence('employee_position', 'position_id'));

    INSERT INTO hangar (hangar_number, airport_id, width, length, height, latitude, longitude) VALUES
        (1, airport_ids[1], 60, 70, 20, 55, 37),
        (2, airport_ids[1], 60, 70, 20, 55, 37),
        (1, airport_ids[2], 60, 70, 20, 56, 38),
        (2, airport_ids[2], 60, 70, 20, 56, 38),
        (1, airport_ids[3], 60, 70, 20, 54, 36),
        (2, airport_ids[3], 60, 70, 20, 54, 36);

    INSERT INTO journaling_object (object_type) VALUES
        ('flight_status');
    journaling_object_ids[1] := currval(pg_get_serial_sequence('journaling_object', 'object_id'));

    INSERT INTO journaling_object (object_type) VALUES
        ('flight_status');
    journaling_object_ids[2] := currval(pg_get_serial_sequence('journaling_object', 'object_id'));

    INSERT INTO journaling_object (object_type) VALUES
        ('flight_status');
    journaling_object_ids[3] := currval(pg_get_serial_sequence('journaling_object', 'object_id'));

    INSERT INTO journaling_object (object_type) VALUES
        ('flight_status');
    journaling_object_ids[4] := currval(pg_get_serial_sequence('journaling_object', 'object_id'));

    INSERT INTO journaling_object (object_type) VALUES
        ('flight_status');
    journaling_object_ids[5] := currval(pg_get_serial_sequence('journaling_object', 'object_id'));

    INSERT INTO journaling_object (object_type) VALUES
        ('flight_status');
    journaling_object_ids[6] := currval(pg_get_serial_sequence('journaling_object', 'object_id'));

    INSERT INTO journaling_object (object_type) VALUES
        ('airplane');
    journaling_object_ids[7] := currval(pg_get_serial_sequence('journaling_object', 'object_id'));

    INSERT INTO journaling_object (object_type) VALUES
        ('airplane');
    journaling_object_ids[8] := currval(pg_get_serial_sequence('journaling_object', 'object_id'));

    INSERT INTO journaling_object (object_type) VALUES
        ('airplane');
    journaling_object_ids[9] := currval(pg_get_serial_sequence('journaling_object', 'object_id'));

    INSERT INTO journaling_object (object_type) VALUES
        ('airplane');
    journaling_object_ids[10] := currval(pg_get_serial_sequence('journaling_object', 'object_id'));

    INSERT INTO journaling_object (object_type) VALUES
        ('airplane');
    journaling_object_ids[11] := currval(pg_get_serial_sequence('journaling_object', 'object_id'));

    INSERT INTO journaling_object (object_type) VALUES
        ('airplane');
    journaling_object_ids[12] := currval(pg_get_serial_sequence('journaling_object', 'object_id'));

    INSERT INTO journaling_object (object_type) VALUES
        ('employee');
    journaling_object_ids[13] := currval(pg_get_serial_sequence('journaling_object', 'object_id'));

    INSERT INTO journaling_object (object_type) VALUES
        ('employee');
    journaling_object_ids[14] := currval(pg_get_serial_sequence('journaling_object', 'object_id'));

    INSERT INTO journaling_object (object_type) VALUES
        ('employee');
    journaling_object_ids[15] := currval(pg_get_serial_sequence('journaling_object', 'object_id'));

    INSERT INTO journaling_object (object_type) VALUES
        ('employee');
    journaling_object_ids[16] := currval(pg_get_serial_sequence('journaling_object', 'object_id'));

    INSERT INTO journaling_object (object_type) VALUES
        ('employee');
    journaling_object_ids[17] := currval(pg_get_serial_sequence('journaling_object', 'object_id'));

    INSERT INTO journaling_object (object_type) VALUES
        ('employee');
    journaling_object_ids[18] := currval(pg_get_serial_sequence('journaling_object', 'object_id'));

    INSERT INTO journaling_object (object_type) VALUES
        ('line');
    journaling_object_ids[19] := currval(pg_get_serial_sequence('journaling_object', 'object_id'));

    INSERT INTO journaling_object (object_type) VALUES
        ('line');
    journaling_object_ids[20] := currval(pg_get_serial_sequence('journaling_object', 'object_id'));

    INSERT INTO journaling_object (object_type) VALUES
        ('line');
    journaling_object_ids[21] := currval(pg_get_serial_sequence('journaling_object', 'object_id'));

    INSERT INTO journaling_object (object_type) VALUES
        ('line');
    journaling_object_ids[22] := currval(pg_get_serial_sequence('journaling_object', 'object_id'));

    INSERT INTO journaling_object (object_type) VALUES
        ('line');
    journaling_object_ids[23] := currval(pg_get_serial_sequence('journaling_object', 'object_id'));

    INSERT INTO journaling_object (object_type) VALUES
        ('line');
    journaling_object_ids[24] := currval(pg_get_serial_sequence('journaling_object', 'object_id'));

    INSERT INTO journaling_object (object_type) VALUES
        ('boarding_pass');
    journaling_object_ids[25] := currval(pg_get_serial_sequence('journaling_object', 'object_id'));

    INSERT INTO journaling_object (object_type) VALUES
        ('boarding_pass');
    journaling_object_ids[26] := currval(pg_get_serial_sequence('journaling_object', 'object_id'));

    INSERT INTO journaling_object (object_type) VALUES
        ('boarding_pass');
    journaling_object_ids[27] := currval(pg_get_serial_sequence('journaling_object', 'object_id'));

    INSERT INTO journaling_object (object_type) VALUES
        ('boarding_pass');
    journaling_object_ids[28] := currval(pg_get_serial_sequence('journaling_object', 'object_id'));

    INSERT INTO journaling_object (object_type) VALUES
        ('boarding_pass');
    journaling_object_ids[29] := currval(pg_get_serial_sequence('journaling_object', 'object_id'));

    INSERT INTO journaling_object (object_type) VALUES
        ('boarding_pass');
    journaling_object_ids[30] := currval(pg_get_serial_sequence('journaling_object', 'object_id'));

    INSERT INTO journal (airport_id, object_id, action_time, action_description) VALUES
        (NULL, journaling_object_ids[1], '2026-11-03 08:00:00+00', 'Register state: in flight'),
        (NULL, journaling_object_ids[2], '2026-11-03 08:00:00+00', 'Register state: ready to takeoff'),
        (NULL, journaling_object_ids[3], '2026-11-03 08:00:00+00', 'Register state: ready to land'),
        (NULL, journaling_object_ids[4], '2026-11-03 08:00:00+00', 'Register state: broken'),
        (NULL, journaling_object_ids[5], '2026-11-03 08:00:00+00', 'Register state: checking'),
        (NULL, journaling_object_ids[6], '2026-11-03 08:00:00+00', 'Register state: waiting checking'),
        (airport_ids[1], journaling_object_ids[7], '2026-11-03 08:00:00+00', 'Register demonstration aircraft'),
        (airport_ids[1], journaling_object_ids[8], '2026-11-03 08:00:00+00', 'Register demonstration aircraft'),
        (airport_ids[1], journaling_object_ids[9], '2026-11-03 08:00:00+00', 'Register demonstration aircraft'),
        (airport_ids[2], journaling_object_ids[10], '2026-11-03 08:00:00+00', 'Register demonstration aircraft'),
        (airport_ids[2], journaling_object_ids[11], '2026-11-03 08:00:00+00', 'Register demonstration aircraft'),
        (airport_ids[2], journaling_object_ids[12], '2026-11-03 08:00:00+00', 'Register demonstration aircraft'),
        (airport_ids[1], journaling_object_ids[13], '2026-11-03 08:00:00+00', 'Register demonstration employee'),
        (airport_ids[2], journaling_object_ids[14], '2026-11-03 08:00:00+00', 'Register demonstration employee'),
        (airport_ids[1], journaling_object_ids[15], '2026-11-03 08:00:00+00', 'Register demonstration employee'),
        (airport_ids[2], journaling_object_ids[16], '2026-11-03 08:00:00+00', 'Register demonstration employee'),
        (airport_ids[1], journaling_object_ids[17], '2026-11-03 08:00:00+00', 'Register demonstration employee'),
        (airport_ids[2], journaling_object_ids[18], '2026-11-03 08:00:00+00', 'Register demonstration employee'),
        (airport_ids[1], journaling_object_ids[19], '2026-11-03 08:00:00+00', 'Register runway'),
        (airport_ids[1], journaling_object_ids[20], '2026-11-03 08:00:00+00', 'Register runway'),
        (airport_ids[2], journaling_object_ids[21], '2026-11-03 08:00:00+00', 'Register runway'),
        (airport_ids[2], journaling_object_ids[22], '2026-11-03 08:00:00+00', 'Register runway'),
        (airport_ids[3], journaling_object_ids[23], '2026-11-03 08:00:00+00', 'Register runway'),
        (airport_ids[3], journaling_object_ids[24], '2026-11-03 08:00:00+00', 'Register runway'),
        (NULL, journaling_object_ids[25], '2026-11-03 08:00:00+00', 'Issue ticket for flight 1'),
        (NULL, journaling_object_ids[26], '2026-11-03 08:00:00+00', 'Issue ticket for flight 1'),
        (NULL, journaling_object_ids[27], '2026-11-03 08:00:00+00', 'Issue ticket for flight 1'),
        (NULL, journaling_object_ids[28], '2026-11-03 08:00:00+00', 'Issue ticket for flight 3'),
        (NULL, journaling_object_ids[29], '2026-11-03 08:00:00+00', 'Issue ticket for flight 3'),
        (NULL, journaling_object_ids[30], '2026-11-03 08:00:00+00', 'Issue ticket for flight 3'),
        (airport_ids[2], journaling_object_ids[12], '2026-11-04 10:03:00+00', 'After arrival: waiting checking; initiated by demo dispatcher employee 16'),
        (airport_ids[1], journaling_object_ids[7], '2026-11-04 11:35:30+00', 'Takeoff completed: in flight; initiated by demo dispatcher employee 15'),
        (airport_ids[1], journaling_object_ids[9], '2026-11-04 11:59:00+00', 'Approaching airport: ready to land; initiated by demo dispatcher employee 15');

    INSERT INTO flight_status (status_id, status) VALUES
        (journaling_object_ids[1], 'in flight'),
        (journaling_object_ids[2], 'ready to takeoff'),
        (journaling_object_ids[3], 'ready to land'),
        (journaling_object_ids[4], 'broken'),
        (journaling_object_ids[5], 'checking'),
        (journaling_object_ids[6], 'waiting checking');

    INSERT INTO airplane (airplane_id, airport_id, hangar_number, status_id, width, length, height) VALUES
        (journaling_object_ids[7], airport_ids[1], NULL, journaling_object_ids[1], 20, 25, 8),
        (journaling_object_ids[8], airport_ids[1], NULL, journaling_object_ids[2], 22, 28, 9),
        (journaling_object_ids[9], airport_ids[1], NULL, journaling_object_ids[3], 20, 25, 8),
        (journaling_object_ids[10], airport_ids[2], 1, journaling_object_ids[4], 22, 28, 9),
        (journaling_object_ids[11], airport_ids[2], 2, journaling_object_ids[5], 20, 25, 8),
        (journaling_object_ids[12], airport_ids[2], 1, journaling_object_ids[6], 22, 28, 9);

    INSERT INTO employee (employee_id, position_id, firstname, lastname, middle_name, birthdate, working_place, contract_information) VALUES
        (journaling_object_ids[13], employee_position_ids[1], 'Ivan', 'Testov', NULL, '1990-02-10', 'North Airport', 'DEMO-P01'),
        (journaling_object_ids[14], employee_position_ids[1], 'Pavel', 'Primernov', 'Olegovich', '1988-06-12', 'Lake Airport', 'DEMO-P02'),
        (journaling_object_ids[15], employee_position_ids[2], 'Anna', 'Testova', NULL, '1992-01-11', 'North Airport', 'DEMO-D01'),
        (journaling_object_ids[16], employee_position_ids[2], 'Elena', 'Primernova', NULL, '1991-03-21', 'Lake Airport', 'DEMO-D02'),
        (journaling_object_ids[17], employee_position_ids[3], 'Oleg', 'Testov', NULL, '1985-04-15', 'North Airport', 'DEMO-M01'),
        (journaling_object_ids[18], employee_position_ids[3], 'Denis', 'Primernov', NULL, '1987-09-09', 'Lake Airport', 'DEMO-M02');

    INSERT INTO line (line_id, airport_id, is_free, latitude, longitude, altitude, width, length, direction) VALUES
        (journaling_object_ids[19], airport_ids[1], true, 55, 37, 150, 40, 2000, 90),
        (journaling_object_ids[20], airport_ids[1], true, 55.001, 37.001, 150, 40, 2200, 270),
        (journaling_object_ids[21], airport_ids[2], true, 56, 38, 180, 40, 2000, 90),
        (journaling_object_ids[22], airport_ids[2], true, 56.001, 38.001, 180, 40, 2200, 270),
        (journaling_object_ids[23], airport_ids[3], true, 54, 36, 120, 40, 2000, 90),
        (journaling_object_ids[24], airport_ids[3], true, 54.001, 36.001, 120, 40, 2200, 270);

    INSERT INTO flight (airplane_id, employee_id, takeoff_line_id, planned_takeoff_time, actual_takeoff_time, planned_land_time, actual_land_time) VALUES
        (journaling_object_ids[12], journaling_object_ids[14], journaling_object_ids[19], '2026-11-04 09:00:00+00', '2026-11-04 09:05:00+00', '2026-11-04 10:00:00+00', '2026-11-04 10:03:00+00');
    flight_ids[1] := currval(pg_get_serial_sequence('flight', 'flight_id'));

    INSERT INTO flight (airplane_id, employee_id, takeoff_line_id, planned_takeoff_time, actual_takeoff_time, planned_land_time, actual_land_time) VALUES
        (journaling_object_ids[7], journaling_object_ids[13], journaling_object_ids[19], '2026-11-04 11:30:00+00', '2026-11-04 11:35:00+00', '2026-11-04 12:30:00+00', NULL);
    flight_ids[2] := currval(pg_get_serial_sequence('flight', 'flight_id'));

    INSERT INTO flight (airplane_id, employee_id, takeoff_line_id, planned_takeoff_time, actual_takeoff_time, planned_land_time, actual_land_time) VALUES
        (journaling_object_ids[8], journaling_object_ids[13], journaling_object_ids[20], '2026-11-04 14:00:00+00', NULL, '2026-11-04 15:00:00+00', NULL);
    flight_ids[3] := currval(pg_get_serial_sequence('flight', 'flight_id'));

    INSERT INTO flight (airplane_id, employee_id, takeoff_line_id, planned_takeoff_time, actual_takeoff_time, planned_land_time, actual_land_time) VALUES
        (journaling_object_ids[9], journaling_object_ids[14], journaling_object_ids[21], '2026-11-04 11:00:00+00', '2026-11-04 11:02:00+00', '2026-11-04 12:05:00+00', NULL);
    flight_ids[4] := currval(pg_get_serial_sequence('flight', 'flight_id'));

    INSERT INTO passenger (firstname, lastname, middle_name, birthdate, passport_data, country) VALUES
        ('Demo1', 'Passenger', NULL, '1995-01-01', 'DEMO-DOCUMENT-1', 'Testland');
    passenger_ids[1] := currval(pg_get_serial_sequence('passenger', 'passenger_id'));

    INSERT INTO passenger (firstname, lastname, middle_name, birthdate, passport_data, country) VALUES
        ('Demo2', 'Passenger', NULL, '1995-01-01', 'DEMO-DOCUMENT-2', 'Testland');
    passenger_ids[2] := currval(pg_get_serial_sequence('passenger', 'passenger_id'));

    INSERT INTO passenger (firstname, lastname, middle_name, birthdate, passport_data, country) VALUES
        ('Demo3', 'Passenger', NULL, '1995-01-01', 'DEMO-DOCUMENT-3', 'Testland');
    passenger_ids[3] := currval(pg_get_serial_sequence('passenger', 'passenger_id'));

    INSERT INTO passenger (firstname, lastname, middle_name, birthdate, passport_data, country) VALUES
        ('Demo4', 'Passenger', NULL, '1995-01-01', 'DEMO-DOCUMENT-4', 'Testland');
    passenger_ids[4] := currval(pg_get_serial_sequence('passenger', 'passenger_id'));

    INSERT INTO passenger (firstname, lastname, middle_name, birthdate, passport_data, country) VALUES
        ('Demo5', 'Passenger', NULL, '1995-01-01', 'DEMO-DOCUMENT-5', 'Testland');
    passenger_ids[5] := currval(pg_get_serial_sequence('passenger', 'passenger_id'));

    INSERT INTO boarding_pass (ticket_id, passenger_id, flight_id, seat, class, gate) VALUES
        (journaling_object_ids[25], passenger_ids[1], flight_ids[1], '1A', 'business', 1),
        (journaling_object_ids[26], passenger_ids[2], flight_ids[1], '12A', 'economy', 1),
        (journaling_object_ids[27], passenger_ids[3], flight_ids[1], '12B', 'economy', 1),
        (journaling_object_ids[28], passenger_ids[1], flight_ids[3], '1A', 'business', NULL),
        (journaling_object_ids[29], passenger_ids[2], flight_ids[3], '12A', 'economy', NULL),
        (journaling_object_ids[30], passenger_ids[4], flight_ids[3], '12B', 'economy', NULL);

    INSERT INTO landing (flight_id, line_id, landing_time) VALUES
        (flight_ids[1], journaling_object_ids[21], '2026-11-04 10:03:00+00');

    INSERT INTO airplane_master (airplane_id, employee_id, started_at, ended_at) VALUES
        (journaling_object_ids[12], journaling_object_ids[15], '2026-11-04 08:50:00+00', '2026-11-04 09:10:00+00'),
        (journaling_object_ids[12], journaling_object_ids[16], '2026-11-04 09:45:00+00', '2026-11-04 10:05:00+00'),
        (journaling_object_ids[7], journaling_object_ids[15], '2026-11-04 11:20:00+00', '2026-11-04 11:40:00+00'),
        (journaling_object_ids[9], journaling_object_ids[15], '2026-11-04 11:55:00+00', NULL);

    INSERT INTO plane_positions (airplane_id, latitude, longitude, altitude, pitch, direction, speed, time_utc) VALUES
        (journaling_object_ids[7], 55.4, 37.4, 2500, 0, 40, 100, '2026-11-04 11:59:00+00'),
        (journaling_object_ids[7], 55.42, 37.42, 2500, 0, 40, 100, '2026-11-04 11:59:30+00'),
        (journaling_object_ids[7], 55.44, 37.44, 2500, 0, 40, 100, '2026-11-04 12:00:00+00'),
        (journaling_object_ids[9], 55.02, 37.02, 600,  -3, 220, 65, '2026-11-04 11:59:00+00'),
        (journaling_object_ids[9], 55.01, 37.01, 500,  -3, 220, 60, '2026-11-04 11:59:30+00'),
        (journaling_object_ids[9], 55.005, 37.005, 400,  -3, 220, 55, '2026-11-04 12:00:00+00'),
        (journaling_object_ids[8], 55, 37, 150, 0, 90, 0, '2026-11-04 12:00:00+00'),
        (journaling_object_ids[10], 56, 38, 180, 0, 0, 0, '2026-11-04 12:00:00+00'),
        (journaling_object_ids[11], 56, 38, 180, 0, 0, 0, '2026-11-04 12:00:00+00'),
        (journaling_object_ids[12], 56, 38, 180, 0, 0, 0, '2026-11-04 10:03:00+00'),
        (journaling_object_ids[12], 56, 38, 180, 0, 0, 0, '2026-11-04 12:00:00+00');
END $load$;

COMMIT;
