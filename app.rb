require 'webpay'

def log(msg)
  puts "====== #{msg} ======"
end

WebPay.api_key = 'test_secret_eHn4TTgsGguBcW764a2KA8Yd' # official test api_key

log("new charge")
charge = WebPay::Charge.create(
  amount: 400,
  currency: "jpy",
  card: {                       # dummy credit card info provided by official apidoc
    number: "4242-4242-4242-4242",
    exp_month: "11",
    exp_year: "2014",
    cvc: "123",
    name: "KEI KUBO"
  }
)
p charge

log("get charge")
charge_id = charge.id
charge = WebPay::Charge.retrieve(charge_id)
p charge

log("get charge: invalid id")
begin
  WebPay::Charge.retrieve('xxx')
rescue => e
  p e
end

log("refund charge")
new_charge = proc {
  WebPay::Charge.create(
    amount: 400,
    currency: "jpy",
    card: {
      number: "4242-4242-4242-4242",
      exp_month: "11",
      exp_year: "2014",
      cvc: "123",
      name: "KEI KUBO"
    }
  )
}

log("refund all amount")
begin
  charge = new_charge.call
  loop { p charge.refund }
rescue => e
  p e
end

log("refund part amount")
begin
  charge = new_charge.call
  loop { p charge.refund(amount: 100) }
rescue => e
  p e
end

log("refund amount lack")
begin
  charge = new_charge.call
  loop { p charge.refund(amount: 100 + rand(10).to_i) }
rescue => e
  p e
end

log("charge list")
p WebPay::Charge.all
p WebPay::Charge.all[:data].size

log("customer")
customer = WebPay::Customer.create(
  card: {                       # dummy credit card info provided by official apidoc
    number: "4242-4242-4242-4242",
    exp_month: "11",
    exp_year: "2014",
    cvc: "123",
    name: "KEI KUBO"
  },
  email: 'keikubo@example.com',
  description: 'my customer'
)
p customer

log("get customer")
customer_id = customer.id
p WebPay::Customer.retrieve(customer_id)

log("update customer")
customer.email = 'kyanny@example.com'
customer.save
p customer
p WebPay::Customer.retrieve(customer.id)

begin
  customer.card = { exp_month: '13' }
  customer.save
rescue => e
  p e
end

log("delete customer")
p customer.delete

begin
  p WebPay::Customer.retrieve(customer.id)
rescue => e
  p e
end

log("customer list")
p WebPay::Customer.all
p WebPay::Customer.all[:data].count

log("new token")
token = WebPay::Token.create(
  card: {                       # dummy credit card info provided by official apidoc
    number: "4242-4242-4242-4242",
    exp_month: "11",
    exp_year: "2014",
    cvc: "123",
    name: "KEI KUBO"
  }
)
p token

log("get token")
token_id = token.id
p WebPay::Token.retrieve(token_id)

log("create charge with token")
new_token = proc {
  WebPay::Token.create(
    card: {                       # dummy credit card info provided by official apidoc
      number: "4242-4242-4242-4242",
      exp_month: "11",
      exp_year: "2014",
      cvc: "123",
      name: "KEI KUBO"
    }
  )
}
token1 = new_token.call
charge = WebPay::Charge.create(
  amount: 400,
  currency: "jpy",
  card: token1.id,
)
p charge
p WebPay::Token.retrieve(token1.id)
begin
  charge = WebPay::Charge.create(
    amount: 400,
    currency: "jpy",
    card: token1.id,
  )
rescue => e
  p e
end

log("create customer with token")
token2 = new_token.call
customer = WebPay::Customer.create(
  card: token2.id,
  email: 'keikubo@example.com',
  description: 'my customer'
)
p customer
p WebPay::Token.retrieve(token2.id)
begin
  customer = WebPay::Customer.create(
    card: token2.id,
    email: 'keikubo@example.com',
    description: 'my customer'
  )
rescue => e
  p e
end

log("event")
log("get event list")
p WebPay::Event.all
p WebPay::Event.all[:data].size

log("get single event")
p WebPay::Event.retrieve(WebPay::Event.all[:data].sample.id)

log("get account")
p WebPay::Account.retrieve

log("delete_data")
p WebPay::Account.delete_data
p WebPay::Account.retrieve
