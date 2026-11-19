import argparse
import io
import psycopg
from psycopg import sql
import math
import random
from collections import Counter
from datetime import date, datetime, timedelta, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parent
CITIES = (
    ('Москва', 55.7558, 37.6173), ('Тверь', 56.8587, 35.9176),
    ('Тула', 54.1931, 37.6173), ('Калуга', 54.5138, 36.2612),
    ('Рязань', 54.6292, 39.7364), ('Владимир', 56.1291, 40.4066),
    ('Иваново', 56.9995, 40.9737), ('Ярославль', 57.6261, 39.8845),
    ('Кострома', 57.7679, 40.9269), ('Смоленск', 54.7826, 32.0453),
    ('Брянск', 53.2436, 34.3634), ('Орёл', 52.9685, 36.0692),
    ('Курск', 51.7304, 36.1926), ('Воронеж', 51.6608, 39.2003),
    ('Липецк', 52.6102, 39.5947), ('Тамбов', 52.7212, 41.4523),
    ('Нижний Новгород', 56.3269, 44.0059), ('Пенза', 53.1959, 45.0183),
)
AIRPORT_NAMES = (
    'Ещё кружочек', 'Попутный гусь', 'Крылатый пельмень',
    'Без паники', 'Чемодан надежды', 'Небесный карась',
    'Мягкая посадочка', 'Взлётный бутерброд', 'Облако в тапочках',
    'Летучий самовар', 'Турбулентный хомяк', 'Почти на месте',
    'Багажный экспресс', 'Счастливый шасси', 'Зефирный горизонт',
)
MALE_NAMES = ('Аркадий', 'Борис', 'Василий', 'Геннадий', 'Григорий', 'Егор',
              'Ернест', 'Игнат', 'Лев', 'Мирон', 'Никита', 'Платон', 'Семён', 'Фёдор', 'Яков')
FEMALE_NAMES = ('Аглая', 'Алиса', 'Варвара', 'Вера', 'Галина', 'Дарья', 'Евдокия',
                'Зоя', 'Инна', 'Кира', 'Лада', 'Нина', 'Полина', 'Таисия', 'Яна')
SURNAMES = ('Бублик', 'Карась', 'Самовар', 'Вареник', 'Компот', 'Сухарик',
            'Пельмень', 'Чемодан', 'Кекс', 'Пряник', 'Штрудель', 'Пончик',
            'Барабан', 'Сквозняк', 'Крендель', 'Кабачок', 'Патиссон', 'Шпунтик',
            'Ландыш', 'Туман', 'Круассан', 'Баклажан', 'Филин', 'Пломбир')
PATRONYMICS = (('Аркадьевич', 'Аркадьевна'), ('Борисович', 'Борисовна'),
               ('Васильевич', 'Васильевна'), ('Геннадьевич', 'Геннадьевна'),
               ('Львович', 'Львовна'), ('Платонович', 'Платоновна'),
               ('Семёнович', 'Семёновна'), ('Фёдорович', 'Фёдоровна'))
