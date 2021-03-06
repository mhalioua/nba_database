class IndexController < ApplicationController

	before_action :confirm_logged_in

	layout 'nba'

	def result
		@seasons = Season.all
	end


	def year
		@years = Array.new
		year = Time.now.year
		bool = true
		while bool
			games = Game.where(:year => year.to_s)
			if games.empty?
				bool = false
			else
				@years << year
				year = year - 1
			end
		end
		@years = @years.map{|y| [y, y]}
	end

	def month
		require 'date'
		@months = Array.new
		games = Game.where(:year => params[:year])

		(1..12).each do |i|
			month = i.to_s
			if i < 10
				month = "0" + month
			end
			if !games.where(:month => month).empty?
				@months << month
			end
		end
		@months = @months.map{|m| [Date::MONTHNAMES[m.to_i], m]}
	end

	def day
		@days = Array.new
		month = params[:month]
		games = Game.where(:year => params[:year], :month => month)

		(1..31).each do |i|
			day = i.to_s
			if i < 10
				day = "0" + day
			end
			if !games.where(:day => day).empty?
				@days << day
			end
		end
		@days = @days.map{|d| 

			if d[0] == '0'
				d_show = d[-1]
			else
				d_show = d
			end

			[d_show, d]
		}
	end

	def game
		require 'date'
		@year = params[:year]
		month = params[:month]
		day = params[:day]
		@time = Date::MONTHNAMES[month.to_i] + ' ' + day + ' Matchups'

		@games = Game.where(:year => @year, :month => month, :day => day).order("home_team_id ASC")
		@month = Date::MONTHNAMES[month.to_i]
	end

end
