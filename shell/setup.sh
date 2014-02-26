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

echo mysql-server mysql-server/root_password password root | sudo debconf-set-selections
echo mysql-server mysql-server/root_password_again password root | sudo debconf-set-selections

sudo apt-get install -y git-core curl wget mc
sudo apt-get install -y apache2
sudo a2enmod rewrite
sudo apt-get install -y mysql-server mysql-client
sudo apt-get install -y php5 libapache2-mod-php5 php5-cli php5-mysql php5-curl php5-gd php5-mcrypt php-pear  php5-xdebug

#install phpmyadmin
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

#install Mailcather
sudo apt-get install -y ruby1.9.1-dev
sudo apt-get install -y sqlite3 libsqlite3-dev
sudo apt-get install -y ruby rubygems
gem install mailcatcher

# Install xdebug
if [ ! -f /var/log/xdebugsetup ];
then
    sudo pecl install xdebug
    XDEBUG_LOCATION=$(find / -name 'xdebug.so' 2> /dev/null)

    sudo touch /var/log/xdebugsetup
fi

#Install Composer
sudo curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Configure PHP
if [ ! -f /var/log/phpsetup ];
then
    sudo sed -i '/;sendmail_path =/c sendmail_path = "/usr/local/bin/catchmail"' /etc/php5/apache2/php.ini
    sudo sed -i '/;sendmail_path =/c sendmail_path = "/usr/local/bin/catchmail"' /etc/php5/cli/php.ini
    sudo sed -i '/display_errors = Off/c display_errors = On' /etc/php5/apache2/php.ini
    sudo sed -i '/error_reporting = E_ALL & ~E_DEPRECATED/c error_reporting = E_ALL | E_STRICT' /etc/php5/apache2/php.ini
    sudo sed -i '/html_errors = Off/c html_errors = On' /etc/php5/apache2/php.ini
    sudo sed -i '/upload_max_filesize = 2M/c upload_max_filesize = 16M' /etc/php5/apache2/php.ini
     echo "zend_extension='$XDEBUG_LOCATION'" | sudo tee -a /etc/php5/apache2/php.ini > /dev/null
     echo "zend_extension='$XDEBUG_LOCATION'" | sudo tee -a /etc/php5/cli/php.ini > /dev/null
    sudo touch /var/log/phpsetup
fi

#restart apache2
sudo service apache2 restart

#ran Mailcather
mailcatcher --http-ip=11.11.11.11








