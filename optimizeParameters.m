clear

alphas = linspace(0,1,100);
betas = linspace(0,1,100);

for i = 1:length(alphas)  
    for j = 1:length(betas) 
        totalWinnings(i,j) = 0;
        for k = 1:5
            alpha = alphas(i);
            beta=betas(j);

            % SETUP:
            num_hands = 1000;
            starting_cash = 100;
            competitor_cards = randi([0 1], num_hands, 1);
            competitor_actions = competitor_cards;
            middle_cards = randi([0 1], num_hands, 1);
            self_cards = randi([0 1], num_hands, 1);
            bluffProportion = 0.25;
            for x=1:length(competitor_actions)
                if competitor_actions(x)==0 && rand<bluffProportion
                    competitor_actions(x)=1;
                end
            end
            trial = poker_simulation(alpha, beta, competitor_cards, competitor_actions, middle_cards, self_cards, starting_cash); 
            totalWinnings(i,j) = totalWinnings(i,j) + sum(trial.reward);
        end
    end
    percentComplete = i
end
%%

meansByBeta = mean(totalWinnings)
meansByAlpha = mean(totalWinnings, 2)

[bestAlphaMean, bestAlphaIndex] = max(meansByAlpha);
[bestBetaMean, bestBetaIndex] = max(meansByBeta);

bestAlpha = alphas(bestAlphaIndex)
bestBetas = alphas(bestBetaIndex)