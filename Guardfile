# A sample Guardfile
# More info at https://github.com/guard/guard#readme

require 'guard/minitest'

unless Minitest::Runner.private_instance_methods.include?(:ruby_command_without_include)
  class Minitest::Runner
    alias :ruby_command_without_include :ruby_command

    def ruby_command(paths)
      command = ruby_command_without_include(paths)
      include_folders = @options[:include]
      command[1...1] = include_folders.map{|f| %Q[-I"#{f}"] } 
      command
    end
  end
end

guard :minitest, include: %w(. app app/presenters lib test), test_folders: %w(test/micro) do
  watch(%r{^test/micro.*\.rb})
  watch(%r{^test/fast_test_helper\.rb}) { "test/micro" }
  watch(%r{^app/presenters/(.*)\.rb}) { |m| "test/micro/presenters/#{m[1]}_test.rb" }
  watch(%r{^app/validators/(.*)\.rb}) { |m| "test/micro/validators/#{m[1]}_test.rb" }
  watch(%r{^app/commands/(.*)\.rb}) { |m| "test/micro/commands/#{m[1]}_test.rb" }
  watch(%r{^lib/(.*)\.rb}) { |m| "test/micro/#{m[1]}_test.rb" }
end

guard :minitest, zeus: true, include: %w(. app app/presenters lib test), 
  test_folders: %w(test/unit test/functional test/integration) do
  watch(%r{^test/test_helper\.rb}) { ['test/unit', 'test/functional', 'test/integration'] }
  watch(%r{^test/.+_test\.rb})
  watch(%r{^app/controllers/(.*)\.rb}) { |m| "test/functional/#{m[1]}_test.rb" }
  watch(%r{^app/models/(.*)\.rb}) { |m| "test/unit/#{m[1]}_test.rb" }
  watch(%r{^app/use_cases/(.*)\.rb}) { |m| "test/unit/use_cases/#{m[1]}_test.rb" }
  watch(%r{^app/validators/(.*)\.rb}) { |m| "test/unit/validators/#{m[1]}_test.rb" }
  watch(%r{^app/helpers/(.*)\.rb}) { |m| "test/unit/helpers/#{m[1]}_test.rb" }
  watch(%r{^app/finders/(.*)\.rb}) { |m| "test/unit/finders/#{m[1]}_test.rb" }
  watch(%r{^lib/(.*)\.rb}) { |m| "test/unit/lib/#{m[1]}_test.rb" }
  watch(%r{^app/processors/(.*)\.rb}) { |m| "test/unit/processors/#{m[1]}_test.rb" }
end

guard 'ctags-bundler', :src_path => ["app", "lib", "test"] do
  watch(/^(app|lib|test)\/.*\.rb$/)
  watch('Gemfile.lock')
end
