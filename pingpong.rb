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
  return system('arecord -d 3 -f S16_LE -D plug:default out.wav')
end

def load_audio
  f =  open('out.wav')
  format = WavFile::readFormat(f)
  data = WavFile::readDataChunk(f).data
  f.close

  return data
end

def delete_old_file
  return system('rm out.wav')
end

def write_to_db
  begin

    db = SQLite3::Database.open "db/production.sqlite3"
    db.execute "INSERT INTO pings(time) VALUES (datetime('now'))"

  rescue SQLite3::Exception => e

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
        system("echo #{Time.now} :: Amplitude: #{get_value(rawSound,index * 2)} >> ~/log/pings")
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
  detect_pings(rawSound)
end

#Create Log file if none
system('mkdir ~/log')
system('touch ~/log/pings')

# RUN
while true
  main_loop
end


