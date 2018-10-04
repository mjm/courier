import loadPage from '../loadPage'
import { Elm } from '../Page/Account/Main'

loadPage(Elm.Page.Account, app => {
  const handler = StripeCheckout.configure({
    key: window.elmFlags.stripeKey,
    locale: 'auto',
    zipCode: true,
    token(token) {
      app.ports.createSubscription.send(token)
    }
  })
  app.ports.openPaymentForm.subscribe(() => {
    handler.open({
      name: 'Courier',
      description: 'Monthly autoposting subscription',
      amount: 500
    })
  })
})
