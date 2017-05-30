FROM alpine:3.6 
RUN apk add --no-cache ruby ruby-dev build-base 
RUN gem install --no-document ultrahook

ADD ./ultrahook.sh /usr/bin/

ENTRYPOINT "/usr/bin/ultrahook.sh"