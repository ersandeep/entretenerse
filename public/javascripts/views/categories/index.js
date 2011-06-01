(function($) {
  function index() {

    var init = function() {

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
  if (!$.entr.views.categories) { $.entr.views.categories = {}; }
  $.entr.views.categories.index = new index();
})(jQuery);
