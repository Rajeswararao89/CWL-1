FROM nginx:alpine

# wipe the default nginx page so only our file gets served
RUN rm -rf /usr/share/nginx/html/*

COPY index.html /usr/share/nginx/html/index.html

# check every 30s that nginx is actually responding
# 3 failed checks = container marked unhealthy
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD wget -qO- http://localhost/ || exit 1

# nginx listens on 80 inside the container
# mapped to host port 8000 at runtime: docker run -p 8000:80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
