# FROM nginx
# RUN echo Hello >/usr/share/nginx/html/index.html

FROM rockylinux:8

# Install EPEL and NGINX in a single layer
RUN yum install -y epel-release && \
    yum install -y nginx && \
    yum clean all && \
    rm -rf /var/cache/yum

ENTRYPOINT ["nginx", "-g" "daemon off;"]

# Expose NGINX default port
EXPOSE 80


