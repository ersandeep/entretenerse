(function($) {
  String.prototype.startsWith = function(str) 
  {
    return (this.match("^"+str)==str);
  };
  String.prototype.endsWith = function(str) 
  {
    return (this.match(str+"$")==str);
  };

  // make a link workin via ajax routing
  jQuery.ajaxify = function(link) {
    var href = link.attr('href');
    if (href && href.indexOf('#') == -1) {
      // Pathname is required because of the issues in iframes
      link.attr('href', location.pathname + '#' + link.attr('href'));
    }
  };

  // Translates location hash into path and query parameters used in the application
  jQuery.unhash = function(location) {
    var url = $.extend({}, location),
        hash = url.hash.indexOf('#') === 0 ? url.hash.slice(1) : url.hash,
        index = hash.indexOf('?');
      // RegExp should be tested against path specified in location hash or the location path itself
      if (index == -1) { // There is no division with question mark
        if (hash[0] == '/') {
          // Entire hash is path
          url.pathname = hash;
        }
        else {
          // Entire hash is params
          url.query = hash;
        }
      }
      else {
        // Path and query devided with question mark
        url.pathname = hash.slice(0, index);
        url.query = hash.slice(index + 1);
      }
      url.hash = hash;
      url.params = $.unparam(url.query);
      url.newHref = url.pathname + '?' + url.query;
      return url;
  };

  jQuery.unparam = function (value) {
    if (!value) { return {}; }
    var
    // Object that holds names => values.
    params = {},
    // Get query string pieces (separated by &)
    pieces = value.split('&'),
    // Temporary variables used in loop.
    pair, i, l;
    // Loop through query string pieces and assign params.
    for (i = 0, l = pieces.length; i < l; i++) {
        pair = pieces[i].split('=', 2);
        // Repeated parameters with the same name are overwritten. Parameters
        // with no value get set to boolean true.
        params[decodeURIComponent(pair[0])] = (pair.length == 2 ?
            decodeURIComponent(pair[1].replace(/\+/g, ' ')) : true);
    }
    return params;
  };
})(jQuery);
