function [loss_perc] = firstOrderImmunization(t_0, portfolio, hedge_inst, r_0, variation)
%Argomenti in input: 
%t_0=istante di tempo in cui voglio calcolare il valore del portafoglio coperto
%portfolio=[NDifferentBond, NBond, T, faceValue, annualCoupon, NPayments], portafoglio da immunizzare
%hedge_inst=[NDifferentBond, NBond, T, faceValue, annualCoupon, NPayments],
%portafoglio che utilizzo per fare copertura
%r_0=struttura per termine che conosco oggi
%variation=struttura per termine che effettivamente si realizza



[price_port,~,  dollar_port]=price_duration(t_0, portfolio,r_0);
[price_H, ~, dollar_H]=price_duration(t_0,hedge_inst,r_0);

V_0=price_port;
phi=-dollar_port/dollar_H;          %quante unità dello strumento di hedging considero=rapporto delle dollar duration

[price_port, ~, ~]=price_duration(t_0,portfolio,variation);
[price_h,~, ~]=price_duration(t_0, hedge_inst,variation);
V=price_port+phi*(price_h-price_H);
loss_perc=100*(V-V_0)/V;
end

%immunizzazione al secondo ordine??
