%abbiamo 3 diversi fattori di rischio che sono collegati
%perchè sono i tassi alle diverse maturità quindi non possono essere
%simulati indipendentemente.
%in t=0 diamo i parametri della curva
clc
clear all
close all
format bank
t_0=0;

%COSA CAMBIA AL VARIARE dei BETA??
beta_0=0.08;
beta_1=-0.03;
beta_2=-0.01;
tau_1=3;
r= @(betaValues,tau,T) betaValues(1)...
    +betaValues(2)*((1-exp(-T/tau(1)))/(T/tau(1)))...
    +betaValues(3)*((1-exp(-T/tau(1)))/(T/tau(1))-exp(-T/tau(1)))...
    +betaValues(4)*((1-exp(-T/tau(2)))/(T/tau(2))-exp(-T/tau(2)));
%metto beta_3 = 0 e tau_2 = 1 così non influenzano il risultato
betaValues=[beta_0 beta_1 beta_2 0];
tau=[tau_1 1];

bond=[1, 1, 5*12, 10000, 0.05, 2];
zero=[1, 1, 0.5*12, 10000, 0, 2]; %capitalizzazione diversa da zero altrimenti errore, rimane uno zeroCouponBond perché coupon = 0% 
[pricebond, D0bond, D1bond, D2bond]=fixed_duration(t_0, bond, r, tau, betaValues);
[pricezero, D0zero, D1zero, D2zero]=fixed_duration(t_0, zero, r, tau, betaValues);
phiNS = - D0bond/D0zero



print_figure = true;
if print_figure
figure
maturities = 1:0.5:20;
tassi = zeros(1,length(maturities));
for i = 1:length(maturities)
    tassi(i) = r(betaValues,tau,maturities(i));
end
plot(maturities,tassi)
end

%Svensson ===> 4 fattori di rischio
beta_3=0.02;
tau_2=5;
betaValues=[beta_0 beta_1 beta_2 beta_3];
tau=[tau_1,tau_2];
%dati temporanei
betaValues = [0.08,-0.03,-0.01,0.02];
tau = [5,8];
bond=[1, 1, 5*12, 10000, 0.05, 2];
zero=[1, 1, 0.5*12, 10000, 0, 2]; %capitalizzazione diversa da zero altrimenti errore, rimane uno zeroCouponBond perché coupon = 0% 
[priceBond, D0bond, D1bond, D2bond]=fixed_duration(t_0, bond, r, tau, betaValues);
[priceZero, D0zero, D1zero, D2zero]=fixed_duration(t_0, zero, r, tau, betaValues);
phi = - D0bond/D0zero
%[priceP, D0P, D1P, D2P, D3P]=fixed_duration(t_0, portfolio, r, tau, betaValues)

if print_figure
figure
maturities = 1:0.5:20;
tassi = zeros(1,length(maturities));
for i = 1:length(maturities)
    tassi(i) = r(betaValues,tau,maturities(i));
end
plot(maturities,tassi)
end

% priceZeroOriginal = priceZero;
% priceBondOriginal = priceBond;
% [priceBond, D0bond, D1bond, D2bond]=fixed_duration(t_0, bond, r, tau, betaValues+betaVariation);
% [priceZero, D0zero, D1zero, D2zero]=fixed_duration(t_0, zero, r, tau, betaValues+betaVariation);
% priceBond + phi*(priceZero-priceZeroOriginal);
% priceBondOriginal;

betaVariation = [0.08 0 0 0];

hedge = zero;
[newValuePosition,priceBondOriginal,priceBondNew] = portfolioShock(t_0,bond,hedge,r,tau,betaValues,betaVariation,phi)
percProfit = (newValuePosition-priceBondOriginal)/priceBondOriginal*100
percProfitNoHedge = (priceBondNew-priceBondOriginal)/priceBondOriginal*100

