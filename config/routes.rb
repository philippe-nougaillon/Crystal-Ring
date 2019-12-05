Rails.application.routes.draw do

  devise_for :users

  resources :factures do
    get :validation
    post :validation
  end

  namespace :tools do
    get :audit_trail
  end

  root to: 'factures#index'

end
