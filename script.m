   
% parameters
alpha = 0.02;
beta = .5;
num_hands = 1000;
starting_cash = 100;

% generate cards for the game (as well as predetermined/static opponent actions)
% for now, card options consist exclusively of 1s and 0s
competitor_cards = randi([0 1], num_hands, 1);
competitor_actions = competitor_cards; % for now, let's have the opponent play only when they have a good card (a 1) for simplicity
% note: as such, right now competitor_actions actions don't yet depend on what the middle card is–this is still a missing component

middle_cards = randi([0 1], num_hands, 1);
self_cards = randi([0 1], num_hands, 1);

% opponent can bluff (play on a zero instead of folding) a given proportion of the time
bluffProportion = 0.25;
for i=1:length(competitor_actions)
    if competitor_actions(i)==0 && rand<bluffProportion
        competitor_actions(i)=1;
    end
    % if we want, we can also have the competitor fold on 1s for a given proportion as well
    % the agent still learns appropriately (yay!), but we can leave this off right now for simplicity
%     if competitor_actions(i)==1 && rand<bluffProportion
%         competitor_actions(i)=0;
%     end
end

% now, let's actually run the learning simulation
output = poker_simulation(alpha, beta, competitor_cards, competitor_actions, middle_cards, self_cards, starting_cash)


% let's see how our agent learned to approximate the playing behavior of the opponent
% (or more specifically, the probability that the opponent plays a 1 when it plays) 
% this allows our agent to then calculate expected utilities of playing vs folding and act appropriately
figure()
plot(output.P_competitor_plays_one_when_playing)
title("Learned Probability of Opponent Playing 1s")
xlabel("Hand #")
ylabel("P( Opponent Plays a 1 | Opponent Plays )")
% yay! we see that our model correctly converges to a value of 0.8!
% this makes sense, because right now the competitor bluffs and plays a 0 one time for every four times it plays a 1 --> 4 ones played / 5 total plays = 0.8

% we can also infer the learned probability that the competitor plays a zero (from bluffing)
figure()
plot(1-output.P_competitor_plays_one_when_playing);
title("Learned Probability of Opponent Playing 0s")
xlabel("Hand #")
ylabel("P( Opponent Plays a 0 | Opponent Plays )")


% let's also see how successfully our model wins rewards
figure()
plot(output.player_balance)
hold on
yline(0);
title("Cumulative Agent Rewards")
xlabel("Hand #")
ylabel("Player Balance ($)");
% yay! our agent performs well and wins more money than it loses!
