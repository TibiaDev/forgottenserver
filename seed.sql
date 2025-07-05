-- Cria a conta 1/1 se não existir 
INSERT INTO `accounts` (`id`, `name`, `password`, `secret`, `type`, `premium_ends_at`, `email`, `creation`)
SELECT '1', '1', '356a192b7913b04c54574d18c28d46e6395428ab', NULL, '6', current_date(), '', '0'
WHERE NOT EXISTS (
  SELECT 1 FROM `accounts` WHERE `id` = 1
);

-- Cria o jogador "God" se não existir
INSERT INTO `players` 
(`id`, `name`, `group_id`, `account_id`, `level`, `vocation`, `health`, `healthmax`, `experience`, `lookbody`, `lookfeet`, `lookhead`, `looklegs`, `looktype`, `lookaddons`,
 `maglevel`, `mana`, `manamax`, `manaspent`, `soul`, `town_id`, `posx`, `posy`, `posz`, `conditions`, `cap`, `sex`, `lastlogin`, `lastip`, `save`, `skull`, `skulltime`,
 `lastlogout`, `blessings`, `onlinetime`, `deletion`, `balance`, `offlinetraining_time`, `offlinetraining_skill`, `stamina`, `skill_fist`, `skill_fist_tries`, `skill_club`,
 `skill_club_tries`, `skill_sword`, `skill_sword_tries`, `skill_axe`, `skill_axe_tries`, `skill_dist`, `skill_dist_tries`, `skill_shielding`, `skill_shielding_tries`, `skill_fishing`, `skill_fishing_tries`) 
SELECT '1', 'God', '6', '1', '1', '0', '150', '150', '0', '0', '0', '0', '0', '136', '0', '0', '0', '0', '0', '0', '1', '0', '0', '0', 0x0, '40000', '1', '0', '0', '1', '0', '0', '0', '0', '0', '0', '0', '43200', '-1', '2520', '10', '0', '10', '0', '10', '0', '10', '0', '10', '0', '10', '0', '10', '0'
WHERE NOT EXISTS (
  SELECT 1 FROM `players` WHERE `id` = 1 OR `name` = 'God'
);

-- Cria o jogador "Player" se não existir
INSERT INTO `players` 
(`id`, `name`, `group_id`, `account_id`, `level`, `vocation`, `health`, `healthmax`, `experience`, `lookbody`, `lookfeet`, `lookhead`, `looklegs`, `looktype`, `lookaddons`,
 `maglevel`, `mana`, `manamax`, `manaspent`, `soul`, `town_id`, `posx`, `posy`, `posz`, `conditions`, `cap`, `sex`, `lastlogin`, `lastip`, `save`, `skull`, `skulltime`,
 `lastlogout`, `blessings`, `onlinetime`, `deletion`, `balance`, `offlinetraining_time`, `offlinetraining_skill`, `stamina`, `skill_fist`, `skill_fist_tries`, `skill_club`,
 `skill_club_tries`, `skill_sword`, `skill_sword_tries`, `skill_axe`, `skill_axe_tries`, `skill_dist`, `skill_dist_tries`, `skill_shielding`, `skill_shielding_tries`, `skill_fishing`, `skill_fishing_tries`) 
SELECT '2', 'Player', '1', '1', '8', '0', '150', '150', '0', '0', '0', '0', '0', '136', '0', '0', '0', '0', '0', '0', '1', '0', '0', '0', 0x0, '40000', '1', '0', '0', '1', '0', '0', '0', '0', '0', '0', '0', '43200', '-1', '2520', '10', '0', '10', '0', '10', '0', '10', '0', '10', '0', '10', '0', '10', '0'
WHERE NOT EXISTS (
  SELECT 1 FROM `players` WHERE `id` = 2 OR `name` = 'Player'
);