function [impact] = hedging_policies(perc_cover, perc_forward, change, volume, volume_policy, K)
% crea matrice degli impatti tramite le politiche di copertura/hedging.
% La matrice ha le seguenti dimensioni nell'ordine: volume, perc_cover,
% perc_forward, change
% cost of the options is 5% of strike value

impact = zeros(length(volume),length(perc_cover),length(change),length(perc_forward));

for i = 1:length(volume)
    for j = 1:length(perc_cover)
        volume_no_cover = volume(i) - volume_policy*perc_cover(j);
        for k = 1:length(change)
            if perc_cover(j) == 0
                impact_no_cover = volume(i)*(K-change(k));
                impact(i,j,k,:) = ones(length(perc_forward),1)*impact_no_cover;
            else
                for w = 1:length(perc_forward)
                    %volume_forward = volume_policy*perc_cover(j)*perc_forward(w); %%%%DA CONTROLLARE
                    volume_options = volume_policy*perc_cover(j)*(1-perc_forward(w));

                    cost_options = -volume_options*K*0.05;

                    impact_no_cover = volume_no_cover*(K-change(k));

                    impact_cover = volume_options*max(K-change(k),0);

                    impact(i,j,k,w) = cost_options + impact_no_cover + impact_cover;
                end
            end
        end
    end
end
