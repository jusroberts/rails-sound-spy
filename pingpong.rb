#!/usr/bin/env ruby

require 'rubygems'
require 'wav-file'


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




f = open("pong_test.wav")
format = WavFile::readFormat(f)
rawSound = WavFile::readDataChunk(f)
f.close

puts format

puts


#STE Sample sizes
SMALL_SAMPLE_SIZE = format.hz / 50  #10ms
LARGE_SAMPLE_SIZE = format.hz / 5   #100ms
SENSITIVITY = 90   #delta amplitude

ste_small_sample = Array.new(10)
ste_large_sample = Array.new(rawSound.size / LARGE_SAMPLE_SIZE)
peak_index = Array.new(rawSound.size / LARGE_SAMPLE_SIZE, false)

index = 0


#****************
#PART 1:
#Determine where small peaks (10-20ms in length) occur in larger sample sets (100ms).
#
#Currently outputs a boolean array where peaks are found.
#
#Change SENSITIVITY to adjust number of peaks reported.
#****************

running_total = 0

#for index in 0..((rawSound.data.length - 1) / 2)
#  running_total = running_total + get_value(rawSound, index * 2)
#
#end
#
#average = running_total / rawSound.data.length
##average = 151
#
#puts "AVERAGE: " + average.to_s
#
#puts rawSound.data.length
#
#average = average * 2
#
#previous = false
#last_detection = nil
#
#for index in 0..((rawSound.data.length - 1) / 2)
#  if (get_value(rawSound, index * 2) > average)
#    if recent_detection(last_detection, index)
#
#    else
#      puts "#{index * 2} : : : Found : : #{get_value(rawSound, index * 2)}"
#      last_detection = index * 2
#    end
#  else
#    previous = false
#  end
#
#  #puts "#{index * 2} : : : Found : : : #{rawSound.data[index].unpack('H*')[0].to_i(32)}"
#
#end
threshold = 1000000
last_detection = nil
for index in 0..((rawSound.data.length - 1) / 2)
  if (get_value(rawSound,index * 2) > threshold)
    unless recent_detection(last_detection, index * 2)
      minutes = (index / (60 * 44100)).to_i
      seconds = ((index.to_f / 44100.0) - (minutes * 60))
      puts "#{minutes}:#{seconds.round(3)}"
      last_detection = index * 2
    end
  end
end

#
#for sample in 0..ste_large_sample.size
#
#  ste_large_sample[sample] = 0
#
#  #fill out the small samples in the large sample
#  # :: for use as peaks
#  for i in 0..10
#    ste_small_sample[i] = 0
#    for j in 0..SMALL_SAMPLE_SIZE
#      ste_small_sample[i] += rawSound.data[index + j].unpack('H*')[0].to_i(16) #convert the hex to usable decimal
#    end
#    ste_small_sample[i] /= SMALL_SAMPLE_SIZE
#  end
#
#  #Get average of 100ms window to compare peaks with
#  for i in 0..10
#    ste_large_sample[sample] += (1/10) * ste_small_sample[i]
#  end
#
#  #Find peaks
#  for i in 0..10
#    if ste_small_sample[i] - ste_large_sample[sample] > SENSITIVITY
#      peak_index[sample] = true
#    end
#  end
#
#  index += LARGE_SAMPLE_SIZE
#end
#
#for index in 0..peak_index.size
#  if (peak_index[index])
#    minutes = (index / (10.0 * 60)).to_i
#    seconds = ((index / 10) - (minutes * 60)).to_i
#    puts "#{minutes}:#{seconds} : " + peak_index[index].to_s
#
#  end
#end
#
