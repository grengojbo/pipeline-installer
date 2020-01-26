CREATE USER 'pipeline'@'%' IDENTIFIED BY '${password}';

CREATE DATABASE `pipeline`;

GRANT ALL PRIVILEGES ON `pipeline`.* TO 'pipeline'@'%';
GRANT ALL PRIVILEGES ON `cicd`.* TO 'pipeline'@'%';

FLUSH PRIVILEGES;