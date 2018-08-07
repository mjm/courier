import 'csrf-xhr'
import 'style/application.scss'
import Elm from '../Page/Feeds'

document.addEventListener('DOMContentLoaded', () => {
  const target = document.getElementById('elm-container')
  Elm.Page.Feeds.embed(target)
})
