Rails.application.routes.draw do
  root to: 'pages#home'
  resources :projects
  resources :posts
  get 'resume', to: 'pages#resume'
end
