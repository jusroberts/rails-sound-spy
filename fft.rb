require "ruby-audio"
require "fftw3"

class Rss
  def self.gen_fft (name)
    fname = name
    window_size = 512
    wave = Array.new
    spectrum = Array.new(window_size/2,0)
    hanning_window = hanning(window_size)
    iterations = 0
    spectrum_array = Array.new(10, Array.new(window_size / 2, 0))
    begin
      buf = RubyAudio::Buffer.float(window_size)
      RubyAudio::Sound.open(fname) do |snd|
        samplerate = snd.info.samplerate
        while snd.read(buf) != 0
          windowed_array = apply_window(buf.to_a, hanning_window)
          wave.concat(windowed_array)
          na = NArray.to_na(windowed_array)
          fft_slice = FFTW3.fft(na).to_a[0, window_size/2]
          i=0
          fft_slice.each { |x| spectrum[i] += x.magnitude; i+=1}

          spectrum_array[iterations] = fft_slice
          i = 0
          spectrum_array[iterations].each { |x| spectrum_array[iterations][i] = x.magnitude; i+=1}
          iterations += 1
        end
      end

    rescue => err
      p "error reading audio file: " + err.to_s
      exit
    end


    return spectrum_array

  end


  private

  def self.apply_window(buffer, window_type)
    windowed_array = Array.new()
    i=0
    buffer.each { |x| windowed_array[i] = x * window_type[i]; i+=1}
  end

  def self.hanning (window_size)
    hannified_array = Array.new
    i=0
    (0..window_size).each { |x| hannified_array[i] = 0.5 - 0.5 * Math.cos(2 * Math::PI * i / window_size) ; i+=1}

    hannified_array
  end

end

