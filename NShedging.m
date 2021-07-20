function q = NShedging(portfolio, hedging_instruments)
%Portfolio da coprire [D0, D1, D2, D3]
%diversi strumenti di hedging da utilizzare ciascuno con [d_0, d_1, d_2]
D=-[portfolio(1), portfolio(2), portfolio(3), portfolio(4)]';
n=length(portfolio);
A=zeros(4, n);

for j=1:n
    for i=1:4
        A(i,j)=hedging_instruments(i+4*(j-1));
    end
end
    q=A\D;
end

