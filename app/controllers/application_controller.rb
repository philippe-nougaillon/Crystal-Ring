class ApplicationController < ActionController::Base
    before_action :authenticate_user!
    before_action :set_layout_variables

private
    def set_layout_variables
      @ctrl = params[:controller]
      @title = "AnoFacto "
      @version = "v0.4"
    end

    def user_not_authorized
      flash[:alert] = "Vous n'êtes pas autorisé.e à effectuer cette action !"
      redirect_to(request.referrer || (current_user.role == 'user' ? moncompte_index_path : root_path))
    end

end
