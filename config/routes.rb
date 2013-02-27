# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
resources :projects do
  get 'issues/:copy_from/create_test', :to => 'create_test#new'
end
