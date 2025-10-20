Rails.application.routes.draw do
  resources :facturas, only: [:index, :show, :create]
end
