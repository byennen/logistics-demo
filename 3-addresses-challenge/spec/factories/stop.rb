FactoryGirl.define do
  factory :origin, class: CloudLogistics::Load do
    feight
    address_line_1 '333 Las Ols Way'
    city 'Ft Lauderdale'
    state 'FL'
    zipcode '33301'
    country 'US'
    latitude ''
    longitude ''
    type CloudLogistics::Load
  end

  factory :stop, class: CloudLogistics::Stop do
    feight
    address_line_1 '222 Lakeviw Ave'
    city 'West Palm Beach'
    state 'FL'
    zipcode '33401'
    country ''
    latitude ''
    longitude ''
    type ''
  end

  factory :destination, class: CloudLogistics::Delivery do
    feight
    address_line_1 '545 Hibiscus St'
    city 'West Palm Beach'
    state 'FL'
    zipcode '33401'
    country ''
    latitude ''
    longitude ''
    type CloudLogistics::Delivery
  end
end
