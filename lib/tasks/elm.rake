task :elm_test do
  sh 'elm-test'
end

task default: :elm_test
