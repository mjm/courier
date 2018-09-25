task :elm_test do
  sh 'elm-test'
end

# While I would like to run the Elm tests in Travis,
# right now they take a long time and stall the build.
#
# I don't feel like figuring that out right now.
#
# task default: :elm_test
