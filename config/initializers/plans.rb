require 'plan'

Plan::MONTHLY = Plan.new(
  key: :monthly,
  name: 'Monthly Plan',
  plan_id: Rails.env.production? ? 'plan_DcPlEgFAqBYpnH' : 'plan_DcLKc40R2MpDkG',
  amount: 500,
  interval: 'month'
)
