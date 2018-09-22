import 'csrf-xhr'
import 'style/application.scss'
import Elm from '../Page/Feeds/Main'
import { getCableUrl } from '../cable'

document.addEventListener('DOMContentLoaded', () => {
  const target = document.getElementById('elm-container')
  const flags = Object.assign({}, window.elmFlags, { cableUrl: getCableUrl() })
  Elm.Page.Feeds.Main.embed(target, flags)
})
