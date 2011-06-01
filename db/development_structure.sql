CREATE TABLE `accounts` (
  `id` int(11) NOT NULL,
  `date` datetime NOT NULL,
  `amount` double NOT NULL,
  `campaign_id` int(11) NOT NULL,
  `sponsor_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `account_campaign_fk` (`campaign_id`),
  KEY `account_sponsor_kf` (`sponsor_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=FIXED;

CREATE TABLE `attributes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `value` varchar(50) NOT NULL,
  `icon` varchar(50) DEFAULT NULL,
  `order` int(11) DEFAULT NULL,
  `count` int(11) DEFAULT NULL,
  `events_count` int(11) DEFAULT NULL,
  `occurrences_count` int(11) DEFAULT NULL,
  `on_home_page` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `attribute_attribute_fk` (`parent_id`),
  KEY `IDX_attributes_value` (`value`)
) ENGINE=MyISAM AUTO_INCREMENT=6343 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `calendars` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime NOT NULL,
  `dayOfWeek` int(11) unsigned NOT NULL,
  `month` int(11) NOT NULL,
  `day` int(11) NOT NULL,
  `status` char(1) NOT NULL,
  `reason` varchar(400) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `calendars_date` (`date`),
  KEY `IDX_calendar_dayOfWeek` (`dayOfWeek`)
) ENGINE=MyISAM AUTO_INCREMENT=1435 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `campaign_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `type` varchar(1) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `campaign_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `ctype` varchar(1) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;

CREATE TABLE `campaigns` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `start` datetime DEFAULT NULL,
  `end` datetime DEFAULT NULL,
  `campaign_type_id` int(11) NOT NULL DEFAULT '0',
  `sponsor_id` int(11) NOT NULL DEFAULT '0',
  `status` char(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `campaign_campaign_type` (`sponsor_id`) USING BTREE,
  KEY `campaign_campaign_type_fk` (`campaign_type_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `attribute_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `event_type_attribute` (`attribute_id`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

CREATE TABLE `comments` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `comment` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `user_id` int(10) NOT NULL,
  `commentable_type` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `commentable_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`,`user_id`) USING BTREE,
  KEY `fk_comments_user` (`user_id`)
) ENGINE=MyISAM AUTO_INCREMENT=15 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `crawler_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `crawler_id` int(11) NOT NULL,
  `status` varchar(255) DEFAULT NULL,
  `url` varchar(2048) NOT NULL,
  `pull_data` text,
  `push_data` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `content` text,
  `config` text,
  `parent_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

CREATE TABLE `crawlers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `home_page` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `running` tinyint(1) DEFAULT '0',
  `config` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

CREATE TABLE `event_campaign` (
  `campaign_id` int(11) NOT NULL,
  `event_id` int(11) NOT NULL,
  PRIMARY KEY (`event_id`,`campaign_id`),
  KEY `event_campaign_campaign_fk` (`campaign_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `event_place` (
  `place_id` int(11) NOT NULL,
  `event_id` int(11) NOT NULL,
  PRIMARY KEY (`place_id`,`event_id`),
  KEY `event_place_event_fk` (`event_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `event_tag` (
  `event_id` int(11) NOT NULL,
  `tag_id` int(11) NOT NULL,
  PRIMARY KEY (`tag_id`,`event_id`),
  KEY `event_tag_event_fk` (`event_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `event_target` (
  `event_id` int(11) NOT NULL,
  `target_id` int(11) NOT NULL,
  `order` int(11) DEFAULT NULL,
  PRIMARY KEY (`event_id`,`target_id`),
  KEY `event_target_target_fk` (`target_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `events` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(128) NOT NULL,
  `description` text NOT NULL,
  `text` longtext,
  `thumbnail` varchar(200) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `sponsor_id` int(11) NOT NULL,
  `price` double DEFAULT NULL,
  `image_url` varchar(200) DEFAULT NULL,
  `web` varchar(200) DEFAULT NULL,
  `duration` int(11) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `rating` float NOT NULL DEFAULT '0',
  `rated_count` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `event_sponsor_fk` (`sponsor_id`),
  KEY `IDX_events_category` (`category_id`),
  FULLTEXT KEY `title` (`title`,`description`,`text`)
) ENGINE=MyISAM AUTO_INCREMENT=77418 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `events_attributes` (
  `event_id` int(11) NOT NULL,
  `attribute_id` int(11) NOT NULL,
  PRIMARY KEY (`attribute_id`,`event_id`),
  KEY `event_attribute_event_fk` (`event_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `events_pepe` (
  `id` int(11) NOT NULL,
  `text` text,
  PRIMARY KEY (`id`),
  FULLTEXT KEY `newindex` (`text`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `occurrence_searches` (
  `occurrence_id` int(11) unsigned NOT NULL,
  `search_text` longtext,
  PRIMARY KEY (`occurrence_id`),
  FULLTEXT KEY `search_text` (`search_text`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `occurrences` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime DEFAULT NULL,
  `dayOfWeek` int(11) DEFAULT NULL,
  `from` datetime DEFAULT NULL,
  `to` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `place_id` int(11) NOT NULL,
  `event_id` int(11) NOT NULL,
  `hour` time DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ocurrence_place_fk` (`place_id`),
  KEY `ocurrence_event_fk` (`event_id`),
  KEY `index_occurrences_on_date` (`date`)
) ENGINE=MyISAM AUTO_INCREMENT=510112 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `occurrences_attributes` (
  `occurrence_id` int(11) NOT NULL,
  `attribute_id` int(11) NOT NULL,
  PRIMARY KEY (`attribute_id`,`occurrence_id`),
  KEY `occurrences_attributes_occurrence_fk` (`occurrence_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `performances` (
  `event_id` int(11) NOT NULL,
  `performer_id` int(11) NOT NULL,
  `rol` varchar(45) NOT NULL,
  `order` int(11) DEFAULT NULL,
  PRIMARY KEY (`event_id`,`performer_id`,`rol`) USING BTREE,
  KEY `event_performer_performer_fk` (`performer_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `performers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `name` varchar(50) NOT NULL DEFAULT ' ',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=4209 DEFAULT CHARSET=utf8;

CREATE TABLE `places` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `name` varchar(50) NOT NULL,
  `address` varchar(50) DEFAULT NULL,
  `town` varchar(50) DEFAULT NULL,
  `state` varchar(50) DEFAULT NULL,
  `country` varchar(50) DEFAULT NULL,
  `phone` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `IDX_places_name` (`name`),
  FULLTEXT KEY `name` (`name`)
) ENGINE=MyISAM AUTO_INCREMENT=1238 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

CREATE TABLE `preferences` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rank` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `attribute_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `preference_user_attribute` (`attribute_id`,`user_id`),
  KEY `preference_attribute_fk` (`attribute_id`),
  KEY `preference_user_fk` (`user_id`)
) ENGINE=MyISAM AUTO_INCREMENT=328 DEFAULT CHARSET=utf8;

CREATE TABLE `promotions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `campaign_id` int(11) NOT NULL,
  `event_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `promotion_event_fk` (`event_id`),
  KEY `promotion_campaign_fk` (`campaign_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `sponsors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `credit` double NOT NULL,
  `telephone` varchar(50) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `user_id` int(11) NOT NULL,
  `url` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `sponsor_user_fk` (`user_id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

CREATE TABLE `tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

CREATE TABLE `targets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `password` varchar(50) DEFAULT NULL,
  `firstName` varchar(50) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `clickpass` varchar(50) NOT NULL,
  `lastName` varchar(50) DEFAULT NULL,
  `admin` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

INSERT INTO schema_migrations (version) VALUES ('20090310204620');

INSERT INTO schema_migrations (version) VALUES ('20090310211959');

INSERT INTO schema_migrations (version) VALUES ('20090310213858');

INSERT INTO schema_migrations (version) VALUES ('20090310224905');

INSERT INTO schema_migrations (version) VALUES ('20090310224939');

INSERT INTO schema_migrations (version) VALUES ('20090310225106');

INSERT INTO schema_migrations (version) VALUES ('20090310225344');

INSERT INTO schema_migrations (version) VALUES ('20090310230346');

INSERT INTO schema_migrations (version) VALUES ('20090310231608');

INSERT INTO schema_migrations (version) VALUES ('20090310231803');

INSERT INTO schema_migrations (version) VALUES ('20090310232327');

INSERT INTO schema_migrations (version) VALUES ('20100105202601');

INSERT INTO schema_migrations (version) VALUES ('20101005040551');

INSERT INTO schema_migrations (version) VALUES ('20101005042141');

INSERT INTO schema_migrations (version) VALUES ('20101005043719');

INSERT INTO schema_migrations (version) VALUES ('20101103150321');

INSERT INTO schema_migrations (version) VALUES ('20101111093509');

INSERT INTO schema_migrations (version) VALUES ('20101107082635');

INSERT INTO schema_migrations (version) VALUES ('20101123103031');

INSERT INTO schema_migrations (version) VALUES ('20110207160347');

INSERT INTO schema_migrations (version) VALUES ('20110207160947');

INSERT INTO schema_migrations (version) VALUES ('20110209120103');

INSERT INTO schema_migrations (version) VALUES ('20110214164628');

INSERT INTO schema_migrations (version) VALUES ('20110217115610');

INSERT INTO schema_migrations (version) VALUES ('20110217130639');

INSERT INTO schema_migrations (version) VALUES ('20110225092401');

INSERT INTO schema_migrations (version) VALUES ('20110225125745');

INSERT INTO schema_migrations (version) VALUES ('20110301092256');

INSERT INTO schema_migrations (version) VALUES ('20110303105812');

INSERT INTO schema_migrations (version) VALUES ('20110303111442');

INSERT INTO schema_migrations (version) VALUES ('20110307182333');