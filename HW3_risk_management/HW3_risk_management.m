clc
clear all
close all
%Sto usando questo tipo di modello (assumo una distribuzione di probabilità),
%ma non vado a beccare i parametri giusti
%quindi si introduce del rumore nel portafoglio. Vediamo cosa comporta in termini
%di rendimento



%Symbol	Company Name
% AAPL	Apple, Inc.
% SBUX	Starbucks, Inc.
% MSFT	Microsoft, Inc.
% CSCO	Cisco Systems, Inc.
% QCOM	QUALCOMM Incorporated
% FB	Facebook, Inc.
% AMZN	Amazon.com, Inc.
% TSLA	Tesla, Inc.
% AMD	Advanced Micro Devices, Inc.
% ZNGA	Zynga Inc.

list_stock= ["AAPL","SBUX","MSFT","CSCO","QCOM","FB","AMZN","TSLA","AMD","ZNGA"];
num_asset = length(list_stock);

% T = readtable(strcat('stock/',list_stock(3),".csv"),'PreserveVariableNames',0);
% values = str2double(strrep(string(T.Close_Last),'$',''));
% date = datetime(T.Date);
% var = (values(2:end)-values(1:end-1))./values(1:end-1);
% figure
% plot(date(2:end),var)

%per eliminare warning nella creazione delle table
warning('OFF', 'MATLAB:table:ModifiedAndSavedVarnames')

figure
returns = zeros(num_asset,1257);
for i = 1:length(list_stock)
    T = readtable(strcat('stock/',list_stock(i),".csv"));
    date = flip(datetime(T.Date));
    date(1) = [];
    values = flip(str2double(strrep(string(T.Close_Last),'$','')));
    returns(i,:) = (values(2:end)-values(1:end-1))./values(1:end-1);
    hold on
    plot(date,returns(i,:))
end
title('Asset returns');
legend(list_stock);

startDate = date(300)
finishDate = date(803)
date = date(300:803);
returns = returns(:,300:803);
figure
for i = 1:num_asset
    hold on
    plot(date,returns(i,:))
end
title('Asset returns (small period)');
legend(list_stock);
hold off

