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
end