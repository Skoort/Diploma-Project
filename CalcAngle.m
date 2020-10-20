function ThetaInDegrees = CalcAngle(u, v)
    CosTheta = max(min(dot(u,v)/(norm(u)*norm(v)),1),-1);  % Basically calculates CosineSimilarity but removes any rounding errors (clamping to literal 1 and -1).
    ThetaInDegrees = real(acosd(CosTheta));
end

