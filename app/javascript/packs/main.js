import 'csrf-xhr'
import 'style/application.scss'
import Elm from '../Main'

document.addEventListener('DOMContentLoaded', () => {
  const target = document.getElementById('elm-container')
  Elm.Main.embed(target)
})
