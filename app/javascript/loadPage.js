import 'csrf-xhr'
import 'style/application.scss'
import { listen } from 'cable'

export default function (page) {
  document.addEventListener('DOMContentLoaded', () => {
    const node = document.getElementById('elm-container')
    const flags = Object.assign({}, window.elmFlags)
    const app = page.Main.init({ node, flags })

    listen(app.ports)
  })
}

