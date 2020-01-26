CREATE USER 'vault'@'%' IDENTIFIED BY '${password}';

CREATE DATABASE `vault`;

GRANT ALL PRIVILEGES ON `vault`.* TO 'vault'@'%';

FLUSH PRIVILEGES;