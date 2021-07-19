function [price, D, dollar_duration, C, dollar_convexity] = price_duration(t_0, portfolio,termStructure, last_rate)
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
%C=Convexity
%dollar_convexity

n_elements=floor(portfolio(1));
I=length(portfolio(n_elements+2:length(portfolio)))/4;
N=portfolio(2:(2+n_elements-1));
prices=zeros(1, I);
durations=zeros(1, I);
convexities=zeros(1, I);

for i=0:(I-1)
T=portfolio(n_elements+2+4*i);
faceValue=portfolio(n_elements+3+4*i);
annualCoupon=portfolio(n_elements+4+4*i);
NPayments=portfolio(n_elements+5+4*i);

    if ~exist('last_rate','var') %il portafoglio è costituito da bond
        c=annualCoupon/NPayments*faceValue;
        if mod(T, 12/NPayments)==0
            n=NPayments*T/12-1; %numero di pagamenti escluso quella della maturità
            time=linspace(t_0, T/12, n+2);
            time(1)=[];
            t=time.*termStructure(1:(NPayments*T/12));
        else
            t_1=mod(T, 12/NPayments);
            n=floor(NPayments*T/12);
            time=linspace(t_1/12, T/12, n+1);
            t=time.*termStructure(1:length(time));
        end 
        prices(1, i+1)=c*sum(exp(-(t(1:n)-t_0)))+(c+faceValue)*exp(-(t(n+1)-t_0));
        durations(1, i+1)=1/prices(1, i+1)*(sum(c*(time(1:n)-t_0).*exp(-(t(1:n)-t_0)))+(c+faceValue)*(time(n+1)-t_0)*exp(-(t(n+1)-t_0)));
        convexities(1, i+1)=1/prices(1, i+1)*(sum(c*(time(1:n)-t_0).^2.*exp(-(t(1:n)-t_0)))+(c+faceValue)*(time(n+1)-t_0)^2*exp(-(t(n+1)-t_0)));

    else          %il portafoglio è costituito da floater
        if mod(T,12/NPayments)==0
            next_reset=12/NPayments;
        else
            next_reset=mod(T,12/NPayments);
        end
    c=faceValue*last_rate/NPayments;
    prices(1, i+1)=(c+faceValue)*exp(-(next_reset/12-t_0)*termStructure(1));
    durations(1, i+1)=(next_reset-t_0)/12;
    end

price=sum(N.*prices);
D=1/price*sum(N.*prices.*durations);
dollar_duration=D*price;
C=1/price*(sum(N.*prices.*convexities));
dollar_convexity=price*C;


    
    
end    
end
