task :proto do
  sh %w[
    protoc
    --ruby_out=app/messages
    --twirp_ruby_out=app/messages
    -Iproto
    proto/*.proto
  ].join ' '
end
