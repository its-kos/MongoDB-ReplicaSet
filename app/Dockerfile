FROM golang:1.20-alpine

WORKDIR /app

COPY . .

RUN go mod download

RUN go build -o /docker-mongo-app

# EXPOSE 8080 # Redundant

CMD ["docker-mongo-app"]