COUNTRIES = ('Россия', 'Беларусь', 'Казахстан', 'Армения', 'Сербия', 'Грузия')
STATES = (
    'in flight', 'ready to takeoff', 'ready to land',
    'broken', 'checking', 'waiting checking',
)
COLUMNS = {
    'runway_usage': 'usage_id,line_id,flight_id,operation_type,assigned_at,occupied_at,released_at',
    'aircraft_inspection': 'inspection_id,airplane_id,mechanic_id,started_at,finished_at,result',
    'airport': 'airport_id,latitude,longitude,altitude,airspace_radius,city,country,name',
    'employee_position': 'position_id,name,duties',
    'hangar': 'hangar_number,airport_id,width,length,height,latitude,longitude',
    'journaling_object': 'object_id,object_type',
    'journal': 'journal_id,airport_id,object_id,action_time,action_description',
    'flight_status': 'status_id,status',
    'airplane': 'airplane_id,airport_id,hangar_number,status_id,width,length,height,base_airport_id,aircraft_type',
    'employee': 'employee_id,position_id,firstname,lastname,middle_name,birthdate,working_place,contract_information',
    'line': 'line_id,airport_id,is_free,latitude,longitude,altitude,width,length,direction',
    'flight': 'flight_id,airplane_id,employee_id,takeoff_line_id,planned_takeoff_time,actual_takeoff_time,planned_land_time,actual_land_time,destination_airport_id',
    'passenger': 'passenger_id,firstname,lastname,middle_name,birthdate,passport_data,country',
    'boarding_pass': 'ticket_id,passenger_id,flight_id,seat,class,gate',
    'landing': 'landing_id,flight_id,line_id,landing_time',
    'airplane_master': 'assignment_id,airplane_id,employee_id,started_at,ended_at',
    'plane_positions': 'position_id,airplane_id,latitude,longitude,altitude,pitch,direction,speed,time_utc',
}
IDENTITY = {
    'runway_usage': 'usage_id', 'aircraft_inspection': 'inspection_id',
    'airport': 'airport_id', 'employee_position': 'position_id',
    'journaling_object': 'object_id', 'journal': 'journal_id',
    'flight': 'flight_id', 'passenger': 'passenger_id',
    'landing': 'landing_id', 'airplane_master': 'assignment_id',
    'plane_positions': 'position_id',
}


def arguments(argv=None):
    parser = argparse.ArgumentParser()
    parser.add_argument('--airports', type=int, default=9)
    parser.add_argument('--airplanes', type=int, default=36)
    parser.add_argument('--flights', type=int, default=300)
    parser.add_argument('--passengers', type=int, default=900)
    parser.add_argument('--max-tickets', type=int, default=12)
    parser.add_argument('--position-step', type=int, default=30)
    parser.add_argument('--seed', type=int, default=40)
    parser.add_argument('--start-date', default='2026-01-01')
    parser.add_argument('--output', type=Path, default=ROOT / 'generated_data.sql')
    parser.add_argument('--dsn', help='PostgreSQL connection string; load instead of exporting SQL')
    parser.add_argument('--overwrite', action='store_true')
    args = parser.parse_args(argv)
    if (args.airports < 2 or args.airplanes < 1
            or min(args.flights, args.passengers, args.max_tickets) < 0
            or not 1 <= args.position_step <= 30
            or args.max_tickets > min(120, max(0, args.passengers - 1))):
        raise ValueError
    args.start = datetime.combine(date.fromisoformat(args.start_date), datetime.min.time(), timezone.utc)
    args.output = (ROOT / args.output).resolve()
    if not args.output.is_relative_to(ROOT) or args.output.suffix.lower() != '.sql':
        raise ValueError(args.output)
    if args.output.name.lower() in {'create.sql', 'seed.sql'}:
        raise ValueError(args.output)
    return args


def distance(a, b):
    lat1, lat2 = math.radians(a[1]), math.radians(b[1])
    dlat = lat2 - lat1
    dlon = math.radians(b[2] - a[2])
    h = math.sin(dlat / 2) ** 2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon / 2) ** 2
    return 6371000 * 2 * math.asin(min(1, math.sqrt(h)))


def bearing(a, b):
    lat1, lat2 = math.radians(a[1]), math.radians(b[1])
    dlon = math.radians(b[2] - a[2])
    return math.degrees(math.atan2(
        math.sin(dlon) * math.cos(lat2),
        math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dlon),
    )) % 360


def departure_time(start, snapshot, plane_index, trip, last, scenario, duration):
    if not last:
        return start + timedelta(days=trip, hours=6, minutes=(plane_index % 20) * 10)
    if scenario == 'completed':
        return snapshot - timedelta(hours=2)
    if scenario == 'in_flight':
        return snapshot - timedelta(minutes=10)
    if scenario == 'approaching':
        return snapshot - duration + timedelta(seconds=60)
    return snapshot + timedelta(hours=1)


