// Run this example by adding <%= javascript_pack_tag "hello_elm" %> to the
// head of your layout file, like app/views/layouts/application.html.erb.
// It will render "Hello Elm!" within the page.

import 'csrf-xhr'
import 'style/application.scss'
import Elm from '../Main'

document.addEventListener('DOMContentLoaded', () => {
  const target = document.getElementById('elm-container')
  Elm.Main.embed(target)
})
