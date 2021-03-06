class StatisticsController < ApplicationController

	before_action :confirm_logged_in

	layout 'nba'

	def predicted
		@season = Season.find_by_year("2015")
		@games = @season.games
	end

	def season
		@seasons = Season.where("year != '2006'")
	end

	def bet
		@season = Season.find(params[:id])
		@seasons = Season.where("year != #{@season.year}")
		full_bets = @season.bets.where(:quarter => 0)
		half_bets = @season.bets.where(:quarter => 12)
		quarter_bets = @season.bets.where(:quarter => 1)
		@full_bets = Array.new
		@half_bets = Array.new
		@quarter_bets = Array.new
		# @full_bets << full_bets.where(:time => "Full Year").first
		# @full_bets << full_bets.where(:time => "First Half").first
		# @full_bets << full_bets.where(:time => "Second Half").first
		# @full_bets << full_bets.where(:time => "November").first
		# @full_bets << full_bets.where(:time => "December").first
		# @full_bets << full_bets.where(:time => "January").first
		# @full_bets << full_bets.where(:time => "February").first
		# @full_bets << full_bets.where(:time => "March").first
		# @full_bets << full_bets.where(:time => "April").first
		full_year_first_half_bets =  half_bets.where(:time => "Full Year", :range => 3).first
		first_half_first_half_bets =  half_bets.where(:time => "First Half", :range => 3).first
		second_half_first_half_bets = half_bets.where(:time => "Second Half", :range => 3).first
		if full_year_first_half_bets != nil
			@half_bets << full_year_first_half_bets
		end
		if first_half_first_half_bets != nil
			@half_bets << first_half_first_half_bets
		end
		if second_half_first_half_bets != nil
			@half_bets << second_half_first_half_bets
		end
		# @half_bets << half_bets.where(:time => "November").first
		# @half_bets << half_bets.where(:time => "December").first
		# @half_bets << half_bets.where(:time => "January").first
		# @half_bets << half_bets.where(:time => "February").first
		# @half_bets << half_bets.where(:time => "March").first
		# @half_bets << half_bets.where(:time => "April").first
		full_year_first_quarter_bets = quarter_bets.where(:time => "Full Year", :range => 3).first
		first_half_first_quarter_bets = quarter_bets.where(:time => "First Half", :range => 3).first
		second_half_first_quarter_bets = quarter_bets.where(:time => "Second Half", :range => 3).first
		if full_year_first_quarter_bets != nil
			@half_bets << full_year_first_quarter_bets
		end
		if first_half_first_quarter_bets != nil
			@half_bets << first_half_first_quarter_bets
		end
		if second_half_first_quarter_bets != nil
			@half_bets << second_half_first_quarter_bets
		end
		# @quarter_bets << quarter_bets.where(:time => "November").first
		# @quarter_bets << quarter_bets.where(:time => "December").first
		# @quarter_bets << quarter_bets.where(:time => "January").first
		# @quarter_bets << quarter_bets.where(:time => "February").first
		# @quarter_bets << quarter_bets.where(:time => "March").first
		# @quarter_bets << quarter_bets.where(:time => "April").first
	end


	def result
		@season = Season.find(params[:id])
		@seasons = Season.where("year != #{@season.year}")
		@past_teams = @season.past_teams.order("id ASC")
		@results = @season.results
		@all_teams = @season.results.where(:past_team_id => nil)
	end

	def season_results
		@seasons = Season.all
	end


	def matchup

		def setVarFalse()
			@id = 0
	 		@GS = 0
	 		@MP = 0
			@FG = 0
			@FGA = 0
	      	@ThP = 0
	      	@ThPA = 0
	      	@FT = 0
	      	@FTA = 0
	      	@ORB = 0
	      	@DRB = 0
	      	@AST = 0
	      	@STL = 0
	      	@BLK = 0
	      	@TO = 0
	      	@PF = 0
	      	@PTS = 0
	      	@GS_2 = 0
			@MP_2 = 0
			@FG_2 = 0
			@FGA_2 = 0
			@ThP_2 = 0
			@ThPA_2 = 0
			@FT_2 = 0
			@FTA_2 = 0
			@ORB_2 = 0
			@DRB_2 = 0
			@AST_2 = 0
			@STL_2 = 0
			@BLK_2 = 0
			@TO_2 = 0
			@PF_2 = 0
			@PTS_2 = 0
		end

		@player = Player.find_by_id(params[:id])

		@team = @player.team # this code checks to see what team the team is playing by checking the day attribute.
		# This could have easily been changed to the controller name which could have us get rid of a url variable altogether.
		if params[:day] == "today"
			@opp_team = @team.today_team
		end
		if params[:day] == "tomorrow"
			@opp_team = @team.tomorrow_team
		end

		# If the player is a forward, find the players that are a forward on the other team. Otherwise find the guards since the player must be a guard.
		if @player.position == 'PG'
			@opp_team_players = @opp_team.player.where(:starter => true, :position => 'PG')
		elsif @player.position == 'SG'
			@opp_team_players = @opp_team.player.where(:starter => true, :position => 'SG')
		elsif @player.position == 'SF'
			@opp_team_players = @opp_team.player.where(:starter => true, :position => 'SF')
		elsif @player.position == 'PF' || @player.position == 'C'
			@opp_team_players = @opp_team.player.where(:starter => true, :position => 'PF')
			@opp_team_players = @opp_team_players + @opp_team.player.where(:starter => true, :position => 'C')
		end


		# Then find the PlayerMatchups of those players.
		# The players are the player we're finding and the player that player is playing.
		@matchups = Array.new
		@opp_team_players.each do |opp_player|
			matchup = PlayerMatchup.where("(player_one_id = #{@player.id} or player_one_id = #{opp_player.id}) and (player_two_id = #{@player.id} or player_two_id = #{opp_player.id})").first
			@matchups << matchup
		end
		# This array will store all the PlayerMatchupGames
		@game = Array.new

		# Iterate through each matchup
		@matchups.each do |matchup|
			# The id checks to see if the a new matchup has come along.
	 		@id = 0
	 		@var = -1
	 		# @save = nil

	 		player_matchup_game = matchup.player_matchup_game

	 		player_matchup_game.each do |game|
	 			@var += 1
	 			# if @id is equal to 0, then that's the first game of the new matchup
	 			if @id == 0
	 				setVarFalse()
			    end
			    if @var%2 == 0
			      	@id = game.player_matchup_id
			      	@name = game.name
			      	@GS = @GS + game.GS
			      	@MP = @MP + game.MP
			      	@FG = @FG + game.FG
			      	@FGA = @FGA + game.FGA
			      	@ThP = @ThP + game.ThP
			      	@ThPA = @ThPA + game.ThPA
			      	@FT = @FT + game.FT
			      	@FTA = @FTA + game.FTA
			      	@ORB = @ORB + game.ORB
			      	@DRB = @DRB + game.DRB
			      	@AST = @AST + game.AST
			      	@STL = @STL + game.STL
			      	@BLK = @BLK + game.BLK
			      	@TO = @TO + game.TO
			      	@PF = @PF + game.PF
			      	@PTS = @PTS + game.PTS
			    else
			    	@id_2 = game.player_matchup_id
			      	@name_2 = game.name
			      	@GS_2 = @GS_2 + game.GS
			      	@MP_2 = @MP_2 + game.MP
			      	@FG_2 = @FG_2 + game.FG
			      	@FGA_2 = @FGA_2 + game.FGA
			      	@ThP_2 = @ThP_2 + game.ThP
			      	@ThPA_2 = @ThPA_2 + game.ThPA
			      	@FT_2 = @FT_2 + game.FT
			      	@FTA_2 = @FTA_2 + game.FTA
			      	@ORB_2 = @ORB_2 + game.ORB
			      	@DRB_2 = @DRB_2 + game.DRB
			      	@AST_2 = @AST_2 + game.AST
			      	@STL_2 = @STL_2 + game.STL
			      	@BLK_2 = @BLK_2 + game.BLK
			      	@TO_2 = @TO_2 + game.TO
			      	@PF_2 = @PF_2 + game.PF
			      	@PTS_2 = @PTS_2 + game.PTS
			    end
			    @game << game
			end

			#initialize variables for percentage
	 		@size = (player_matchup_game.size)/2
	 		@FGP = 0
	 		@ThPP = 0
	 		@FTP = 0
	 		@FGP_2 = 0
	 		@ThPP_2 = 0
	 		@FTP_2 = 0
	 		if @FGA != 0
	 			@FGP = ((@FG.to_f/@FGA.to_f)*100).round(1)
	 		end
	 		if @ThPA != 0
	 			@ThPP = ((@ThP.to_f/@ThPA.to_f)*100).round(1)
	 		end
	 		if @FTA != 0
	 			@FTP = ((@FT.to_f/@FTA.to_f)*100).round(1)
	 		end
	 		if @FGA_2 != 0
	 			@FGP_2 = ((@FG_2.to_f/@FGA_2.to_f)*100).round(1)
	 		end
	 		if @ThPA_2 != 0
	 			@ThPP_2 = ((@ThP_2.to_f/@ThPA_2.to_f)*100).round(1)
	 		end
	 		if @FTA_2 != 0
	 			@FTP_2 = ((@FT_2.to_f/@FTA_2.to_f)*100).round(1)
	 		end
	 		if @size == 1
	 			@date = "Previous Game"
	 		else
	 			@date = "Previous " + @size.to_s + " Games"
	 		end
	 		@MP = @MP.round(2)
	 		@MP_2 = @MP_2.round(2)
	 		if @size != 0 && @size != 1
		 		@total = PlayerMatchupGame.new(:player_matchup_id => @id, :date => @date, :name => @name, :GS => @GS, :MP => @MP, :FG => @FG, :FGA => @FGA, :FGP => @FGP, :ThP => @ThP,
		 			:ThPA => @ThPA, :ThPP => @ThPP, :FT => @FT, :FTA => @FTA, :FTP => @FTP, :ORB => @ORB, :DRB => @DRB, :AST => @AST,
		 			:STL => @STL, :BLK => @BLK, :TO => @TO, :PF => @PF, :PTS => @PTS)
		 		@total_2 = PlayerMatchupGame.new(:player_matchup_id => @id_2, :date => @date, :name => @name_2, :GS => @GS_2, :MP => @MP_2, :FG => @FG_2, :FGA => @FGA_2, :FGP => @FGP_2, :ThP => @ThP_2,
		 			:ThPA => @ThPA_2, :ThPP => @ThPP_2, :FT => @FT_2, :FTA => @FTA_2, :FTP => @FTP_2, :ORB => @ORB_2, :DRB => @DRB_2, :AST => @AST_2,
		 			:STL => @STL_2, :BLK => @BLK_2, :TO => @TO_2, :PF => @PF_2, :PTS => @PTS_2)
		 		if @total.name == @player.name
		 			@game << @total_2
		 			@game << @total
		 		else
		 			@game << @total
		 			@game << @total_2
		 		end
	 		end
	 	end

	end

  	def team
  		@teams = Team.all.order('id ASC').limit(30)
  		@zero = @one = @two = @three = @sunday = @monday = @tuesday = @wednesday = @thursday = @friday = @saturday = 0
  		@teams.each do |team|
  			@zero += team.zero_PTS
  			@one += team.one_PTS
  			@two += team.two_PTS
  			@three += team.three_PTS
  			@sunday += team.sun_PTS
  			@monday += team.mon_PTS
  			@tuesday += team.tue_PTS
  			@wednesday += team.wed_PTS
  			@thursday += team.thu_PTS
  			@friday += team.fri_PTS
  			@saturday += team.sat_PTS
  		end
  		@zero /= 30
  		@one /= 30
  		@two /= 30
  		@three /= 30
  		@sunday /= 30
  		@monday /= 30
  		@tuesday /= 30
  		@wednesday /= 30
  		@thursday /= 30
  		@friday /= 30
  		@saturday /= 30
 	end

 	def yesterday
 		@home_team = Team.find_by_id(params[:id])
 		@away_team = @home_team.yesterday_team
 		@home_players = @home_team.player.where(:starter => true)
 		@away_players = @away_team.player.where(:starter => true)
 	end

 	def today
 		@home_team = Team.find_by_id(params[:id])
 		@away_team = @home_team.today_team
 		@home_players = @home_team.player.where(:starter => true)
 		@away_players = @away_team.player.where(:starter => true)
 	end

 	def tomorrow
 		@home_team = Team.find_by_id(params[:id])
 		@away_team = @home_team.tomorrow_team
 		@home_players = @home_team.player.where(:starter => true)
 		@away_players = @away_team.player.where(:starter => true)
 	end

end
