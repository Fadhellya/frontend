# Base image ditarik langsung dari Docker Hub (tanpa mirror registry internal)
FROM docker.io/library/golang:1.26-alpine AS builder

ARG VERSION=1.0.0
WORKDIR /src
COPY . .
# layout podinfo: entrypoint di ./cmd/podinfo (bukan main.go di root)
RUN CGO_ENABLED=0 go build -mod=vendor -ldflags "-s -w" -o /out/podinfo ./cmd/podinfo

FROM docker.io/library/alpine:3.23
# runtime-base internal digantikan alpine polos -> user non-root dibuat di sini
RUN addgroup -S app && adduser -S -G app app

ARG VERSION=1.0.0
ENV VERSION=${VERSION}
WORKDIR /home/app
COPY --from=builder /out/podinfo .
# podinfo serve aset UI dari ./ui (default --ui-path)
COPY --from=builder /src/ui ./ui
USER app
EXPOSE 9898
CMD ["./podinfo", "--random-error"]
