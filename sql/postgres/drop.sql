REVOKE CONNECT ON DATABASE anchore FROM public;
SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = 'anchore';
DROP DATABASE IF EXISTS anchore;

REVOKE CONNECT ON DATABASE cicd FROM public;
SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = 'cicd';
DROP DATABASE IF EXISTS cicd;

REVOKE CONNECT ON DATABASE dex FROM public;
SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = 'dex';
DROP DATABASE IF EXISTS dex;

REVOKE CONNECT ON DATABASE pipeline FROM public;
SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = 'pipeline';
DROP DATABASE IF EXISTS pipeline;

REVOKE CONNECT ON DATABASE vault FROM public;
SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = 'vault';
DROP DATABASE IF EXISTS vault;

DROP USER anchore;
DROP USER cicd;
DROP USER dex;
DROP USER pipeline;
DROP USER vault;