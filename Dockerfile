# Build the Go app for Linux (assuming x86_64 architecture)
FROM golang:1.18 AS builder
WORKDIR /app
COPY go.mod ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o trustwallet

# Use a minimal base image for the final image
FROM alpine:latest
WORKDIR /
COPY --from=builder /app/trustwallet /trustwallet
EXPOSE 8080
CMD ["/trustwallet"]
