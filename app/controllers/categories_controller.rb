class CategoriesController < ApplicationController
  before_filter :set_locale
  before_filter :admin_only, :except => :index
  layout 'index'

  def index
    admin_only unless request.xhr?
    category_id = params[:category].to_i
    if params[:counts]
      params[:hours] ||= params[:date] ? '06-24' : Time.now.in_time_zone("Buenos Aires").strftime('%H-24')
      params[:date] ||= Time.zone.now.to_s
      categories = Attribute.find_with_counts(Occurrence.conditions(params))
    else
      categories = Attribute.find(:all)
    end

    identity_map = categories.inject({}) { |hash, category| hash[category.id] = category; hash }
    @categories = parents_for(categories, identity_map)
    collapse!(category_id, @categories, identity_map) if category_id > 0
    if request.xhr?
      render :partial => 'layouts/category', :collection => @categories
    elsif category_id > 0
      @category = Attribute.find(category_id)
      render 'show'
    end
  end

  def show
    @category = Attribute.find(params[:category].to_i, :include => [:children, :parent])

    render :layout => !request.xhr?
  end

  def update
    category = Attribute.find(params[:id].to_i)
    if params[:category] && params[:category][:on_home_page]
      category.on_home_page = !category.on_home_page?
      category.save!
    end
    redirect_to '/categories/?category=' + category.id.to_s
  end

  protected

  # Collapses category tree over selected category in order to show its child leafs (if any)
  def collapse!(selected_id, category_tree, identity_map)
    return unless selected = identity_map[selected_id] # It should exist on identity map
    return unless selected.parent_id # Top category selected. Skip it.
    parent = identity_map[selected.parent_id] ||= Attribute.find(selected.parent_id)
    return collapse!(parent.id, category_tree, identity_map) if selected.leafs.length == 0 # Collapse parent only if selected category has no leafs itself
    if parent.parent_id # Not a Top category?
      selected.value = parent.value + ' › ' + selected.value
      parent = identity_map[parent.parent_id] ||= Attribute.find(parent.parent_id)
    #else
      #category_tree.delete_if { |cat| cat != parent } # Remove all other top categories
    end
    parent.leafs = [selected]
  end

  def parents_for(categories, identity_map)
    return categories if categories.blank?
    groups = categories.group_by(&:parent_id)
    return categories if groups.length == 1 && groups.key?(nil) # Check if all categories fall a single one group with parent_id == nil
    parents = []
    groups.each do |parent_id, children|
      parents += children and next if parent_id.nil?
      parent = identity_map[parent_id] ||= Attribute.find(parent_id)
      parent.leafs += children #there can be an error. What if parent already has leafs from enother node of the same tree
      parent.leafs.uniq!
      parent.occurrences_count = parent.leafs.inject(0) { |sum, child| sum + (child.occurrences_count ? child.occurrences_count : 0) }
      parents << parent
    end
    parents_for parents.uniq, identity_map
  end
end
