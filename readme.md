# Convert IP2Proxy LITE database to Maxmind MMDB database

This simple script will help you to convert IP2Proxy LITE CSV database to Maxmind MMDB database. You can get the free IP2Proxy LITE database from here: https://lite.ip2location.com/ip2proxy-lite.

## Requirements

1. Perl in Linux environment.
2. IP2Proxy LITE PX10 database.

## Steps

1. Download free IP2Proxy LITE PX10 database from https://lite.ip2location.com/ip2proxy-lite.

   Note: Download the database with **CSV** only.

2. After you have download this repository, open you terminal and type `'perl convert.pl'`.

3. Now you can use Maxmind reader library to read the MMDB database.

## Disclaimer

IP2Location and Maxmind are trademarks of respective owners. This Perl script is a project inspired by Perl script https://github.com/antonvlad999/convert-ip2location-geolite2