Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users" }
  root to: 'pages#home'
  resources :projects
  resources :posts
  resources :users
  get 'resume', to: 'pages#resume'
end
