clear
clc

betas= [0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5];

num_hands = 1000;
starting_cash = 100;
bust_limit = 7;
bluff_rate = 0.75;

for i=1:length(betas)
    for j=1:1000
        
        output = poker_simulation(0.10, betas(i), num_hands, starting_cash, bust_limit, bluff_rate);
        competitor_bluff_indexes = output.competitor_bluff_indexes;
        bust(i,j)= output.player_balance(end);
        
        competitor_bluff_index_shortened=[];
        W=1;
        while W<length(competitor_bluff_indexes) && competitor_bluff_indexes(W)<length(output.reward)-1
            
            competitor_bluff_index_shortened(end+1)=competitor_bluff_indexes(W);
            W=W+1;
        end
        
        
        if length(competitor_bluff_index_shortened)>0
            N1=length((output.player_actions(competitor_bluff_index_shortened+1)));
            N2=length(output.player_actions);

            post_bluff=output.player_actions(competitor_bluff_index_shortened+1);
            n1=length(post_bluff(post_bluff==1));
            n2= length(output.player_actions(output.player_actions==1));

            p0 = (n1+n2) / (N1+N2);
              n10 = N1 * p0;
              n20 = N2 * p0;
            observed = [n1 N1-n1 n2 N2-n2];
                   expected = [n10 N1-n10 n20 N2-n20];
                   chi2stat = sum((observed-expected).^2 ./ expected);
                   p = 1 - chi2cdf(chi2stat,1);
                   %chi^2 test code via https://www.mathworks.com/matlabcentral/answers/96572-how-can-i-perform-a-chi-square-test-to-determine-how-statistically-different-two-proportions-are-in
            play_after_bluff_rate= mean(output.player_actions(competitor_bluff_index_shortened+1));
            play_rate=mean(output.player_actions);
                   play_more_after_bluff_rate(i,j)=play_after_bluff_rate > play_rate;
                   different_behavior(i,j)=p<0.1;
        end
    end
    
end
% ttest2(bust(1,:), bust(2,:))
% ttest2(bust(2,:), bust(3,:))
% ttest2(different_behavior(1,:),different_behavior(2,:))
[h,p] = ttest2((play_more_after_bluff_rate(1,:)),play_more_after_bluff_rate(2,:))
[h,p] = ttest2((play_more_after_bluff_rate(2,:)),play_more_after_bluff_rate(3,:))
[h,p] = ttest2((play_more_after_bluff_rate(3,:)),play_more_after_bluff_rate(4,:))
[h,p] = ttest2((play_more_after_bluff_rate(4,:)),play_more_after_bluff_rate(5,:))
[h,p] = ttest2((play_more_after_bluff_rate(5,:)),play_more_after_bluff_rate(6,:))
[h,p] = ttest2((play_more_after_bluff_rate(6,:)),play_more_after_bluff_rate(7,:))
[h,p] = ttest2((play_more_after_bluff_rate(7,:)),play_more_after_bluff_rate(8,:))
[h,p] = ttest2((play_more_after_bluff_rate(8,:)),play_more_after_bluff_rate(9,:))

%if =1, then our model implements the gamblers fallacy, playing
%differently after getting bluffed every time

%% 
clf
bar(betas, mean(play_more_after_bluff_rate,2))
ylabel("Proportion of time playing more after bluff occurances")
xlabel("Beta")
title("Gambler's Fallacy Strength by Beta")
ylim([0.55 0.7])