betaVariation = [0 -0.03 0 0];
[newValuePosition,priceBondOriginal,priceBondNew] = portfolioShock(t_0,bond,hedge,r,tau,betaValues,betaVariation,phi)
percProfit = (newValuePosition-priceBondOriginal)/priceBondOriginal*100
percProfitNoHedge = (priceBondNew-priceBondOriginal)/priceBondOriginal*100

betaVariation = [0 0 0.04 0];
[newValuePosition,priceBondOriginal,priceBondNew] = portfolioShock(t_0,bond,hedge,r,tau,betaValues,betaVariation,phi)
percProfit = (newValuePosition-priceBondOriginal)/priceBondOriginal*100
percProfitNoHedge = (priceBondNew-priceBondOriginal)/priceBondOriginal*100

betaVariation = [0 0 0 0.09];
[newValuePosition,priceBondOriginal,priceBondNew] = portfolioShock(t_0,bond,hedge,r,tau,betaValues,betaVariation,phi)
percProfit = (newValuePosition-priceBondOriginal)/priceBondOriginal*100
percProfitNoHedge = (priceBondNew-priceBondOriginal)/priceBondOriginal*100

%priceBond+dot(phi,priceZero-priceZeroOriginal)

%PROVARE CON PIù ZERI

%struttura dei tassi per alcune variazioni dei beta
seed = 'default';
num_scenari = 7;
mu = zeros(1,4);
sigma = 0.001;
Sigma = eye(4)*(sigma^2);
rng(seed) % For reproducibility
betaVariation = mvnrnd(mu,Sigma,num_scenari);

figure
maturities = 1:0.5:20;
betaValues = [0.08,-0.03,-0.01,0.02];
for j = 1:size(betaVariation,1)
    hold on
    tassi = zeros(1,length(maturities));
    for i = 1:length(maturities)
        tassi(i) = r(betaValues+betaVariation(j,:),tau,maturities(i));
    end
    plot(maturities,tassi)
end

%proviamo con vari valori di deviazione standard
for diff = [1,2,4]
    seed = 'default';
    num_scenari = 10000;%10000
    mu = zeros(1,4);
    sigma = 0.001*diff;
    Sigma = eye(4)*(sigma^2);
    rng(seed) % For reproducibility
    betaVariation = mvnrnd(mu,Sigma,num_scenari);
    
    percProfit = zeros(num_scenari,1);
    percProfitNoHedge = zeros(num_scenari,1);
    for s = 1:num_scenari
        [newValuePosition,priceBondOriginal,priceBondNew] = portfolioShock(t_0,bond,hedge,r,tau,betaValues,betaVariation(s,:),phi);
        percProfit(s) = (newValuePosition-priceBondOriginal)/priceBondOriginal*100;
        percProfitNoHedge(s) = (priceBondNew-priceBondOriginal)/priceBondOriginal*100;
    end
    figure
    histogram(percProfitNoHedge,'Normalization','probability')
    hold on
    histogram(percProfit,'Normalization','probability')
    legend('percProfitNoHedge','percProfitWithHedge')
    hold off
end

%%%%%   SWAP

%%%%% PORTAFOGLIO CON PIù ELEMENTI

%consideriamo 3 bond diversi ===> 3 fattori di rischio
% b1=[2*12, 100, 0.05,1];
% b2=[7*12, 100, 0.05, 1];
% b3=[15*12, 100, 0.05, 1];
% B1=[1, 1, 2*12, 100, 0.05, 1];
% B2=[1, 1, 7*12, 100, 0.05, 1];
% B3=[1, 1, 15*12, 100, 0.05, 1];
% portfolio=[3, 1, 1, 1, b1, b2, b3];
%[price1, D01, D11, D21]=fixed_duration(t_0, B1, r, 3);
%[price2, D02, D12, D22]=fixed_duration(t_0, B2, r, 3);
%[price3, D03, D13, D23]=fixed_duration(t_0, B3, r, 3);

bond=[1, 1, 5*12, 10000, 0.05, 2];
[priceP, D0P, D1P, D2P, D3P]=fixed_duration(t_0, bond, r, tau, betaValues);

