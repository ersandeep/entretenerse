EasyNavigation::Builder.config do |map|
    map.navigation :default do |navigation|
      navigation.tab :users, :url => { :controller => "/users", :action => "index"} do |tab|
      end
      navigation.tab :attributes, :url => { :controller => "/attributes", :action => "index"} do |tab|
      end      
      navigation.tab :campaign_types, :url => { :controller => "/campaign_types", :action => "index"} do |tab|
      end      
      navigation.tab :events, :url => { :controller => "/events", :action => "index"} do |tab|
      end      
      navigation.tab :sponsors, :url => { :controller => "/sponsors", :action => "index"} do |tab|
      end      
      navigation.tab :tags, :url => { :controller => "/tags", :action => "index"} do |tab|
      end      
      navigation.tab :targets, :url => { :controller => "/targets", :action => "index"} do |tab|
      end      
      navigation.tab :performers, :url => { :controller => "/performers", :action => "index"} do |tab|
      end      
    end
    map.navigation :nektra do |navigation|
      navigation.tab :users, :url => { :controller => "/users", :action => "index"} do |tab|
      end
      navigation.tab :attributes, :url => { :controller => "/attributes", :action => "index"} do |tab|
      end      
      navigation.tab :campaign_types, :url => { :controller => "/campaign_types", :action => "index"} do |tab|
      end      
      navigation.tab :events, :url => { :controller => "/events", :action => "index"} do |tab|
      end      
      navigation.tab :sponsors, :url => { :controller => "/sponsors", :action => "index"} do |tab|
      end      
      navigation.tab :tags, :url => { :controller => "/tags", :action => "index"} do |tab|
      end      
      navigation.tab :targets, :url => { :controller => "/targets", :action => "index"} do |tab|
      end      
      navigation.tab :performers, :url => { :controller => "/performers", :action => "index"} do |tab|
      end
      navigation.tab :places, :url => { :controller => "/places", :action => "index"} do |tab|
      end
      navigation.tab :calendars, :url => { :controller => "/calendars", :action => "index"} do |tab|
      end
    end
  end
