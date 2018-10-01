import cable from "actioncable"

export function listen(ports) {
  const consumer = cable.createConsumer()
  
  consumer.subscriptions.create({ channel: "EventsChannel" }, {
    received(data) {
      ports.events.send(data)
    }
  })
}
