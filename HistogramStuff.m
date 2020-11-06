
% factorOfAverage is the weight of faces not being merged.
function HistogramStuff(averageFace, factorOfAverage, OBJs, chosenFaces, finalFace, numBins, upperAngleLimit, indicesByRegion)

    weightedAverageFace = clone(averageFace);
    weightedAverageFace.Vertices = averageFace.Vertices * factorOfAverage;
    
    for i = 1:length(chosenFaces)
        newVerts = OBJs{chosenFaces(i)}.Vertices;
        weightedAverageFace.Vertices = weightedAverageFace.Vertices + (1 - factorOfAverage) / length(chosenFaces) * newVerts;
    end
    
    %{
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
    %}

    figure;
    subplot(1,3,1);
    edges = [];
    counts = [];
    for i=1:length(chosenFaces)
        faceId = chosenFaces(i);
        face = OBJs{faceId};
        
        % Calculate hist information for the face.
        [vertNormals, ~] = CalcNormals(face.Vertices, face.Faces);
        angles1 = CalcNormalAngles(face.Vertices, face.Faces, vertNormals);
        [histCounts, histEdges, ~] = CalcHistAngles(angles1, numBins, upperAngleLimit);
        
        edges = histEdges(1:end-1);
        counts = [counts, histCounts(:)];
    end
    hb = bar(edges, counts ./ sum(counts, 1), 'grouped');
    hold on;
    title('Histogrami začetnih obrazov.');
    
    
    subplot(1,3,2);
    face = finalFace;

    % Calculate hist information for the face.
    [vertNormals, ~] = CalcNormals(face.Vertices, face.Faces);
    angles1 = CalcNormalAngles(face.Vertices, face.Faces, vertNormals);
    [histCounts, histEdges, ~] = CalcHistAngles(angles1, numBins, upperAngleLimit);
        
    hb2 = bar(histEdges(1:end-1), histCounts / sum(histCounts));
    hold on;
    title('Histogrami končnega obraza.');
    
    
    
    subplot(1,3,3);
    edges = [];
    counts = [];
    for i=1:length(chosenFaces)
        faceId = chosenFaces(i);
        face = OBJs{faceId};
        
        validVerts = indicesByRegion{i};
        % Get faces containing these vertices.
        locations1_ = ismember(face.Faces, validVerts);
        [locations1_, ~] = find(locations1_);

        % Get the faces that contain some other kind of vertex.
        locations2_ = ~ismember(face.Faces, validVerts);
        [locations2_, ~] = find(locations2_);

        % Get the faces containing only these vertices.
        validFaces = setdiff(locations1_, locations2_);
        
        % Calculate hist information for the face.
        [vertNormals1, ~] = CalcNormals(face.Vertices, face.Faces(validFaces, :));
        angles1 = CalcNormalAngles(face.Vertices, face.Faces(validFaces, :), vertNormals1);
        angles1 = angles1(validVerts, :);
        [histCounts1, histEdges1, ~] = CalcHistAngles(angles1, numBins, upperAngleLimit);
        
        % Calculate hist information for the final face.
        [vertNormals2, ~] = CalcNormals(finalFace.Vertices, finalFace.Faces(validFaces, :));
        angles2 = CalcNormalAngles(finalFace.Vertices, finalFace.Faces(validFaces, :), vertNormals2);
        angles2 = angles2(validVerts, :);
        [histCounts2, histEdges2, ~] = CalcHistAngles(angles2, numBins, upperAngleLimit);
        
        histDif = histCounts1 - histCounts2;
        
        edges = histEdges1(1:end-1);
        counts = [counts, histDif(:)];
    end
    hb3 = bar(edges, counts ./ sum(abs(counts), 1), 'grouped');
    hold on;
    title('Histogrami razlik začetnih obrazov in končnega obraza.');
    
    %{
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
    %}
end