% bond=[5*12, 10000, 0.05, 2];
% zero=[0.5*12, 10000, 0, 2];
% portfolio=[2, 1, phi, bond, zero];
% [priceP, D0P, D1P, D2P]=fixed_duration(t_0, portfolio, r, tau, betaValues)

% %posso calcolarli con la funzione di prima
portfolio_sensitivities = [D0P;D1P;D2P;D3P];

%treasury bonds as hedging assets
% A1=[3*12, 100, 0.07, 1];
% A2=[7*12, 100, 0.08, 1];
% A3=[12*12, 100, 0.05, 1];
% A4=[18*12, 100, 0.06, 1];
% A1=[0.5*12, 10000, 0, 2];
% A2=[1.0*12, 10000, 0, 2];
% A3=[1.5*12, 10000, 0, 2];
% A4=[2.0*12, 10000, 0, 2];

asset_sentitivities = zeros(4);

% [p, Dl, Ds,Dg ]=fixed_duration(0, [1, 1, A1], r, tau, betaValues);
% asset_durations(:,1) = [Dl, Ds, Dg, p];
% [p, Dl, Ds,Dg ]=fixed_duration(0, [1, 1, A2], r, tau, betaValues);
% asset_durations(:,2) = [Dl, Ds, Dg, p];
% [p, Dl, Ds,Dg ]=fixed_duration(0, [1, 1, A3], r, tau, betaValues);
% asset_durations(:,3) = [Dl, Ds, Dg, p];
% [p, Dl, Ds,Dg ]=fixed_duration(0, [1, 1, A4], r, tau, betaValues);
% asset_durations(:,4) = [Dl, Ds, Dg, p];

% [p, D_0, D_1, D_2, D_3]=fixed_duration(0, [1, 1, A1], r, tau, betaValues);
% asset_sentitivities(:,1) = [D_0, D_1, D_2, D_3];
% [p, D_0, D_1, D_2, D_3]=fixed_duration(0, [1, 1, A2], r, tau, betaValues);
% asset_sentitivities(:,2) = [D_0, D_1, D_2, D_3];
% [p, D_0, D_1, D_2, D_3]=fixed_duration(0, [1, 1, A3], r, tau, betaValues);
% asset_sentitivities(:,3) = [D_0, D_1, D_2, D_3];
% [p, D_0, D_1, D_2, D_3]=fixed_duration(0, [1, 1, A4], r, tau, betaValues);
% asset_sentitivities(:,4) = [D_0, D_1, D_2, D_3];
% phi = asset_sentitivities\(-portfolio_sensitivities)

A1=[1, 1, 0.5*12, 10000, 0, 2];
A2=[1, 1, 1.0*12, 10000, 0, 2];
A3=[1, 1, 1.5*12, 10000, 0, 2];
A4=[1, 1, 2.0*12, 10000, 0, 2];
[~, D_0, D_1, D_2, D_3]=fixed_duration(0, A1, r, tau, betaValues);
asset_sentitivities(:,1) = [D_0, D_1, D_2, D_3];
[~, D_0, D_1, D_2, D_3]=fixed_duration(0, A2, r, tau, betaValues);
asset_sentitivities(:,2) = [D_0, D_1, D_2, D_3];
[~, D_0, D_1, D_2, D_3]=fixed_duration(0, A3, r, tau, betaValues);
asset_sentitivities(:,3) = [D_0, D_1, D_2, D_3];
[~, D_0, D_1, D_2, D_3]=fixed_duration(0, A4, r, tau, betaValues);
asset_sentitivities(:,4) = [D_0, D_1, D_2, D_3];

phi = asset_sentitivities\(-portfolio_sensitivities)

%swap

fixed = true;
T = 5;
faceValue = 10000;
NPayments = 2;
last_rate = 0.05;
[p_swap,Dd_swap] = swap_duration(fixed, t_0, T, faceValue, NPayments, r, tau, betaValues, last_rate)