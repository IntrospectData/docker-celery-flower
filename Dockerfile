FROM python:alpine

# Get latest root certificates
RUN apk add --update ca-certificates && update-ca-certificates

# Install the required packages
RUN pip install redis elasticsearch flower

# PYTHONUNBUFFERED: Force stdin, stdout and stderr to be totally unbuffered. (equivalent to `python -u`)
# PYTHONHASHSEED: Enable hash randomization (equivalent to `python -R`)
# PYTHONDONTWRITEBYTECODE: Do not write byte files to disk, since we maintain it as readonly. (equivalent to `python -B`)
ENV PYTHONUNBUFFERED=1 PYTHONHASHSEED=random PYTHONDONTWRITEBYTECODE=1

# Run as a non-root user by default, run as user with least privileges.
USER nobody

## Env variables that should be set all the time
ENV CELERY_BROKER_URL amqp://username:password@rabbitmq-server-name:5672//
ENV CELERY_RESULT_BACKEND elasticsearch://elasticsearch.kube-system:9200/celery/task_result
ENV FLOWER_BROKER_API http://username:password@rabbitmq-server-name:15672/api/

## Env variables that are likely to stay the same all the time
ENV FLOWER_ADDRESS=0.0.0.0 \
    FLOWER_PORT=5555 \
    FLOWER_DEBUG=false \
    FLOWER_MAX_WORKERS=5000 \
    FLOWER_MAX_TASKS=10000 \
    FLOWER_XHEADERS=True

EXPOSE 5555

ENTRYPOINT ["flower"]
CMD ["flower", "--port=5555", "--host=0.0.0.0"]
