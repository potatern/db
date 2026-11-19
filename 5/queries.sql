/*
Первый запрос должен предоставлять статистику эксплуатации самолётов.
Отчёт должен содержать информацию о каждом самолёте, его типе, аэропорте базирования, общем количестве выполненных рейсов, суммарном времени нахождения в полёте, средней продолжительности рейса, дате последнего вылёта и текущем техническом состоянии.

Второй запрос предназначен для анализа загрузки авиадиспетчеров.
В отчёте необходимо отразить ФИО диспетчера, аэропорт, количество самолётов под его ответственностью, общее число назначений за выбранный период, среднее время сопровождения самолёта, дату последнего назначения, а также относительную загрузку диспетчера по сравнению со средним значением по аэропорту.

Третий запрос должен анализировать использование взлётно-посадочных полос.
Отчёт формируется по каждой полосе и включает количество выполненных взлётов и посадок, среднее время занятости полосы, максимальное время непрерывного использования, а также дату и время последнего применения полосы.

Четвёртый запрос предназначен для анализа отклонений от планового расписания рейсов.
В отчёте необходимо отразить плановые и фактические времена вылета и прилёта, величину отклонений в минутах, аэропорты вылета и назначения, а также итоговый статус рейса.

Пятый запрос формирует статистику работы механиков.
Отчёт должен содержать информацию о количестве проведённых проверок, числе самолётов, признанных исправными и неисправными, проценте критических неисправностей, среднем времени проверки и дате последней выполненной проверки.
*/



WITH completed_flights AS (
    SELECT f.airplane_id,
        COUNT(f.actual_land_time) AS completed_count,
        SUM(actual_land_time - actual_takeoff_time) AS total_flight_time,
        AVG(actual_land_time - actual_takeoff_time) AS avg_flight_time
    FROM flight AS f
    JOIN line AS l ON l.line_id = f.takeoff_line_id
    JOIN airport AS a ON a.airport_id = l.airport_id
    WHERE f.actual_takeoff_time IS NOT NULL
    GROUP BY f.airplane_id
    HAVING COUNT(f.actual_land_time) > 0
),
last_departures AS (
    SELECT airplane_id, MAX(actual_takeoff_time) AS last_departure_at
    FROM flight
    GROUP BY airplane_id
)
SELECT p.airplane_id,
    p.aircraft_type AS airplane_type,
    base.name AS base_airport,
    a.name AS recorded_airport,
    COALESCE(c.completed_count, 0) AS completed_count,
    COALESCE(c.total_flight_time, INTERVAL '0 seconds') AS total_flight_time,
    c.avg_flight_time,
    d.last_departure_at,
    s.status AS current_status
FROM airplane AS p
JOIN airport AS a ON a.airport_id = p.airport_id
JOIN airport AS base ON base.airport_id = p.base_airport_id
JOIN flight_status AS s ON s.status_id = p.status_id
LEFT JOIN completed_flights AS c ON c.airplane_id = p.airplane_id
LEFT JOIN last_departures AS d ON d.airplane_id = p.airplane_id
ORDER BY p.airplane_id;

