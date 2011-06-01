// Matchers should throw an error when they get an unexpected result.

ramble.match(/^I follow "(.+)"$/, function(linkText) {
  this.clickLink(linkText);
});

ramble.match(/^I press "(.+)"$/, function(buttonText) {
  this.clickButton(buttonText);
});

ramble.match(/^I fill in "(.+)" with "(.+)"$/, function(labelText, value) {
  this.fillIn(labelText, value);
});

ramble.match(/^I should see "(.+)"$/, function(string) {
  console.log('see');
  this.assertHasContent(string);
});

ramble.match(/^I am on (.+)$/, function(pathName) {
  this.visit(ramble.pathTo(pathName));
});

ramble.match(/^I should be on (.+)$/, function(pageName) {
  this.assertCurrentPath(ramble.pathTo(pageName));
});

ramble.match(/^I make the heading "(.+)"$/, function(color) {
  this.find('h1').css('color', color);
});

ramble.match(/^I should eventually see "(.+)"$/, function(string) {
  var ms = 5000;
  ramble.retryOnFailWithinMilliseconds = ms;
  this.assertHasContent(string);
});
