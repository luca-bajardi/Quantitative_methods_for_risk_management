function [wp,mup,sigmap] = QuadFolio(expRet, covMat, lambda)
n = length(expRet);
iVet = ones(n,1);
mu = expRet(:);
invSigma = inv(covMat);
charII = iVet' * invSigma * iVet;
charIM = iVet' * invSigma * mu;
wp = invSigma*iVet/charII + ...
 1/lambda * (charII*invSigma*mu - charIM*invSigma*iVet)/charII;
mup = wp'*mu;
sigmap = sqrt(wp' * covMat * wp);
end

