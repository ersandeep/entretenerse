class FrontendController < ApplicationController
  before_filter :set_locale 
  layout 'index'

  def index

  end

  def find_holidays
    holidays = Calendar.find(:all, :conditions => ["status = 'F'"], :order => "date")
    render :js => holidays.to_json(:only => [:date]), :layout => false
  end

  def find_categories
    categories = Attribute.find(:all, :conditions => 'parent_id IS NULL', :order => "attributes.order, attributes.name", :include => [{:children => [:children]}])

    render :js => categories.to_json(:only => [:id, :value, :icon, :order], :order => "attributes.order, attributes.value", :include => { :children => { :only => [:id, :icon, :value], :order=> "category_id, title", :include => {:children => { :only => [:id, :value] } } } }), :layout => false
  end

  def find_wizard
    #Hay cuatro agrupaciones, dos por eventos y dos por ocurrencias. Cada una de estas dos se divide ademas en agrupaciones
    #hasta el nivel 3 y hasta el nivel 4 de atributos, segun lo elegido en el asistente
    gpaIds = []
    paIdsFor4 = []
    aIdsFor4 = []

    gppacats = ActiveSupport::JSON.decode(params[:cat]) 
    gppacats.each do |gppacat|
      unless gppacat.length == 0
        gppacat['children'].each do |gpacat|
          if (gpacat['children'])
            unless gpacat['children'].delete_if {|x| x.length == 0 } == 0
              paIds = gpacat['children'].map{|n| n['id'].to_i}
              if (paIds.length == 1)
                pacat = gpacat['children'].slice(0)
                paIdsFor4 << paIds[0]
                if (pacat['children'])
                  aIds = pacat['children'].delete_if {|x| x.length == 0 }.map{|n| n['id'].to_i};
                  aIdsFor4 |= aIds unless aIds == 0
                end
              else
                paIdsFor3 |= paIds
              end
            end #unless
          else
            gpaIds <<  gpacat['id']
          end
        end unless !gppacat['children']
      end
    end

    commonCond = [condition_time, condition_price, condition_text, condition_attributes]

    #Esto es para cuando un grupo del menu tiene opciones pero todas desmarcadas
    #gpaAttCond = ["gpa.id IN (:a)",{:a=>gpaIds}] unless gpaIds.length == 0

    with3AttCond = [] << ["pa.id IN (:a)",{:a=>paIdsFor3}]
    with4AttCond = []
    with4AttCond << ["pa.id IN (:a)",{:a=>paIdsFor4}] unless paIdsFor4.length == 0
    with4AttCond << ["a.id IN (:a)",{:a=>aIdsFor4}] unless aIdsFor4.length == 0
    with4AttCond << "1 = 0" if paIdsFor4.length == 0

    with3AttCond = commonCond | [with3AttCond.map { |c| Event.merge_conditions(c) }.join(' OR ')]
    with4AttCond = commonCond | [with4AttCond.map { |c| Event.merge_conditions(c) }.join(' OR ')]

    sql = "SELECT id_0, id_1, id_2, id_3, name_0, name_1, name_2, name_3, order_0, 
       SUM(events_with_att) events_with_att, SUM(occurrences_with_att) occurrences_with_att, SUM(events_in_place) events_in_place, SUM(occurrences_in_place) occurrences_in_place "+
      (('D' == params[:sortBy])? ", (SUM(occurrences_with_att)+SUM(occurrences_in_place)) count" : ", (SUM(events_with_att)+SUM(events_in_place)) count")+
      " FROM ( (
      "+wizard_events_grouping(with3AttCond, false)+
      "
      ) UNION (
      "+wizard_events_grouping(with4AttCond, true)+
      "
      ) UNION (
      "+wizard_occurrences_grouping(with3AttCond, false)+
      "
      ) UNION (
      "+wizard_occurrences_grouping(with4AttCond, true)+
      "
      )) all_group GROUP BY id_0, id_1, id_2, id_3, name_0, name_1, name_2, name_3 ORDER BY id_0, order_0"

    categories = Attribute.find_by_sql(sql);

    attributes = []
    categories.each do |category|
      create_attribute(attributes, category)
    end

    render :js => attributes.to_json(:only => [:id, :value, :count, :children]), :layout => false
  end

  def create_attribute(atts, c, l = 0)#atributos, fila SQL, nivel actual 
    key = c['id_'+l.to_s].to_i
    node = nil
    count = 0
    atts.each do |att|
      node = att unless att[:id] != key
    end
    if (node == nil)
      node = {:id => key, :value => c['name_'+l.to_s], :order => c['order_0'].to_i, :level => l, :count => 0}
      if (l == 3)
        node[:count] = c['count'].to_i
      else
        node[:children] = []
      end
      atts << node

      count = node[:count]
    end
    
    if (l != 3)
      count += create_attribute(node[:children], c, l+1)
      node[:count] += count
    end

    atts.sort! do |x,y|
     res = 0
     if(x[:level] == y[:level] && x[:level] == 0)
       res = x[:id] <=> y[:id]
     elsif(x[:level] == y[:level] && x[:level] == 1)
       res = x[:order] <=> y[:order]
     end
     res = y[:count] <=> x[:count] if res == 0
     res = x[:value] <=> y[:value] if res == 0
     res
    end

    count 
  end

  def render_thumbnail
    @image = Event.find(params[:id], :select => 'image_url')
    if @image.image_url
      send_data(@image.image_url, :disposition => 'inline')
    else
      render :file => Rails.root.join("public", "404.html"), :status => 404
    end
  end

  def find_event
    @occurrence = Occurrence.find(params[:id], :include => [{:event => [:category, :comments]}, :place])
    
    render :xml => @occurrence, :template => "frontend/find_event"
  end


  def count_events_by_category
    options = create_sql_options([condition_time, condition_price, condition_text, condition_attributes])
    #options[:select] = options[:select] + ", `events`.category_id AS category_id"
    
    sql = Occurrence.send(:construct_finder_sql_with_included_associations, options, ActiveRecord::Associations::ClassMethods::JoinDependency.new(Occurrence, options[:include], options[:joins]))

    @summary = Occurrence.find_by_sql "SELECT t1_r12 as category_id, count(*) as q FROM ("+sql+") as cat_sum GROUP BY category_id"

    render :xml => @summary, :template => "frontend/count_events_by_category"
  end

  def find_random_events
    options = create_sql_options([condition_time])
    options[:order] = "RAND(), "+options[:order]
    options[:limit] = params[:cantidad]? params[:cantidad].to_i : 3

    @events = Occurrence.find(:all, options)

    render :xml => [@events], :template => "frontend/find_events_date"
  end

  def find_events
    offset = params[:offset] ? params[:offset].to_i : 0
    cantidad = (offset == 0) ? 200 : 25 

    options = create_sql_options([condition_time, condition_price, condition_text, condition_attributes])
    options[:limit] = cantidad
    options[:offset] = offset

    @events = Occurrence.find(:all, options)

    render :xml => @events, :template => "frontend/find_events_date"
  end

 private

  def create_sql_options(cond, limit = nil, offset = 0, random = false)
    select_fields = '`occurrences`.`id`, `calendars`.`date`, `occurrences`.`hour`, `places`.`name`, `events`.`id`, `events`.`title`, `events`.`image_url`, `categories`.`name`';
    options = {
            #:select => select_fields,
            :include => [{:event => [:category]}, :labels, :place],
            :joins => [" ,`calendars`"],
            :conditions => cond.map { |c| Event.merge_conditions(c) }.compact.join(' AND '),
            :group => condition_group_by, :order => condition_order_by
            }
     return options
  end

  def condition_group_by
    ('D' == params[:sortBy])? "`occurrences`.id" : "`events`.id"
  end

  def condition_order_by
    if (params[:q].blank?)
      ('D' == params[:sortBy])? "`calendars`.date, `occurrences`.hour, `events`.category_id" : "`events`.category_id, `events`.title, `calendars`.date, `occurrences`.hour"
    else
      ('D' == params[:sortBy])? "`calendars`.date, `occurrences`.hour, 1 DESC" : "`events`.category_id, 1 DESC"
    end
  end

  def condition_text
    return ["MATCH (`events`.`title`,`events`.`description`,`events`.`text`, `places`.`name`) AGAINST (:q IN BOOLEAN MODE)", {:q => params[:q]}] unless params[:q].blank? 
  end

  def condition_attributes
    #Fulltext de los atributos
    #categoria y subcategorias --> , separador de subcategorias | ; separador de grupos | : separador de categorias principales 

    mainCatsCond = []

    gppacats = ActiveSupport::JSON.decode(params[:cat])
    gppacats.each do |gppacat|
      unless gppacat.length == 0
        catsGroupCond = []
        catsGroupCond << ["category_id = ?", gppacat['id'].to_i] #Aca esta el ID de la categoria
        gppacat['children'].each do |gpacat|
            aIds = [gpacat['id']]
            if (gpacat['children'])
              unless gpacat['children'].delete_if {|x| x.length == 0 } == 0
                aIds = gpacat['children'].map{|n| n['id'].to_i}

                if (gpacat['children'].length == 1 && gpacat['children'].slice(0)['children'])
                 pacatCh = gpacat['children'].slice(0)['children'].delete_if {|x| x.length == 0 }
                 aIds = pacatCh.map{|n| n['id'].to_i} unless pacatCh.length == 0
                end
              end
            end

            if (aIds.length > 0)
              if (gpacat['type'] == 'O')
                catsGroupCond << ["1 <= (SELECT COUNT(1) c FROM `occurrences_attributes` oa1 WHERE oa1.`occurrence_id` = occurrences.id AND oa1.`attribute_id` IN (:q))", {:q=>aIds}]
              else
                catsGroupCond << ["1 <= (SELECT COUNT(1) c FROM `events_attributes` ea1 WHERE ea1.`event_id` = events.id AND `attribute_id` IN (:q))", {:q=>aIds}]
              end
            end
        end unless !gppacat['children']

        mainCatsCond << catsGroupCond.map { |c| Event.merge_conditions(c) }.join(' AND ')
      end
    end

    return mainCatsCond.map { |c| Event.merge_conditions(c) }.join(' OR ') unless params[:cat].blank?
  end
  
  def condition_price
    #Busco que el precio sea menor al indicado
    return "events.price IS ? OR events.price <= ?", nil, params[:price].to_i unless params[:price].blank?  
  end

  def condition_hours(hours)
    #Condiciones para la hora
    hoursCond = []
    dateFrom = Time.zone.now.beginning_of_day
    hours.each do |hour|
      case hour
        when 'E'
          hoursCond << ["`occurrences`.`hour` >= ? AND `occurrences`.`hour` <= ?",
                        (dateFrom + 1.hour).strftime('%H:%M:%S'), (dateFrom + 6.hours - 1.second).strftime('%H:%M:%S')]
        when 'M'
          hoursCond << ["`occurrences`.`hour` >= ? AND `occurrences`.`hour` <= ?",
                        (dateFrom + 6.hours).strftime('%H:%M:%S'), (dateFrom + 12.hours - 1.second).strftime('%H:%M:%S')]
        when 'A'
          hoursCond << ["`occurrences`.`hour` >= ? AND `occurrences`.`hour` <= ?",
                        (dateFrom + 12.hours).strftime('%H:%M:%S'), (dateFrom + 18.hours - 1.second).strftime('%H:%M:%S')]
        when 'N'
          hoursCond << ["`occurrences`.`hour` >= ? AND `occurrences`.`hour` <= ?",
                        (dateFrom + 18.hours).strftime('%H:%M:%S'), (dateFrom + 24.hours - 1.second).strftime('%H:%M:%S')]
        end
      end
      
      return hoursCond.map { |c| Event.merge_conditions(c) }.join(' OR ')
  end

  def condition_dates(dateFrom, dateTo)
    #Condiciones para el dia: Busco eventos para la fecha exacta, eventos para el dia de la semana y eventos sin fecha
    #El dateFrom tiene un dia mas que el elegido, para tener en cuenta el hecho de que el dia de hoy termina mañana a las 06:00 am.
    #Del dia exacto
    daysCond = []
    daysCond << ["`occurrences`.`date` >= ? AND `occurrences`.`date` <= ? AND `calendars`.`date` = `occurrences`.`date`", dateFrom, dateTo]
    #Eventos sin fecha pero con dia de la semana
    da/sOfWeek = []
    dateFrom.to_date.step(dateTo.to_date, 1) do |date|
      daysOfWeek << date.wday
    end
    daysCond << ["`occurrences`.`date` IS ? " +
      "AND `calendars`.`dayOfWeek` IN (?) " +
      "AND `calendars`.`dayOfWeek` = `occurrences`.`dayOfWeek` " +
      "AND `calendars`.`date` >= ? " +
      "AND `calendars`.`date` <= ?", nil, daysOfWeek, dateFrom, dateTo]
    #Sin fecha (se supone se repiten todos los dias)
    daysCond << ["`occurrences`.`date` IS ? " +
      "AND `occurrences`.`dayOfWeek` IS ? " +
      "AND `occurrences`.`hour` IS NOT ? " +
      "AND `calendars`.`date` >= ? " +
      "AND `calendars`.`date` <= ?", nil, nil, nil, dateFrom, dateTo]
    return daysCond.map { |c| Event.merge_conditions(c) }.join(' OR ')
  end

  def condition_range(dateFrom, dateTo, now, showOlder)
    cond = []
    this_date = (now.to_date == dateFrom.to_date)? now : dateFrom + 6.hours
    #El rango horario va desde el dateFrom a las 06, hasta el dateTo a las 06. Si el dateFrom es el dia de hoy, filtro los eventos que ya pasaron
    if (showOlder)
      cond << ["ADDDATE(ADDTIME(`calendars`.date,`occurrences`.hour),INTERVAL COALESCE(`events`.duration,120) MINUTE) >= ?", this_date]
    else
      cond << ["ADDTIME(`calendars`.date,`occurrences`.hour) >= ?", this_date]
    end
    cond << ["ADDTIME(`calendars`.date,`occurrences`.hour) < ?", dateTo + 6.hours]

    return cond.map { |c| Event.merge_conditions(c) }.join(' AND ')
  end

  def condition_time
    dateFrom = Time.zone.at(params[:dateFrom].to_i/1000).beginning_of_day
    dateTo = Time.zone.at(params[:dateTo].to_i/1000).beginning_of_day + 1.day
    hours = params[:hours].split(',').map {|n| n.to_s}
    now = Time.zone.at(params[:dateNow].to_i/1000)
    showOlder = ("true" == params[:showOlder])

    cond = [Event.merge_conditions(["`occurrences`.`hour` IS NOT ?", nil])]
    cond << condition_dates(dateFrom, dateTo)
    cond << condition_hours(hours) unless hours.blank?
    cond << condition_range(dateFrom, dateTo, now, showOlder)
    
    return cond.map { |c| Event.merge_conditions(c) }.join(' AND ')
  end

  def wizard_events_grouping(cond, groupAtt)
    "SELECT gpa.parent_id id_0, pa.parent_id id_1, a.parent_id id_2, a.id id_3, gpa.name name_0, pa.name name_1, a.name name_2, a.value name_3
       , COUNT(DISTINCT ea.event_id) events_with_att
       , COUNT(DISTINCT CONCAT(`occurrences`.id,`calendars`.date)) occurrences_with_att
       , 0 events_in_place
       , 0 occurrences_in_place
       , gpa.order order_0
       FROM `attributes` a
       join `attributes` pa on pa.id=a.parent_id
       join `attributes` gpa on gpa.id=pa.parent_id
       left join `events_attributes` ea on ea.attribute_id=a.id
       left join `events` on ea.event_id=`events`.id
       left join `occurrences` on `occurrences`.event_id = ea.event_id
       join `places` on `places`.`id`=`occurrences`.`place_id`
       , `calendars`
       WHERE "+cond.map { |c| Attribute.merge_conditions(c) }.compact.join(' AND ')+" 
        GROUP BY gpa.id, pa.id"+((groupAtt)? ", a.id" : "")+" 
        HAVING events_with_att+occurrences_with_att > 0";
  end

  def wizard_occurrences_grouping(cond, groupAtt)
    "SELECT gpa.parent_id id_0, pa.parent_id id_1, a.parent_id id_2, a.id id_3, gpa.name name_0, pa.name name_1, a.name name_2, a.value name_3
       , 0 events_with_att
       , 0 occurrences_with_att
       , COUNT(DISTINCT `occurrences`.event_id) events_in_place
       , COUNT(DISTINCT CONCAT(oa.occurrence_id,`calendars`.date)) occurrences_in_place
       , gpa.order order_0
       FROM `attributes` a
       join `attributes` pa on pa.id=a.parent_id
       join `attributes` gpa on gpa.id=pa.parent_id
       left join `occurrences_attributes` oa on oa.attribute_id=a.id
       left join `occurrences` on `occurrences`.id = oa.occurrence_id
       left join `events` on `occurrences`.event_id=`events`.id
       join `places` on `places`.`id`=`occurrences`.`place_id`
       , `calendars`
       WHERE "+cond.map { |c| Attribute.merge_conditions(c) }.compact.join(' AND ')+" 
        GROUP BY gpa.id, pa.id"+((groupAtt)? ", a.id" : "")+" 
        HAVING events_in_place+occurrences_in_place > 0";
  end

end
