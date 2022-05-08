   
% parameters
alpha = 0.1;
beta = .25;
num_hands = 1000;
starting_cash = 100;
bust_limit = 7;
bluff_rate = 0.25;

% now, let's actually run the learning simulation
output = poker_simulation(alpha, beta, num_hands, starting_cash, bust_limit, bluff_rate)


% let's see how our agent learned to approximate the playing behavior of the opponent
% (or more specifically, the probability that the opponent plays a 1 when it plays) 
% this allows our agent to then calculate expected utilities of playing vs folding and act appropriately
figure()
plot(output.opponent_card_expected_value)
title("Learned Expected Value of Opponent's Card")
xlabel("Hand #")
ylabel("Expected Value of Opponent's Card")
ylim([1 10])
% yay! we see that our model correctly converges to a value of 0.8!
% this makes sense, because right now the competitor bluffs and plays a 0 one time for every four times it plays a 1 --> 4 ones played / 5 total plays = 0.8

% we can also infer the learned probability that the competitor plays a zero (from bluffing)
figure()
plot(output.P_bluffing);
title("Learned Probability of Opponent Bluffing")
xlabel("Hand #")
ylabel("P( Bluffing | Opponent Plays )")
ylim([0 1])


% let's also see how successfully our model wins rewards
figure()
plot(output.player_balance)
hold on
yline(0);
title("Cumulative Agent Reward Balance")
xlabel("Hand #")
ylabel("Player Balance ($)");
% yay! our agent performs well and wins more money than it loses!