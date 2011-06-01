RAILS_ENV = (ENV['RAILS_ENV'])? ENV['RAILS_ENV'] : 'development'
RAILS_ROOT = "../sandbox" unless defined?(RAILS_ROOT)

require File.join(File.dirname(__FILE__), RAILS_ROOT, '/config/environment')


def require_tree(name)
  path_to_lib = RAILS_ROOT + "/app"    #adjust if necessary
  path_to_tree = "#{path_to_lib}/#{name}"
  Dir["#{path_to_tree}/**/*.rb"].each { |fn|
    fn =~ /^#{Regexp.escape(path_to_lib)}\/(.*)\.rb$/
    require fn
  }
end

require_tree "models"

$config = YAML.load_file(File.join(File.dirname(__FILE__), 'database.yml'))[RAILS_ENV]

ActiveRecord::Base.establish_connection($config['import'])

class Movie < ActiveRecord::Base  
  establish_connection $config['crawler']
end  

class MovieShow < ActiveRecord::Base  
  establish_connection $config['crawler']
end  

class Theater < ActiveRecord::Base  
  establish_connection $config['crawler']
end  

class MusicShow < ActiveRecord::Base  
  establish_connection $config['crawler']
end 

class TvShow < ActiveRecord::Base  
  establish_connection $config['crawler']
end 

def grab_picture(event, image_url, readEnv = true)
  begin
    if (!image_url || (readEnv && ENV['MGP_DEBUG']))
      return
    end
    
    #URI.escape won't escape square brackets ('[]'), so let's just assume
    #we're getting an escaped string.
    #In case You're wondering who does escape square brackets,
    #well of course, python's urllib2.quote does :)
    begin
      webFile = rio(image_url)
      image = '/thumbnails/event_'+event.id.to_s+webFile.extname.downcase;
      localFile = rio('../sandbox/public'+image)
      if (!localFile.exist?)
        webFile.binmode > localFile
        puts image_url + ' downloaded for event '+event.id.to_s 
      else
        puts image_url + ' exists for event '+event.id.to_s
      end
      event.image_url = image
      event.save
    rescue Exception => e
      puts image_url + ' can\'t be downloaded for event '+event.id.to_s + ' (' + e.message + ')'
    end    
  end
end

def add_attributes(mo, attributes, addParent = true)
  for at in attributes
    if ( ! mo.labels.exists?(at))
      mo.labels.push(at)
    end
    if ( addParent && at.parent != nil && ! mo.labels.exists?(at.parent))
      mo.labels.push(at.parent)
    end
  end
end

def find_or_add_attributes(mo, new_attributes, parent_name, parent_value, grandparent_name, grandparent_value)
    new_attributes.each do |g|
      g = g.strip
      ats = Attribute.find(:all,:conditions=>["attributes.value = ? AND parents_attributes_2.name = ? AND parents_attributes_2.value = ?", g, grandparent_name, grandparent_value], :include => [{:parent => :parent}])
      if ( ats.empty? )
        parent_att = Attribute.find(:first,:conditions=>["attributes.name = ? and attributes.value = ? AND parents_attributes.name = ? AND parents_attributes.value = ?", parent_name, parent_value, grandparent_name, grandparent_value], :include => [:parent]);
        at = Attribute.new
        at.name = parent_value
        at.value = g
        at.parent = parent_att
        #at.icon = parent_att.icon

        at.save
        puts "Saved attribute" + g
        ats << at;
      end
      
      add_attributes(mo, ats);   
    end
end