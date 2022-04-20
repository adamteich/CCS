function output = poker_simulation(alpha, beta, competitor_cards, competitor_actions, middle_cards, self_cards)

num_hands = length(competitor_cards);

% initialize output variables
P_competitor_plays_one_when_playing = zeros(1,num_hands+1); % probability that opponent plays high-value card when playing
player_actions = zeros(1,num_hands+1); % actions chosen by our agent, 1 == plays, 0 == folds
reward = zeros(1,num_hands); % rewards obtained
cumulative_reward = zeros(1,num_hands); % cumulative rewards obtained

% by learning the probability that an opponent plays 1s when playing, we can understand their behavior and predict the utility of their moves
P_competitor_plays_one_when_playing(1) = 0; % arbitrarily initialize probability to zero (we could change this to anything / optimize later)

for t = 1:num_hands
    
    % 1. calculate expected utility of competitor's card
    U_competitor = P_competitor_plays_one_when_playing(t) * competitor_actions(t);
    
    % 2. calculate expected utilities of our own actions (playing and folding)
    % U = [utility_of_playing, utility_of_folding]
    % to do: expected utilities should probably be more directly based on probabilities (rather than being discrete values: -1, 50, or -50)
    if competitor_actions(t) % if competitor plays...
        if self_cards(t) + U_competitor + middle_cards(t) > 2 % ...and we expect to bust, then we expect utility of -50
            U(1) = -50;
        else % ...and we don't bust...
            if self_cards(t)>U_competitor % ...and we expect to win, then we expect utility of 50
                U(1) = 50;
            else % ...and we expect to lose, then we expect utility of -50
                U(1) = -50;
            end
        end
        U(2) = -1; % expected utility of folding
    else % if competitor folds, we can always play and win for utility of 50
        U(1) = 50;
    end
    U(2) = -1; % folding always has utility of -1
    
    % 3. use expected utilities to determine our own best action
    P_playing_card = exp(beta*U(1))/sum(exp(beta*U)); % probability of our agent playing rather than folding
    player_actions(t) = rand < P_playing_card; % probability --> action (1 == playing, 0 == folding)
    
    % 4. now that all players have made their choice, we can calculate the actual outcome and reward for our agent
    if player_actions(t)==0 % if we fold, we automatically get reward=-1
        reward(t) = -1;
    else % if we play...
        if competitor_actions(t) % if competitor plays...
            if self_cards(t) + competitor_cards(t) + middle_cards(t) > 2 % ...and we bust, then reward=-50
                reward(t) = -50; % ...
            else % ...and we don't bust...
                if self_cards(t)>competitor_cards(t) % ...and win, then then reward=50
                    reward(t) = 50;
                else % ...and lose, then reward=-50
                    reward(t) = -50;
                end
            end
        else % if competitor folds
            reward(t) = 50;
        end
    end
    cumulative_reward(t) = sum(reward);
    
    % 5. learn from outcome!
    if competitor_actions(t)==0
        delta = 0; % if competitor folds, there's nothing to learn about the values they play
    else
        delta = (competitor_cards(t)*competitor_actions(t)) - P_competitor_plays_one_when_playing(t); % prediction error (actual - estimate)
    end
    P_competitor_plays_one_when_playing(t+1) = P_competitor_plays_one_when_playing(t) + alpha*delta;  % update
    
end

output.P_competitor_plays_one_when_playing = P_competitor_plays_one_when_playing;
output.reward = reward;
output.cumulative_reward = cumulative_reward;
output.player_actions = player_actions;