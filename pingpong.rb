#!/usr/bin/env ruby

require 'rubygems'
require 'wav-file'

f = open("test1.wav")
format = WavFile::readFormat(f)
rawSound = WavFile::readDataChunk(f)
f.close

puts format

puts


#STE Sample sizes
SMALL_SAMPLE_SIZE = format.hz / 100  #10ms
LARGE_SAMPLE_SIZE = format.hz / 10   #100ms
SENSITIVITY = 150   #delta amplitude

ste_small_sample = Array.new(10)
ste_large_sample = Array.new(rawSound.size / LARGE_SAMPLE_SIZE)
peak_index = Array.new(rawSound.size / LARGE_SAMPLE_SIZE, false)

index = 0

for sample in 0..ste_large_sample.size

  ste_large_sample[sample] = 0

  #fill out the small samples in the large sample
  for i in 0..10
    ste_small_sample[i] = 0
    for j in 0..SMALL_SAMPLE_SIZE
      ste_small_sample[i] += rawSound.data[index + j].unpack('H*')[0].to_i(16) #convert the hex to usable decimal
    end
    ste_small_sample[i] /= SMALL_SAMPLE_SIZE
  end

  for i in 0..10
    ste_large_sample[sample] += (1/10) * ste_small_sample[i]
  end

  #Find peaks
  for i in 0..10
    if ste_small_sample[i] - ste_large_sample[sample] > SENSITIVITY
      peak_index[sample] = true
    end
  end

  index += LARGE_SAMPLE_SIZE
end


puts peak_index