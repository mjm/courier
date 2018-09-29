import 'csrf-xhr'
import 'style/application.scss'
import { getCableUrl } from 'cable'

export default function (page) {
  document.addEventListener('DOMContentLoaded', () => {
    const target = document.getElementById('elm-container')
    const flags = Object.assign({}, window.elmFlags, { cableUrl: getCableUrl() })
    page.Main.embed(target, flags)
  })
}

