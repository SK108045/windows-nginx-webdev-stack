# windows-nginx-webdev-stac
## nginx-based-xampp-alternative

![Nginx](https://sk10codebase.online/images/nginx2.png)

This guide explains how to set up a web development environment on Windows using Nginx, PHP, MySQL, and phpMyAdmin. Unlike XAMPP (which uses Apache), this setup uses Nginx, providing better performance and lower resource usage.

## Why Nginx over XAMPP?

While XAMPP is popular among Windows users for its ease of setup, it uses Apache as its web server, which can be resource-intensive. Nginx offers several advantages:

- **Lower resource usage**: Nginx is designed to be lightweight and efficient.
- **Better performance**: Especially noticeable with static content and high-concurrency situations.
- **Scalability**: Easily handles growth from small projects to large applications.
- **Flexibility**: Functions well as a web server, reverse proxy, or load balancer.

### Growing Popularity of Nginx

Recent market trends support the shift towards Nginx. According to [W3Techs](https://w3techs.com/technologies/history_overview/web_server/ms/q), Nginx has overtaken Apache in market share. From October 2020 to November 2023, Nginx's usage increased from 32.4% to 34.1%, while Apache's decreased from 36.2% to 30.8%. This trend indicates a growing preference for Nginx's performance and efficiency in the web development community.

## Installation Steps

1. **Install Nginx**
   - Download nginx by visiting their website [Download Nginx](https://nginx.org/en/download.html)
   - Download and extract Nginx to `D:\nginx`
   - Test the installation by running `nginx.exe` and visiting `http://localhost` on your browser and you'll see this page

![Nginx Welcome Page](https://sk10codebase.online/images/nginx.png)
     
## 2. Install PHP

### 2.1 Download PHP

1. Visit the official PHP for Windows download page: https://windows.php.net/download/
2. Download the latest stable version of PHP (Non Thread Safe) zip package.
   - Choose the x64 version for 64-bit systems or x86 for 32-bit systems.
   - Ensure you select the "Non Thread Safe" version as we'll be using PHP with Nginx.

### 2.2 Extract PHP

1. Create a new folder: `D:\php`
2. Extract the contents of the downloaded ZIP file into `D:\php`

### 2.3 Configure PHP

1. In the `D:\php` directory, locate the file named `php.ini-development`
2. Make a copy of this file and rename it to `php.ini`
3. Open `php.ini` with a text editor (e.g., Notepad++ or Visual Studio Code)
4. Make the following changes in `php.ini`:

   ```ini
   ; Change the extension_dir to point to the ext folder
   extension_dir = "D:/php/ext"

   ; Enable required extensions by removing the semicolon (;) at the start of these lines
   extension=curl
   extension=gd
   extension=mbstring
   extension=mysqli
   extension=openssl
   extension=pdo_mysql

   ; Optionally, increase the memory limit if needed
   memory_limit = 256M

   ; Set the maximum upload file size (if needed)
   upload_max_filesize = 20M
   post_max_size = 20M```
### 2.4 Set up PHP as a Windows environment variable
  - Search for **Environment Variables** on the start menu
  - Under **System variables**, find and select **Path**, then click **Edit**
  - Click **New** and add `D:\php`
  - Click 'OK' to close all dialogs
  - Open a new Command Prompt Type `php -v` and press **Enter** then you should see the PHP version information, confirming that PHP is 
    installed correctly

## 3. Install MySQL

### 3.1 Download MySQL Installer

1. Visit the official MySQL download page: [Download Mysql](https://dev.mysql.com/downloads/installer/) 
2. Download the MySQL Installer for Windows.

### 3.2 Run MySQL Installer

1. Launch the MySQL Installer executable.
2. Choose the "Custom" setup type.
3. Select the following components:
   - MySQL Server
4. Click "Next" and then "Execute" to download and install the selected components.

### 3.3 Configure MySQL Server

1. In the configuration step, choose:
   - Standalone MySQL Server / Classic MySQL Replication
   - Development Computer for the config type
2. In the "Type and Networking" step:
   - Set the port number to 3310 (instead of the default 3306)
3. Set a root password. Remember this password; you'll need it later.
4. Configure Windows Service:
   - Name: MySQL80
   - Run Windows Service as: Standard System Account
5. Apply the configuration and finish the installation.

### 3.4 Verify MySQL Installation

1. Open Command Prompt
2. Type `mysql -u root -p -P 3310` and press Enter
3. Enter the root password you set during installation
4. If successful, you'll see the MySQL prompt. Type `exit` to close the connection.

## 4. Install phpMyAdmin

### 4.1 Download phpMyAdmin

1. Visit the official phpMyAdmin download page: [Download phpmyadmin](https://www.phpmyadmin.net/downloads/)  
2. Download the latest version of phpMyAdmin (English version, .zip file)

### 4.2 Extract phpMyAdmin

1. Create a new folder: `D:\phpMyAdmin`
2. Extract the contents of the downloaded ZIP file into `D:\phpMyAdmin`

### 4.3 Configure phpMyAdmin

1. In the `D:\phpMyAdmin` directory, locate the file named `config.sample.inc.php`
2. Make a copy of this file and rename it to `config.inc.php`
3. Open `config.inc.php` with a text editor
4. Find the line containing `$cfg['blowfish_secret']` and set a random string:

   ```php
     $cfg['blowfish_secret'] = 'your_random_string_here'; // Use a random string of your choice
   ```
   - Also configure the MySQL server connection to this values
   ```php
   $cfg['Servers'][$i]['host'] = '127.0.0.1';
   $cfg['Servers'][$i]['port'] = '3310';
   $cfg['Servers'][$i]['auth_type'] = 'cookie';
   ```

## 5 Configure Nginx
1. Open your Nginx configuration file. The location is typically: `D:\nginx\conf\nginx.conf`
###  Modify `nginx.conf`

Within the `nginx.conf`, replace it with the following code:

```nginx
worker_processes  1;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    sendfile        on;
    keepalive_timeout  65;

    server {
        listen       8000;
        server_name  localhost;

        root   D:/nginx/html;
        index  index.php index.html index.htm;

        location / {
            try_files $uri $uri/ =404;
        }

        location ~ \.php$ {
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
            include        fastcgi_params;
        }

        location /phpmyadmin {
            root D:/;
            index index.php index.html index.htm;
            location ~ ^/phpmyadmin/(.+\.php)$ {
                try_files $uri =404;
                root D:/;
                fastcgi_pass 127.0.0.1:9000;
                fastcgi_index index.php;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                include fastcgi_params;
            }
            location ~* ^/phpmyadmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))$ {
                root D:/;
            }
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }
}
```
**NB: I am running Nginx on port 8000 just to avoid conflicts with other services using port 80.**
## Starting the Server

Finally To simplify the process of starting both Nginx and PHP-FPM, you can create a batch file that launches both services with a single click.

### Create a Batch File

1. Create a new text file in your Nginx directory (e.g., `D:\nginx\start_server.bat`).
2. Open the file with a text editor and add the following content:

   ```batch
   @echo off
   start /B D:\nginx\nginx.exe
   start /B D:\php\php-cgi.exe -b 127.0.0.1:9000
   echo Nginx and PHP-FPM started.
   ```
3. Double-click the start_server.bat file to run it. This will start both Nginx and PHP-FPM in the background.
   You should see a command prompt window briefly appear with the message "Nginx and PHP-FPM started."
4. After running the batch file: Open a web browser and navigate to http://localhost:8000 where you will see nginx running
5. Now in order to open phpmyadmin navigate to `http://localhost:8000/phpmyadmin` and you'll see this page:


![phpmyadmin Login Page](https://sk10codebase.online/images/phpmyadmin.png)

   
## Wrap-up

You've now set up a Windows web development environment using Nginx, PHP, MySQL, and phpMyAdmin. This setup is an alternative to XAMPP, offering better performance and resource management.

### Key takeaways:

- Nginx outperforms Apache in resource usage and handling concurrent connections
- This stack mirrors many production environments, unlike XAMPP
- You've gained practical experience in server configuration

### What's next

- Test your setup with actual web projects
- Fine-tune configurations for optimal performance
- Keep your software updated

### Repository maintenance

If you find issues or have improvements:
- Open an issue in the repository
- Submit pull requests

This guide is a starting point to how Real-world applications work.
   


   
   
   
