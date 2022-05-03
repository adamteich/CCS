   
% parameters
alpha = 0.12;
beta = .5;
num_hands = 10000;
starting_cash = 100;
bust_limit = 7;

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
bluffProportion = 0.25;
for i=1:length(competitor_actions)
    if competitor_actions(i)==0 && rand<bluffProportion
        competitor_actions(i)=1;
    end
end

% now, let's actually run the learning simulation
output = poker_simulation(alpha, beta, competitor_cards, competitor_actions, middle_cards, self_cards, starting_cash, bust_limit)


% let's see how our agent learned to approximate the playing behavior of the opponent
% (or more specifically, the probability that the opponent plays a 1 when it plays) 
% this allows our agent to then calculate expected utilities of playing vs folding and act appropriately
figure()
plot(output.opponent_card_expected_value)
title("Opponent Expected Value")
xlabel("Hand #")
ylabel("Expected Value")
% yay! we see that our model correctly converges to a value of 0.8!
% this makes sense, because right now the competitor bluffs and plays a 0 one time for every four times it plays a 1 --> 4 ones played / 5 total plays = 0.8

% we can also infer the learned probability that the competitor plays a zero (from bluffing)
figure()
plot(output.P_bluffing);
title("Learned Probability of Opponent Bluffinig")
xlabel("Hand #")
ylabel("P( Bluffing | Opponent Plays )")


% let's also see how successfully our model wins rewards
figure()
plot(output.player_balance)
hold on
yline(0);
title("Cumulative Agent Rewards")
xlabel("Hand #")
ylabel("Player Balance ($)");
% yay! our agent performs well and wins more money than it loses!
