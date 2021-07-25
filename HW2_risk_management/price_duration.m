function [price, D, dollar_duration] = price_duration(t_0, portfolio, r, tau, betaValues, last_rate)
%Argomenti in input:
%t_0=istante di tempo in cui voglio calcolare il valore del portafoglio
%portfolio=[NDifferentBond, NBond, T, faceValue, annualCoupon, NPayments], portafoglio da immunizzare
%termStructure=quella che conosco oggi
%last_rate=parametro opzionale, serve solo quando di tratta di un floater
%perchè serve per calcolare il prossimo pagamento

%Argomenti in output
%price=valore attuale del portafoglio
%D=duration
%dollar_duration


I=floor(portfolio(1));
N=portfolio(2:(2+I-1));
prices=zeros(1, I);
durations=zeros(1, I);

for i=0:(I-1)
    T=portfolio(I+2+4*i);
    faceValue=portfolio(I+3+4*i);
    annualCoupon=portfolio(I+4+4*i);
    NPayments=portfolio(I+5+4*i);
    
    if ~exist('last_rate','var') %il portafoglio è costituito da bond
        if mod(T, 1/NPayments)==0
            n=NPayments*T-1; %numero di pagamenti escluso quello della maturità
            time=linspace(t_0, T, n+2);
            time(1)=[];
            
        else
            t_1=mod(T, 1/NPayments);
            n=floor(NPayments*T);
            time=linspace(t_1, T, n+1);
            
        end
        termStructure=zeros(1, length(time));
        for j=1:length(time)
            termStructure(j)=r(betaValues,tau,time(j));
        end
        
        t=time.*termStructure;
        if ~isnan(annualCoupon)
            c=annualCoupon/NPayments*faceValue;
        else    %calcoliamo lo swap rate
            c=NPayments*(1-exp(-T*termStructure(T+2)))/sum(exp(-t(1:T+2)));
        end
        prices(1, i+1)=c*sum(exp(-(t(1:n)-t_0)))+(c+faceValue)*exp(-(t(n+1)-t_0));
        durations(1, i+1)=1/prices(1, i+1)*(sum(c*(time(1:n)-t_0).*exp(-(t(1:n)-t_0)))+(c+faceValue)*(time(n+1)-t_0)*exp(-(t(n+1)-t_0)));
        
    else          %il portafoglio è costituito da floater
        if mod(T,1/NPayments)==0
            next_reset=1/NPayments;
        else
            next_reset=mod(T,1/NPayments);
        end
        c=faceValue*last_rate/NPayments;
        prices(1, i+1)=(c+faceValue)*exp(-(next_reset-t_0)*r(betaValues,tau,next_reset));
        durations(1, i+1)=(next_reset-t_0);
    end
    
    price=sum(N.*prices);
    D=1/price*sum(N.*prices.*durations);
    dollar_duration=D*price;
    
    
end
end
