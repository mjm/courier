task :proto do
  sh 'protoc --ruby_out=app/messages --twirp_ruby_out=app/messages -Iproto proto/*.proto'
end
