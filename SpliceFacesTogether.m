% Requires a random face to make a copy of.
function splicedFace = SpliceFacesTogether(template, OBJs, numRegions, indicesByRegion, numMergedFaces, chosenFaces, chosenFacesByRegion)
    
    splicedFace = clone(template);
    
    for i=1:numRegions
        %color = [255, 255, 255] * (chosenFacesByRegion(i) / numMergedFaces);
        fromColor = [255, 0, 255];
        toColor = [0, 255, 255];
        t = ((chosenFacesByRegion(i)-1) / (numMergedFaces-1));
        color = floor(min(max(fromColor + t*(toColor - fromColor), 0), 255));
        
        faceIndex = chosenFaces(chosenFacesByRegion(i));
        vertices = indicesByRegion{i};
        splicedFace.Vertices(vertices, :) = OBJs{faceIndex}.Vertices(vertices, :);
        splicedFace.VertexRGB(vertices, :) = repmat(color, size(vertices, 1), 1);
    end
end

