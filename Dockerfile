# Base images dari internal registry — build tidak tergantung internet (uplink lab lambat)
FROM image-registry.openshift-image-registry.svc:5000/virtus-shop-ci/golang:1.26-alpine AS builder

ARG REVISION

WORKDIR /podinfo
COPY . .

RUN CGO_ENABLED=0 go build -mod=vendor -ldflags "-s -w     -X github.com/stefanprodan/podinfo/pkg/version.REVISION=${REVISION}"     -a -o bin/podinfo cmd/podinfo/*

FROM image-registry.openshift-image-registry.svc:5000/virtus-shop-ci/runtime-base:latest

ARG BUILD_DATE
ARG VERSION
ARG REVISION

WORKDIR /home/app
COPY --from=builder /podinfo/bin/podinfo .
COPY ./ui ./ui
USER app
CMD ["./podinfo"]