def add_trajectory(rows, flight, snapshot, step):
    start_point = rows['airport'][flight['origin'] - 1]
    end_point = rows['airport'][flight['destination'] - 1]
    start = flight['actual_takeoff_time']
    seconds = int(flight['duration'].total_seconds())
    flown_seconds = seconds if flight['actual_land_time'] else int((snapshot - start).total_seconds())
    offsets = list(range(0, flown_seconds + 1, step))
    if offsets[-1] != flown_seconds:
        offsets.append(flown_seconds)
    total_distance = distance(start_point, end_point)
    direction = round(bearing(start_point, end_point), 3) % 360
    speed = total_distance / seconds
    for offset in offsets:
        fraction = offset / seconds
        lat = round(start_point[1] + (end_point[1] - start_point[1]) * fraction, 7)
        lon = round(start_point[2] + (end_point[2] - start_point[2]) * fraction, 7)
        altitude = round(start_point[3] + (end_point[3] - start_point[3]) * fraction + 2000 * math.sin(math.pi * fraction), 2)
        vertical_speed = (end_point[3] - start_point[3] + 2000 * math.pi * math.cos(math.pi * fraction)) / seconds
        pitch = round(math.degrees(math.atan2(vertical_speed, speed)), 3)
        position = (
            len(rows['plane_positions']) + 1, flight['airplane_id'],
            lat, lon, altitude, pitch, direction, round(speed, 2),
            start + timedelta(seconds=offset),
        )
        rows['plane_positions'].append(position)
    return flown_seconds, total_distance


def available_passengers(bookings, start, end):
    available = []
    for passenger, intervals in bookings.items():
        free = True
        for booked_start, booked_end in intervals:
            if start < booked_end and end > booked_start:
                free = False
                break
        if free:
            available.append(passenger)
    return available


def choose_dispatcher(assignments, candidates, start):
    workloads = []
    for candidate in candidates:
        active = 0
        for _, _, employee_id, assigned_at, ended_at in assignments:
            if employee_id == candidate and assigned_at <= start:
                if ended_at is None or ended_at > start:
                    active += 1
        workloads.append((active, candidate))
    _, employee_id = min(workloads)
    return employee_id


