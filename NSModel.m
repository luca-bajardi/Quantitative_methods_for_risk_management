%abbiamo 3 diversi fattori di rischio che sono collegati
%perchè sono i tassi alle diverse maturità quindi non possono essere
%simulati indipendentemente.
%in t=0 diamo i parametri della curva
clc
clear all
close all
t_0=0;

%COSA CAMBIA AL VARIARE dei BETA??
beta_0=0.08;
beta_1=-0.03;
beta_2=-0.01;
beta_3=0.02;
tau_1=3;
tau_2=5;
% r= @(beta_0,beta_1,beta_2,T) beta_0+beta_1*((1-exp(-T/tau_1))/(T/tau_1))...
%     +beta_2*((1-exp(-T/tau_1))/(T/tau_1)-exp(-T/tau_1));
r= @(betaValues,tau,T) betaValues(1)...
                      +betaValues(2)*((1-exp(-T/tau(1)))/(T/tau(1)))...
                      +betaValues(3)*((1-exp(-T/tau(1)))/(T/tau(1))-exp(-T/tau(1)));
%consideriamo 3 bond diversi ===> 3 fattori di rischio
b1=[2*12, 100, 0.05,1];
b2=[7*12, 100, 0.05, 1];
b3=[15*12, 100, 0.05, 1];
B1=[1, 1, 2*12, 100, 0.05, 1];
B2=[1, 1, 7*12, 100, 0.05, 1];
B3=[1, 1, 15*12, 100, 0.05, 1];
portfolio=[3, 1, 1, 1, b1, b2, b3];
%[price1, D01, D11, D21]=fixed_duration(t_0, B1, r, 3);
%[price2, D02, D12, D22]=fixed_duration(t_0, B2, r, 3);
%[price3, D03, D13, D23]=fixed_duration(true, t_0, B3, r, 3);
betaValues=[beta_0 beta_1 beta_2];
tau=[tau_1];
[priceP, D0P, D1P, D2P]=fixed_duration(true, t_0, portfolio, r, tau, betaValues)

figure
maturities = 1:0.5:20;
tassi = zeros(1,length(maturities));
for i = 1:length(maturities)
    tassi(i) = r(betaValues,tau,maturities(i));
end
plot(maturities,tassi)


%Svensson ===> 4 fattori di rischio
r2= @(betaValues,tau,T) betaValues(1)...
    +betaValues(2)*((1-exp(-T/tau(1)))/(T/tau(1)))...
    +betaValues(3)*((1-exp(-T/tau(1)))/(T/tau(1))-exp(-T/tau(1)))...
    +betaValues(4)*((1-exp(-T/tau(2)))/(T/tau(2))-exp(-T/tau(2)));
betaValues=[beta_0 beta_1 beta_2 beta_3];
tau=[tau_1,tau_2];
[priceP, D0P, D1P, D2P, D3P]=fixed_duration(true, t_0, portfolio, r2, tau, betaValues)

figure
maturities = 1:0.5:20;
tassi = zeros(1,length(maturities));
for i = 1:length(maturities)
    tassi(i) = r2(betaValues,tau,maturities(i));
end
plot(maturities,tassi)

%
%Vasicek=esempio 6.8
clear all 
%close all
%clc

L=0.06;
S=0.025;
G=-0.05;
a=0.4;
%syms L S G T
rv=@(T) L-S*((1-exp(-0.4*T))/(0.4*T))+G*((1-exp(-0.4*T))^2/(4*0.4*T));
%rv=subs(rv, {L, S, G, T}, {0.06, 0.025, -0.05, sym('T')});
%rv=subs(rv, {L, S, G, T}, {sym('L'), sym('S'), sym('G'), 1});

%beta_0=L;
%beta_1=-S;
%beta_2= @(T) (G/4+G/4*exp(-2*a*T)-G/2*exp(-a*T))/(1-(exp(-a*T)*(1+a*T)));
%tau_1=1/a;
%r= @(T) beta_0+beta_1*((1-exp(-T/tau_1))/(T/tau_1))...
%    +beta_2(T)*((1-exp(-T/tau_1))/(T/tau_1)-exp(-T/tau_1));
%posso calcolarli con la funzione di prima
P=32863500;
DL=-224016404;
DS=63538154;
DG=-13264994;
portfolio_duration = [DL;DS;DG;P];

%treasury bonds as hedging assets
A1=[3*12, 100, 0.07, 1];
A2=[7*12, 100, 0.08, 1];
A3=[12*12, 100, 0.05, 1];
A4=[18*12, 100, 0.06, 1];

asset_durations = zeros(4);

[p, Dl, Ds,Dg ]=fixed_duration(false, 0, [1, 1, A1], rv, 1/a);
asset_durations(:,1) = [Dl, Ds, Dg, p];
[p, Dl, Ds,Dg ]=fixed_duration(false, 0, [1, 1, A2], rv, 1/a);
asset_durations(:,2) = [Dl, Ds, Dg, p];
[p, Dl, Ds,Dg ]=fixed_duration(false, 0, [1, 1, A3], rv, 1/a);
asset_durations(:,3) = [Dl, Ds, Dg, p];
[p, Dl, Ds,Dg ]=fixed_duration(false, 0, [1, 1, A4], rv, 1/a);
asset_durations(:,4) = [Dl, Ds, Dg, p];

phi = asset_durations\(-portfolio_duration)