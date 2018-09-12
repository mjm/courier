import cable from "actioncable"

export function getCableUrl() {
  let url = cable.getConfig('url')
  return cable.createWebSocketURL(url)
}
