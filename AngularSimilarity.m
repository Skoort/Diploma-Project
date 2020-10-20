function theta = AngularSimilarity(u, v)
    theta = 1 - acos(CosineSimilarity(u, v)) / pi;  % Biggest angular distance is pi, smallest is 0.
end

function cosTheta = CosineSimilarity(u, v)
    cosTheta = dot(u, v) / (norm(u, 2) * norm(v, 2));
end
