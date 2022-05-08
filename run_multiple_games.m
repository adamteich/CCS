%% run multiple trials @ specific bluff rate
alpha = 0.10;
beta = .25;
num_hands = 1000;
starting_cash = 100;
bust_limit = 7;


num_games = 5000;
win_count = 0;

for i=1:num_games
    output = poker_simulation(alpha, beta, num_hands, starting_cash, bust_limit, bluff_rate);
    if output.player_balance(end)>=starting_cash
        win_count = win_count + 1;
    end
end

winning_rate = win_count/num_games
losing_rate = 1 - winning_rate

%% run multiple trials at different bluff rates
alpha = 0.10;
beta = .25;
num_hands = 1000;
starting_cash = 100;
bust_limit = 7;

num_games = 1000;


bluff_rates = linspace(0,1,21);

for i=1:length(bluff_rates)
    bluff_rate = bluff_rates(i)
    totalWinnings(i) = 0;
    for j=1:num_games
        output = poker_simulation(alpha, beta, num_hands, starting_cash, bust_limit, bluff_rate);
        totalWinnings(i) = totalWinnings(i) + output.player_balance(end);
    end
end
totalWinnings = totalWinnings ./ num_games
plot(bluff_rates,totalWinnings)
title("Model Performance by Bluff Rate")
xlabel("Bluff Rate")
ylabel("Mean Final Balance ($)")