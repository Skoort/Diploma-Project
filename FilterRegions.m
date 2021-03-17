% chosenFaces stays the same.
function [newNumRegions, newRegionByIndex, newIndicesByRegion, newChosenFacesByRegion] = FilterRegions(regionByIndex, indicesByRegion, chosenFaces, chosenFacesByRegion)
    newNumRegions = length(chosenFaces);

    newChosenFacesByRegion = (1:length(chosenFaces))';  % We want column vector.
    
    newIndicesByRegion = cell(size(chosenFaces));
    for i = 1:length(indicesByRegion)
        faceIndex = chosenFacesByRegion(i);
        newIndicesByRegion{faceIndex} = [newIndicesByRegion{faceIndex}; indicesByRegion{i}];
    end
    
    newRegionByIndex = zeros(size(regionByIndex));
    for i = 1:length(regionByIndex)
        oldRegionId = regionByIndex(i);
        newRegionId = chosenFacesByRegion(oldRegionId);
        newRegionByIndex(i) = newRegionId;
    end
end