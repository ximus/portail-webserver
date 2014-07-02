require 'daybreak'


db = Daybreak::DB.new('test.db')

db['foo'] = {:a => {ba: 1}}

db.flush

puts db['foo']

db['foo'][:a][:ba] = 2

puts db['foo']

db.flush

puts db['foo']


db.close

db = Daybreak::DB.new('test.db')

puts db['foo']