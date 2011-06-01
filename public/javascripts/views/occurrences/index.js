(function($) {
  function index() {
    var initUrl,
        cache = [],
        occurrences_list_cashed;

    var Bar = function() {
      var barScrollable;
      this.init = function() {
        $('#carouselbarbox').scrollable({ keyword: false });
        var barScrollable = $('#carouselbarbox').data('scrollable');
        $('#carouselbarpaginatorbuttonforward').click(function() {
          // Scroll occurrences one page forward
          seekTo(visibleIndex('last') + 1);
          return false;
        });
        $('#carouselbarpaginatorbuttonbackward').click(function() {
          // Scroll occurrences one page backward
          var firstIndex = visibleIndex(),
              lastIndex = visibleIndex('last');
          seekTo(firstIndex - (lastIndex - firstIndex) - 1);
          return false;
        });
      };

      this.clear = function() {
        $('#carouselbarcontainer .carouselbarcolumn').remove();
      };

      this.addColumn = function(canvas) {
        var column = $('<div></div>').addClass('carouselbarcolumn');
        canvas.append(column);
        var index = canvas.children().length - 1;
        column.click(function() { seekTo(index); });
        // Check if column already visible
        if (visibleIndex() <= index && index < visibleIndex('last')) {
          column.addClass('carouselbarhighlightedcolumn');  // This is visible item
        }
        return column;
      };

      this.addEntry = function(entry, column) {
        var barEntry = $('<span></span>');
        $($('a.title', entry).attr('class').split(/\s+/)).each(function(i, value) {
          if (value != 'title') { barEntry.addClass(value); }
        });
        column.append(barEntry);
        // Tune up bar tooltip
        var tooltip = $('#carouselbar .tooltip'),
            timer = null;
        barEntry.hover(function() {
          if (timer) { clearTimeout(timer); timer = null; }
          var offset = $(this).offset();
          tooltip.html($('.bar_tooltip', entry).html());
          tooltip.fadeIn('fast');
          tooltip.offset({ top: offset.top - tooltip.outerHeight() - 5, left: offset.left });
        },
        function() {
          if (timer) { clearTimeout(timer); timer = null; }
          timer = setTimeout(function() {
            tooltip.fadeOut('slow');
          }, 1000);
        });
        return barEntry;
      };

      this.highlight = (function() {
        var firstHighlightedIndex= null,
            lastHighlihtedIndex = null;
        return function() {
          if (!scrollable()) { return; }
          var first = visibleIndex(),
              last = visibleIndex('last');
          if (first == firstHighlightedIndex && last == lastHighlightedIndex) {
            return;
          }
          firstHighlightedIndex = first;
          lastHighlightedIndex = last;

          var selector = '#carouselbarcontainer .carouselbarcolumn';
          $(selector).removeClass('carouselbarhighlightedcolumn');
          if (first > 0) {
            selector += ':gt(' + (first - 1) + ')'; // Because of 'greater then' selector, not 'greater or equal then'
          }
          selector += ':lt(' + (last - first + 1) + ')'; // Selector applyed to previously selected elements
          var highlighted = $(selector).addClass('carouselbarhighlightedcolumn');  // This is visible item
          if (highlighted.length > 0) {
            // Try to center this
            var firstHighlightedPoint = $(highlighted[0]).position().left,
                lastHighlighted = $(highlighted[highlighted.length - 1]),
                lastHighlightedPoint = lastHighlighted.position().left + lastHighlighted.outerWidth(),
                viewport = $('#carouselbarbox'),
                left = $('#carouselbarcontainer').position().left;

            if (lastHighlightedPoint + left > viewport.width()) {
              // Last highlighted item exceeded navigation bar
              left = (lastHighlightedPoint - viewport.width() + 20) * -1;
            }
            else if (firstHighlightedPoint + left < 0) {
              // First highlighted item hidden by navigation bar
              left = (firstHighlightedPoint - 20) * -1;
            }

            $('#carouselbarcontainer').animate({ 'left': left < 0 ? left : 0 }, 500);
          }
        };
      })();
    };

    var bar = new Bar();

    var scrollable = (function() {
      return function() {
        var _scrollable = $('.scrollable').data('scrollable');
        if (!_scrollable) {
          $('.scrollable').scrollable({
            keyboard: false,
            mousewheel: true,
            wheelSpeed: 1,
            speed: 400
          });
        }
        _scrollable = $('.scrollable').data('scrollable');
        return _scrollable;
      };
    })();

    var init = function() {
      $('#carousel-container').css('position', 'absolute');
      $('.scrollable').css('overflow', 'hidden');
      $('#view-button-prev-img, #view-button-next-img').css('position', 'absolute');
      scrollable();
      // Next button
      $('#view-button-next-img').click(function() {
        try { seekTo('next'); } catch (e) {console.error(e);}
        return false;
      });
      // Prev button
      $('#view-button-prev-img').click(function() {
        try { seekTo('prev'); } catch (e) {console.error(e);}
        return false;
      });
      bar.init();
    };

    var load = (function() {
      return function(url, data) {
        if (data) { $('#col2').html(data); }
        init();
        resize();
        showImages();
        initUrl = url;
      };
    })();

    // PreLoad the next page add apdate the view
    var nextPage = (function() {
      var nextPageLock = false,
          pageIsEmpty = false,
          lastParams = null;
      return function() {
        if (!initUrl) { return; }     // The view is not loaded yet
        if (nextPageLock) { return; } // Allow request if lock is not set
        if (!scrollable()) { return; }
        var params = $.param($.extend({}, initUrl.params, { 'offset': $('.entry').length, 'page': true }));
        if (pageIsEmpty && lastParams == params) { return; }
        // Request new page once carousel scrolled to particular position relative to its size
        if (visibleIndex('last') < scrollable().getSize() - 16) {
          return; // No need to request next page yet.
        }
        nextPageLock = true; // Setup the lock now
        lastParams = params;
        $.get('/?' + params, function(data) {
          if (data.trim().length === 0) { 
            pageIsEmpty = true;
            nextPageLock = false; // Release lock
            return; 
          }
          // Render the items outside visible borders first
          var canvas = $('<div></div>').css('position', 'absolute').css('top', '-100000px');
          $('body').append(canvas);
          canvas.append(data);
          showImages(canvas);
          addEntries($('.entry', canvas));
          canvas.remove();
          nextPageLock = false; // Release lock
        });
      };
    })();

    var highlightInterval,
        nextPageInterval;
    // The method should be called each 1 second
    var interval = (function() {
      highlightInterval = setInterval(function() {
        // TODO: decreace CPU usage by reducing DOM calls on interval methods
        bar.highlight(); // Highlight currently visible columns at first
      }, 1000);

      nextPageInterval = setInterval(function() {
        // Check if next page should be preloaded
        nextPage();
      }, 1000);
    })();

    // Get index of first visible column
    // returns index of last visible column if 'last' is specified.
    var visibleIndex = function(param) {
      if (param === 'last') {
        return parseInt(scrollable().getIndex() + $('#occurrences_container').width() / $('#occurrences_container .entrycol:first').outerWidth() - 1, 10);
      }
      return scrollable().getIndex();
    };

    // Seeks scrollable to the column with index specified.
    // 'next' of 'prev' will scroll to next or previous columns respectively
    var seekTo = function(index) {
      if (typeof index == 'string') {
        if ($('.scrollable').children().queue("fx").length < 2) {
          if (index == 'next') { index = visibleIndex() + 1; }
          else if (index == 'prev') { index = visibleIndex() - 1; }
          else { return false; }
        }
      }
      if (isFinite(index)) {
        if (index < 0) { index = 0; }
        scrollable().seekTo(index);
      }
    };

    var select = function(index) {
      if (typeof index == 'string') {
        var currentIndex = $('#carousel-container .entrycol')
          .index($('#carousel-container .entrycol.selected'));
        if (index === 'next') {
          index = currentIndex + 1;
        }
        else if (index === 'prev') {
          index = currentIndex - 1;
        }
        else { return; }
      }
      if (index < 0) { index = 0; }
      var columns = $('#carousel-container .entrycol'),
          columnsLen = columns.length;
      if (index >= columnsLen) { index = columnsLen - 1; }
      // Clear current selection
      columns.removeClass('selected');
      $('#carousel-container .entrycol:eq(' + index + ')').addClass('selected');
      var firstIndex = visibleIndex(),
          lastIndex = visibleIndex('last'),
          scrollIndex;
      if (index < firstIndex) { scrollIndex = index - (lastIndex - firstIndex); }
      else if (index > lastIndex) { scrollIndex = index; }
      if (isFinite(scrollIndex)) { seekTo(scrollIndex); }
    };

    var addColumn = function(canvas) {
      var column = $('<li></li>').addClass('entrycol');
      canvas.append(column);
      column.click(function () {
        select($('#carousel-container .entrycol').index($(this)));
      });
      return column;
    };

    var addEntry = function(entry, column) {
      entry = $(entry).clone();
      column.append(entry);
      $('.title', entry).each(function(index, link) {
        $.ajaxify($(link));
      });
    };

    var addEntries = function(entries, canvas, barCanvas) {
      if (!canvas) { canvas = $('#carousel-container'); }
      if (!barCanvas) { barCanvas = $('#carouselbarcontainer'); }
      var column = $('.entrycol:last', canvas),
          innerHeight = 0,
          columnHeight = $('#occurrences_container').height() - $('#carouselbar').outerHeight(true) - 40,
          barColumn = $('.carouselbarcolumn:last', barCanvas);
      if (column.length === 0) { column = null; }
      else {
        column.find('.entry').each(function(index, entry) {
          innerHeight += $(entry).outerHeight(true);
        });
      }
      entries.each(function(index, entry) {
        var entryHeight = $(entry).outerHeight(true);
        if (column === null || (innerHeight + entryHeight) > columnHeight) {
          // add new column to the canvas
          column = addColumn(canvas);
          column.height(columnHeight);
          innerHeight = 0;
          barColumn = bar.addColumn(barCanvas);
        }
        // Fill the entry in the column
        addEntry(entry, column);
        bar.addEntry(entry, barColumn);
        innerHeight += entryHeight;
      });
      // Update width
      canvas.css('width', (canvas.children().length * ($('.entrycol:first').outerWidth(true) || 190)) + 'px');
    };

    // Refow occurrences according to the new size of the canvas
    // Or according to the new content of the canvas
    // sourceCanvas is current canvas if undefined or the new one.
    var reflow = function(sourceCanvas) {
      var currentCanvas = $('#carousel-container'),
          newCanvas = $('<ul></ul>'),
          currentBarCanvas = $('#carouselbarcontainer'),
          newBarCanvas = $('<div></div>');
      // Init source canvase with default value if not set
      sourceCanvas = sourceCanvas || currentCanvas;
      bar.clear();
      addEntries($('.entry', sourceCanvas), newCanvas, currentBarCanvas);
      newBarCanvas.attr('id', currentBarCanvas.attr('id'));
      newBarCanvas.attr('style', currentBarCanvas.attr('style'));
      // Swap children
      currentCanvas.children().remove();
      currentCanvas.append(newCanvas.children());
      currentCanvas.css('width', newCanvas.css('width')); // Copy updated width
    };

    var resize = function() {
      // Height only should be adapted
      // Width is simply 100%
      var newHeight = $('#col2').height() - $('#occurrences_title').outerHeight(true);
      if (newHeight != $('#occurrences_container').height()) {
        $('#occurrences_container').height(newHeight);
        reflow();
      }
    };

    // Call this on keydown to catch up the keyboard events the view is interested in
    var keydown = function(key) {
      var index = null;
      switch(key) {
        case $.entr.keyboard.arrows.right:
          select('next');
          return false;
        case $.entr.keyboard.arrows.left:
          select('prev');
          return false;
      }
    };

    // Images on the view are not loaded by default if JavaScript is enabled
    // They should be preloaded manually and after all scripts finished running
    // This makes page load more smooth
    var showImages = function(canvas) {
      var attributes = ['src', 'alt', 'width', 'height'];
      $('.image', canvas).each(function(i, image_div) {
        var image = $('<img></img>'),
            container = $(image_div);
        for (var index = 0; index < attributes.length; index++) {
          var attribute = attributes[index];
          image.attr(attribute, container.attr('data-' + attribute));
        }
        container.append(image);
      });
    };

    return {
      load: load,
      keydown: keydown,
      resize: resize
    };
  }
  if (!$.entr) { $.entr = {}; }
  if (!$.entr.views) { $.entr.views = {}; }
  if (!$.entr.views.occurrences) { $.entr.views.occurrences = {}; }
  $.entr.views.occurrences.index = new index();
})(jQuery);
