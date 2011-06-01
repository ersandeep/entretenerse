(function($) {
  var categories = {
    init: function() {
      $('#categories').css('position', 'absolute').css('display', 'block'); // Make categories to overlap content
      categories.retitle();
    },
    expand: function() {
      if ($('#categories').hasClass('visible')) { return; }
      // Make a shadow copy of the categories panel
      var copy = $('#categories').clone();
      copy.css('width', 'auto').css('height', 'auto');
      copy.find('.category').css('width', 'auto');
      copy.css('position', 'absolute').css('top', '-10000px');
      $('body').append(copy);

      // Collect real widthes of categories
      var widths = copy.find('.category').map(function() { return $(this).width(); });
      var height = copy.height();

      // Change class for the bar
      $('#categories').removeClass('hidden').addClass('visible');

      // Expand top category widths
      $('#categories .category').each(function(index) {
        var width = widths[index];
        if (isFinite(width)) {
          $(this).animate( { 'width': width }, 'fast', function() {
            $(this).css('width', 'auto');
          });
        }
      });
      // Animate subcategories panel
      $('#categories').animate( { 'height': 'fast' }, 'slow', 'easeOutBounce',
        function() {
          $(this).css('height', 'auto');
      });

      copy.remove();
    },
    collapse: function() {
      $('#categories').animate( { height: '34px' }, 'slow', 'easeOutBounce', function() { });
      // Collapse top category titles
      $('#categories .category').animate( { width: '100px' }, 'slow'); 
      // Show label "Show Search Assistant"
      $('#hide_search_options').hide();
      $('#show_search_options').show();
      // Change class for categories bar
      $('#categories').removeClass('visible').addClass('hidden');
    },
    update: function(params) {
      // Request for categories counts
      $.get('/categories?' + $.param(params || {}), function(data) {
        $('#categories').html(data);
        categories.retitle();
      });
    },
    tree: function(category) {
      var node = $('#categories a[data-category=' + category + ']');
      var topCategory = node.parents('div.category').find('.category-item a[data-category]');
      var subCategory = node.parents('div.subcategory').find('.sub-category-item a[data-category]');

      var categoryTree = {};
      if (topCategory.length) {
        categoryTree[topCategory.attr('data-category')] = topCategory.text();
      }
      if (subCategory.length) {
        categoryTree[subCategory.attr('data-category')] = subCategory.text(); 
      }
      categoryTree[node.attr('data-category')] = node.text();
      return categoryTree;
    },
    retitle: function() {
      var expandTimeout = null;
      // Expand / Collapse categories pane
      $('.category .category-item #category_title').mouseenter(function() {
        expandTimeout = setTimeout(categories.expand, 700);
      });
      $('#categories').mouseleave(function() {
        if (expandTimeout !== null) { clearTimeout(expandTimeout); }
        categories.collapse();
      });

      // Category selection
      $('.category-item a, .sub-category-item a, .child-category-item a').click(function() {
        var selectedCategory = $(this).attr('data-category');
        if (categories.onSelect) {
          try { categories.onSelect(selectedCategory); }
          catch(e) { console.error(e); }
        }
        return false; // Prevent link walking
      });

    }
  };

  $.fn.categories = function(options) {
    if (typeof options == 'string') {
      if ($.inArray(options, ['update', 'collapse', 'expand', 'tree']) == -1) {
        console.error('Method "' + options + '" not found on categories object');
        return;
      }
      return categories[options].apply(categories, Array.prototype.slice.call(arguments, 1)); // Execute the allowed method
    }
    else if (!options || typeof options == 'object') {
      // Init the categories object
      var defaults = { };
      options = $.extend({}, defaults, options);

      categories.onSelect = options.onSelect;

      // Init code
      categories.init();
    }
  }

})(jQuery);
