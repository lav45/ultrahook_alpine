FROM alpine:3.15

RUN apk add --no-cache ruby
RUN gem install --no-document ultrahook

ADD ./ultrahook.sh /usr/bin/

RUN rm -rf /var/cache/apk/*

ENTRYPOINT "/usr/bin/ultrahook.sh"