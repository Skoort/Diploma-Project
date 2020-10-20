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
%{

% Previous idea was that I wanted to separate each face region into
separate regions that don't touch. So group 3 regions with same face that
touch, but leave last region with that face alone because it doesn't touch.
Turns out that is probably unnecessary because of how I am chiseling away
at the regions.
function [newRegions, newRegionByIndex, newIndicesByRegion, newChosenFacesByRegion] = FilterRegions(template, regionByIndex, indicesByRegion, chosenFacesByRegion)
    % We only need template for the Faces member.
    
    regionEquivalences = {};

    % Iterate over every vertex.
    for vertexIndex = 1:length(regionByIndex)
        regionIndex = regionByIndex(vertexIndex);
        chosenFaceIndex = chosenFacesByRegion(regionIndex);
        
        % 1. Get the vertex's neighbors.
        % Get the indices of faces containing vertexIndex.
        locations_ = (merged_copy.Faces == vertexIndex);
        [locations_, ~] = find(locations_);
        
        % Get the vertices in these faces that are not vertexId.
        neighbors = unique(merged_copy.Faces(locations_, :));
        neighbors = setdiff(neighbors, vertexId);
        
        % 2. Iterate over these neighbors.
        for neighborId = 1:length(neighbors)
            neighborRegionId = regionByIndex(neighborId);
            
            if chosenFacesByRegion(neighborRegionId) ~= chosenFaceIndex
                continue;
            end
            
            % 3. For every member of the same face not in the same region,
            % add a relation to that vertex's region.
            if regionIndex ~= neighborRegionId
                
            end
        end
    end

end
%}