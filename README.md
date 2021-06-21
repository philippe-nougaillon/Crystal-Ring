# Ring

## Application de centralisation et de validation des factures fournisseurs

# Le principe

Chaque nouvelle facture ajoutée dans l'application va suivre un circuit de validation (Workflow) qui passe par d'état et état grâce à l'action des utilisateurs.

# Les états d'une facture

Ce workflow est un exemple. Il peut être très facilement adapté à des besoins spécifiques (cf. [workflow](https://github.com/geekq/workflow/)).

* Ajoutée (la facture vient d'être ajoutée)
* Envoyée (une notification a été envoyée au premier destinataire)
* Ring1 (le destinataire n'a pas réagi au bout de 3 jours, une nouvelle notification a été envoyée)
* Ring2 (idem Ring1)
* Ring3 (idem Ring1)
* Validée (La facture a été validée par l'ensemble des destinataires)
* Rejetée (la facture a été rejeté par un des destinataires) 
* Imputatée (la facture a été saisie dans le système comptable)

Chaque passage d'étape provoque un changement d'état de la facture, qui est consigné dans un historique des modifications ("Audit trail"). Cet "Audit Trail" permet d'avoir une tracabilité complète et précise de tous les changements intervenus sur une facture. Les données ainsi collectées sont exportables au format XLS.  

## l'état 'Ajoutée'

Un formulaire permet la saisie des propriétés de la facture; numéro de facture, nom du fournisseur, montant, etc, ainsi que les adresses mail des signataires qui doivent l'approuver.

Les signataires doivent être saisies dans l'ordre de validation souhaité: 

Ex: Signataire1 > Signataire2 > Signataire3 > SignataireX

Ce formulaire permet aussi le chargement de la facture au format PDF. Un aperçu de la première page du document est alors créé.

## l'état 'Envoyée'

Une notification est envoyée par courrier électronique au premier signataire (Signataire1) qui aura alors le choix de valider ou de rejeter la facture et de commenter sa décision.

Si la facture est validée par un signataire, une notification est envoyée au signataire suivant.

## l'état 'Ring(1..3)'

Une relance est automatiquement envoyée tous les 4 jours aux signataires qui n'ont pas encore répondu. A chaque nouvelle relance, l'état de la facture est avancé d'un cran jusqu'à la relance N°3 (Ring3).
L'état Ring3 marque la fin des relances automatiques. Les factures doivent alors être relancées manuellement.

## l'état 'Validée'

Tous les signataires ont validé la facture.

## l'état 'Rejetée'

Un des signataires a rejeté la facture.

## l'état 'Imputée'

La facture est considérée comme ayant terminé son chemin dans le circuit de validation quand elle a été imputée dans la comptabilité fournisseurs.

# Actions

Après avoir coché une ou plusieurs factures dans la liste, un menu proposant plusieurs action apparaît. L'action choisie sera alors appliquée à l'ensemble des factures sélectionnées.

## Action 'Relancer'

Envoyer une notification par email et incrémenter l'état de la facture.

## Action 'Passer à l'état 'Imputée''

Passer les factures sélectionnées à l'état 'Imputée'


# Les petits extras 

## Vue Liste/Grille
Les factures peuvent être vues sous la forme d'une liste, sorte de tableau excel qui présente que les données des factures, ou bien sous la forme d'une grille pour voir les factures sous forme d'images uniquement.

## Export Excel

Une fonction permet d'exporter toutes les factures et leurs données vers une feuille Excel.

