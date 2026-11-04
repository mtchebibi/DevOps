# Image Nginx légère servant la page Hello World du TP
FROM nginx:1.27-alpine

# Page statique du TP (site/index.html)
COPY --chmod=644 site/index.html /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
