ARG FROM_IMG=flyway/flyway:7.15.0-alpine

FROM --platform=amd64 ${FROM_IMG}

ENV TZ=Asia/Shanghai

ADD --chown=flyway:flyway sql /flyway/sql/