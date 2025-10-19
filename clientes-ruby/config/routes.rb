Rails.application.routes.draw do
  resources :clientes, only: [:index, :create], controller: 'interfaces/controllers/clientes'
end
