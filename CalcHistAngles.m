function [histCounts, histEdges, histNorm] = CalcHistAngles(angles, numBins, upperAngleLimit)
    % If we don't supply an upper angle limit, take the biggest possible
    % one, which is 180 degrees.
    if nargin < 3
        % This warning will easily enable me to find where the function was
        % used. Should be in MergeFaces4 and Pre_LoadAddFaces.
        warning("Parameter upperAngleLimit not supplied, assuming 180 degrees.");
        upperAngleLimit = 180;
    end

    % If an angle is greater than the upper angle limit, then we will count
    % that as an occurrence of the last (greatest) bin. By default, I think
    % histcount ignores elements greater than a certain value.
    indicesGreaterThan = angles > upperAngleLimit;
    angles(indicesGreaterThan) = upperAngleLimit;

    edges = linspace(0, upperAngleLimit, numBins+1);
    [histCounts, histEdges] = histcounts(angles, edges);
    histNorm = histCounts / norm(histCounts, 2);

end

