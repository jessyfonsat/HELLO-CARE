
DROP DATABASE IF EXISTS hellocare;
CREATE DATABASE hellocare CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hellocare;


-- 1. Tables de référence (aucune clé étrangère)

CREATE TABLE role (
  id_role INT UNSIGNED NOT NULL AUTO_INCREMENT,
  libelle VARCHAR(30) NOT NULL,
  PRIMARY KEY (id_role),
  UNIQUE KEY uq_role_libelle (libelle)
) ENGINE=InnoDB;

CREATE TABLE commune (
  id_commune INT UNSIGNED NOT NULL AUTO_INCREMENT,
  code_postal CHAR(5) NOT NULL,
  nom VARCHAR(80) NOT NULL,
  PRIMARY KEY (id_commune),
  UNIQUE KEY uq_commune (code_postal, nom)
) ENGINE=InnoDB;

CREATE TABLE qualification (
  id_qualification INT UNSIGNED NOT NULL AUTO_INCREMENT,
  libelle VARCHAR(60) NOT NULL,
  PRIMARY KEY (id_qualification),
  UNIQUE KEY uq_qualification_libelle (libelle)
) ENGINE=InnoDB;

CREATE TABLE prestation (
  id_prestation INT UNSIGNED NOT NULL AUTO_INCREMENT,
  libelle VARCHAR(60) NOT NULL,
  PRIMARY KEY (id_prestation),
  UNIQUE KEY uq_prestation_libelle (libelle)
) ENGINE=InnoDB;

CREATE TABLE tache (
  id_tache INT UNSIGNED NOT NULL AUTO_INCREMENT,
  libelle VARCHAR(60) NOT NULL,
  PRIMARY KEY (id_tache),
  UNIQUE KEY uq_tache_libelle (libelle)
) ENGINE=InnoDB;

CREATE TABLE statut_demande (
  id_statut_demande INT UNSIGNED NOT NULL AUTO_INCREMENT,
  libelle VARCHAR(30) NOT NULL,
  PRIMARY KEY (id_statut_demande),
  UNIQUE KEY uq_statut_demande_libelle (libelle)
) ENGINE=InnoDB;

CREATE TABLE statut_intervention (
  id_statut_intervention INT UNSIGNED NOT NULL AUTO_INCREMENT,
  libelle VARCHAR(30) NOT NULL,
  PRIMARY KEY (id_statut_intervention),
  UNIQUE KEY uq_statut_intervention_libelle (libelle)
) ENGINE=InnoDB;

CREATE TABLE type_incident (
  id_type_incident INT UNSIGNED NOT NULL AUTO_INCREMENT,
  libelle VARCHAR(50) NOT NULL,
  PRIMARY KEY (id_type_incident),
  UNIQUE KEY uq_type_incident_libelle (libelle)
) ENGINE=InnoDB;

-- 2. Utilisateurs et intervenants

