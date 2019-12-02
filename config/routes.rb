Rails.application.routes.draw do

  devise_for :users

  resources :factures do
    get :validation
    post :validation
  end

  root to: 'factures#index'

end
