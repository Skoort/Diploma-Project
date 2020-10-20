
% factorOfAverage is the weight of faces not being merged.
function HistogramStuff(averageFace, factorOfAverage, OBJs, chosenFaces, finalFace, numBins, upperAngleLimit)

    weightedAverageFace = clone(averageFace);
    weightedAverageFace.Vertices = averageFace.Vertices * factorOfAverage;
    
    for i = 1:length(chosenFaces)
        newVerts = OBJs{chosenFaces(i)}.Vertices;
        weightedAverageFace.Vertices = weightedAverageFace.Vertices + (1 - factorOfAverage) / length(chosenFaces) * newVerts;
    end
    

    % Calculate hist information for the final face (collage).
    [vertNormals, ~] = CalcNormals(finalFace.Vertices, finalFace.Faces);
    angles1 = CalcNormalAngles(finalFace.Vertices, finalFace.Faces, vertNormals);
    [histCounts, histEdges, ~] = CalcHistAngles(angles1, numBins, upperAngleLimit);
    
    % Calculate hist information for the expected average face.
    [vertNormals, ~] = CalcNormals(weightedAverageFace.Vertices, weightedAverageFace.Faces);
    angles3 = CalcNormalAngles(weightedAverageFace.Vertices, weightedAverageFace.Faces, vertNormals);
    [weightedAverageHistCounts, weightedAverageHistEdges, ~] = CalcHistAngles(angles3, numBins, upperAngleLimit);

    figure;
    subplot(1,3,1);
    histogram('BinEdges', weightedAverageHistEdges, 'BinCounts', weightedAverageHistCounts);
    subplot(1,3,2);
    histogram('BinEdges', histEdges, 'BinCounts', histCounts);
    subplot(1,3,3);
    histogram('BinEdges', histEdges, 'BinCounts', abs(histCounts - weightedAverageHistCounts));


    
    

    angle_diff = abs(angles1 - angles3);
    
    finalFaceDiffColored = clone(finalFace);
    for i = 1:size(finalFaceDiffColored.Vertices, 1)
        colorscale = angle_diff(i) / upperAngleLimit;
        finalFaceDiffColored.VertexRGB(i, :) = [1, 1, 1] * colorscale;
    end
    
    finalFaceDiffColored.ColorMode = 'Texture';
    

    DrawFace(finalFaceDiffColored, "Final face angle differences from average", false);
    
    DrawFace(weightedAverageFace, "Weighted average face", false);
    

    
    
    disp('Angular similarity is:');
    disp(AngularSimilarity(weightedAverageHistCounts, histCounts));
   
    
    face_differences = weightedAverageFace.Vertices - finalFaceDiffColored.Vertices;
    
    distances = sqrt(sum(face_differences .^ 2, 2));
    average_distance = sum(distances) / length(distances);

    disp('Average distance is:');
    disp(average_distance);
    
end

