(function($) {
  function show() {
    var init = function() {
      // Title
      $('title').text($('#page_title').val());
      $('meta[name=description]').attr('content', $('#page_description').val());
      // Back link
      $('a#go_back').click(function() {
        var historyPoint = $.entr.history[$.entr.history.length - 2];
        if (historyPoint && historyPoint.url) {
          $.entr.navigate(historyPoint.url.pathname, historyPoint.url.query); // Go to root list
        }
        else {
          // The page's url inputed directly or referenced from external source
          $.entr.navigate('/', '');
        }
        return false;
      });
      // Rating
      var rating = $('form.edit_event');
      rating.find('input[type=submit]').hide();
      rating.stars({
        inputType: 'select',
        captionEl: $("#event_rating_label"),
        oneVoteOnly: true,
        callback: function(ui, type, value) {
          $('#event_rating_label').text('Thanks!');
          $.get('/event/rate/' + $('input[type=hidden]#event_id').val() + '?event[rating]=' + value, function(data) {
            $('#event_rating_label').text('Avg: ' + data.avg + ' (' + data.count + ')');
          });
        }
      });
    };

    var load = (function() {
      return function(url, data) {
        if (data) { $('#col2').html(data); }
        init();
      };
    })();

    return {
      load: load
    };
  }

  if (!$.entr) { $.entr = {}; }
  if (!$.entr.views) { $.entr.views = {}; }
  if (!$.entr.views.occurrences) { $.entr.views.occurrences = {}; }
  $.entr.views.occurrences.show = new show();
})(jQuery);
