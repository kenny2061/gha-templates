FROM nginx:1.23.3-alpine

RUN apk add tzdata

ENV APP_ROOT_DIR /usr/share/nginx/html
ENV WEB_ROOT_DIR /usr/share/nginx/html

WORKDIR /usr/share/nginx/html

COPY . /usr/share/nginx/html

EXPOSE 80