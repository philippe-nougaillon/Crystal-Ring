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
            .where(workflow_state: e)
            .where("DATE(updated_at) <= ?", Date.today - j.days)
            .each do | facture |
                puts "-=" * 80
                puts "Facture ##{facture.num_chrono} (id:#{facture.id})"
                puts "Etat: #{facture.etat}" 
                puts "Date de dernière màj: #{facture.updated_at}"

                # Envoyer à nouveau un mail (relance) vers toutes les cibles
                facture.cibles.where(repondu_le: nil).each do |c|
                    puts "Envoyer relance à #{c.email}"
                    if enregistrer    
                        FactureMailer.with(cible: c).notification_email.deliver_later
                        c.update!(envoyé_le: DateTime.now) 
                    end
                end

                # Passer à l'état suivant
                facture.relancer! if enregistrer
                puts "Facture.Etat: #{facture.workflow_state}"
            end
        end
        puts "-- Traitement terminé --"
    end
end
