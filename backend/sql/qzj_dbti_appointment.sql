-- DBTI 预约（同一手机号只保留一条；重复提交走 ON DUPLICATE KEY UPDATE 覆盖为最新信息）
CREATE TABLE IF NOT EXISTS `qzj_dbti_appointment` (
	`id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
	`phone` CHAR(11) NOT NULL COMMENT '11位手机号，唯一',
	`mbti_type` VARCHAR(8) NOT NULL DEFAULT '' COMMENT '四字母类型',
	`recommended_jobs` TEXT NULL COMMENT '推荐岗位，顿号或逗号分隔存一列',
	`target_direction` VARCHAR(32) NOT NULL DEFAULT '' COMMENT '目标方向',
	`current_stage` VARCHAR(32) NOT NULL DEFAULT '' COMMENT '当前阶段',
	`difficulties` JSON NULL COMMENT '当前困难，多选数组',
	`contact_time` VARCHAR(32) NOT NULL DEFAULT '' COMMENT '方便联系时间',
	`lead_level` VARCHAR(16) NOT NULL DEFAULT 'high' COMMENT 'high=主动预约',
	`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (`id`),
	UNIQUE KEY `uk_phone` (`phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='DBTI结果页主动预约';
