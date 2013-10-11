class StatusController < ApplicationController
  def index
  	available
    chart
  end

  def available
  	@ping = Ping.last()

   	unless @ping.nil?
   		@available = (Time.now - @ping[:time] > 10 ? true : false)
   	else
   		@available = 'unknown'
   	end
  end

  def chart

    @yesterdayChartData = Array.new((9 * 60 / 5), 0)
    @todayChartData = Array.new((9 * 60 / 5), 0)
    @averageChartData = Array.new((9 * 60 / 5), 0)

    histories = History.all
    days = Day.all

    #This is set to today and tomorrow until we get more data.
    yesterday = Date.yesterday.to_time
    today = Date.today.to_time

    @day = nil
    @finalDay = nil
    @numDays = 0

    startTime = 9 * 60 * 60
    endTime = 18 * 60 * 60

    histories.each do |h|
      @averageChartData[h.time] = h.number_of_hits
    end

    @numDays = days.size

    unless @numDays == 0
      @averageChartData.map!{
          |n| n / @numDays
      }
    end

    #TODO: add average data points
    @hitsChart = LazyHighCharts::HighChart.new('graph') do |f|
      f.title({ :text=>"Ping Pong Data"})
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
      f.series(:type=> 'spline',:name=> 'Previous', :data=> @averageChartData)

    end
  end

end
