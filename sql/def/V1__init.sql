-- db_homing_def.tb_def_area definition

CREATE TABLE `tb_def_area` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `area_id` bigint(20) NOT NULL COMMENT '地区标识',
  `parent_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '父ID',
  `area_name` varchar(128) NOT NULL COMMENT '全名',
  `area_level` int(10) NOT NULL COMMENT '行政区级',
  `sort_value` int(10) DEFAULT NULL COMMENT '排序',
  `longitude` varchar(64) DEFAULT NULL COMMENT '经度',
  `latitude` varchar(64) DEFAULT NULL COMMENT '维度',
  `state` tinyint(1) DEFAULT '1' COMMENT '状态;1：启用，0：禁用',
  `del_flag` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除;0：未删除；1：已删除',
  `created_by` varchar(32) DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_by` varchar(32) DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_area_id` (`area_id`),
  KEY `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='地区表';