(function($) {
  var navBar = {
    init: function() {
      // Home link, which will clear all this mess
      $('#titlebarhome').click(function() {
        // Clear category status bar
        try {
          if (navBar.onClear) {
            navBar.onClear();
          }
        }
        catch(e) { console.error(e); }
        return false;
      });
    },
    clear: function() {
      $('#titlebarcontainer').children().each(function(indx, child) { $(child).remove(); });
    },
    update: function(text, categoryTree) {
      navBar.clear();
      if (text) {
        $('#titlebarcontainer').append(
          $('<span/>').addClass('titlebarcat').attr('data-text', text)
            .append($('<span/>').addClass('value').text('"' + text + '"'))
            .append($('<span/>').addClass('remove').html('&nbsp;'))
        );
        $('.titlebarcat[data-text] .remove').click(function() {
          $(this).parent('.titlebarcat').remove();
          if (navBar.onRemove) {
            try { navBar.onRemove(undefined, $('.titlebarcat[data-category]:last').attr('data-category')); }
            catch(e) { console.error(e); }
          }
        });
      }
      if (categoryTree) {
        var seen = {};
        for(var id in categoryTree) {
          if (id) {
            if (categoryTree[id] && !seen[id]) {
              $('#titlebarcontainer').append(
                $('<span/>').addClass('titlebarcat').attr('data-category', id)
                  .append($('<span/>').addClass('value').html(categoryTree[id]))
                  .append($('<span/>').addClass('remove').html('&nbsp;'))
              );
              seen[id] = true;
            }
          }
        }
        $('.titlebarcat[data-category] .remove').click(function() {
          var categoryNode = $(this).parent('.titlebarcat');
          var category = categoryNode.prev().attr('data-category');
          categoryNode.next('[data-category]').remove().end().remove();
          if (navBar.onRemove) {
            try { navBar.onRemove(text, category); }
            catch(e) { console.error(e); }
          }
          return false;
        });
      }
    }
  };

  $.fn.navigation = function(options) {
    if (typeof options == 'string') {
      if ($.inArray(options, ['clear', 'update']) == -1) {
        console.error('Method "' + options + '" not found on navigation object');
        return;
      }
      navBar[options].apply(navBar, Array.prototype.slice.call(arguments, 1)); // Execute the allowed method
    }
    else if (!options || typeof options == 'object') {
      // Init the navigation bar
      var defaults = { };
      options = $.extend({}, defaults, options);

      navBar.onClear = options.onClear;
      navBar.onRemove = options.onRemove;
      navBar.init();
    }
  };
})(jQuery);

