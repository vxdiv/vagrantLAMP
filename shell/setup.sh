#! /bin/bash

# Set timezone
echo "Europe/Kiev" | sudo tee /etc/timezone
sudo dpkg-reconfigure --frontend noninteractive tzdata

sudo apt-get update

sudo locale-gen ru_RU.UTF-8

sudo cp /vagrant/shell/conf/.gitconfig  /home/vagrant/
sudo cp /vagrant/shell/conf/.profile    /home/vagrant/
sudo cp /vagrant/shell/conf/.selected_editor    /home/vagrant/
sudo chmod 644 /home/vagrant/.gitconfig
sudo chmod 644 /home/vagrant/.profile
sudo chmod 644 /home/vagrant/.selected_editor

#install mysql server
if [ ! -f /var/log/mysql.setup ];
then
echo mysql-server mysql-server/root_password password root | sudo debconf-set-selections
echo mysql-server mysql-server/root_password_again password root | sudo debconf-set-selections
sudo apt-get install -y mysql-server mysql-client
fi

#install soft
if [ ! -f /var/log/soft.setup ];
then
sudo apt-get install -y git-core curl wget mc atop htop
sudo touch /var/log/soft.install
fi

#install apache2
if [ ! -f /var/log/soft.setup ];
then
sudo apt-get install -y apache2
sudo a2enmod rewrite
sudo touch /var/log/apache2.install
fi

#install php
if [ ! -f /var/log/php.install ];
then
sudo apt-get install -y php5 libapache2-mod-php5 php5-cli php5-mysql php5-curl php5-gd php5-mcrypt php-pear  php5-xdebug
sudo touch /var/log/php.install
fi

#install phpmyadmin
if [ ! -f /var/log/phpmyadmin.install ];
then
    echo 'phpmyadmin phpmyadmin/dbconfig-install boolean false' | debconf-set-selections
	echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | debconf-set-selections

	echo 'phpmyadmin phpmyadmin/app-password-confirm password root' | debconf-set-selections
	echo 'phpmyadmin phpmyadmin/mysql/admin-pass password root' | debconf-set-selections
	echo 'phpmyadmin phpmyadmin/password-confirm password root' | debconf-set-selections
	echo 'phpmyadmin phpmyadmin/setup-password password root' | debconf-set-selections
	echo 'phpmyadmin phpmyadmin/database-type select mysql' | debconf-set-selections
	echo 'phpmyadmin phpmyadmin/mysql/app-pass password root' | debconf-set-selections

	echo 'dbconfig-common dbconfig-common/mysql/app-pass password root' | debconf-set-selections
	echo 'dbconfig-common dbconfig-common/password-confirm password root' | debconf-set-selections
	echo 'dbconfig-common dbconfig-common/app-password-confirm password root' | debconf-set-selections
	echo 'dbconfig-common dbconfig-common/app-password-confirm password root' | debconf-set-selections
	echo 'dbconfig-common dbconfig-common/password-confirm password root' | debconf-set-selections
sudo apt-get install -y phpmyadmin
sudo touch /var/log/phpmyadmin.install
fi

#install Mailcather
if [ ! -f /var/log/mailcather.install ];
then
sudo apt-get install -y build-essential libsqlite3-dev ruby1.9.3
sudo gem install mailcatcher
sudo touch /var/log/mailcather.install
fi

#Install Composer
if [ ! -f /var/log/composer.install ];
then
sudo curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo touch /var/log/composer.install
fi

#CONFIGURATION

# Configure PHP
if [ ! -f /var/log/php.setup ];
then
    # Configure sendmail path to mailcathcer
    sudo sed -i '/;sendmail_path =/c sendmail_path = "/usr/local/bin/catchmail -f local@dev"' /etc/php5/apache2/php.ini
    sudo sed -i '/;sendmail_path =/c sendmail_path = "/usr/local/bin/catchmail -f local@dev"' /etc/php5/cli/php.ini
    # Display  Errors
    sudo sed -i '/display_errors = Off/c display_errors = On' /etc/php5/apache2/php.ini
    sudo sed -i '/display_errors = Off/c display_errors = On' /etc/php5/cli/php.ini
    sudo sed -i '/error_reporting = E_ALL & ~E_DEPRECATED/c error_reporting = E_ALL | E_STRICT' /etc/php5/apache2/php.ini
    sudo sed -i '/error_reporting = E_ALL & ~E_DEPRECATED/c error_reporting = E_ALL | E_STRICT' /etc/php5/cli/php.ini
    sudo sed -i '/html_errors = Off/c html_errors = On' /etc/php5/apache2/php.ini
    sudo sed -i '/html_errors = Off/c html_errors = On' /etc/php5/apache2/php.ini

    sudo sed -i '/log_errors = Off/c log_errors = On' /etc/php5/apache2/php.ini
    sudo sed -i '/log_errors = Off/c log_errors = On' /etc/php5/cli/php.ini

    sudo sed -i '/upload_max_filesize = 2M/c upload_max_filesize = 64M' /etc/php5/apache2/php.ini
    sudo sed -i '/upload_max_filesize = 2M/c upload_max_filesize = 64M' /etc/php5/cli/php.ini

    sudo sed -i '/post_max_size = 8M/c post_max_size = 64M' /etc/php5/apache2/php.ini
    sudo sed -i '/post_max_size = 8M/c post_max_size = 64M' /etc/php5/cli/php.ini

    sudo sed -i '/;error_log = php_errors.log/c error_log = /var/log/php_errors.log' /etc/php5/apache2/php.ini
    sudo sed -i '/;error_log = php_errors.log/c error_log = /var/log/php_errors.log' /etc/php5/apache2/php.ini

    sudo touch /var/log/php.setup
fi

# Configure Apache2
if [ ! -f /var/log/apache2.setup ];
then
    sudo sed -i 's/AllowOverride None/AllowOverride all/' /etc/apache2/apache2.conf
    sudo sed -i 's/export APACHE_RUN_USER=www-data/export APACHE_RUN_USER=vagrant/' /etc/apache2/envvars
    sudo sed -i 's/export APACHE_RUN_GROUP=www-data/export APACHE_RUN_GROUP=vagrant/' /etc/apache2/envvars
    # If you want to install a different path to the web directory. For example:
    #sudo sed -i 's/DocumentRoot \/var\/www/DocumentRoot \/mnt\/var\/www\/html/g' /etc/apache2/sites-available/default
    #sudo sed -i 's/<Directory \/var\/www\/>/<Directory \/mnt\/var\/www\/html\/>/' /etc/apache2/sites-available/default
    sudo touch /var/log/apache2.setup
fi

#restart apache2
sudo service apache2 restart

#ran Mailcather
mailcatcher --http-ip=10.10.10.10








