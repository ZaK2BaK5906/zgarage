-- Script SQL pour esx_garage
-- Ce script suppose que vous utilisez déjà la table owned_vehicles d'ESX
-- Si ce n'est pas le cas, décommentez la création de table ci-dessous

-- CREATE TABLE IF NOT EXISTS `owned_vehicles` (
--   `owner` varchar(60) NOT NULL,
--   `plate` varchar(12) NOT NULL,
--   `vehicle` longtext DEFAULT NULL,
--   `type` varchar(20) NOT NULL DEFAULT 'car',
--   `stored` tinyint(1) NOT NULL DEFAULT 0,
--   `parking` varchar(60) DEFAULT NULL,
--   PRIMARY KEY (`plate`)
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Assurez-vous que votre table owned_vehicles a les colonnes nécessaires
-- Si vous n'avez pas la colonne 'type', ajoutez-la avec cette commande:
-- ALTER TABLE `owned_vehicles` ADD COLUMN `type` varchar(20) NOT NULL DEFAULT 'car';

-- Si vous n'avez pas la colonne 'stored', ajoutez-la avec cette commande:
-- ALTER TABLE `owned_vehicles` ADD COLUMN `stored` tinyint(1) NOT NULL DEFAULT 0;

-- Optionnel: Ajouter des index pour améliorer les performances
CREATE INDEX IF NOT EXISTS `owner` ON `owned_vehicles` (`owner`);
CREATE INDEX IF NOT EXISTS `type` ON `owned_vehicles` (`type`);
CREATE INDEX IF NOT EXISTS `stored` ON `owned_vehicles` (`stored`);
