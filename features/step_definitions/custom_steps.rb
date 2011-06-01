Given /^the occurrence has that attribute$/ do
  occurrence = model("the occurrence")
  occurrence.labels << model("that attribute")
  occurrence.save

end

