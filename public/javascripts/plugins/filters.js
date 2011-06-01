(function($) {
  var filter = {
    init: function() {
      // Expand / Collapse filters pane
      $('#colapse-filters').click(function() { filter.collapse(); });
      $('#expand-filters').click(function() { filter.expand(); });
      this.hours.init();
      this.calendar.init();
      this.days.init();
    },
    expand: function() {
      $('#expand-filters-pane').css('display', 'none');
      $('#col1').animate( { left: '0px' }, 'slow', 'swing', function() {
        filter.show();
        $(document).trigger('expanded.filters.entretenerse');
      });
    },
    collapse: function() {
      $('#col1').css('position', 'absolute');
      $('#col1').animate( { left: '-300px' }, 1000, 'swing', function() {
        $('#expand-filters-pane').css('display', 'block').css('left', '0');
        $(document).trigger('collapsed.filters.entretenerse');
      });
    },
    show: function() {
      $('#col1').css('position', 'static');
    },
    clear: function() {
      filter.hours.clear();
      filter.calendar.clear();
      filter.days.clear();
    },
    update: function(params) {
      filter.hours.update(params);
      filter.calendar.update(params);
      filter.days.update(params);
    },

    hours: {
      init: function() {
        // Hour selection
        $('a.filter-hours-item, a.filter-already-started').click(function() {
          var select = !$(this).hasClass('selected');
          filter.hours.clear();
          if (select) { $(this).addClass('selected'); } // Indicate current selection
          try {
            $(document).trigger('selected.hours.entretenerse', select ? $(this).attr('data-hours') : false);
          }
          catch(e) { console.error(e); }
          return false;
        });
      },
      update: function(params) {
        filter.hours.clear();
        if (!params.hours) { return; }
        var hoursAttr = '[data-hours=' + params.hours + ']';
        $('a.filter-hours-item' + hoursAttr + ', a.filter-already-started' + hoursAttr).addClass('selected');
      },
      clear: function() {
        $('a.filter-hours-item, a.filter-already-started').each(function(index, link) {
          $(link).removeClass('selected');
        });
      }
    },

    calendar: {
      init: function() {
        // Calendar
        $('#filter-calendar-container').datepicker({
          nextText: '',
          prevText: '',
          showOtherMonths: true,
          firstDay: 1,
          dateFormat: 'yy-mm-dd',
          onSelect: function(date, inst) {
            try {
              $(document).trigger('selected.date.entretenerse', date);
            }
            catch(e) { console.error(e); }
          }
        });
      },
      update: function(params) {
        $('#filter-calendar-container').datepicker('setDate', null); // Clear the calendar
        if (!params.date) { return; }
        $('#filter-calendar-container').datepicker('setDate', params.date); // Select specific date
      },
      clear: function() {
        $('#filter-calendar-container').datepicker("setDate", new Date()); // Clear calendar selections
      }
    },

    days: {
      init: function() {
        // Day selection
        $('a.filter-days-item').click(function() {
          var select = !$(this).hasClass('selected'),
              date = $(this).attr('data-date');
          filter.days.clear();
          if (select) {
            $(this).addClass('selected');
            // Update selected date
            // Set appropriate day on calendar
            var today = new Date();
            if ($(this).attr('data-date') == 'tomorrow') {
              var tomorrow = new Date(today.getFullYear(),
                today.getMonth(), today.getDate() + 1);
              $('#filter-calendar-container').datepicker("setDate", tomorrow);
            }
            else if ($(this).attr('data-date') == 'weekend') {
              var weekend = new Date(today.getFullYear(), today.getMonth(), today.getDate() + (6 - today.getDay()));
              $('#filter-calendar-container').datepicker("setDate", weekend);
            }
            else { $('#filter-calendar-container').datepicker("setDate", today); }
          }
          try {
            $(document).trigger('selected.date.entretenerse', select ? date : undefined);
          }
          catch(e) { console.error(e); }
          return false;
        });
      },
      update: function(params) {
        filter.days.clear();
        if (!params.date) { return; }
        var dateAttr = '[data-date=' + params.date + ']';
        $('a.filter-days-item' + dateAttr).addClass('selected');
      },
      clear: function() {
        $('a.filter-days-item').each(function(index, link) { $(link).removeClass('selected'); });
      }
    }
  };

  // Triggers 'expanded.filters.entretenerse' when filters expanded
  // Triggers 'collapsed.filters.entretenerse' when filters collapsed
  $.fn.filters = function(options) {
    if (typeof options == 'string') {
      if ($.inArray(options, ['update', 'collapse', 'expand', 'visible', 'clear', 'show']) == -1) {
        console.error('Method "' + options + '" not found on filters object');
        return;
      }
      filter[options].apply(filter, Array.prototype.slice.call(arguments, 1)); // Execute the allowed method
    }
    else if (!options || typeof options == 'object') {
      // Init the categories object
      var defaults = { };
      options = $.extend({}, defaults, options);

      // Init code
      filter.init();
    }
  };

})(jQuery);
