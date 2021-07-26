function [newValuePosition,priceBondOriginal,priceBondNew] = portfolioShock(t_0,bond,hedge,r,tau,betaValues,betaVariation,phi,type,fixed,last_rate)



[priceBondOriginal, ~, ~, ~]=fixed_duration(t_0, bond, r, tau, betaValues);
[priceBondNew, ~, ~, ~]=fixed_duration(t_0, bond, r, tau, betaValues+betaVariation);

if exist('type','var') && strcmp(type,'swap')
    [priceSwapOriginal, ~,k,last_rateUsed]=swap_duration(t_0, hedge, r, tau, betaValues, fixed, last_rate);
    I=floor(hedge(1));
    for i=0:(I-1)
        hedge(I+4+4*i) = k; %diciamo qual è l'annual coupon perché già definito e non influenzato dagli shock
    end
    [priceSwap, ~, ~, ~]=swap_duration(t_0, hedge, r, tau, betaValues+betaVariation, fixed, last_rateUsed);
    newValuePosition = priceBondNew + (priceSwap - priceSwapOriginal);
else
    hedge(2:2+hedge(1)-1)=phi;
    [priceZeroOriginal, ~, ~, ~]=fixed_duration(t_0, hedge, r, tau, betaValues);
    [priceZero, ~, ~, ~]=fixed_duration(t_0, hedge, r, tau, betaValues+betaVariation);
    newValuePosition = priceBondNew + (priceZero - priceZeroOriginal);
end

