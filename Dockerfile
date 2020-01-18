FROM 	alpine:3.11 AS build

WORKDIR /usr/src

RUN 	apk add --no-cache make g++ boost-dev openssl-dev

COPY 	. .

RUN 	make

FROM 	alpine:3.11 AS release

EXPOSE 	3478/tcp 3478/udp

WORKDIR /opt/stunserver

HEALTHCHECK CMD	/opt/stunserver/stunclient localhost

RUN 	apk add --no-cache libstdc++ libgcc \
    	&& addgroup -g 1000 stun \
    	&& adduser -u 1000 -G stun -s /bin/false -D stun \
    	&& mkdir -p /opt/stunserver 

COPY --from=build 	/usr/src/stunserver /opt/stunserver/stunserver
COPY --from=build 	/usr/src/stunclient /opt/stunserver/stunclient

USER 	stun

ENTRYPOINT 	["/opt/stunserver/stunserver"]