def generate(args):
    rng = random.Random(args.seed)
    rows = {name: [] for name in COLUMNS}
    registration = args.start - timedelta(days=1)
    snapshot = args.start + timedelta(days=(args.flights + args.airplanes - 1) // args.airplanes + 2, hours=12)
    scenarios = Counter()
    occupied_runways = set()

    def person():
        gender = rng.randrange(2)
        firstname = rng.choice((MALE_NAMES, FEMALE_NAMES)[gender])
        lastname = rng.choice(SURNAMES)
        middle_name = rng.choice(PATRONYMICS)[gender] if rng.random() < 0.8 else None
        birthdate = date(rng.randint(1965, 2005), rng.randint(1, 12), rng.randint(1, 28))
        return firstname, lastname, middle_name, birthdate

    def add_event(object_id, airport_id, when, description):
        rows['journal'].append((len(rows['journal']) + 1, airport_id, object_id, when, description))

    def register_object(kind, airport_id=None):
        object_id = len(rows['journaling_object']) + 1
        add_event(object_id, airport_id, registration, f'Register demonstration {kind}')
        rows['journaling_object'].append((object_id, kind))
        return object_id

    for airport_id in range(1, args.airports + 1):
        city, city_lat, city_lon = CITIES[(airport_id - 1) % len(CITIES)]
        lat = round(city_lat + rng.uniform(-0.08, 0.08), 7)
        lon = round(city_lon + rng.uniform(-0.08, 0.08), 7)
        altitude = round(rng.uniform(100, 300), 2)
        name = f'{city} — {AIRPORT_NAMES[(airport_id - 1) % len(AIRPORT_NAMES)]} №{airport_id}'
        rows['airport'].append((airport_id, lat, lon, altitude, rng.choice((25000, 30000, 40000)), city, 'Россия', name))
        for hangar in (1, 2):
            rows['hangar'].append((hangar, airport_id, 80, 90, 25, lat, lon))
    for i, state in enumerate(STATES, 1):
        rows['flight_status'].append((register_object('flight_status'), state))
    rows['employee_position'] = [(1, 'pilot', 'Operate aircraft'), (2, 'dispatcher', 'Coordinate aircraft'), (3, 'mechanic', 'Inspect aircraft')]

    dispatchers, mechanics, runways = {}, {}, {}

    def create_employee(role, airport):
        employee_id = register_object('employee', airport)
        rows['employee'].append((employee_id, role, *person(), rows['airport'][airport - 1][7], f'ТРУД-{employee_id:06d}'))
        return employee_id

    for airport_id in range(1, args.airports + 1):
        dispatchers[airport_id] = [create_employee(2, airport_id), create_employee(2, airport_id)]
        mechanics[airport_id] = create_employee(3, airport_id)
        runways[airport_id] = []
        airport = rows['airport'][airport_id - 1]
        for direction in (90, 270):
            runway_id = register_object('line', airport_id)
            rows['line'].append((runway_id, airport_id, True, airport[1], airport[2], airport[3], 45, 2500, direction))
            runways[airport_id].append(runway_id)

    planes = []
    for i in range(args.airplanes):
        home = i % args.airports + 1
        planes.append((register_object('airplane', home), create_employee(1, home), home))
    for i in range(1, args.passengers + 1):
        rows['passenger'].append((i, *person(), f'УЧЕБНЫЙ-{i:08d}', rng.choices(COUNTRIES, weights=(65, 10, 10, 5, 5, 5))[0]))

    flights = []
    for plane_index, (plane_id, pilot, home) in enumerate(planes):
        count = len(range(plane_index, args.flights, args.airplanes))
        current = home
        status = (2, 4, 5, 6)[plane_index % 4]
        ground = True
        for trip in range(count):
            last = trip == count - 1
            scenario = ('completed', 'in_flight', 'approaching', 'planned')[plane_index % 4] if last else 'completed'
            duration = timedelta(minutes=rng.randint(25, 55))
            destinations = [a for a in range(1, args.airports + 1) if a != current]
            destination = rng.choices(destinations, weights=[3 if a == 1 else 1 for a in destinations])[0]
            planned_start = departure_time(args.start, snapshot, plane_index, trip, last, scenario, duration)
            delay = rng.randint(-3, 15) if not last else 0
            actual_start = None if scenario == 'planned' else planned_start + timedelta(minutes=delay)
            actual_end = actual_start + duration if scenario == 'completed' else None
            planned_end = planned_start + duration + timedelta(minutes=rng.randint(-3, 3))
            flight_id = len(flights) + 1
            flight = {
                'flight_id': flight_id,
                'airplane_id': plane_id,
                'employee_id': pilot,
                'takeoff_line_id': rng.choice(runways[current]),
                'planned_takeoff_time': planned_start,
                'actual_takeoff_time': actual_start,
                'planned_land_time': planned_end,
                'actual_land_time': actual_end,
                'origin': current,
                'destination': destination,
                'destination_airport_id': destination,
                'duration': duration,
                'scenario': scenario,
            }
            rows['flight'].append(tuple(flight[column] for column in COLUMNS['flight'].split(',')))
            flights.append(flight)
            scenarios[scenario] += 1
            if actual_start is not None:
                occupied_at = actual_start - timedelta(minutes=1 + flight_id % 3)
                rows['runway_usage'].append((
                    len(rows['runway_usage']) + 1, flight['takeoff_line_id'], flight_id, 'takeoff',
                    occupied_at - timedelta(minutes=2), occupied_at, actual_start + timedelta(seconds=30),
                ))
            if scenario == 'planned':
                status = 2
                occupied_runways.add(flight['takeoff_line_id'])
                rows['runway_usage'].append((
                    len(rows['runway_usage']) + 1, flight['takeoff_line_id'], flight_id, 'takeoff',
                    snapshot - timedelta(minutes=20), snapshot - timedelta(minutes=1), None,
                ))
                add_event(plane_id, current, snapshot - timedelta(minutes=20), f'Ready to takeoff; demo mechanic {mechanics[current]}')
                continue

            add_event(plane_id, current, actual_start - timedelta(minutes=10), f'Ready to takeoff; demo mechanic {mechanics[current]}')
            add_event(plane_id, current, actual_start, f'In flight; demo pilot {pilot}')
            seconds = int(duration.total_seconds())
            flown_seconds, total_distance = add_trajectory(rows, flight, snapshot, args.position_step)
            if actual_end:
                status = 6
                current = destination
                landing_line = rng.choice(runways[destination])
                rows['landing'].append((len(rows['landing']) + 1, flight_id, landing_line, actual_end))
                rows['runway_usage'].append((
                    len(rows['runway_usage']) + 1, landing_line, flight_id, 'landing',
                    actual_end - timedelta(minutes=4), actual_end - timedelta(seconds=30),
                    actual_end + timedelta(seconds=30 + 15 * (flight_id % 4)),
                ))
                add_event(plane_id, destination, actual_end, f'Waiting checking after flight {flight_id}; demo dispatcher')
                if last:
                    status = (4, 5, 6)[(plane_index // 4) % 3]
                    if status != 6:
                        add_event(plane_id, destination, actual_end + timedelta(minutes=10), f'{STATES[status - 1]}; mechanic {mechanics[destination]}')
                if not last or status in (4, 5):
                    started_at = actual_end + timedelta(minutes=5)
                    finished_at = None if last and status == 5 else started_at + timedelta(minutes=10 + flight_id % 20)
                    result = None if finished_at is None else (
                        'critical_defect' if status == 4 else 'serviceable'
                    )
                    rows['aircraft_inspection'].append((
                        len(rows['aircraft_inspection']) + 1, plane_id, mechanics[destination],
                        started_at, finished_at, result,
                    ))
            else:
                ground = False
                status = 3 if scenario == 'approaching' else 1
            approach_offset = max(1, math.ceil(seconds * max(0, 1 - 19000 / max(total_distance, 1))))
            if approach_offset <= flown_seconds:
                add_event(plane_id, destination, actual_start + timedelta(seconds=approach_offset), f'Ready to land for flight {flight_id}; demo pilot {pilot}')
                if not actual_end:
                    status = 3

        if not count:
            add_event(plane_id, current, snapshot, f'Current demonstration state: {STATES[status - 1]}')
        hangar = 1 + plane_index % 2 if ground and status != 2 else None
        rows['airplane'].append((plane_id, current, hangar, status, round(rng.uniform(18, 35), 2), round(rng.uniform(22, 40), 2), round(rng.uniform(7, 12), 2), home, ('Turboprop', 'Regional jet')[plane_index % 2]))
        if ground:
            airport = rows['airport'][current - 1]
            rows['plane_positions'].append((len(rows['plane_positions']) + 1, plane_id, airport[1], airport[2], airport[3], 0, 0, 0, snapshot))

    rows['line'] = [(*row[:2], row[0] not in occupied_runways, *row[3:]) for row in rows['line']]
    bookings = {i: [] for i in range(1, args.passengers)}
    responsibilities = []
    flights.sort(key=lambda flight: flight['actual_takeoff_time'] or flight['planned_takeoff_time'])
    for flight in flights:
        flight_id = flight['flight_id']
        plane_id = flight['airplane_id']
        origin = flight['origin']
        scenario = flight['scenario']
        actual_start = flight['actual_takeoff_time']
        actual_end = flight['actual_land_time']
        start = actual_start or flight['planned_takeoff_time']
        end = actual_end or (start + flight['duration'])
        eligible = available_passengers(bookings, start, end)
        wanted = 0 if flight_id % 7 == 0 else rng.randint(0, args.max_tickets)
        passengers = rng.sample(eligible, min(wanted, len(eligible)))
        for seat_index, passenger in enumerate(passengers):
            ticket_id = register_object('boarding_pass', origin)
            seat = f'{seat_index // 4 + 1}{"ABCD"[seat_index % 4]}'
            cabin = 'business' if seat_index < 4 else 'economy'
            rows['boarding_pass'].append((ticket_id, passenger, flight_id, seat, cabin, None if scenario == 'planned' else 1 + flight_id % 4))
            bookings[passenger].append((start, end))
            add_event(ticket_id, origin, min(start - timedelta(hours=2), snapshot), f'Issue ticket for flight {flight_id}')
        if actual_start:
            responsibilities.append((actual_start - timedelta(minutes=5), actual_start + timedelta(minutes=2), origin, plane_id))
            arrival_start = end - timedelta(minutes=5)
            if arrival_start <= snapshot:
                responsibilities.append((arrival_start, end + timedelta(minutes=1) if actual_end else None, flight['destination'], plane_id))

    for start, end, airport, plane_id in sorted(responsibilities):
        dispatcher = choose_dispatcher(rows['airplane_master'], dispatchers[airport], start)
        rows['airplane_master'].append((len(rows['airplane_master']) + 1, plane_id, dispatcher, start, end))

    metadata = {
        'parameters': {key: getattr(args, key) for key in ('airports', 'airplanes', 'flights', 'passengers', 'max_tickets', 'position_step', 'seed', 'start_date')},
        'snapshot_utc': snapshot.isoformat(),
        'rows': {table: len(data) for table, data in rows.items()},
        'scenarios': dict(sorted(scenarios.items())),
        'limitations': [
            'Status changes are recorded as journal text.',
            'Geometric trajectories are not a flight dynamics simulation.',
            'The 30-second bound covers flight segments, not parked periods.',
        ],
    }
    return rows, metadata


REFERENCES = {
    'base_airport_id': 'airport', 'destination_airport_id': 'airport',
    'mechanic_id': 'journaling_object',
    'airport_id': 'airport',
    'object_id': 'journaling_object', 'airplane_id': 'journaling_object',
    'employee_id': 'journaling_object', 'status_id': 'journaling_object',
    'line_id': 'journaling_object', 'takeoff_line_id': 'journaling_object',
    'ticket_id': 'journaling_object', 'flight_id': 'flight',
    'passenger_id': 'passenger',
}
ORDER = ['airport', 'employee_position', 'hangar', 'journaling_object', 'journal',
         'flight_status', 'airplane', 'employee', 'line', 'flight', 'passenger',
         'boarding_pass', 'landing', 'airplane_master', 'plane_positions',
         'runway_usage', 'aircraft_inspection']


def write_sql(handle, rows, metadata):
    saved_ids = ('airport', 'employee_position', 'journaling_object', 'flight', 'passenger')
    handle.write("BEGIN;\nSET LOCAL TIME ZONE 'UTC';\n\nDO $load$\nDECLARE\n")
    for table in saved_ids:
        handle.write(f'    {table}_ids bigint[];\n')
    handle.write('BEGIN\n')
    handle.write('    LOCK TABLE ' + ', '.join(ORDER) + ' IN EXCLUSIVE MODE;\n')
    for table in ORDER:
        handle.write(f"    IF EXISTS (SELECT 1 FROM {table}) THEN\n")
        handle.write(f"        RAISE EXCEPTION 'Table must be empty: {table}';\n    END IF;\n")
    for table in ORDER:
        columns = COLUMNS[table].split(',')
        selected = [column for column in columns if column != IDENTITY.get(table)]
        insert = f"    INSERT INTO {table} ({', '.join(selected)}) VALUES\n"
        batch = []
        for row in rows[table]:
            values = []
            for column, value in zip(columns, row):
                if column not in selected:
                    continue
                target = REFERENCES.get(column)
                if table == 'employee' and column == 'position_id':
                    target = 'employee_position'
                if value is not None and target:
                    values.append(f'{target}_ids[{value}]')
                else:
                    values.append(sql.Literal(value).as_string())
            batch.append('        (' + ', '.join(values) + ')')
            if table in saved_ids:
                handle.write('\n' + insert + batch.pop() + ';\n')
                handle.write(f"    {table}_ids[{row[0]}] := currval(pg_get_serial_sequence('{table}', '{IDENTITY[table]}'));\n")
        if batch:
            handle.write('\n' + insert + ',\n'.join(batch) + ';\n')
    handle.write('END $load$;\n\nCOMMIT;\n')


def main(argv=None):
    args = arguments(argv)
    rows, metadata = generate(args)
    if args.dsn is not None:
        buffer = io.StringIO()
        write_sql(buffer, rows, metadata)
        with psycopg.connect(args.dsn) as connection:
            connection.execute(buffer.getvalue())
        print(metadata['rows'])
    else:
        with args.output.open('w' if args.overwrite else 'x', encoding='utf-8', newline='\n') as handle:
            write_sql(handle, rows, metadata)
        print(args.output)


if __name__ == '__main__':
    main()
