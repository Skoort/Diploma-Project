%{
template.VertexRGB(1:template.nVertices, 1:3) = repmat([1, 1, 1], template.nVertices, 1);
template.VertexRGB(indicesByRegion{1}, :) = repmat([1, 0, 0], length(indicesByRegion{1}), 1);
template.ColorMode = 'texture';
%}

function [newNumRegions, newRegionByIndex, newIndicesByRegion, newChosenFacesByRegion] = FilterRegions2(template, regionByIndex, indicesByRegion, chosenFacesByRegion)
    % We only need template for the Faces member.
    
    regionEquivalences = cell(length(indicesByRegion), 1);  % Each index is a region, each value represents that region's equivalent regions.
	
    % Iterate over every vertex.
    for vertexIndex = 1:length(regionByIndex)
        regionIndex = regionByIndex(vertexIndex);
        chosenFaceIndex = chosenFacesByRegion(regionIndex);
        
        % 1. Get the vertex's neighbors.
        % Get the indices of faces containing vertexIndex.
        locations_ = (template.Faces == vertexIndex);
        [locations_, ~] = find(locations_);
        
        % Get the vertices in these faces that are not vertexId.
        neighbors = unique(template.Faces(locations_, :));
        neighbors = setdiff(neighbors, vertexIndex);
        
        % 2. Iterate over these neighbors.
        for neighborId = 1:length(neighbors)
            neighborIndex = neighbors(neighborId);
            neighborRegionId = regionByIndex(neighborIndex);
            neighborFace = chosenFacesByRegion(neighborRegionId);
            
            if neighborFace ~= chosenFaceIndex 
                continue;
            end
            
            % 3. For every member of the same face not in the same region,
            % add a relation to that vertex's region.
			equivalences = regionEquivalences{regionIndex};
            if regionIndex ~= neighborRegionId && ~any(equivalences == neighborRegionId)
                regionEquivalences{regionIndex} = [equivalences; neighborRegionId];
            end
        end
    end
	
    % The regionEquivalences each only have direct neighbors. Need to take
    % recursive union.
    
	usedRegions = {};
	newNumRegions = 0;
		
	newRegionByIndex = zeros(size(regionByIndex));
	newIndicesByRegion = {};
	newChosenFacesByRegion = [];
	
	for vertexIndex = 1:length(regionByIndex)
		regionIndex = regionByIndex(vertexIndex);
		chosenFaceIndex = chosenFacesByRegion(regionIndex);
		
		equivalences = [regionIndex; regionEquivalences{regionIndex}];
		
		newRegion = newNumRegions + 1;
		for i = 1:newNumRegions
            if (regionIndex == 6)
                disp(1);
            end
			if any(ismember(equivalences, usedRegions{i}))
				newRegion = i;
				break;
			end
		end
		if newRegion == newNumRegions + 1
			usedRegions{newRegion} = equivalences;
			newIndicesByRegion{newRegion} = [];
			newChosenFacesByRegion(newRegion) = chosenFaceIndex;
            newNumRegions = newNumRegions + 1;
		end
		
		newRegionByIndex(vertexIndex) = newRegion;
		newIndicesByRegion{newRegion} = [newIndicesByRegion{newRegion}; vertexIndex];
	end
end