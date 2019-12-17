Rails.application.routes.draw do

  devise_for :users

  resources :factures do
    post :validation
  end

  namespace :tools do
    get :index
    get :audit_trail
    get :relancer
    
    post :relancer_do
  end

  root to: 'factures#index'

end
