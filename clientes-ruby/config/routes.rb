Rails.application.routes.draw do
  resources :clientes, only: [:index, :create]
  resources :clientes, only: [:index, :create]
end
