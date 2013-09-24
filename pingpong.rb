#!/usr/bin/env ruby

require 'rubygems'
require 'wav-file'

#return true if less than time interval
def recent_detection (last_detection, current_detection)
  interval = 3000
  if last_detection.nil?
    return false
  end
  return (current_detection < last_detection + interval)
end

def get_value(rawSound, index)
  return (rawSound[index].unpack('H*')[0].to_i(8) + (rawSound[index + 1].unpack('H*')[0].to_i(8) << 8)).to_f
end

def record_audio
  return system('arecord -d 3 -f S16_LE -D plug:default out.wav')
end

def load_audio
  f =  open("out.wav")
  format = WavFile::readFormat(f)
  data = WavFile::readDataChunk(f).data
  f.close

  return data
end

def delete_old_file
  return system("rm out.wav")
end

def detect_pings(rawSound)
  last_detection = nil
  for index in 0..((rawSound.length - 1) / 2)
    if ((rawSound[index * 2 + 1].unpack('H*')[0].to_i(8) >> 4) > 0)
      unless recent_detection(last_detection, index * 2)
        minutes = (index / (60 * 8000)).to_i
        seconds = ((index.to_f / 8000.0) - (minutes * 60))
        puts "#{minutes}:#{seconds.round(3)} :::: #{get_value(rawSound,index * 2)} :: #{Time.now}"
        last_detection = index * 2
      end
    end
  end
end

def main_loop
  record_audio
  rawSound = load_audio
  delete_old_file
  detect_pings(rawSound)
end

while true
  main_loop
end


