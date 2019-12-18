namespace :factures do
    
    desc "Relancer par email et changer l'état: Ring2=>Ring3, Ring1=>Ring2, Envoyée=>Ring1"
    task :relancer, [:enregistrer] => :environment do |task, args|

        enregistrer = (args[:enregistrer] == '1')    
        puts "Envoyer les mails et enregistrer les modifications !" if enregistrer
        
        etats = [:ring2, :ring1, :envoyée]
        jours = [3,3,7]

        etats.each_with_index do | e, index | 
            j = jours[index]

            Facture
            .where(etat: e)
            .where("DATE(updated_at) <= ?", Date.today - j.days)
            .each do | facture |
                puts "-=" * 80
                puts "Facture ##{facture.num_chrono} (id:#{facture.id})"
                puts "Etat: #{facture.etat}" 
                puts "Date de dernière màj: #{facture.updated_at}"

                # Envoyer à nouveau un mail (relance) vers toutes les cibles
                facture.cibles.where(repondu_le: nil).each do |c|
                    puts "Envoyer relance à #{c.email}"    
                    FactureMailer.with(cible: c).notification_email.deliver_later
                    c.update!(envoyé_le: DateTime.now) if enregistrer
                end

                # Passer à l'état suivant
                nouvel_etat = facture.etat_before_type_cast + 1
                facture.update!(etat: nouvel_etat) if enregistrer
                puts "Facture.Etat: #{facture.etat}"
            end
        end
        puts "-- Traitement terminé --"
    end
end
