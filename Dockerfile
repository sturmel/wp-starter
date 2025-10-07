FROM wordpress:php8.4-apache

# Installer les dépendances système nécessaires
RUN apt-get update && apt-get install -y \
    libzip-dev \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Installer l'extension PHP Redis
RUN pecl install redis \
    && docker-php-ext-enable redis

# Installer d'autres extensions PHP utiles
RUN docker-php-ext-install zip opcache

# Configuration PHP recommandée pour WordPress
RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Configuration Redis
RUN { \
    echo 'session.save_handler = redis'; \
    echo 'session.save_path = "tcp://redis:6379"'; \
    } > /usr/local/etc/php/conf.d/redis-session.ini

# Activer mod_rewrite pour les permaliens WordPress
RUN a2enmod rewrite

# Nettoyer
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
