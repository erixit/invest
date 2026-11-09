CREATE TABLE `invest`.`failed_dividend_update` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `share_id` int(10) unsigned NOT NULL,
  `share_name` varchar(45) DEFAULT NULL,
  `isin` varchar(15) NOT NULL DEFAULT '',
  `ticker` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
