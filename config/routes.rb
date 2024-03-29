Rails.application.routes.draw do
  get '/feeds(/:user_id)', to: 'feeds#show', defaults: { format: :rss }
  get 'password_resets/new'
  get 'password_resets/edit'
  root 'static_pages#home'
  get '/signup', to: "users#new"
  get "/help", to: "static_pages#help"
  get "/about", to: "static_pages#about"
  get "/contact", to: "static_pages#contact"
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
  resources :users do
    member do
      get :following, :followers
    end
    collection do
      get :search
    end
  end
  resources :account_activations, only: [:edit]
  resources :password_resets, only: [:new, :create, :edit, :update]
  resources :microposts, only: [:create, :destroy] do
    collection do
      get 'search'
    end
  end
  resources :relationships, only: [:create, :destroy]
  resources :conversations, only: [:index, :show]
  resources :messages, only: [:create]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
