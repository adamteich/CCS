function output = poker_simulation(alpha, beta, num_hands, starting_cash, bust_limit, bluff_rate)

% generate cards for the game (as well as predetermined/static opponent actions)
% for now, card options consist exclusively 1 through 10
middle_cards = randi([1 5], num_hands, 1);
self_cards = randi([1 5], num_hands, 1);
competitor_cards = randi([1 5], num_hands, 1);

% for now, let's have the opponent fold only when they know they'll bust
for i=1:num_hands
    if competitor_cards(i) + middle_cards(i) >= bust_limit
        competitor_actions(i) = 0;
    else
        competitor_actions(i) = 1;
    end
end

% opponent can bluff (play on a bust instead of folding) a given proportion of the time
competitor_bluff_indexes = [];
for i=1:length(competitor_actions)
    if competitor_actions(i)==0 && rand<bluff_rate
        competitor_actions(i)=1;
        competitor_bluff_indexes(end+1) = i;
    end
end

reward(1) = 0;
player_balance(1) = starting_cash;

% learn expected value of opponent card and prob of bluffing on each card
opponent_card_expected_value(1) = 3;
P_bluffing(1) = 0;

t=1;
bet_amount=50;
while t<=num_hands && sum(reward)+starting_cash>0
    % 1. calculate expected utility of competitor's card
    U_competitor = opponent_card_expected_value(t) * competitor_actions(t);
    
    % dynamic betting - in progress
%     if player_balance(t)>300
%         bet_amount= round(player_balance(t)* (rand()+1)/3); %if past a certain threshold, agent bets between 1/3 and 2/3 of current balance
%     end
   
    % 2. calculate expected utilities of our own actions (playing and folding)
    % U = [utility_of_playing, utility_of_folding]
    we_bust = self_cards(t) + middle_cards(t) >= bust_limit;
    opponent_busts = U_competitor + middle_cards(t) >= bust_limit;
    if rand < P_bluffing(t)
        opponent_busts = 1;
    end
        
    if competitor_actions(t) % if competitor plays...
        
        if we_bust && opponent_busts
            U(1) = 0;  %  if we both expect to bust, is that utility 0????? or do we both lose??
        elseif we_bust
            U(1) = -bet_amount;
        elseif opponent_busts
            U(1) = bet_amount;
        elseif self_cards(t)>round(U_competitor) % if we expect to win, then we expect utility of 50
            U(1) = bet_amount;
        elseif self_cards(t)==round(U_competitor)
            U(1) = 5;
        else
            U(1) = -bet_amount;
        end

    else % if competitor folds, we can always play and win for utility of 10
        U(1) = 10;
    end
    
    U(2) = -10; % folding always has utility of -10
    
    % 3. use expected utilities to determine our own best action
    P_playing_card = exp(beta*U(1))/sum(exp(beta*U)); % probability of our agent playing rather than folding
    if isnan(P_playing_card) % correct for rounding errors when using large utility discrepencies
        P_playing_card=1;
    end
    player_actions(t) = rand < P_playing_card; % probability --> action (1 == playing, 0 == folding)
    
    % 4. now that all players have made their choice, we can calculate the actual outcome and reward for our agent
    if competitor_actions(t)==1 && player_actions(t)==1
            we_bust = self_cards(t) + middle_cards(t) >= bust_limit;
            opponent_busts = competitor_cards(t) + middle_cards(t) >= bust_limit;
            if we_bust && opponent_busts
                reward(t) = 0;
            elseif we_bust
                reward(t) = -bet_amount;
            elseif opponent_busts
                reward(t) = bet_amount;
            elseif self_cards(t)>competitor_cards(t) % ...and win, then then reward=50
                reward(t) = bet_amount;
            elseif self_cards(t)==competitor_cards(t) % ...and tie, then then reward=5
                reward(t) = 5;
            else % ...and lose, then reward=-50
                reward(t) = -bet_amount;
            end
    elseif player_actions(t)==1
        reward(t) = 10;
    elseif competitor_actions(t)==1
        reward(t) = -10;
    else
        reward(t) = -10;
    end
    
    player_balance(t+1) = sum(reward) + starting_cash;
    
    % 5. learn from outcome!
    if competitor_actions(t)==0
        deltaEV = 0; % if competitor folds, there's nothing to learn about the values they play
    else
        deltaEV = competitor_cards(t) - opponent_card_expected_value(t); % prediction error (actual - estimate)
    end
    opponent_card_expected_value(t+1) = opponent_card_expected_value(t) + alpha*deltaEV;  % update
    
    
    % 5. learn from outcome!
    if competitor_actions(t)==0
        deltaBluffing = 0; % if competitor folds, there's nothing to learn about the values they play
    else
        opponent_busts = competitor_cards(t) + middle_cards(t) >= bust_limit;
        deltaBluffing = opponent_busts - P_bluffing(t); % prediction error (actual - estimate)
    end
    P_bluffing(t+1) = P_bluffing(t) + alpha*deltaBluffing;  % update
    
    t=t+1;
 end
  

output.P_bluffing = P_bluffing;
output.opponent_card_expected_value = opponent_card_expected_value;
output.reward = reward;
output.player_balance = player_balance;
output.player_actions = player_actions;
output.fold_rate = sum(output.reward(:) == -10) / length(reward);
output.win_rate = sum(output.reward(:) >= 50) / length(reward);
output.lose_rate = sum(output.reward(:) <= -50) / length(reward);
output.tie_rate = sum(output.reward(:) == 5) / length(reward);
output.win_from_opponent_fold = sum(output.reward(:) == 10) / length(reward);
output.play_rate= output.win_rate+output.lose_rate+output.tie_rate;
output.competitor_bluff_indexes = competitor_bluff_indexes;
