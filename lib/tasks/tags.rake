module Tags
  RUBY_FILES = FileList['**/*.rb'].exclude("pkg")
end

desc "Rerun ctags on current project"
task :ctags do
  %x{ctags -R --exclude=.git --exclude=log *}
end

namespace "tags" do
  task :emacs => Tags::RUBY_FILES do
    puts "Making Emacs TAGS file"
    sh "ctags -e #{Tags::RUBY_FILES}", :verbose => false
  end
  task :cscope => Tags::RUBY_FILES do
    puts "Making Cscope TAGS file"
    sh "cscope -bq #{Tags::RUBY_FILES}", :verbose => false
  end
end

task :tags => ["tags:emacs", "tags:cscope"]
