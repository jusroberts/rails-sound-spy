
require 'rubygems'
require 'sqlite3'

def write_to_db
  begin

    db = SQLite3::Database.open "db/development.sqlite3"
    db.execute "INSERT INTO histories(number_of_hits) VALUES (0)"

  rescue SQLite3::Exception => e

    puts "Exception occured"
    puts e

  ensure
    db.close if db
  end
end


for i in 0..(9 * 60 / 5)
  write_to_db
end



begin

  db = SQLite3::Database.open "db/development.sqlite3"
  db.execute "INSERT INTO days(date) VALUES (date('now'))"

rescue SQLite3::Exception => e

  puts "Exception occured"
  puts e

ensure
  db.close if db
end