FROM nginx:alpine

RUN apk add --no-cache openssl bash

COPY /conf.d/default.conf.template /etc/nginx/conf.d/default.conf.template
COPY /conf.d/fastcgi.inc.template /etc/nginx/conf.d/fastcgi.inc.template
COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN mkdir -p /etc/nginx/certs && chmod +x /docker-entrypoint.sh

CMD ["nginx", "-g", "daemon off;"]