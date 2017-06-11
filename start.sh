#!/bin/bash
# python manage.py migrate                  # Apply database migrations
python manage.py collectstatic --noinput  # Collect static files

# Prepare log files and start outputting logs to stdout
mkdir ./logs
touch ./logs/gunicorn.log
touch ./logs/access.log
tail -n 0 -f ./logs/*.log &

# Start Gunicorn processes
echo Starting Gunicorn.
exec gunicorn syte.wsgi:application \
    --name sirius_syte \
    --bind 0.0.0.0:8008 \
    --workers 1 \
    --log-level=info \
    --log-file=./logs/gunicorn.log \
    --access-logfile=./logs/access.log \
    "$@"
