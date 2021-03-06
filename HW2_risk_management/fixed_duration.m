function [price, D_0, D_1, D_2, D_3] = fixed_duration(t_0, portfolio, r, tau, betaValues)
%DETTAGLI PORTAFOGLIO
%quanti bond nel portafoglio
%quanti bond di quel tipo
%maturit? in anni
%face value
%cedola annuale
%numero capitalizzazioni in un anno

% r ? la formula della struttura per scadenza
% tau e betaValues sono collegati alla struttura per scadenza

I=floor(portfolio(1));
N=portfolio(2:(2+I-1));
prices=zeros(1, I);
d_0=zeros(1, I);
d_1=zeros(1, I);
d_2=zeros(1, I);
d_3=zeros(1, I);
tau_1 = tau(1);

if length(tau)~=1 && betaValues(4)~=0 %usiamo la correzione di Svensson 
    tau_2 = tau(2);
end

for i=0:(I-1)
    T=portfolio(I+2+4*i);
    faceValue=portfolio(I+3+4*i);
    annualCoupon=portfolio(I+4+4*i);
    NPayments=portfolio(I+5+4*i);
    
    if NPayments==0
        c=0;
    else
    c=annualCoupon/NPayments*faceValue;
    end
    if mod(T, 1/NPayments)==0
        n=NPayments*T-1; %numero di pagamenti escluso quello della maturit?
        time=linspace(t_0, T, n+2);
        time(1)=[];
    else
        t_1=mod(T, 1/NPayments);
        n=floor(NPayments*T);
        time=linspace(t_1, T, n+1);
    end
    termStructure=zeros(1, length(time));
    for j=1:length(time)
        termStructure(1, j)=r(betaValues,tau,time(j));
        
    end
    t=time.*termStructure;
    prices(1, i+1)=c*sum(exp(-(t(1:n)-t_0)))+(c+faceValue)*exp(-(t(n+1)-t_0));
    
    %derivata parziale del prezzo rispetto beta_0
    d_0(1, i+1)=-((c*sum(time(1:n).*exp(-t(1:n)-t_0)))+(time(n+1)*(c+faceValue)*exp(-(t(n+1)-t_0))));
    d_1(1, i+1)=-((c*sum(time(1:n).*exp(-t(1:n)-t_0).*(1-exp(-time(1:n)/tau_1))./(time(1:n)/tau_1)))...
        +((c+faceValue)*time(n+1).*exp(-t(n+1)-t_0).*(1-exp(-time(n+1)/tau_1))./(time(n+1)/tau_1)));
    d_2(1, i+1)=-((c*sum(time(1:n).*exp(-t(1:n)-t_0).*((1-exp(-time(1:n)/tau_1))./(time(1:n)/tau_1)-exp(-time(1:n)/tau_1))))...
        +((c+faceValue)*time(n+1).*exp(-t(n+1)-t_0).*((1-exp(-time(n+1)/tau_1))./(time(n+1)/tau_1)-exp(-time(n+1)/tau_1))));
    if length(tau)~=1 && betaValues(4)~=0
        d_3(1, i+1)=-((c*sum(time(1:n).*exp(-t(1:n)-t_0).*((1-exp(-time(1:n)/tau_2))./(time(1:n)/tau_2)-exp(-time(1:n)/tau_2))))...
            +((c+faceValue)*time(n+1).*exp(-t(n+1)-t_0).*((1-exp(-time(n+1)/tau_2))./(time(n+1)/tau_2)-exp(-time(n+1)/tau_2))));
    end
    
end
price=sum(N.*prices); %valore del bond

% beta sentitivities
D_0=sum(N.*d_0); %dollar duration
D_1=sum(N.*d_1);
D_2=sum(N.*d_2);
if length(tau)~=1 && betaValues(4)~=0
    D_3=sum(N.*d_3);
else
    D_3=NaN;
end
end
