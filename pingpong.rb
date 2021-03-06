#!/home/pi/.rvm/rubies/ruby-1.9.3-p194/bin/ruby


require 'rubygems'
require 'wav-file'
require 'sqlite3'
require 'spectrum-analyzer'


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




end

def detect_pings(rawSound)
  amplitude_threshold = get_amplitude_threshold

  for index in 0..((rawSound.length - 1) / 2)
    if (get_value(rawSound, index * 2) > amplitude_threshold)
      if (SpectrumAnalyzer.quick_analyze)
        puts "#{Time.now} Ping Detected :: Amplitude: #{get_value(rawSound,index * 2)}"
        system("echo #{Time.now} :: Amplitude: #{get_value(rawSound,index * 2)} >> /rss/log")
        #Write it to the DB!
        write_to_db
      end

        return
    end
  end
end


def main_loop
  record_audio
  rawSound = load_audio
  detect_pings(rawSound) unless rawSound.nil?
  delete_old_file
end

def get_amplitude_threshold
  amplitude_threshold = 7000
  set_configuration
  begin
    file = File.new '/www/rails-sound-spy/sensitivity.var', 'r'
  rescue
    #File doesn't exist.
  end

  unless file.nil?
    while (line = file.gets)
      begin
        amplitude_threshold = line.to_i
      rescue
        #We don't have a number in here.
      end
    end

    file.close
  end

  amplitude_threshold
end

def set_configuration
  conf = load_configuration
  unless conf == {}
    SpectrumAnalyzer.configuration.window_size     = conf[:window_size]     unless conf[:window_size].blank?
    SpectrumAnalyzer.configuration.window_function = conf[:window_function] unless conf[:window_function].blank?
    SpectrumAnalyzer.configuration.analysis_range  = conf[:analysis_range]  unless conf[:analysis_range].blank?
    SpectrumAnalyzer.configuration.file_name       = conf[:file_name]       unless conf[:file_name].blank?
  end
end

def load_configuration
  begin
    return YAML.load_file('/rss/ping.yml')
  rescue
    return {}
  end
end

#Create Log file if none
system('touch /rss/log')

SpectrumAnalyzer.configuration(load_configuration)

# RUN
while true
  main_loop
end


