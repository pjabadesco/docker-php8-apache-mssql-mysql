# Use the official PHP 8.2 image with Apache
FROM php:8.2-apache-bookworm

# Enable Apache modules
RUN a2enmod rewrite headers remoteip

# Update package list and install necessary packages
RUN apt-get update -yqq \
    && apt-get install -y apt-transport-https gnupg wget \
    libcurl4-openssl-dev libedit-dev libsqlite3-dev libssl-dev libxml2-dev zlib1g-dev libpng-dev libmcrypt-dev libpng-dev libjpeg-dev \
    freetds-dev freetds-bin freetds-common libdbd-freetds libsybdb5 libqt5sql5-tds libzip-dev zip unzip \
    && ln -s /usr/lib/x86_64-linux-gnu/libsybdb.so /usr/lib/libsybdb.so \
    && ln -s /usr/lib/x86_64-linux-gnu/libsybdb.a /usr/lib/libsybdb.a \
    && curl -s https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl -s https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update -yqq \
    && ACCEPT_EULA=Y apt-get install -y unixodbc unixodbc-dev libgss3 odbcinst msodbcsql17 locales mssql-tools \
    && echo "en_US.UTF-8 zh_CN.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen

# Update OpenSSL configuration to allow lower TLS protocols
RUN sed -i 's/MinProtocol = TLSv1.2/MinProtocol = TLSv1/g' /etc/ssl/openssl.cnf \
    && sed -i 's/DEFAULT@SECLEVEL=2/DEFAULT@SECLEVEL=1/g' /etc/ssl/openssl.cnf

# Install PHP extensions via PECL
RUN pecl install -f pdo_sqlsrv sqlsrv xdebug redis mongodb \
    && docker-php-ext-enable pdo_sqlsrv sqlsrv xdebug redis mongodb

# Configure and install additional PHP extensions
RUN docker-php-ext-configure gd --enable-gd --with-jpeg \
    && docker-php-ext-configure pdo_odbc --with-pdo-odbc=unixODBC,/usr \
    && docker-php-ext-install gd pdo pdo_mysql pdo_dblib curl mysqli pdo_odbc opcache zip

# Install PostgreSQL extension for PHP
RUN apt-get install -y libpq-dev \
    && docker-php-ext-install pdo_pgsql

# Copy custom configuration files
COPY conf/php.ini /usr/local/etc/php/
COPY conf/httpd.conf /etc/apache2/sites-available/000-default.conf
COPY www/ /var/www/html/

# Fix permissions for the web directory
RUN chmod 755 /var/www/html -R \
    && chown www-data:www-data /var/www/html

# Expose port 80 for the Apache server
EXPOSE 80