CREATE TABLE utilisateur (
  id_utilisateur INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_role INT UNSIGNED NOT NULL,
  nom VARCHAR(50) NOT NULL,
  prenom VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL,
  mot_de_passe_hash VARCHAR(255) NOT NULL,
  actif TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (id_utilisateur),
  UNIQUE KEY uq_utilisateur_email (email),
  CONSTRAINT fk_utilisateur_role FOREIGN KEY (id_role)
    REFERENCES role (id_role) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE intervenant (
  id_intervenant INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_utilisateur INT UNSIGNED NOT NULL,
  telephone VARCHAR(20) NOT NULL,
  heures_contrat SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY (id_intervenant),
  UNIQUE KEY uq_intervenant_utilisateur (id_utilisateur),
  CONSTRAINT fk_intervenant_utilisateur FOREIGN KEY (id_utilisateur)
    REFERENCES utilisateur (id_utilisateur) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT ck_intervenant_heures CHECK (heures_contrat BETWEEN 0 AND 48)
) ENGINE=InnoDB;

CREATE TABLE intervenant_qualification (
  id_intervenant INT UNSIGNED NOT NULL,
  id_qualification INT UNSIGNED NOT NULL,
  PRIMARY KEY (id_intervenant, id_qualification),
  CONSTRAINT fk_iq_intervenant FOREIGN KEY (id_intervenant)
    REFERENCES intervenant (id_intervenant) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_iq_qualification FOREIGN KEY (id_qualification)
    REFERENCES qualification (id_qualification) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE intervenant_commune (
  id_intervenant INT UNSIGNED NOT NULL,
  id_commune INT UNSIGNED NOT NULL,
  PRIMARY KEY (id_intervenant, id_commune),
  CONSTRAINT fk_ic_intervenant FOREIGN KEY (id_intervenant)
    REFERENCES intervenant (id_intervenant) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_ic_commune FOREIGN KEY (id_commune)
    REFERENCES commune (id_commune) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 3. Bénéficiaires et CRM

CREATE TABLE beneficiaire (
  id_beneficiaire INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nom VARCHAR(50) NOT NULL,
  prenom VARCHAR(50) NOT NULL,
  date_naissance DATE NOT NULL,
  adresse VARCHAR(150) NOT NULL,
  id_commune INT UNSIGNED NOT NULL,
  gir TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (id_beneficiaire),
  CONSTRAINT fk_beneficiaire_commune FOREIGN KEY (id_commune)
    REFERENCES commune (id_commune) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT ck_beneficiaire_gir CHECK (gir BETWEEN 1 AND 6)
) ENGINE=InnoDB;

CREATE TABLE besoin_beneficiaire (
  id_beneficiaire INT UNSIGNED NOT NULL,
  id_prestation INT UNSIGNED NOT NULL,
  frequence VARCHAR(40) NULL,
  PRIMARY KEY (id_beneficiaire, id_prestation),
  CONSTRAINT fk_bb_beneficiaire FOREIGN KEY (id_beneficiaire)
    REFERENCES beneficiaire (id_beneficiaire) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_bb_prestation FOREIGN KEY (id_prestation)
    REFERENCES prestation (id_prestation) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE contact_famille (
  id_contact INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_beneficiaire INT UNSIGNED NOT NULL,
  id_utilisateur INT UNSIGNED NULL,
  nom VARCHAR(50) NOT NULL,
  prenom VARCHAR(50) NOT NULL,
  telephone VARCHAR(20) NOT NULL,
  lien VARCHAR(30) NOT NULL,
  PRIMARY KEY (id_contact),
  CONSTRAINT fk_cf_beneficiaire FOREIGN KEY (id_beneficiaire)
    REFERENCES beneficiaire (id_beneficiaire) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_cf_utilisateur FOREIGN KEY (id_utilisateur)
    REFERENCES utilisateur (id_utilisateur) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE demande (
  id_demande INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_statut_demande INT UNSIGNED NOT NULL,
  id_beneficiaire INT UNSIGNED NULL,
  id_commune INT UNSIGNED NOT NULL,
  nom_demandeur VARCHAR(100) NOT NULL,
  tel_demandeur VARCHAR(20) NOT NULL,
  email_demandeur VARCHAR(100) NOT NULL,
  nom_personne_aidee VARCHAR(100) NOT NULL,
  adresse VARCHAR(150) NOT NULL,
  date_demande DATE NOT NULL,
  PRIMARY KEY (id_demande),
  CONSTRAINT fk_demande_statut FOREIGN KEY (id_statut_demande)
    REFERENCES statut_demande (id_statut_demande) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_demande_beneficiaire FOREIGN KEY (id_beneficiaire)
    REFERENCES beneficiaire (id_beneficiaire) ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_demande_commune FOREIGN KEY (id_commune)
    REFERENCES commune (id_commune) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE demande_prestation (
  id_demande INT UNSIGNED NOT NULL,
  id_prestation INT UNSIGNED NOT NULL,
  PRIMARY KEY (id_demande, id_prestation),
  CONSTRAINT fk_dp_demande FOREIGN KEY (id_demande)
    REFERENCES demande (id_demande) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_dp_prestation FOREIGN KEY (id_prestation)
    REFERENCES prestation (id_prestation) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;


-- 4. Planning et suivi

CREATE TABLE intervention (
  id_intervention INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_beneficiaire INT UNSIGNED NOT NULL,
  id_intervenant INT UNSIGNED NULL,            
  id_prestation INT UNSIGNED NOT NULL,
  id_statut_intervention INT UNSIGNED NOT NULL,
  date_intervention DATE NOT NULL,
  heure_debut TIME NOT NULL,
  heure_fin TIME NOT NULL,
  PRIMARY KEY (id_intervention),
  KEY idx_intervention_date (date_intervention),
  CONSTRAINT fk_intervention_beneficiaire FOREIGN KEY (id_beneficiaire)
    REFERENCES beneficiaire (id_beneficiaire) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_intervention_intervenant FOREIGN KEY (id_intervenant)
    REFERENCES intervenant (id_intervenant) ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_intervention_prestation FOREIGN KEY (id_prestation)
    REFERENCES prestation (id_prestation) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_intervention_statut FOREIGN KEY (id_statut_intervention)
    REFERENCES statut_intervention (id_statut_intervention) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT ck_intervention_heures CHECK (heure_fin > heure_debut)
) ENGINE=InnoDB;

CREATE TABLE pointage (
  id_pointage INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_intervention INT UNSIGNED NOT NULL,
  arrivee DATETIME NOT NULL,
  depart DATETIME NULL,
  PRIMARY KEY (id_pointage),
  UNIQUE KEY uq_pointage_intervention (id_intervention),
  CONSTRAINT fk_pointage_intervention FOREIGN KEY (id_intervention)
    REFERENCES intervention (id_intervention) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT ck_pointage_horaires CHECK (depart IS NULL OR depart > arrivee)
) ENGINE=InnoDB;

CREATE TABLE intervention_tache (
  id_intervention INT UNSIGNED NOT NULL,
  id_tache INT UNSIGNED NOT NULL,
  realisee TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_intervention, id_tache),
  CONSTRAINT fk_it_intervention FOREIGN KEY (id_intervention)
    REFERENCES intervention (id_intervention) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_it_tache FOREIGN KEY (id_tache)
    REFERENCES tache (id_tache) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE compte_rendu (
  id_compte_rendu INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_intervention INT UNSIGNED NOT NULL,
  etat_general VARCHAR(30) NOT NULL,
  observations TEXT NULL,
  partage_famille TINYINT(1) NOT NULL DEFAULT 0,
  date_saisie DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_compte_rendu),
  UNIQUE KEY uq_cr_intervention (id_intervention),
  CONSTRAINT fk_cr_intervention FOREIGN KEY (id_intervention)
    REFERENCES intervention (id_intervention) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT ck_cr_etat CHECK (etat_general IN ('Très bien','Bien','Fatigué','Inquiétant'))
) ENGINE=InnoDB;


-- 5. Remplacements, incidents, notifications

CREATE TABLE remplacement (
  id_remplacement INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_intervention INT UNSIGNED NOT NULL,
  id_intervenant_absent INT UNSIGNED NOT NULL,
  id_intervenant_remplacant INT UNSIGNED NULL,
  motif VARCHAR(100) NOT NULL,
  statut VARCHAR(20) NOT NULL DEFAULT 'À pourvoir',
  PRIMARY KEY (id_remplacement),
  CONSTRAINT fk_remp_intervention FOREIGN KEY (id_intervention)
    REFERENCES intervention (id_intervention) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_remp_absent FOREIGN KEY (id_intervenant_absent)
    REFERENCES intervenant (id_intervenant) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_remp_remplacant FOREIGN KEY (id_intervenant_remplacant)
    REFERENCES intervenant (id_intervenant) ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT ck_remp_statut CHECK (statut IN ('À pourvoir','Proposé','Confirmé','Refusé'))
) ENGINE=InnoDB;

CREATE TABLE incident (
  id_incident INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_intervention INT UNSIGNED NOT NULL,
  id_intervenant INT UNSIGNED NOT NULL,
  id_type_incident INT UNSIGNED NOT NULL,
  gravite VARCHAR(20) NOT NULL,
  description TEXT NOT NULL,
  statut VARCHAR(20) NOT NULL DEFAULT 'Ouvert',
  date_incident DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_incident),
  CONSTRAINT fk_incident_intervention FOREIGN KEY (id_intervention)
    REFERENCES intervention (id_intervention) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_incident_intervenant FOREIGN KEY (id_intervenant)
    REFERENCES intervenant (id_intervenant) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_incident_type FOREIGN KEY (id_type_incident)
    REFERENCES type_incident (id_type_incident) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT ck_incident_gravite CHECK (gravite IN ('Faible','Moyenne','Urgente')),
  CONSTRAINT ck_incident_statut CHECK (statut IN ('Ouvert','En cours','Clos'))
) ENGINE=InnoDB;

CREATE TABLE notification (
  id_notification INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_utilisateur INT UNSIGNED NOT NULL,
  contenu VARCHAR(255) NOT NULL,
  date_envoi DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  lue TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_notification),
  CONSTRAINT fk_notification_utilisateur FOREIGN KEY (id_utilisateur)
    REFERENCES utilisateur (id_utilisateur) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;


