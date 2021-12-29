FROM golang:1.16-alpine3.12 as builder

WORKDIR $GOPATH/src/github.com/saswatamcode/configmap-operator
# Change in the docker context invalidates the cache so to leverage docker
# layer caching, moving update and installing apk packages above COPY cmd
# More info https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#leverage-build-cache
RUN apk update && apk add --no-cache alpine-sdk
# Replaced ADD with COPY as add is generally to download content form link or tar files
# while COPY supports the basic copying of local files into the container.
# https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#add-or-copy
COPY . $GOPATH/src/github.com/saswatamcode/configmap-operator

RUN git update-index --refresh; make build

# -----------------------------------------------------------------------------
FROM alpine:3.12 as base
LABEL maintainer="Saswata Mukherjee"

COPY --from=builder /go/bin/configmap-operator /bin/configmap-operator

ENTRYPOINT [ "/bin/configmap-operator" ]
