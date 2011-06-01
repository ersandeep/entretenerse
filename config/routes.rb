Entretenerse::Application.routes.draw do
  resources :crawlers do
    post :import, :on => :member
    post :start, :on => :member
    post :stop, :on => :member
  end

  match '/' => 'login#index'
  match 'c/:category' => 'login#index', :as => :categories
  match 'c/:top_category/:category' => 'login#index', :as => :categories
  match 'c/:top_category/:sub_category/:category' => 'login#index', :as => :categories
  match 'server/xrds' => 'server#idp_xrds'
  match 'user/:username' => 'server#user_page'
  match 'user/:username/xrds' => 'server#user_xrds'
  match ':controller/service.wsdl' => '#wsdl'
  match 'session' => 'session#create', :as => :open_id_complete, :constraints => { :method => 'get' }
  resource :session
  match 'e/:event/:place/:id' => 'event#view', :as => :e
  match 'static/categories/:att_name' => 'frontend_static#find_attributes'
  match 'static/categories/:att_parent/:att_name' => 'frontend_static#find_attributes'
  match 'static/categories/:att_parent1/:att_parent1/:att_name' => 'frontend_static#find_attributes'
  match 'static/categories/:att_parent1/:att_parent1/:att_name1/:att_name' => 'frontend_static#find_attributes'
  match 'event/detail/:id' => 'event#detail'
  match 'static/hoy/:att_name' => 'frontend_static#find_eventos_hoy'
  match 'static/semana/:att_name' => 'frontend_static#find_eventos_semana'
  match 'static/categories' => 'frontend_static#find_attributes'

  get  '/proxy' => 'crawlers#proxy'
  post 'crawlers/new' => 'crawlers#create'
  resources :crawlers do
    member do
      get  'configuration'
      get  'proceed'
      post 'activate'
      post 'deactivate'
      post 'run'
      post 'stop'
      post 'reset'
    end
  end

  resources :crawler_logs, :only => [:show, :update] do
    member do
      get  'pull_data'
      get  'push_data'
      post 'proceed'
      post 'restart'
    end
  end

  #scope '/translate' do
    #match '/translate_list', :to => 'translate#index'
    #match '/translate', :to => 'translate#translate'
    #match '/translate_reload', :to => 'translate#reload', :as => 'translate_reload'
  #end

  match '/:controller(/:action(/:id))'
end

