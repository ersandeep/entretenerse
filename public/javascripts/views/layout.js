(function($) {
  $(function() {
    var layout = function() {

      // Search field
      var initSearchField = function() {
        $('#searchfield').watermark($('#searchfield').attr('title'));
        $('#searchfield').keyup(function(e) {
          if ($(this).val().length > 0) {
            $('#searchbutton').removeClass('yui-button-disabled').removeClass('yui-push-button-disabled');
            $('#searchbutton-button').removeAttr('disabled');
            $(this).removeClass('hint');
            if (e && (e.keyCode || e.which) == $.entr.keyboard.enter) {
              $('#searchbutton-button').click();
            }
          }
          else {
            $('#searchbutton').addClass('yui-button-disabled').addClass('yui-push-button-disabled');
            $('#searchbutton-button').attr('disabled', 'disabled');
            $(this).addClass('hint');
          }
        });
        $('#searchbutton-button').click(function() {
          $.entr.filter.values.text = $('#searchfield').val();
          var categoryTree = $('#categories').categories('tree', $.entr.filter.values.category);
          $('#titlebarcontainer').navigation('update', $.entr.filter.values.text, categoryTree);
          $.entr.navigate('/', $.param($.entr.filter.values));
        });
        // Search options label
        $('#searchoptionslabel').click(function() {
          var show = $('#show_search_options', this);
          var hide = $('#hide_search_options', this);
          if (show.is(':visible')) {
            show.hide();
            hide.show();
            $('#categories').categories('expand');
          }
          else {
            hide.hide();
            show.show();
            $('#categories').categories('collapse');
          }
        });
      };

      var initCategories = function() {
        // Init categories
        $('#categories')
          .categories({
            onSelect: function(category) {
              $.entr.filter.values.category = category;
              var categoryTree = $('#categories').categories('tree', category);
              $('#titlebarcontainer').navigation('update', $.entr.filter.values.text, categoryTree);
              $.entr.navigate('/', $.param($.entr.filter.values));
            }
          });
      };

      // Init navigation bar
      var initNavigationBar = function() {
        $('#titlebarcontainer').navigation({
          onClear: function() {
            // Clear filters fist
            delete $.entr.filter.values.category;
            delete $.entr.filter.values.date;
            delete $.entr.filter.values.text;
            delete $.entr.filter.values.hours;
            // Clear selections (if any)
            $('#col1').filters('clear');
            $('#titlebarcontainer').navigation('clear');
            $('#searchfield').val(''); // Clear text search
            $.entr.navigate('/', $.param($.entr.filter.values));
          },
          onRemove: function(text, categoryId) {
            if (text === undefined) {
              delete $.entr.filter.values.text;
              $('#searchfield').val('');
            }
            else { $.entr.filter.values.text = text; }
            if (typeof categoryId === undefined) { delete $.entr.filter.values.category; }
            else { $.entr.filter.values.category = categoryId; }
            $.entr.navigate('/', $.param($.entr.filter.values));
          }
        });
      };

      // Init filters
      var initFilters = function() {
        $('#col1').filters();
        $(document).bind('selected.hours.entretenerse', function(e, hours) {
          if (hours) { $.entr.filter.values.hours = hours; }
          else { delete $.entr.filter.values.hours; }
          $.entr.navigate('/', $.param($.entr.filter.values));
        });
        $(document).bind('selected.date.entretenerse', function(e, date) {
          if (date) { $.entr.filter.values.date = date; }
          else { delete $.entr.filter.values.date; }
          $.entr.navigate('/', $.param($.entr.filter.values));
        });
        $(document).bind('expanded.filters.entretenerse', function(e, data) {
          $.entr.filter.visible = true;
          $(window).resize();
        });
        $(document).bind('collapsed.filters.entretenerse', function(e, data) {
          $.entr.filter.visible = false;
          $(window).resize();
        });

        $.entr.filter.visible = true;
      };

      // Switch to category view
      var initCategoryViewLink = function() {
        $('#switch_to_calendar_view').click(function() {
          $(this).hide();
          $('#switch_to_category_view').show();
          $.entr.filter.values.view = 'calendar';
          $.entr.navigate('/', $.param($.entr.filter.values));
          return false;
        });
        $('#switch_to_category_view').click(function() {
          $(this).hide();
          $('#switch_to_calendar_view').show();
          $.entr.filter.values.view = 'category';
          $.entr.navigate('/', $.param($.entr.filter.values));
          return false;
        });
      };

      // Clickpass iframe
      var initClickpass = function() {
        var clickpass = document.getElementById('clickpassIframe');
        if (clickpass) {
          clickpass.src="http://www.clickpass.com/embedded_buttons/login-standard/SjTAtHs5cf";
          var clickpassPanel = new ClickpassPanel('clickpassbox');
        }
      };

      var resize = function() {
        var win = $(window),
            winWidth = win.width(),
            winHeight = win.height();

        $('#categories').width($('#thirdbar').width() - $('#refineby').outerWidth(true) - 21);

        // Update height
        var width = winWidth - 60;
        if ($.entr.filter.visible) { width -= $('#col1').width(); }
        var minHeight = $('.filters').outerHeight(true) + 21;
        var newHeight = winHeight - ($('#ft').outerHeight(true) + $('#header').outerHeight(true) + 21);
        var height = Math.max(newHeight, minHeight, 300);
        if (newHeight < minHeight) {
          $('body').css('overflow', 'scroll');
        }
        else { $('body').css('overflow', 'hidden'); console.log('height is normal'); }

        $('#col1').height(height - 21);
        var content = $('#col2').width(width).height(height);
        var contentOffset = content.offset();
        $('#in_progress').width(width).height(height)
          .css('left', contentOffset.left)
          .css('top', contentOffset.top);
      };

      // Update layout elements according to params provided
      var update = function(params) {
        if (!params) { params = {}; }
        $.entr.filter.values = params;
        // Update textbox
        $('#searchfield').val(params.text || '').keyup();
        // Switch to category
        $('#switch_to_category_view').hide();
        $('#switch_to_calendar_view').hide();
        if (params.view == 'category') { $('#switch_to_calendar_view').show(); }
        else { $('#switch_to_category_view').show(); }
        // Update categories
        $('#categories').categories('update', $.extend({}, params, { counts: true }));
        // Update filter
        $('#col1').filters('update', $.extend({}, params));
      };

      var load = (function() {
        var initialized = false,
            init = function() {
          // init body element first
          //$('body').css('overflow', 'hidden');
          $('#bd').css('overflow', 'hidden');
          initSearchField();
          initCategories();
          initNavigationBar();
          initFilters();
          initCategoryViewLink();
          initClickpass();
        };
        return function(url) {
          if (!initialized) { init(); }
          initialized = true;
          // Update layout state according to parameters
          update(url.params);
        };
      })();

      return {
        load: load,
        resize: resize,
        progressBar: {
          show: function() { $('#in_progress').show(); },
          hide: function() { $('#in_progress').hide(); }
        },
        categories: {
          update: function(params) {
                     }
        },
        filters: {
          show: function() {
            $('#col1').filters('show');
          }
        }
      };
    };

    if (!$.entr) { $.entr = {}; }
    if (!$.entr.views) { $.entr.views = {}; }
    if (!$.entr.views.occurrences) { $.entr.views.occurrences = {}; }
    $.entr.views.layout = new layout();
  });
})(jQuery);
