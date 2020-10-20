function [chosenFaces, chosenFacesByRegion] = ChooseRandomFaces(numFaces, numRegions, numMergedFaces)
    chosenFaces = datasample(1:numFaces, numMergedFaces, "Replace", false);
    
    % This returned a list of indices of faces.
    %facesByRegion = datasample(chosenFaces, numRegions, "Replace", true);
    %facesByRegion = facesByRegion(:);  % Change to column vector.
    
    % I'd much rather have a list of indices into chosenFaces.
    while true
        chosenFacesByRegion = datasample(1:numMergedFaces, numRegions, "Replace", true);
        chosenFacesByRegion = chosenFacesByRegion(:);  % Change to column vector.
        
        isSurjection = true;
        for face=1:length(chosenFaces)
            if sum(chosenFacesByRegion == face) < 1
                isSurjection = false;
            end
        end
        
        if isSurjection
            break;
        end
    end
end

