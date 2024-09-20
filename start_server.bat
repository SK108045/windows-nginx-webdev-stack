@echo off
start /B D:\nginx\nginx.exe
start /B D:\php\php-cgi.exe -b 127.0.0.1:9000
echo Nginx and PHP-FPM started.
