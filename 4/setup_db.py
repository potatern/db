import argparse
from pathlib import Path

import psycopg
from psycopg import sql


ROOT = Path(__file__).resolve().parent


def read_script(name):
    text = (ROOT / name).read_text(encoding='utf-8-sig').strip()
    if not text.startswith('BEGIN;') or not text.endswith('COMMIT;'):
        raise ValueError(f'{name}: expected BEGIN and COMMIT')
    return text[len('BEGIN;'):-len('COMMIT;')]


def main(argv=None):
    parser = argparse.ArgumentParser(description='Create the laboratory database')
    parser.add_argument('--database', required=True)
    parser.add_argument('--dsn', default='', help='Connection settings; password may be supplied through PGPASSWORD')
    parser.add_argument('--data', choices=('schema', 'seed', 'generated'), default='seed')
    parser.add_argument('--recreate', action='store_true', help='Delete the named database and create it again')
    args = parser.parse_args(argv)

    if not args.database.strip() or len(args.database.encode('utf-8')) > 63:
        parser.error('Database name must contain 1 to 63 UTF-8 bytes')
    if args.database.lower() in ('postgres', 'template0', 'template1'):
        parser.error('System databases cannot be used as the target')

    scripts = [read_script('create.sql')]
    if args.data != 'schema':
        name = 'seed.sql' if args.data == 'seed' else 'generated_data.sql'
        scripts.append(read_script(name))

    database = sql.Identifier(args.database)
    with psycopg.connect(args.dsn, dbname='postgres', autocommit=True, connect_timeout=5) as admin:
        existing = admin.execute(
            'SELECT datistemplate FROM pg_database WHERE datname = %s',
            (args.database,),
        ).fetchone()
        if existing:
            if existing[0]:
                raise ValueError('Template databases cannot be recreated')
            if not args.recreate:
                raise ValueError('Database already exists. Use --recreate to delete and rebuild it')
            admin.execute(sql.SQL('DROP DATABASE {}').format(database))
        admin.execute(sql.SQL('CREATE DATABASE {} TEMPLATE template0').format(database))

    try:
        with psycopg.connect(args.dsn, dbname=args.database, connect_timeout=5) as connection:
            connection.execute('SET LOCAL search_path TO public')
            for script in scripts:
                connection.execute(script)
            tables = connection.execute(
                "SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename"
            ).fetchall()
            counts = []
            for (table,) in tables:
                count = connection.execute(
                    sql.SQL('SELECT count(*) FROM {}').format(sql.Identifier('public', table))
                ).fetchone()[0]
                counts.append((table, count))
    except Exception:
        print('Schema and data transaction rolled back. The new database remains; retry with --recreate.')
        raise

    print(f'Database {args.database!r} is ready ({args.data}).')
    for table, count in counts:
        print(f'{table}: {count}')


if __name__ == '__main__':
    try:
        main()
    except (psycopg.Error, OSError, ValueError) as error:
        raise SystemExit(str(error))
