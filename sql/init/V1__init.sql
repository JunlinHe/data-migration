-- 创建数据库
CREATE DATABASE IF NOT EXISTS `db_homing_base` DEFAULT CHARACTER SET utf8mb4 COLLATE UTF8MB4_UNICODE_CI;
CREATE DATABASE IF NOT EXISTS `db_homing_def` DEFAULT CHARACTER SET utf8mb4 COLLATE UTF8MB4_UNICODE_CI;

-- 创建普通用户
DROP USER IF EXISTS '${mysql_user}'@'%';
FLUSH PRIVILEGES;
CREATE USER '${mysql_user}'@'%' IDENTIFIED BY '${mysql_pwd}';
GRANT ALL PRIVILEGES ON db_homing_base.* TO '${mysql_user}'@'%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON db_homing_def.* TO '${mysql_user}'@'%' WITH GRANT OPTION;
GRANT SELECT ON `performance_schema`.`user_variables_by_thread` TO '${mysql_user}'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;