function output = poker_simulation(alpha, beta, competitor_cards, competitor_actions, middle_cards, self_cards, starting_cash)

num_hands = length(competitor_cards);
reward(1) = 0;
player_balance(1) = starting_cash;

% by learning the probability that an opponent plays 1s when playing, we can understand their behavior and predict the utility of their moves
P_competitor_plays_one_when_playing(1) = 1; % starts assuming no bluffing
t=1;
bet_amount=50;
while t<=num_hands && sum(reward)+starting_cash>0
    % 1. calculate expected utility of competitor's card
    U_competitor = P_competitor_plays_one_when_playing(t) * competitor_actions(t);
    if player_balance(t) >300
        bet_amount= round(player_balance(t)* (rand()+1)/4) %if past a certain threshold, agent bets between 1/4 and 1/2 of current balance
    end
   
    % 2. calculate expected utilities of our own actions (playing and folding)
    % U = [utility_of_playing, utility_of_folding]
    % to do: expected utilities should probably be more directly based on probabilities (rather than being discrete values: -10, 50, or -50)
    if competitor_actions(t) % if competitor plays...
        if self_cards(t) + U_competitor + middle_cards(t) > 2 % ...and we expect to bust, then we expect utility of -50
            U(1) = -bet_amount;
        else % ...and we don't bust...
            if self_cards(t)>U_competitor % ...and we expect to win, then we expect utility of 50
                U(1) = bet_amount;
            else % ...and we expect to lose, then we expect utility of -50
                U(1) = -bet_amount;
            end
        end
    else % if competitor folds, we can always play and win for utility of 10
        U(1) = 10;
    end
    U(2) = -10; % folding always has utility of -10
    
    % 3. use expected utilities to determine our own best action
    P_playing_card = exp(beta*U(1))/sum(exp(beta*U)); % probability of our agent playing rather than folding
    player_actions(t) = rand < P_playing_card; % probability --> action (1 == playing, 0 == folding)
    
    % 4. now that all players have made their choice, we can calculate the actual outcome and reward for our agent
    if player_actions(t)==0 % if we fold, we automatically get reward=-10
        reward(t) = -10;
    else % if we play...
        if competitor_actions(t) % if competitor plays...
            if self_cards(t) + competitor_cards(t) + middle_cards(t) > 2 % ...and we bust, then reward=-50
                reward(t) = -bet_amount; % ...
            else % ...and we don't bust...
                if self_cards(t)>competitor_cards(t) % ...and win, then then reward=50
                    reward(t) = bet_amount;
                elseif self_cards(t)==competitor_cards(t) % ...and tie, then then reward=0
                    reward(t) = 0;
                else % ...and lose, then reward=-50
                    reward(t) = -bet_amount;
                end
            end
        else % if competitor folds
            reward(t) = 10;
        end
    end
    player_balance(t+1) = sum(reward) + starting_cash;
    
    % 5. learn from outcome!
    if competitor_actions(t)==0
        delta = 0; % if competitor folds, there's nothing to learn about the values they play
    else
        delta = (competitor_cards(t)*competitor_actions(t)) - P_competitor_plays_one_when_playing(t); % prediction error (actual - estimate)
    end
    P_competitor_plays_one_when_playing(t+1) = P_competitor_plays_one_when_playing(t) + alpha*delta;  % update
    
    t=t+1;
 end
  

output.P_competitor_plays_one_when_playing = P_competitor_plays_one_when_playing;
output.reward = reward;
output.player_balance = player_balance;
output.player_actions = player_actions;
output.fold_rate = sum(output.reward(:) == -10) / length(reward);
output.win_rate = sum(output.reward(:) >= 50) / length(reward);
output.lose_rate = sum(output.reward(:) <= -50) / length(reward);
output.tie_rate = sum(output.reward(:) == 0) / length(reward);
output.win_from_opponent_fold = sum(output.reward(:) == 10) / length(reward);
