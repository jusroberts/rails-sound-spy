#!/usr/bin/env ruby

require 'rubygems'
require 'wav-file'
require 'alsa'

#return true if less than time interval
def recent_detection (last_detection, current_detection)
  interval = 8000
  if last_detection.nil?
    return false
  end
  return (current_detection < last_detection + interval)
end

def get_value(rawSound, index)
  return (rawSound.data[index].unpack('H*')[0].to_i(16) + (rawSound.data[index + 1].unpack('H*')[0].to_i(16) << 16)).to_f
end




#f = open("pong_test.wav")
#format = WavFile::readFormat(f)
#rawSound = WavFile::readDataChunk(f)
#f.close
#
#puts format
#
#puts
#
#last_detection = nil
#for index in 0..((rawSound.data.length - 1) / 2)
#  if ((rawSound.data[index * 2 + 1].unpack('H*')[0].to_i(16) >> 4) > 0)
#    unless recent_detection(last_detection, index * 2)
#      minutes = (index / (60 * 44100)).to_i
#      seconds = ((index.to_f / 44100.0) - (minutes * 60))
#      puts "#{minutes}:#{seconds.round(3)}"
#      last_detection = index * 2
#    end
#  end
#end
ALSA::PCM::Capture.open do |capture|
  capture.read do |buffer, frame_count|
    $stdout.write buffer
  end
end

