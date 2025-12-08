# frozen_string_literal: true

require "rdoc/task"

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = "doc"
  rdoc.title = "Accessibility Map API Documentation"
  rdoc.options << "--all"
  rdoc.rdoc_files.include("app/**/*.rb")
  rdoc.rdoc_files.include("lib/**/*.rb")
  rdoc.rdoc_files.exclude("app/models/concerns/**")
  rdoc.rdoc_files.exclude("app/controllers/concerns/**")
end
