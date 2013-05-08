if !Dir.exist?(shared_path + "/config/OpenPNE.yml") then
  run "cp #{release_path}/config/OpenPNE.yml.sample #{shared_path}/config/OpenPNE.yml"
  run "cp #{release_path}/config/ProjectConfiguration.class.php.sample #{shared_path}/config/ProjectConfiguration.class.php"
end

# prepare shared files
run "cp #{shared_path}/config/OpenPNE.yml #{release_path}/config/OpenPNE.yml"
run "cp #{shared_path}/config/ProjectConfiguration.class.php #{release_path}/config/ProjectConfiguration.class.php"

# set timezone in php.ini
sudo "echo 'date.timezone = Asia/Tokyo' > /etc/php/cgi-php5.4/ext-active/timezone.ini"
sudo "echo 'date.timezone = Asia/Tokyo' > /etc/php/cli-php5.4/ext-active/timezone.ini"
sudo "echo 'date.timezone = Asia/Tokyo' > /etc/php/fpm-php5.4/ext-active/timezone.ini"

# set allow_url_fopen = On
sudo "echo 'allow_url_fopen = On' > /etc/php/cgi-php5.4/ext-active/allow_url.ini"
sudo "echo 'allow_url_fopen = On' > /etc/php/cli-php5.4/ext-active/allow_url.ini"
sudo "echo 'allow_url_fopen = On' > /etc/php/fpm-php5.4/ext-active/allow_url.ini"

run "echo \"    location ~ \.php($|/) {
        try_files $uri =404;
 
        set $path_info \"/\";
 
        if ($uri ~ \"^(.+\.php)(\$|/)\") {
            set \$script \$1;
        }
 
        if ($uri ~ \"^(.+\.php)(/.+)\") {
            set $script \$1;
            set $path_info \$2;
        }
        include                     /etc/nginx/common/proxy.conf;
        include                     /etc/nginx/common/fcgi.conf;
        fastcgi_pass                upstream_#{app};
        fastcgi_index               index.php;
        fastcgi_intercept_errors    off;
        fastcgi_param               SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param               SERVER_NAME \$hostname;
        fastcgi_param SCRIPT_FILENAME \$document_root\$script;
        fastcgi_param SCRIPT_NAME \$script;
        fastcgi_param PATH_INFO \$path_info;
    }\" > /data/nginx/servers/#{app}/custom.conf"
# set APC
#sudo "echo 'extension=apc.so' > /etc/php/cgi-php5.4/ext-active/apc.ini"
#sudo "echo 'extension=apc.so' > /etc/php/cli-php5.4/ext-active/apc.ini"
#sudo "echo 'extension=apc.so' > /etc/php/fpm-php5.4/ext-active/apc.ini"


# kick composer install
#run "curl -s https://getcomposer.org/installer | php -d allow_url_fopen=on"
#run "php -d allow_url_fopen=on composer.phar install"

run "./symfony openpne:fast-install --dbms=mysql --dbuser=deploy --dbpassword=#{node['users'][0]['password']} --dbhost=#{node['db_host']} --dbname=#{app}"