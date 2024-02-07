FROM nginx:1.25-bullseye

WORKDIR /home

# add certbot
RUN apt-get update && apt-get install -y nginx-full certbot

COPY confs/nginx.conf scripts/generate_config.sh scripts/entrypoint.sh ./

RUN chmod +x generate_config.sh
RUN chmod +x entrypoint.sh

RUN mkdir -p /var/www/html && chown -R www-data:www-data /var/www/html

CMD ["bash", "entrypoint.sh"]