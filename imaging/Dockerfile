# FROM nginx
# RUN echo Hello >/usr/share/nginx/html/index.html

# FROM rockylinux:8
# RUN yum install -y epel-release && \
#     yum install -y nginx && \
#     yum clean all && \
#     rm -rf /var/cache/yum
# ENTRYPOINT ["nginx", "-g" "daemon off;"]
# EXPOSE 80


FROM rockylinux:8
ENTRYPOINT ["ping", "-c3"]
CMD ["google.com"]