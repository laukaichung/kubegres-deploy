# Custom PG Image
FROM postgres:13.3
RUN  apt-get update -y && apt-get install -y awscli && apt-get install -y curl