WITH report_snapshot AS (
    SELECT COALESCE(MAX(time_utc), CURRENT_TIMESTAMP) AS as_of
    FROM plane_positions
),
report_period AS (
    SELECT DATE_TRUNC('month', as_of AT TIME ZONE 'UTC') AT TIME ZONE 'UTC' AS starts_at,
        (DATE_TRUNC('month', as_of AT TIME ZONE 'UTC') + INTERVAL '1 month') AT TIME ZONE 'UTC' AS ends_at,
        as_of
    FROM report_snapshot
),
period_employees AS (
    SELECT DISTINCT m.employee_id
    FROM airplane_master AS m
    CROSS JOIN report_period AS r
    WHERE m.started_at >= r.starts_at AND m.started_at < r.ends_at AND m.started_at <= r.as_of
),
unassigned_dispatchers AS (
    SELECT e.employee_id
    FROM employee AS e
    JOIN employee_position AS p ON p.position_id = e.position_id
    LEFT JOIN period_employees AS m ON m.employee_id = e.employee_id
    WHERE p.name = 'dispatcher' AND m.employee_id IS NULL
),
dispatcher_stats AS (
    SELECT e.employee_id,
        CONCAT_WS(' ', e.lastname, e.firstname, e.middle_name) AS full_name,
        e.working_place AS airport,
        COUNT(DISTINCT m.airplane_id) FILTER (
            WHERE m.started_at <= r.as_of
                AND (m.ended_at IS NULL OR m.ended_at > r.as_of)
        ) AS active_airplanes,
        COUNT(m.assignment_id) FILTER (
            WHERE m.started_at >= r.starts_at AND m.started_at < r.ends_at AND m.started_at <= r.as_of
        ) AS assignments_in_period,
        AVG(m.ended_at - m.started_at) FILTER (
            WHERE m.started_at >= r.starts_at
                AND m.started_at < r.ends_at AND m.started_at <= r.as_of
                AND m.ended_at <= r.as_of
        ) AS avg_tracking_time,
        MAX(m.started_at) FILTER (WHERE m.started_at <= r.as_of) AS last_assignment_at
    FROM employee AS e
    JOIN employee_position AS p ON p.position_id = e.position_id
    CROSS JOIN report_period AS r
    LEFT JOIN airplane_master AS m ON m.employee_id = e.employee_id
    WHERE p.name = 'dispatcher'
    GROUP BY e.employee_id, e.lastname, e.firstname, e.middle_name, e.working_place
),
airport_load AS (
    SELECT d.*, AVG(active_airplanes) OVER (PARTITION BY airport) AS avg_active_airplanes
    FROM dispatcher_stats AS d
)
SELECT d.employee_id, full_name, airport, active_airplanes, assignments_in_period,
    u.employee_id IS NOT NULL AS no_assignments_in_period,
    avg_tracking_time, last_assignment_at,
    ROUND(avg_active_airplanes, 2) AS airport_avg_active_airplanes,
    ROUND(100 * active_airplanes / NULLIF(avg_active_airplanes, 0), 2) AS load_pct_of_airport_avg
FROM airport_load AS d
LEFT JOIN unassigned_dispatchers AS u ON u.employee_id = d.employee_id
ORDER BY airport, active_airplanes DESC, d.employee_id;

