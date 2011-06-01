(function($) {
$(document).ready(function() {
  // Munk 'entr' namespace
  if (!$.entr) { $.entr = {}; }

  // Constants
  $.entr.keyboard = { arrows: { left: 37, up: 38, right: 39, down: 40 }, enter: 13 };

  // Munk console
  if (typeof console == 'undefined') {
    console = {
      log: function() {},
      error: function() {}
    };
  }
  console.trace = function(mes) { console.log(mes); };

  // Few semiglobal vatiables used through the application
  $.entr.navigate = function(path, query) {
    if (!path)  { path = '/'; }
    if (!query) { query = ''; }
    var url = path + '?' + query;
    window.location.hash = url;
  };
  $.entr.filter = { values: {} };

  // Init global event handlers (views should not subscribe to global events directly)
  $(window).keydown(function(e) {
    var key = e.keyCode || e.which,
        result = true;

    // Update layout if interested
    if ($.entr.views.layout && $.entr.views.layout.keydown) {
      result = $.entr.views.layout.keydown(key);
    }
    // Update current view if interested
    if ($.entr.views.current && $.entr.views.current.keydown) {
      result = result && $.entr.views.current.keydown(key);
    }
    return result;
  });

  var resizeTimeout;
  $(window).resize(function() {
    if (resizeTimeout) { clearTimeout(resizeTimeout); } // Clear previous timeout if still valid
    resizeTimeout = setTimeout(function() {
      if ($.entr.views.layout && $.entr.views.layout.resize) {
        $.entr.views.layout.resize();
      }
      if ($.entr.views.current && $.entr.views.current.resize) {
        $.entr.views.current.resize();
      }
    }, 100);
  }).resize();

  $.entr.viewOccurrences = function() { return $('#occurrences_container').length > 0; };

  $.entr.views.layout.filters.show();
  $.entr.filter.visible = true;
  $.entr.history = [];

  var routes = {
    "^\\/e\/\\S+": $.entr.views.occurrences.show,
    "^\/?$": $.entr.views.occurrences.index,
    "^\/admin$": $.entr.views.admin.index,
    "^\/crawlers$": $.entr.views.crawlers.index,
    "^/crawlers/[1-9]+/edit$": $.entr.views.crawlers.edit,
    "^/crawlers/\\d+": $.entr.views.crawlers.show,
    "^\/categories$": $.entr.views.categories.index
  };
  var matchRoute = function(path) {
    for (var key in routes) {
      if ((new RegExp(key, 'gi')).test(path)) {
        return routes[key];
      }
    }
    return false;
  };

  var checkHistory = function(url) {
    var historyLen = $.entr.history.length;
    for (var i = historyLen - 1; i >= 0; i--) {
      var historyPoint = $.entr.history[i];
      if (historyPoint && historyPoint.url && url.newHref == historyPoint.url.newHref) {
        // History point found
        return historyPoint;
      }
    }
  };

  var setTitle = function() {
    // Setup title and page description
    $('title').text($('#page_title').val());
    $('meta[name=description]').attr('content', $('#page_description').val());
  };

  var firstCall = true;
  var loadView = function(url, view) {
    if (!view) { return false; }
    $.entr.views.current = view;
    if (firstCall) {
      if ($.entr.views.current.load) {
        $.entr.views.current.load($.extend({}, url));
      }
      firstCall = false;
      return true;
    }
    // Check history if it already has the content required
    var historyPoint = checkHistory(url);
    // Create new entry in history
    $.entr.history.push({ 'url': url });
    if (historyPoint && historyPoint.content) {
      $('#col2').html(historyPoint.content);
      setTitle();
      return true;
    }
    // Get the data view is waiting for
    // But show the progress bar first
    $.entr.views.layout.progressBar.show();
    $.get(url.newHref, function(data) {
      if ($.entr.views.current.load) {
        $.entr.views.current.load($.extend({}, url), data);
      }
      setTitle();
      // Hide progress bar finally
      $.entr.views.layout.progressBar.hide();
    });
    return view;
  };

  var unloadView = function(url, view) {
    if (!view) { return; }
    // Find history point appropriate to the view
    // And save content there for later use
    var historyPoint = $.entr.history[$.entr.history.length - 1];
    if (historyPoint) {
      historyPoint.content = $('#col2').children().detach();
    }
  };

  var router = (function(hash) {
    return function(hash) {
      var url = $.unhash(window.location);
      var view = matchRoute(url.pathname);
      console.log('view: ');
      console.log(view);
      if (!view) { return false; }
      // Update layout first
      $.entr.views.layout.load($.extend({}, url));
      // Unload the current view if it needed
      unloadView(url, view);
      // load the view specified in the value
      loadView(url, view);
      return true;
    };
  })();
  $.history.init(router, { unescape: ",/" });

});
})(jQuery);
