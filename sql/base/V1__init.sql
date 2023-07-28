-- db_homing_base.tb_base_customer definition

CREATE TABLE `tb_base_customer` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `customer_id` bigint(20) NOT NULL COMMENT '顾客标识;租户唯一',
  `customer_code` varchar(32) NOT NULL COMMENT '顾客编号;租户唯一',
  `account_id` bigint(20) DEFAULT NULL COMMENT '账号标识;#tb_def_consumer_account',
  `org_id` bigint(20) NOT NULL COMMENT '机构标识;#tb_def_org',
  `tenant_code` varchar(32) NOT NULL COMMENT '租户编码',
  `register_source` tinyint(2) DEFAULT NULL COMMENT '注册来源',
  `add_way` varchar(32) DEFAULT NULL COMMENT '添加顾客来源',
  `state` int(11) DEFAULT NULL COMMENT '状态',
  `del_flag` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否删除;0：未删除；1：已删除',
  `created_by` varchar(32) DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_by` varchar(32) DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_customer_id` (`customer_id`,`del_flag`) USING BTREE,
  UNIQUE KEY `uniq_customer_code` (`customer_code`,`del_flag`) USING BTREE,
  KEY `idx_tenant_org` (`tenant_code`,`org_id`),
  KEY `idx_account_id` (`account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='顾客表';