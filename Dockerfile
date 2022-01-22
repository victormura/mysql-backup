FROM debian:sid-slim

# Install tools
RUN apt-get update && apt-get install -y tzdata gzip openssl netcat-openbsd

# Install AWSCLI v2
RUN apt-get update && apt-get install -y curl unzip 
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.1.39.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install
RUN rm awscliv2.zip

# Install MySql Client
RUN apt-get update && apt-get install -y mysql-client

# Clear apt manager cache
RUN rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh

ENTRYPOINT ["bash", "entrypoint.sh"]
