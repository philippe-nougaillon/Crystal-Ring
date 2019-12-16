namespace :factures do
    
    desc "Relancer par email et changer l'état: Ring2=>Ring3, Ring1=>Ring2, Envoyée=>Ring1"
    task :relancer, [:current_user_id, :enregistrer, :date] => :environment do |task, args|

        enregistrer = (args[:enregistrer] == '1')    
        puts "Enregistrer les modifications !" if enregistrer
        
        user = User.find(args.current_user_id)

        etats = [:ring2, :ring1, :envoyée]

        etats.each do | e | 
            Facture.where(etat: e).each do | facture |
                puts "-=" * 80
                puts facture.id
                puts "Etat: #{facture.etat}" 

                # Envoyer à nouveau (relance) vers toutes les cibles
                facture.cibles.each do |c|
                    puts "Envoyer relance à #{c.email}"    
                    FactureMailer.with(cible: c).notification_email.deliver_now
                    c.update!(envoyé_le: DateTime.now) if enregistrer
                end

                # Passer à l'état suivant
                nouvel_etat = facture.etat_before_type_cast + 1
                puts "Nouvel Etat: #{nouvel_etat}"
                facture.update!(etat: nouvel_etat) if enregistrer
                puts "Facture.Etat: #{facture.etat}"
            end
        end
        puts "Traitement terminé"
    end
end
