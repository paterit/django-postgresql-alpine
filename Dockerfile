ARG PYTHON_VERSION=3.7.3-alpine3.9

FROM python:${PYTHON_VERSION} as builder

ENV PYTHONUNBUFFERED 1

# build time dependencies
RUN apk update && \
        apk add --no-cache \
        python3-dev \
        gcc \
        musl-dev \
        postgresql-dev \
        postgresql-libs

# build wheels instead of installing
WORKDIR /wheels

COPY requirements.txt .

RUN pip install -U pip && \
    pip wheel -r requirements.txt


FROM python:${PYTHON_VERSION}

# dependencies you need in your final image
RUN apk update && \
    apk add --no-cache \
    # good to have make
    make \
    # good to have bash
    bash \
    # needed for psycopg2 to work
    libpq

# copy built previously wheels archives
COPY --from=builder /wheels /wheels

COPY requirements.txt /wheels/requirements.txt

# use archives from /weels dir
RUN pip install -U pip \
       && pip install -r /wheels/requirements.txt -f /wheels \
       && rm -rf /wheels \
       && rm -rf /root/.cache/pip/*
