CREATE USER 'cadence'@'%' IDENTIFIED BY '${password}';

CREATE DATABASE `cadence`;
CREATE DATABASE `cadence_visibility`;

GRANT ALL PRIVILEGES ON `cadence`.* TO 'cadence'@'%';
GRANT ALL PRIVILEGES ON `cadence_visibility`.* TO 'cadence'@'%';

FLUSH PRIVILEGES;