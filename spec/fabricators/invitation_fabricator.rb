Fabricator :invitation do
  recipient_name { Faker::Name.name }
  recipient_email { Faker::Internet.email }
  message { Faker::Lorem.words(5).join(' ') }
end
