# frozen_string_literal: true

require 'rake/testtask'
require 'rubocop/rake_task'

Dir.glob('tasks/**/*.rake').each do |task_file|
  load task_file
end

RuboCop::RakeTask.new

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.warning = false
end

task 'release:test' => :test
