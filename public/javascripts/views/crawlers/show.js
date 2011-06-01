(function($) {
  function show() {

    var load = function() {
      $('#crawlers_history');
      $('#view_config, [data-config=true], [data-pull=true], [data-push=true]').overlay({
        onBeforeLoad: function() {
          var wrapper = this.getOverlay().find("#config_content");
          wrapper.load(this.getTrigger().attr("href"));
        },
        close: '#close_config'
      });
      $('#col2').css('overflow', 'scroll');
    };

    return {
      load: load
    };
  }

  if (!$.entr) { $.entr = {}; }
  if (!$.entr.views) { $.entr.views = {}; }
  if (!$.entr.views.crawlers) { $.entr.views.crawlers = {}; }
  $.entr.views.crawlers.show = new show();
})(jQuery);
