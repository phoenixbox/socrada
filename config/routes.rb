Socrada::Application.routes.draw do
  root :to => "home#index"
  resources :users, :only => [:show]
  match 'auth/failure' => redirect('/')
  match 'auth/:provider/callback', to: 'sessions#create', as: 'signin'
  match 'signout', to: "sessions#destroy", as: "signout"
end