trueMu = mean(returns,2)
trueSigma = cov(returns')

% %Consideriamo una distribuzione normale multivariata
% trueMu = [0.07; 0.05];
% trueVols = [0.20; 0.15]; % deviazione standard del rendimento
% trueRho = 0.7;
% % trucco per ottenere matrice di covarianza da matrice correlazione
% trueSigma = [1 trueRho; trueRho 1].*(trueVols * trueVols');
lambda = 3;
%Non impongo vincoli sulla vendita allo scoperto
[truewp,~,~] = QuadFolio(trueMu, trueSigma, lambda);
truew1 = truewp(1);

figure
stockCat = categorical(list_stock);
stockCat = reordercats(stockCat,list_stock);
bar(stockCat,truewp)
title('Weights with Lambda = 3')
Weights = zeros(num_asset,3);
Weights(:,2) = truewp;
%in alternativa posso usare la funzione già implementata in matlab che però
%non sfrutta la soluzione in forma chiusa

options = optimoptions('quadprog','Display','none');
x = quadprog(lambda*trueSigma,-trueMu,[],[],ones(1,num_asset),1,[],[],[],options);
%check stesso risultato
max(abs(truewp-x))<1.0e-4

% %errori di stima sui valori attesi
% err_absMu=max(abs(mup-trueMu));
% err_relMu=max(abs(mup-trueMu))/trueMu;
% 
% %errori di stima sulla matrice di cov
% err_abs_S=max(abs(trueSigma-sigmap));
% err_rel_S=max(abs(trueSigma-sigmap))/trueSigma;


%facendo varie replicazioni vediamo che a seconda dei valori di mu e sigma
%campionati si ottengono valori di w diversi (usando 250 campioni ad
%indicare un'analisi relativa all'anno precedente
% w=estimated_weights(1000, 250, trueMu, trueSigma, lambda);
% figure
% histogram(w(:,1),50); %peso del primo asset nel portafoglio
% xline(truew1,'r','LineWidth',3); %valore ottimo vero
% title('Peso del primo asset nel portafoglio');

rng('default'); % ripetibilità
[~,w] = estimated_portfolio(1000, trueMu, trueSigma, lambda, 0, 'estimated', false, 250);
figure
histogram(w(:,1),50); %peso del primo asset nel portafoglio
xline(truew1,'r','LineWidth',3); %valore ottimo vero
title('Peso del primo asset nel portafoglio');
%estrema variabilità del peso nel portafoglio

%possiamo vederlo equivalentemente sul secondo asset perchè in questo caso
%sono solamente due
%histogram(w(:,2),50); 
%xline(1-truew1,'r','LineWidth',3);

%%

%EFFETTO DELLA DIMENSIONE DEI DATI SU CUI FITTO LA DISTRIBUZUIONE

%vediamo come migliora la soluzione quando aumentiamo il numero di
%campioni a disposizione
figure 
% w1=estimated_weights(1000, 2500, trueMu, trueSigma, lambda);
rng('default'); % ripetibilità
[~,w1] = estimated_portfolio(1000, trueMu, trueSigma, lambda, 0, 'estimated', false, 2500);
histogram(w1(:, 1),50);
xline(truew1,'r','LineWidth',3);
title('Aumento la dimensione dei dati su cui fitto la distribuzione')
%la variabilità si riduce di molto
%nella realtà non avremo mai a disposizione tutti questi dati
%quindi continuo ad usare un numero più basso

%%
%EFFETTO DELL'AVVERSIONE AL RISCHIO
 lambda2=2;
[truewp,~,~] = QuadFolio(trueMu, trueSigma, lambda2);
Weights(:,1) = truewp;
% truew_lambda = truewp(1);
% w_lambda=estimated_portfolio(1000, 300, trueMu, trueSigma, lambda2);
% figure
% histogram(w_lambda(:,1),50); %peso del primo asset nel portafoglio
% xline(truew_lambda,'r','LineWidth',3); %valore ottimo vero
% title('Effetto del coef. di avversione al rischio');

lambda3=4;
[truewp,~,~] = QuadFolio(trueMu, trueSigma, lambda3);
% truew_lambda = truewp(1);
Weights(:,3) = truewp;
% w_lambda=estimated_portfolio(1000, 300, trueMu, trueSigma, lambda3);
% figure
% histogram(w_lambda(:,1),50); %peso del primo asset nel portafoglio
% xline(truew_lambda,'r','LineWidth',3); %valore ottimo vero
% title('Effetto del coef. di avversione al rischio2');

%Valori accettabili del coefficiente di avversione al rischio sono quelli
%dell'intervallo [2, 4]. Sembra che all'aumentare di lambda la variabilità
%viene ridotta perché siamo più avversi al rischio e quindi vogliamo meno
%variabilità
figure
bar(stockCat,Weights)

%%
%EFFETTO DEI VINCOLI SULLO SCOPERTO
%Andiamo ad imporre un ulteriore vincolo
%Non solo richiediamo che la somma di tutti i pesi deve essere uguale ad 1,
%ma anche che tutti i pesi devono essere positivi (no vendita allo
%scoperto)
% options = optimoptions('quadprog','Display','none');
% rng('default');
% x_no_scoperto1 = quadprog(lambda*trueSigma,-trueMu,-eye(length(trueMu)),zeros(length(trueMu),1),ones(1,length(trueMu)),1,[],[],[],options);
rng('default');
[~,x_no_scoperto] = estimated_portfolio(1, trueMu, trueSigma, lambda, 0, 'optimalNoShort', false, 0);
% wns=estimated_portfolio(1000, 3000, trueMu, trueSigma, lambda);
% figure
% histogram(wns(:, 1),50);
% xline(x_no_scoperto(1),'r','LineWidth',3);
% title('No vendita allo scoperto');
bar(stockCat,x_no_scoperto)
title('Weights with w>=0')

%%
%PORTAFOGLIO DI MINIMA VARIANZA
%Non tengo conto dei valori attesi e intuitivamente potrebbe sembrare una
%scelta azzardata, ma visto che sto commettendo degli errori di stima
%faccio entrare meno errori nel modello, quindi in alcune circostanze
%potrebbe essere utile capire cosa accade.
% options = optimoptions('quadprog','Display','none');
% rng('default'); 
% returnsObs = mvnrnd(trueMu,trueSigma,250);
% hatSigma = cov(returnsObs);
% xmv= quadprog(lambda*hatSigma,[],[],[],ones(1,num_asset),1,[],[],[],options);
rng('default'); % ripetibilità
[~,xmv] = estimated_portfolio(1, trueMu, trueSigma, lambda, 0, 'minvariance', false, 250);

% truew_lambda = xmv(2);
% %non so se serve farlo??
% w_mv=minvariance(1000, 300, trueMu, trueSigma, lambda, options);
% figure
% histogram(w_mv(:,2),50); %peso del secondo asset nel portafoglio
% xline(truew_lambda,'r','LineWidth',3); %valore ottimo vero
% title('Portafoglio di minima varianza');
% figure
% bar(stockCat,xmv)
% title('Pesi di un portafoglio di minima varianza')
figure
bar(stockCat,xmv)
title('Pesi di un portafoglio di minima varianza')

%BISOGNA confrontare il rendimento del portafoglio ottimo con quello di
%minima varianza su un orizzonte di tempo

%%
%PORTAFOGLIO NAIVE
%Stesso orizzonte di tempo di prima, confrontare il rendimento
w_naive=1/length(trueMu)*ones(length(trueMu), 1);
figure
bar(stockCat,w_naive)
title('Pesi di un portafoglio naive')
%[x0,y0,width,height] = [0,0,0.2,0.2];
% fig=gcf;
% fig.Position(2)=0;
% fig.Position(4)=0.2;
ylim([-0.05 0.2])
%% stima rendimenti
rng(2020); % ripetibilità
numRepl = 1;
plotWealth = true;
num_days = 250;
numPastDays = 250;
types = ["optimal","optimalNoShort","estimated","estimatedNoShort","minvariance","naive"];
for type = 1:length(types)
    estimated_portfolio(numRepl, trueMu, trueSigma, lambda, num_days, types(type), plotWealth, numPastDays);
end

%% stima rendimenti con aggiornamento pesi ogni settimana
rng(2020); % ripetibilità
plotWealth = true;
num_days = 250;
num_days_update = 5;
types = ["estimated","estimatedNoShort","minvariance"];
for type = 1:length(types)
    estimated_portfolio(numRepl, trueMu, trueSigma, lambda, num_days, types(type), plotWealth, numPastDays, num_days_update);
end

%%
%Hanno più impatto errori sui premi per il rischio o sulle
%covarianze/correlazioni?? errori sui premi per il rischio, PERCHE'????
numRepl = 1000;
plotWealth = false;
rng(2020);
[wealth,w] = estimated_portfolio(numRepl, trueMu, trueSigma, lambda, num_days, 'optimal', plotWealth, numPastDays);


%applichiamo piccola variazione sulla stima (errore di stima) e aumenta
%variabilità sia in positivo che in negativo
muVariation = zeros(length(trueMu),1);
muVariation(5) =  0.001;
muVariation(10) = -0.001;
rng(2020);
[wealthVar,wVar] = estimated_portfolio(numRepl, trueMu+muVariation, trueSigma, lambda, num_days, 'estimated', plotWealth, numPastDays);

%il valore medio più basso senza variazione ma anche meno variabilità,
%intesa sia come perdita che guadagno
meanOptimal = mean(wealth(:,end))
meanVariation = mean(wealthVar(:,end))
stdOptimal = std((wealth(:,end)))
stdVariation = std((wealthVar(:,end)))

figure
histogram(wealth(:,end),35,'BinLimits',[0,35000])
hold on
histogram(wealthVar(:,end),35,'BinLimits',[0,35000])
xline(1000,'r','LineWidth',2);
legend('orginal','variation')

figure
bar([w(1,:)' wVar(1,:)'])
legend('orginal','variation')

%%
%Effetto di asimmetrie o code grasse (volendo potete cambiare distribuzione di probabilità e
%valutare la variabilità del portafoglio)
 %la normale è già una distribuzione abbastanza buona, ma si può trovare
 %qualcosa di meglio... COPULE