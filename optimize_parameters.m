clear

alphas = linspace(0.01,1,100);
betas = linspace(0.01,1,100);

for i = 1:length(alphas)
    totalWinningsAlpha(i) = 0;
    for k = 1:1000
        alpha = alphas(i);
        beta=0.2;
        num_hands = 1000;
        starting_cash = 100;
        bluff_rate = 0.25;
        bust_limit = 7;
        trial = poker_simulation(alpha, beta, num_hands, starting_cash, bust_limit, bluff_rate); 
        totalWinningsAlpha(i) = totalWinningsAlpha(i) + sum(trial.reward);
    end
    percentComplete = i/2
end
[bestAlphaMean, bestAlphaIndex] = max(totalWinningsAlpha);
bestAlpha = alphas(bestAlphaIndex)
for i = 1:length(betas)
    totalWinningsBeta(i) = 0;
    for k = 1:1000
        alpha = bestAlpha;
        beta=betas(i);
        trial = poker_simulation(alpha, beta, num_hands, starting_cash, bust_limit, bluff_rate); 
        totalWinningsBeta(i) = totalWinningsBeta(i) + sum(trial.reward);
    end
    percentComplete = i/2 + 50
end
totalWinningsAlpha = totalWinningsAlpha ./ 1000;
[bestAlphaMean, bestAlphaIndex] = max(totalWinningsAlpha);
bestAlpha = alphas(bestAlphaIndex)
totalWinningsBeta = totalWinningsBeta ./ 1000;
[bestBetaMean, bestBetaIndex] = max(totalWinningsBeta);
bestBeta = alphas(bestBetaIndex)

%%
figure()
plot(alphas, totalWinningsAlpha)
title("Optimal Alpha Values")
ylabel("Average Ending Balance ($)")
xlabel("Alpha Value")
figure()
plot(betas, totalWinningsBeta)
title("Optimal Beta Values")
ylabel("Average Ending Balance ($)")
xlabel("Beta Value")