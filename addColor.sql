ALTER TABLE `permutation`.`method` 
ADD COLUMN `bgColor` VARCHAR(45) NOT NULL DEFAULT '#FFFFFF' AFTER `description`,
ADD COLUMN `txtColor` VARCHAR(45) NOT NULL DEFAULT '#000000' AFTER `bgColor`;
