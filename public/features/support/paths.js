// Paths may be a string of function. When a function is supplied, it's
// arguments will be the matches from the regexp's.
ramble.addPath(/the homepage/, '/');
ramble.addPath(/(.+) page/, function(word) { return '/' + word; });

