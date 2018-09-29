require 'simplecov'
SimpleCov.start do
  # Don't get coverage on the test cases themselves.
  add_filter '/spec/'
  add_filter '/test/'
  # Codecov doesn't automatically ignore vendored files.
  add_filter '/vendor/'
end

if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end
