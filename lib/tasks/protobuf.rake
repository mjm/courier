task :proto do
  include_paths = Dir[Rails.root / '..' / 'courier-*' / 'client' / 'lib']
  sh "protoc --ruby_out=. --twirp_ruby_out=. -I. #{include_paths.map { |path| "-I#{path}/" }.join(' ')} app/service/*.proto"
end
