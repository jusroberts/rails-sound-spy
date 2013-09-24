class DataController < ApplicationController

  def index

    @chartData = Array.new((24 * 60 / 5), 0)

    pings = Ping.all()

    #This is set to today and tomorrow until we get more data.
    yesterday = Date.today.to_time
    today = Date.tomorrow.to_time

    pings.each do |p|
      unless p[:time] > yesterday and p[:time] < today
        next
      end
      rawTime = p[:time] - yesterday
      @chartData[(rawTime / (60 * 5)).to_int] += 1
    end

    #TODO: add average data points
    @yesterdayChart = LazyHighCharts::HighChart.new('graph') do |f|
      f.title({ :text=>"Yesterday's Data"})
      f.legend({:align => 'right',
              :x => -100,
              :verticalAlign=>'top',
              :y=>20,
              :floating=>"true",
              :backgroundColor=>'#FFFFFF',
              :borderColor=>'#CCC',
              :borderWidth=>1,
              :shadow=>"false"
             })
      f.options[:yAxis][:title] = {:text=>"Detections"}
      f.options[:xAxis][:title] = {:text=>"Time"}
      f.series(:type=> 'spline',:name=> 'Ping Pong Hits', :data=> @chartData)

    end
  end

end
