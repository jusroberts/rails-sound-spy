#!/home/pi/.rvm/rubies/ruby-1.9.3-p194/bin/ruby

require 'rubygems'
require 'wav-file'
require 'sqlite3'

#return true if less than time interval
#def recent_detection (last_detection, current_detection)
#  interval = 3000
#  if last_detection.nil?
#    return false
#  end
#  return (current_detection < last_detection + interval)
#end

def get_value(rawSound, index)
  return (rawSound[index].unpack('H*')[0].to_i(8) + (rawSound[index + 1].unpack('H*')[0].to_i(8) << 8)).to_f
end

def record_audio
  `arecord -d 3 -f S16_LE -D plug:default /rss/out.wav`
end

def load_audio
  if File.exists?('/rss/out.wav')
    f =  open('/rss/out.wav')
    format = WavFile::readFormat(f)
    data = WavFile::readDataChunk(f).data
    f.close

    return data
  end
end

def delete_old_file
  return system('rm /rss/out.wav') if File.exists?('/rss/out.wav')
end

def write_to_db

  db_name = "/www/rails-sound-spy/db/production.sqlite3"

  #Record Ping
  begin

    db = SQLite3::Database.open db_name
    db.execute "INSERT INTO pings(time) VALUES (datetime('now'))"

  rescue SQLite3::Exception => e

    system("echo Pings error >> /rss/log")
    system("echo #{e}>> /rss/log")
    puts "Exception occured"
    puts e

  ensure
    db.close if db
  end


  #Record History
  begin

    rawTime = Time.now - Date.now.to_time
    startTime = startTime = 9 * 60 * 60

    index = (rawTime / (60 * 5)).to_int - (startTime / (60 * 5))

    db = SQLite3::Database.open db_name

    system("echo #{index} >> /rss/log")

    number_of_hits = db.execute "SELECT number_of_hits FROM histories WHERE time='#{index}'"

    system("echo number of hits: #{number_of_hits} >> /rss/log")

    if number_of_hits.nil?
      db.execute "INSERT INTO histories (number_of_hits, time) VALUES (1,#{index})"
    else
      db.execute "UPDATE histories SET number_of_hits='#{number_of_hits.to_i + 1}' WHERE time='#{index}'"
    end

  rescue SQLite3::Exception => e

    system("echo History error >> /rss/log")
    system("echo #{e}>> /rss/log")
    puts "Exception occured"
    puts e

  ensure
    db.close if db
  end

  #Days
  begin
    db = SQLite3::Database.open db_name

    if db.execute('SELECT count(*) from days').to_i == 0
      db.execute "INSERT INTO days(date) VALUES (date('now'))"

    else
      unless db.execute('SELECT date FROM days WHERE id = (SELECT MAX(ID) FROM TABLE)').to_time == Date.today.to_time
        db.execute "INSERT INTO days(date) VALUES (date('now'))"
      end
    end

  rescue SQLite3::Exception => e

    system("echo Days error >> /rss/log")
    system("echo #{e}>> /rss/log")
    puts "Exception occured"
    puts e

  ensure
    db.close if db
  end


end

def detect_pings(rawSound)
  for index in 0..((rawSound.length - 1) / 2)
    if (get_value(rawSound, index * 2) > 4000)
        puts "#{Time.now} Ping Detected :: Amplitude: #{get_value(rawSound,index * 2)}"
        system("echo #{Time.now} :: Amplitude: #{get_value(rawSound,index * 2)} >> /rss/log")
        #Add DB call here
        write_to_db
        return
    end
  end
end


def main_loop
  record_audio
  rawSound = load_audio
  delete_old_file
  detect_pings(rawSound) unless rawSound.nil?
end

#Create Log file if none
system('touch /rss/log')

# RUN
while true
  main_loop
end


