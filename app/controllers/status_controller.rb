class StatusController < ApplicationController
  def index
  	available
    @message_text = message
    #chart
  end

  def available
  	@ping = Ping.limit(2).order('id desc').reverse

   	unless @ping.nil?
   		@available = (Time.now - @ping[0][:time] > 60 ? true : false)
   	else
   		@available = true
   	end
  end

  private

  def message
    msg = ""
    File.open("message.html", "r") do |infile|
      while (line = infile.gets)
        msg += line
      end
    end
    msg.html_safe
  end
end
