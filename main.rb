require 'rubygems'
require 'sinatra'

set :sessions, true

helpers do 
	def calculate_total(cards) 
		arr = cards.map{|element| element[1]}

		total = 0 
		arr.each do |card|
			if card  == 'A'
				total += 11 
			else 
				total += card.to_i == 0 ? 10 : card.to_i
			end 
		end 

		arr.select{|element| element == 'A'}.count.times do 
			break if total <= 21 
			total -= 10 
		end 

		total 
	end 

	def card_image(card) #['H'.'4']
		suit = case card[0]
			when 'H' then 'hearts'
			when 'D' then 'diamonds'
			when 'C' then 'clubs'
			when 'S' then 'spades'
		end 
		value =card[1]
		if ['J','K','Q','A'].include?(value)
			value = case card[1]
				when 'J' then 'jack'
				when 'Q' then 'queen'
				when 'K' then 'king'
				when 'A' then 'ace'
			end 
		end 
		"<img src='/images/cards/#{suit}_#{value}.jpg' class ='card_img'>"
	end 

	def game_over(dealer_choice,dealer_total)
		if dealer_cards.nil? && decks.nil? 
			return true 
		end 

		

	end 

	def winner(dealer_cards,player_cards)
		player_total= calculate_total(player_cards)
		dealer_total = calculate_total(dealer_cards)
		if dealer_total == 21 
			'Dealer hits blackjack'
		elsif dealer_total > 21 
			'Dealer busted'
		elsif player_total == dealer_total 
			'Draw'
		elsif dealer_total > player_total
			'Dealer wins'
		else 'Player win'
		end 
	end 

end 

before do 
	@show_hit_or_stay_buttons = true
end 


get "/" do 
	session.clear
	if session[:name].nil? then 
		redirect '/new_game'
	else 
		#if session[:balance].nil?
		#	redirect '/bet'
		#else
			redirect '/game'	
		#end 
	end 
end 

get "/new_game" do 
	session.clear
	erb :username_form 
end 

post "/new_game" do 
	if params['username'].empty? 
		@error = "Name is required!"
		halt erb :username_form
	end 
	session[:name] = params['username']
	redirect "/game"
end 

#get "/bet" do 
#	if session[:balance].nil? then session[:balance]=500 end 
#	erb :bet_form
#end 
#
#post '/bet' do 
#	session[:current_bet]= params['bet']
#	redirect '/game'
#end 



get '/game' do 
	# deck 

	if session[:game_over].nil? then 

		suits = ['H','D','C','S']
		values = ['2','3','4','5','6','7','8','9','10','J','Q','K','A']
		session[:deck] = suits.product(values).shuffle! #[['H','9'],['C','K'] ... ]
		# deal cards 
		session[:dealer_cards] = []
		session[:player_cards] = []
		session[:show_hit_or_stay_buttons] = true 
		session[:show_dealer_first_card] = false
		session[:dealer_cards] << session[:deck].pop
		session[:player_cards] << session[:deck].pop
		session[:dealer_cards] << session[:deck].pop
		session[:player_cards] << session[:deck].pop
		session[:game_over] = false 

		
		"<h1> Blackjack </h1>"
		erb :game
	else
		session[:choice] = rand(1..2)
		if (calculate_total(session[:dealer_cards]) < 16) then session[:choice] = 1 end 
		if (calculate_total(session[:dealer_cards])>calculate_total(session[:player_cards])) then session[:choice] = 2 end 
		if (session[:choice] == 2 || (calculate_total(session[:dealer_cards]) >= 21))
			@success = winner(session[:dealer_cards],session[:player_cards])
			session[:game_over] = true 
		end 
		erb :game
	end 

end

post '/game/dealer/next' do 
	if (session[:choice] == 1) && (calculate_total(session[:dealer_cards]) < 21)
		session[:dealer_cards] << session[:deck].pop
		session[:game_over] = false 
		session[:choice] = rand(1..2)
		if (calculate_total(session[:dealer_cards]) < 16) then session[:choice] = 1 end 
		if (calculate_total(session[:dealer_cards])>calculate_total(session[:player_cards])) then session[:choice] = 2 end 
	end 
	if (session[:choice] == 2 || (calculate_total(session[:dealer_cards]) >= 21) )
		@success = winner(session[:dealer_cards],session[:player_cards])
		session[:game_over] = true 
		
	end 
	erb :game  
end 


post '/game/player/hit' do 
	session[:player_cards] << session[:deck].pop
	total = calculate_total(session[:player_cards])

	if total == 21 
		@success = "Congrats ! #{session[:name]} hits blackjack!"
		session[:show_hit_or_stay_buttons] = false 
		#erb :game
	elsif total > 21 
		@error = "Sorry, it looks like #{session[:name]} have busted!"
		session[:show_hit_or_stay_buttons] = false 
		
	end
	erb :game
	
	#game_over?
end 


post '/game/player/stay' do 
	@success =  " #{session[:name]} has chosen to stay"
	session[:show_hit_or_stay_buttons] = false 
	session[:show_dealer_first_card] = true
	redirect '/game'
	
end 



