WITH runway_events AS (
    SELECT takeoff_line_id AS line_id, actual_takeoff_time AS happened_at,
           'takeoff' AS event_type
    FROM flight
    WHERE actual_takeoff_time IS NOT NULL
    UNION ALL
    SELECT line_id, landing_time, 'landing'
    FROM landing
    WHERE line_id IS NOT NULL
),
event_totals AS (
    SELECT line_id,
        COUNT(*) FILTER (WHERE event_type = 'takeoff') AS takeoff_count,
        COUNT(*) FILTER (WHERE event_type = 'landing') AS landing_count,
        MAX(happened_at) AS last_operation_at
    FROM runway_events
    GROUP BY line_id
),
ordered_usage AS (
    SELECT usage_id, line_id, occupied_at, released_at,
        MAX(released_at) OVER (
            PARTITION BY line_id ORDER BY occupied_at, usage_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS previous_end
    FROM runway_usage
    WHERE released_at IS NOT NULL
),
numbered_usage AS (
    SELECT line_id, occupied_at, released_at,
        SUM(CASE WHEN previous_end IS NULL OR occupied_at > previous_end THEN 1 ELSE 0 END) OVER (
            PARTITION BY line_id ORDER BY occupied_at, usage_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS group_id
    FROM ordered_usage
),
continuous_usage AS (
    SELECT line_id, MAX(released_at) - MIN(occupied_at) AS duration
    FROM numbered_usage
    GROUP BY line_id, group_id
),
longest_usage AS (
    SELECT line_id, MAX(duration) AS duration
    FROM continuous_usage
    GROUP BY line_id
),
usage_totals AS (
    SELECT line_id, AVG(released_at - occupied_at) AS avg_duration,
        MAX(occupied_at) AS last_occupied_at
    FROM runway_usage
    GROUP BY line_id
)
SELECT l.line_id, a.name AS airport, l.direction, l.is_free,
    COALESCE(e.takeoff_count, 0) AS takeoff_count,
    COALESCE(e.landing_count, 0) AS landing_count,
    u.avg_duration AS avg_occupancy_time,
    longest.duration AS max_continuous_use_time,
    GREATEST(e.last_operation_at, u.last_occupied_at) AS last_used_at
FROM line AS l
JOIN airport AS a ON a.airport_id = l.airport_id
LEFT JOIN event_totals AS e ON e.line_id = l.line_id
LEFT JOIN usage_totals AS u ON u.line_id = l.line_id
LEFT JOIN longest_usage AS longest ON longest.line_id = l.line_id
ORDER BY a.name, l.line_id;

WITH departure_deviations AS (
    SELECT flight_id,
           EXTRACT(EPOCH FROM (actual_takeoff_time - planned_takeoff_time)) / 60 AS deviation_minutes,
           LAG(EXTRACT(EPOCH FROM (actual_takeoff_time - planned_takeoff_time)) / 60)
               OVER (PARTITION BY airplane_id ORDER BY actual_takeoff_time, flight_id)
               AS previous_deviation_minutes
    FROM flight
    WHERE actual_takeoff_time IS NOT NULL
)
SELECT f.flight_id, origin.name AS departure_airport, planned_destination.name AS destination_airport,
       destination.name AS actual_landing_airport,
       f.planned_takeoff_time, f.actual_takeoff_time,
       ROUND(d.deviation_minutes, 2) AS departure_deviation_minutes,
       ROUND(d.previous_deviation_minutes, 2) AS previous_departure_deviation_minutes,
       ROUND(d.deviation_minutes - d.previous_deviation_minutes, 2) AS deviation_change_minutes,
       f.planned_land_time, f.actual_land_time,
       ROUND(EXTRACT(EPOCH FROM (f.actual_land_time - f.planned_land_time)) / 60, 2)
           AS arrival_deviation_minutes,
       CASE
           WHEN f.actual_land_time IS NOT NULL THEN 'Завершён'
           WHEN f.actual_takeoff_time IS NOT NULL THEN 'Вылетел'
           ELSE 'Вылет не зафиксирован'
       END AS flight_status
FROM flight AS f
LEFT JOIN departure_deviations AS d ON d.flight_id = f.flight_id
JOIN airport AS planned_destination ON planned_destination.airport_id = f.destination_airport_id
JOIN line AS takeoff_line ON takeoff_line.line_id = f.takeoff_line_id
JOIN airport AS origin ON origin.airport_id = takeoff_line.airport_id
LEFT JOIN LATERAL (
    SELECT l.line_id
    FROM landing AS l
    WHERE l.flight_id = f.flight_id AND l.landing_time = f.actual_land_time
    ORDER BY (l.line_id IS NOT NULL) DESC, l.landing_id DESC
    LIMIT 1
) AS actual_landing ON TRUE
LEFT JOIN line AS landing_line ON landing_line.line_id = actual_landing.line_id
LEFT JOIN airport AS destination ON destination.airport_id = landing_line.airport_id
ORDER BY f.planned_takeoff_time, f.flight_id;

WITH mechanic_stats AS (
    SELECT e.employee_id,
        CONCAT_WS(' ', e.lastname, e.firstname, e.middle_name) AS full_name,
        e.working_place AS airport,
        COUNT(i.inspection_id) AS inspection_count,
        COUNT(DISTINCT i.airplane_id) FILTER (WHERE i.result = 'serviceable') AS serviceable_airplanes,
        COUNT(DISTINCT i.airplane_id) FILTER (WHERE i.result = 'critical_defect') AS unserviceable_airplanes,
        ROUND(100.0 * COUNT(*) FILTER (WHERE i.result = 'critical_defect')
            / NULLIF(COUNT(i.inspection_id), 0), 2) AS critical_defect_pct,
        AVG(i.finished_at - i.started_at) AS avg_inspection_time,
        MAX(i.finished_at) AS last_inspection_at
    FROM employee AS e
    JOIN employee_position AS p ON p.position_id = e.position_id
    LEFT JOIN aircraft_inspection AS i ON i.mechanic_id = e.employee_id AND i.finished_at IS NOT NULL
    WHERE p.name = 'mechanic'
    GROUP BY e.employee_id
)
SELECT m.*, DENSE_RANK() OVER (ORDER BY inspection_count DESC) AS inspection_rank
FROM mechanic_stats AS m
ORDER BY inspection_rank, employee_id;
