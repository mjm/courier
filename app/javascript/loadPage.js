import 'csrf-xhr'
import 'style/application.scss'
import { listen } from 'cable'

export default function (page) {
  document.addEventListener('DOMContentLoaded', () => {
    const environment = document.body.dataset.env
    const flags = Object.assign({ environment }, window.elmFlags)
    const app = page.Main.init({ flags })

    listen(app.ports)
  })
}

