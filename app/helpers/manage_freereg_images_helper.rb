module ManageFreeregImagesHelper
    def do_we_offer_the_delete_action
      offer = false
      offer = true if (session[:role] == 'data_manager' ||  session[:role] == 'system_administrator' ||  session[:manage_user_origin] == 'manage county')
      offer
    end 
end
