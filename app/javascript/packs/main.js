import 'csrf-xhr'
import 'style/application.scss'
import Elm from '../Page/Posts/Main'
import { getCableUrl } from '../cable'

document.addEventListener('DOMContentLoaded', () => {
  const target = document.getElementById('elm-container')
  const flags = Object.assign({}, window.elmFlags, { cableUrl: getCableUrl() })
  Elm.Page.Posts.Main.embed(target, flags)
})
