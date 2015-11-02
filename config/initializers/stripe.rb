Stripe.api_key = ENV['STRIPE_SECRET_KEY']

StripeEvent.setup do
  subscribe 'charge.succeeded' do |event|
    user = User.find_by(customer_token: event.data.object.customer)
    Payment.create(reference_id: event.data.object.id, user: user, amount: event.data.object.amount)
  end

  subscribe 'charge.failed' do |event|
    user = User.find_by(customer_token: event.data.object.customer)
    user.deactivate!
  end
end
