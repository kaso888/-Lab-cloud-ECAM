FROM nginx:1.23.1-alpine

#!/bin/sh

RUN rm -rf /usr/share/nginx/html/*

COPY index.html /usr/share/nginx/html


RUN chown root /usr/share/nginx/html/*
RUN chmod 755 /usr/share/nginx/html/*

ENTRYPOINT ["nginx", "-g", "daemon off;"]