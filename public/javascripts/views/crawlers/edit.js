(function($) {
  function edit() {

    var init = function() {
      $('#go').click(function() {
        $('#preview').attr('src', '/proxy?url=' + encodeURIComponent($('#address_line').val()));
      });
      $('#address_line').keyup(function(e) {
        if (e && (e.keyCode || e.which) == $.entr.keyboard.enter) {
          $('#go').click();
        }
      });

      $('.expression').watermark($('.expression').attr('title'));
      $('.expression').keyup(function(e) {
        var expression = $(this).val();
        var previewDocument = document.getElementById('preview').contentWindow.document;
        // Clear previous selection
        $('[data-selection=true]', previewDocument).css('border', 'none').removeAttr('data-selection');
        // Select new
        var selection = $(expression, previewDocument);
        selection.attr('data-selection', true);
        selection.css('border', 'solid 2px red');
      });
      $('#import_configuration').overlay({ close: '#import_dialog_close' });
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
  if (!$.entr.views.crawlers) { $.entr.views.crawlers = {}; }
  $.entr.views.crawlers.edit = new edit();
})(jQuery);
