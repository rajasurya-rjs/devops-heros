# Apache HTTP Server Hello World - DevOps homework
FROM httpd:2.4

# httpd serves everything in this directory by default
COPY index.html /usr/local/apache2/htdocs/
COPY style.css  /usr/local/apache2/htdocs/

EXPOSE 80
# the base image already starts httpd in the foreground
