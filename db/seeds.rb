# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Alert.create(
  uuid: 'uuid1',
  title: 'Tornado Warning',
  location: 'Kansas',
  message: 'Grab Toto and run!',
  publish_at: '1900-05-17 09:00:00-0600'
)

Alert.create(
  uuid: 'uuid2',
  title: 'Land Shark',
  location: 'NYC',
  message: 'Delivery. Singing telegram. Land shark!',
  publish_at: '1988-09-01 23:30:00-0500'
)

Recipient.create(
  channel: 'SMS',
  address: '2064122526'
)

Source.create(
  channel: 'NWS CAP Atom Feed',
  address: 'https://alerts.weather.gov/cap/us.php?x=0'
)
