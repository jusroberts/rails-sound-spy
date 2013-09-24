class StatusController < ApplicationController
  def index
  	available
  end

  def available
  	@ping = Ping.last()

   	unless @ping.nil?
   		@available = (Time.now - @ping[:time] > 10 ? true : false)
   	else
   		@available = 'unknown'
   	end
  end

end
