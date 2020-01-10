namespace :factures do
    
    desc "Relancer par email"
    task :relancer, [:enregistrer] => :environment do |task, args|

        enregistrer = (args[:enregistrer] == '1')    
        puts "Envoyer les mails et enregistrer les modifications !" if enregistrer
        
        délai = 4.days

        factures = Facture
                    .with_envoyée_state
                    .or(Facture.with_ring1_state)
                    .or(Facture.with_ring2_state)
                    .or(Facture.with_ring3_state)
                    .where("DATE(updated_at) <= ?", Date.today - délai)
        
        # Envoyer à nouveau (relance) vers toutes les cibles
        factures = Facture.relancer(factures)

        puts "-- Traitement terminé --"
        puts "#{factures.size} facture(s) traitée(s)"
    end
end
