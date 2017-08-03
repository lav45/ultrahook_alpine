FROM alpine:3.6 
RUN apk add --no-cache ruby ruby-dev build-base 
COPY ./ultrahook-0.1.4.gem /tmp
RUN gem install --no-document json && cd /tmp && gem install --no-document --local ultrahook

ADD ./ultrahook.sh /usr/bin/

ENTRYPOINT "/usr/bin/ultrahook.sh"