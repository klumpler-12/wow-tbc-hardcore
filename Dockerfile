FROM nginx:alpine
COPY web/nginx-nocache.conf /etc/nginx/conf.d/default.conf
COPY web/ /usr/share/nginx/html/
EXPOSE 80
