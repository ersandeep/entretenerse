(function($) {
  function index() {
    var init = function() {
      //$('#admin_index #links a').each(function(index, link) {
        //$.ajaxify($(link));
      //});
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
  if (!$.entr.views.admin) { $.entr.views.admin = {}; }
  $.entr.views.admin.index = new index();
})(jQuery);
