FROM golang:1.14.2-alpine as build_modules

WORKDIR /src
COPY go.mod /src
COPY go.sum /src

RUN go mod download

FROM build_modules AS build

COPY . /src

ENV GOOS=linux
ENV GOARCH=amd64
ENV CGO_ENABLED=0

RUN go build -v -o /bin/cloudwatch_exporter .

FROM alpine:3.11.6

ENV AWS_ACCESS_KEY none
ENV AWS_SECRET_KEY none

RUN apk add --no-cache ca-certificates

COPY --from=build /bin/cloudwatch_exporter /bin/cloudwatch_exporter
COPY config.yml   /etc/cloudwatch_exporter/config.yml

RUN chmod +x /bin/cloudwatch_exporter

WORKDIR /bin

EXPOSE      9042
ENTRYPOINT  [ "/bin/cloudwatch_exporter", "-config.file=/etc/cloudwatch_exporter/config.yml" ]
