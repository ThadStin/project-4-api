Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/beers', to: 'beers#index'
  get '/beers/:id', to: 'beers#show'
  post '/beers', to: 'beers#create'
  delete '/beers/:id', to: 'beers#delete'
  put '/beers/:id', to: 'beers#update'
  
end
