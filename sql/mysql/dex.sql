CREATE USER 'dex'@'%' IDENTIFIED BY '${password}';

CREATE DATABASE `dex`;

GRANT ALL PRIVILEGES ON `dex`.* TO 'dex'@'%';

FLUSH PRIVILEGES;