FROM nginx:1.30-alpine
RUN apk upgrade --no-cache libexpat pcre2
COPY docker/frontend.conf /etc/nginx/nginx.conf
COPY application/index.html /usr/share/nginx/html/index.html
USER nginx
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
