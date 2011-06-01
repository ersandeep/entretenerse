When /^(?:|I )follow "([^"]*)"(?: within "([^"]*)")? translated$/ do |link, selector|
  with_scope(selector) do
    click_link(I18n.t link)
  end
end

Then /^(?:|I )should see "([^"]*)"(?: within "([^"]*)")? translated$/ do |text, selector|
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_content(I18n.t text)
    else
      assert page.has_content?(I18n.t text)
    end
  end
end

Then /^(?:|I )should see button "([^"]*)"(?: within "([^"]*)")? translated$/ do |text, selector|
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_button(I18n.t text)
    else
      assert page.has_button?(I18n.t text)
    end
  end
end
