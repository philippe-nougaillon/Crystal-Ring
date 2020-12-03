# Ring

## Application de centralisation et de validation des factures fournisseurs

# Le principe

Chaque nouvelle facture ajoutée dans l'application suit un circuit de validation (workflow) qui passe par les états suivants grâce à des actions de l'utilisateur.

# Les états d'une facture

* Ajoutée (la facture vient d'être ajoutée)
* Envoyée (une notification a été envoyée au premier destinataire)
* Ring1 (le destinataire n'a pas réagi au bout de 3 jours, une nouvelle notification a été envoyée)
* Ring2 (idem Ring1)
* Ring3 (idem Ring1)
* Validée (La facture a été validée par l'ensemble des destinataires)
* Rejetée (la facture a été rejeté par un des destinataires) 
* Imputatée (la facture a été saisie dans le système comptable)

Ce workflow est un exemple. Il peut être très facilement adapté à des besoins spécifiques (cf. [workflow](https://github.com/geekq/workflow/)).

Chaque passage d'étape provoque un changement d'état de la facture qui est consigné dans un "Audit trail". Cet audit trail permet d'avoir une tracabilité complète et précise de tous les changements intervenus sur une facture.   


## l'état 'Ajoutée'

Un formulaire permet la saisie des propriétés de la facture; numéro de facture, nom du fournisseur, montant, etc, ainsi que les adresses mail des signataires qui doivent l'approuver.

Les signataires doivent être saisies dans l'ordre de validation souhaité: 

Ex: Signataire1 > Signataire2 > Signataire3 > SignataireX

Ce formulaire permet aussi le chargement de la facture au format PDF. Un aperçu de la première page du document est alors créé.

## l'état 'Envoyée'

Une notification est envoyée par courrier électronique au premier signataire (Signataire1) qui aura alors le choix de valider ou de rejeter la facture et de commenter sa décision.

Si la facture est validée par un signataire, une notification est envoyée au signataire suivant lui demandant approbation. 

## l'état 'Ring(1..3)'

Une relance est automatiquement envoyée tous les 4 jours aux signataires qui n'ont pas encore répondu. A chaque nouvelle relance, l'état de la facture est avancé d'un cran jusqu'à la relance N°3 (Ring3).
L'état Ring3 marque la fin des relances automatiques. Les factures doivent alors être relancées manuellement dans l'outil.

## l'état 'Validée'

Tous les signataires ont validé la facture.

## l'état 'Rejetée'

Un des signataire a rejeté la facture.

## l'état 'Imputée'

La facture est considérée comme ayant terminé son chemin dans le circuit de validation quand elle a été imputée dans la comptabilité fournisseurs.

# Actions

Après avoir coché une ou plusieurs factures dans la liste, un menu proposant plusieurs action apparait. L'action choisie sera alors appliquée à l'ensemble des factures sélectionnées.

## Action 'Relancer'

Envoyer une notification par email et incrémenter l'état de la facture.

## Action 'Passer à l'état 'Imputée''

Passer les factures sélectionnées à l'état 'Imputée'


# Les petis extras 

## Vue Liste/Grille
Les factures peuvent être vues sous la forme d'une liste, sorte de tableau excel qui presenté les données ou bien sous la forme d'une grille qui présente les factures sous forme d'images.

## Export Excel

Une fonction permet d'exporter toutes les factures et leurs données vers une feuille Excel.

