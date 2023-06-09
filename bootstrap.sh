# Waiting to run the file operations until database is up
until nc -z -v -w30 feed-server-db 3306
do
  echo "Waiting for database connection..."
  sleep 10
done

# Install composer dependencies and set basic Laravel config
composer install
php artisan key:generate
php artisan config:cache

# Setting up database
php artisan migrate:fresh

# Creating project password grant client and personal access client to handle oauth2 authenctication
php artisan passport:install

# Setting files and dir permissions to work inside container with root
chmod 775 /var/www/storage/logs
chown -R root:www-data /var/www/storage

# Creating symbolic links of the project
php artisan storage:link

# Cleaning project caches
php artisan config:cache
php artisan cache:clear
php artisan route:cache


# Fixing some storage permissions
chmod -R gu+w storage
chmod -R guo+w storage

# Cleaning application cache again to make sure all updates are up-to-date
php artisan cache:clear
