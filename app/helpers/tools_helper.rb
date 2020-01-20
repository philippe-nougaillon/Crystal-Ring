module ToolsHelper

    def prettify(audit)    

        pretty_changes = []
        
        audit.audited_changes.each do |c|
            key = c.first.humanize
            if key == 'User'
                ids = audit.audited_changes['user_id']
                case ids.class.name
                when 'Integer'
                    pretty_changes << "'#{key}' initialisé à '#{User.find(ids).nom_et_prénom}'"
                when 'Array'
                    pretty_changes << "'#{key}' changé de '#{User.find(ids.first).nom_et_prénom if ids.first}' à '#{User.find(ids.last).nom_et_prénom if ids.last}'"
                end 
            elsif key == 'Anomalie'
                ids = audit.audited_changes['anomalie']
                case ids.class.name
                when 'Integer'
                    pretty_changes << "'#{key}' initialisé à '#{Facture.anomalies.keys[ids].humanize}'"
                when 'Array'
                    pretty_changes << "'#{key}' changé de '#{Facture.anomalies.keys[ids.first].humanize if ids.first}' à '#{Facture.anomalies.keys[ids.last].humanize if ids.last}'"
                end 
            else
                if audit.action == 'update'
                    unless c.last.first.blank? && c.last.last.blank?    
                        pretty_changes << "'#{key}' modifié de '#{c.last.first}' à '#{c.last.last}'"
                    end
                else 
                    unless c.last.blank?
                        pretty_changes << "'#{key}' #{audit.action == 'create' ? 'initialisé à' : 'était'} '#{c.last}'"
                    end
                end
            end
        end
        pretty_changes
    end

end