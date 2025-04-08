FROM nginx:alpine

COPY terraform/index.html /usr/share/nginx/html/index.html
COPY terraform/style.css /usr/share/nginx/html/style.css

