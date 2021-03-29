FROM alpine
RUN apk add --no-cache bash gawk sed grep bc coreutils
COPY workshop-files /build
COPY workshop-instructions /build/workshop
WORKDIR /build
RUN tar -czf workshop.tar.gz .

FROM nginx:1.19.2-alpine
COPY --from=0 /build /usr/share/nginx/html