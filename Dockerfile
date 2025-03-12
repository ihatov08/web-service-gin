FROM golang:1.24-bullseye AS builder

WORKDIR /myapp

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -trimpath -ldflags "-w -s" -o app

FROM debian:bullseye-slim AS runner

RUN apt-get update

COPY --from=builder /myapp/app .

CMD ["./app"]

FROM golang:1.24 AS dev

WORKDIR /myapp
RUN go install github.com/air-verse/air@latest
COPY go.mod go.sum ./
RUN go mod download

COPY . .

CMD ["air", "-c", ".air.toml"]