% Requires a random face to make a copy of.
function SpliceFacesTogetherCloud(pathToRegions, numRegions, indicesByRegion, numMergedFaces, chosenFacesByRegion)
    
    ptCloud = pcread(pathToRegions);
    ptCloud2 = pcread(pathToRegions);
    
    for i=1:numRegions
        indices = indicesByRegion{i};
        %regionColor = [255, 255, 255] * (chosenFacesByRegion(i) / numMergedFaces);
        fromColor = [255, 0, 255];
        toColor = [0, 255, 255];
        t = ((chosenFacesByRegion(i)-1) / (numMergedFaces-1));
        regionColor = floor(min(max(fromColor + t*(toColor - fromColor), 0), 255));
        
        ptCloud.Color(indices, :) = repmat(regionColor, size(indices, 1), 1);
    end
    
    % Visualize the point cloud.
    % Define a rotation matrix and 3D transform.
    x = pi/180; 
    R = [ cos(x) sin(x) 0 0
         -sin(x) cos(x) 0 0
          0         0   1 0
          0         0   0 1];
    
    tform = affine3d(R);
    
    % Compute x-_y_ limits that ensure that the rotated teapot is not clipped.
    lower = min([ptCloud.XLimits ptCloud.YLimits]);
    upper = max([ptCloud.XLimits ptCloud.YLimits]);
      
    xlimits = [lower upper];
    ylimits = [lower upper];
    zlimits = ptCloud.ZLimits;
    
    % Create the player and customize player axis labels.
    player = pcplayer(xlimits,ylimits,zlimits);
    player2 = pcplayer(xlimits,ylimits,zlimits);
    
    xlabel(player.Axes,'X (m)');
    ylabel(player.Axes,'Y (m)');
    zlabel(player.Axes,'Z (m)');
    xlabel(player2.Axes,'X (m)');
    ylabel(player2.Axes,'Y (m)');
    zlabel(player2.Axes,'Z (m)');
    
    % Rotate the face around the z-axis.
    for i = 1:360      
        ptCloud = pctransform(ptCloud,tform);    
        ptCloud2 = pctransform(ptCloud2,tform);    
        view(player,ptCloud);  
        view(player2,ptCloud2);  
    end

end

