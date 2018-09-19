require 'plan'

Plan::MONTHLY = Plan.new(
  key: :monthly,
  name: 'Monthly Plan',
  plan_id: STRIPE_ENV == :production ? 'plan_DcPlEgFAqBYpnH' : 'plan_DcLKc40R2MpDkG',
  amount: 500,
  interval: 'month'
)
