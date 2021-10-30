FROM golang:1.15 AS builder
# 按需安装依赖包
# RUN  apk --update --no-cache add gcc libc-dev ca-certificates
# 设置Go编译参数
ARG PACK_SRV
WORKDIR $GOPATH/src/github.com/SuperSleepyU/house
COPY . .

RUN go env -w GO111MODULE=on
RUN go env
RUN CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' -o /main  $GOPATH/src/github.com/SuperSleepyU/house/cmd/$PACK_SRV

FROM scratch

WORKDIR /app

COPY --from=builder /main .

ENTRYPOINT ["/app/main"]