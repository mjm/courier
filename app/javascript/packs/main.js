import 'csrf-xhr'
import 'style/application.scss'
import Elm from '../Page/Posts/Main'

document.addEventListener('DOMContentLoaded', () => {
  const target = document.getElementById('elm-container')
  Elm.Page.Posts.Main.embed(target, window.elmFlags)
})
