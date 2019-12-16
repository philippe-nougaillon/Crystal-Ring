class ToolsController < ApplicationController

    def audit_trail
        @audits = Audited::Audit.order("id DESC")
        @types  = @audits.pluck(:auditable_type).uniq.sort
        @users  = User.all

        unless params[:date].blank?  
            @audits = @audits.where("DATE(created_at) = ?", params[:date])
        end

        unless params[:type].blank?
            @audits = @audits.where(auditable_type: params[:type])
        end

        unless params[:user_id].blank?
            @audits = @audits.where(user_id: params[:user_id])
        end
            
        @audits = @audits.paginate(page: params[:page], per_page: 10)
    end

    def relancer
    end

    def relancer_do
        # authorize(:admin)
        
        require 'rake'
    
        Rake::Task.clear # necessary to avoid tasks being loaded several times in dev mode
        Rails.application.load_tasks # providing your application name is 'sample'
          
        # capture output
        @stdout_stream = capture_stdout do
          Rake::Task['factures:relancer'].reenable # in case you're going to invoke the same task second time.
          Rake::Task['factures:relancer'].invoke(current_user.id, params[:enregistrer])
        end
    
        # # Garder une trace dans un fichier de log
        # if params[:enregistrer] == '1'
        #   f = File.new("log/prestations_#{DateTime.now}.log", 'w')
        #   f << @stdout_stream
        #   f.close
        # end
    end
    
end