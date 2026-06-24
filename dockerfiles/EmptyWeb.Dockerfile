FROM busybox

RUN mkdir /app

ENV APP_ROOT_DIR /app
ENV WEB_ROOT_DIR /app

WORKDIR /app
EXPOSE 80

COPY empty.html index.html

CMD ["httpd", "-f"]
