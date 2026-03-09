 Présentation du Projet
Ce projet consiste à transformer et nettoyer un jeu de données brutes contenant des informations sur le marché immobilier de Nashville. L'objectif est de rendre les données plus exploitables pour l'analyse en corrigeant les formats, en gérant les valeurs manquantes et en supprimant les redondances.

 Compétences SQL Utilisées
Standardisation (Data Formatting) : Conversion de formats de dates pour une meilleure manipulation temporelle. 📅

Jointures de Récupération (Self-Joins) : Utilisation de JOIN sur la même table pour remplir des adresses manquantes basées sur des identifiants de parcelles (ParcelID). 🔗

Parsing de Chaînes : Extraction de composants (Adresse, Ville, État) à l'aide de SUBSTRING, CHARINDEX et de la méthode astucieuse PARSENAME. ✂️

Logique Conditionnelle : Utilisation de l'instruction CASE pour harmoniser les réponses binaires (Y/N en Yes/No). 🔄

Détection de Doublons : Emploi de CTE et de la fonction de fenêtrage ROW_NUMBER() pour identifier et isoler les lignes répétées. 👯

Modification de Schéma : Nettoyage final de la table avec DROP COLUMN pour supprimer les colonnes obsolètes après transformation. 🗑️
