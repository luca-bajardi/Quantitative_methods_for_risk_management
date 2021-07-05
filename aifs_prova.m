clc
clear all
close all
format bank


%definizione variabili
usd=[1.01, 1.22, 1.48];
percentuale_copertura=[0, 0.25, 0.5, 0.75, 1];
volume_h=25000;
volume_effettivo=[10000, 25000, 30000];
costo_individuale=1;
K=1.22; %strike price dei contratti forward e opzioni
percentuale_contratto=percentuale_copertura;


%alloco 
r_nohedge=zeros(1, length(usd));
r=zeros(length(percentuale_contratto)+1, length(usd)+1, length(percentuale_copertura)-1, length(volume_effettivo));



for v=1:length(volume_effettivo) %per ogni realizzazione del volume
   uno = figure('Name', strcat('Volume effettivo= ', string(volume_effettivo(v))));
   %servononper fare i disegni una sola volta
   flag=0;
   flag2=0;
 
   for i=1: length(usd) %per ogni scenario del valore del dollaro
      
     for k=1:length(percentuale_copertura) %quanto voglio coprire
    
         if percentuale_copertura(k)==0 %non faccio hedging
            
             zero_impact=volume_effettivo(v)*costo_individuale*K; %costo di riferimento
             costo_effettivo=costo_individuale*volume_effettivo(v)*usd(i); %quello che effettivamente spendo
             r_nohedge(1, i, v)=zero_impact-costo_effettivo;
         
        
         else %sto facendo hedging
              
            r(1,1,k-1, v)=percentuale_copertura(k); %di quanto faccio la copertura
            r(1, 2:length(usd)+1, k-1, v)=usd;
            r(2:length(percentuale_contratto)+1, 1, k-1, v)=percentuale_contratto';
             %prova plot
                    if v==2 && percentuale_copertura(k)==1 && i==3 && flag==0 
                        hold off
                        figure('Name', 'Diverse percentuali FW');
                        flag=1; 
                    end
                    
            for j=1:length(percentuale_contratto)
                    %copertura_contratto=percentuale_copertura(k)*percentuale_contratto(j)*(K-usd(i))*(volume_effettivo(v)-volume_h)*costo_individuale;
                    copertura_contratto=percentuale_contratto(j)*(K-usd(i))*(volume_effettivo(v)-volume_h*percentuale_copertura(k))*costo_individuale;
                    
                   % if percentuale_contratto(j)==1 %sto coprendo tutto con forward
                    %    costo_opzione=0;
                    %    copertura_opzione=0;
                   % else %sto coprendo qualcosa con un'opzione
                        costo_opzione=5/100*percentuale_copertura(k)*(1-percentuale_contratto(j))*K*volume_h*costo_individuale;
                        %copertura_opzione=percentuale_copertura(k)*(1-percentuale_contratto(j))*(K-usd(i))*(volume_effettivo(v)-(volume_h*max(0, (usd(i)-K)/abs(usd(i)-K))))*costo_individuale;
                  %  end
                  copertura_opzione=(1-percentuale_contratto(j))*(K-usd(i))*(volume_effettivo(v)-(percentuale_copertura(k)*volume_h*max(0, (usd(i)-K)/abs(usd(i)-K))))*costo_individuale;
                  
                    
                   r(j+1,i+1,k-1, v)=copertura_contratto+copertura_opzione-costo_opzione;
                   if flag==1 
                      hold on
                      plot(usd,r(j+1,2:length(usd)+1,4, 2))
                      flag2=1;
                   end
                  
            end
           
         end
   
     end
     
     if flag2==1
        legend(string(percentuale_contratto))
        flag2=0;   
     end  
    end
 
 figure(uno)
 hold off
 plot(usd, r_nohedge(1, :, v), '-s','MarkerSize',10, 'MarkerEdgeColor','red', 'MarkerFaceColor',[1 .6 .6]);
 hold on
 plot(usd, r(2,2:length(usd)+1, 4, v), '-s','MarkerSize',10, 'MarkerEdgeColor','red', 'MarkerFaceColor',[1 .6 .6]);
 hold on
 plot (usd, r(6, 2:length(usd)+1, 4, v),'-s','MarkerSize',10, 'MarkerEdgeColor','red', 'MarkerFaceColor',[1 .6 .6]);
 legend('no hedge', '100% options', '100% forward')
end