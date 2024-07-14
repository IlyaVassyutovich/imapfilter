FROM alpine:3.20.1 AS shared

# Install shared dependencies
RUN apk update
RUN apk add --no-cache openssl
RUN apk add --no-cache make
RUN apk add --no-cache lua5.1
RUN apk add --no-cache pcre2



FROM shared AS build

# Install build dependencies
RUN apk add --no-cache openssl-dev
RUN apk add --no-cache alpine-sdk
RUN apk add --no-cache lua5.1-dev
RUN apk add --no-cache pcre2-dev


# Build imapfilter
WORKDIR /dist

ARG IMAP_FILTER_TAG=v2.8.2
RUN wget https://github.com/lefcha/imapfilter/archive/${IMAP_FILTER_TAG}.tar.gz \
    --quiet \
    --output-document ./archive.tar.gz
RUN tar \
    --extract --file ./archive.tar.gz \
    --strip-components 1

RUN make all



FROM shared AS final

# Install imapfilter
COPY --from=build /dist /dist
WORKDIR /dist
RUN make install


# Clean-up dist
RUN rm -rf /dist


WORKDIR /

ENTRYPOINT [ "imapfilter" ]
