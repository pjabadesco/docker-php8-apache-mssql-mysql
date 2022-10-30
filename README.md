## OLD
docker-compose build
docker build -t pjabadesco/php8-apache-mssql-mysql:0.01 .

## NEW
docker buildx build --platform=linux/amd64 --tag=php8-apache-mssql-mysql:latest --load .

docker tag php8-apache-mssql-mysql:latest pjabadesco/php8-apache-mssql-mysql:0.01
docker push pjabadesco/php8-apache-mssql-mysql:0.01

docker tag pjabadesco/php8-apache-mssql-mysql:0.01 pjabadesco/php8-apache-mssql-mysql:latest
docker push pjabadesco/php8-apache-mssql-mysql:latest

docker tag pjabadesco/php8-apache-mssql-mysql:latest ghcr.io/pjabadesco/php8-apache-mssql-mysql:latest
docker push ghcr.io/pjabadesco/php8-apache-mssql-mysql:latest
