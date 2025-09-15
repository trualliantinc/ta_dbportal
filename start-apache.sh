#!/usr/bin/env bash
set -e

# Make Apache listen on $PORT (Render sets this)
: "${PORT:=8080}"
sed -ri "s/^Listen 80$/Listen ${PORT}/" /etc/apache2/ports.conf || true
sed -ri "s/:80>/:${PORT}>/" /etc/apache2/sites-available/000-default.conf || true

# Show PHP version & enabled modules for debugging
php -v
apache2-foreground
