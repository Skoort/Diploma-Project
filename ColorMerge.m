% MERGE_SIMPLE_PERCENT
% Currently treats each region differently, even if two neighboring regions
% belong to the same face.
function collageFace = ColorMerge(OBJs, splicedFace, numRegions, regionByIndex, indicesByRegion, chosenFaces, chosenFacesByRegion, shouldAverageWeights, maxDistanceToSmooth)

	maxDistanceToSmooth = max(maxDistanceToSmooth, 0);  % The maximum relative distance to smooth. Can also put something like twice that distance.

    collageFace = clone(splicedFace);
    collageFace.SingleColor = [0.9, 0.9, 0.9];
    collageFace.VertexRGB = repmat([0.9, 0.9, 0.9], collageFace.nVertices, 1);
    collageFace.ColorMode = 'texture';
    
    vertWeights = zeros(length(regionByIndex), numRegions);
    for i = 1:length(vertWeights)
        vertWeights(i, regionByIndex(i)) = 1;  % Initially, every vertex is weighted fully (only) by its own region.
    end
    
    for i = 1:numRegions
        region = indicesByRegion{i};
        
        outerVerts = GetOutsideBorderVerts(collageFace, region);
        outerDists = zeros(size(outerVerts));
        V_ = collageFace.Vertices(outerVerts, :);
        
        % Assign each outer_verts vertex a transition strength.
        for j = 1:length(outerVerts)
            v_ = outerVerts(j);
            
            % Get the indices of faces containing outerVerts(j).
            locations_ = (collageFace.Faces == v_);
            [locations_, ~] = find(locations_);
            
            % Get the vertices in these faces inside of region (all are border vertices).
            verts_ = unique(collageFace.Faces(locations_, :));
            verts_ = intersect(verts_, region);

            verts_ = collageFace.Vertices(verts_, :);
            
            % Get the farthest vertex to outer_verts(j) of these.
            distList_ = Distance(collageFace.Vertices(v_, :), verts_);
            outerDists(j) = AggregateDistances(distList_);
        end
		
		% Find the minimum distance from one of the outer vertices to the average of the last ring.
		regionCenter = [0, 0, 0];
		regionDepth = 0;
		regionCopy = region;
        initialInnerVerts = GetInsideBorderVerts(collageFace, regionCopy);
		while true
			innerVerts = GetInsideBorderVerts(collageFace, regionCopy);
			nextRegionCopy = setdiff(regionCopy, innerVerts);
			
			if length(nextRegionCopy) == 0
				regionCenter = sum(collageFace.Vertices(innerVerts, :)) / length(innerVerts);
				regionDepth = AggregateDistances(Distance(regionCenter, collageFace.Vertices(initialInnerVerts, :)));
				break;
			else
				regionCopy = nextRegionCopy;
			end
		end
        
        % Get the next inner ring and set their vertex color and position.
        while 1
            innerVerts = GetInsideBorderVerts(collageFace, region);
            
            changedVert = false;
            
            for j = 1:length(innerVerts)
                v_ = collageFace.Vertices(innerVerts(j), :);
                
                % Calculate the distances from the inner vertices to the outer
                % vertices.
                dists_ = Distance(v_, V_);
                
                region_amount_counter = 0;
                region_ids_ = [];
                region_vert_indices_ = [];
                region_distances_ = [];
                % Get min distance for each region.
                for h = 1:numRegions  % h is the region index
                    
                    % NOTICE This is probably something that would change
                    % if you wanted to merge whole continuous same face
                    % regions.
                    remove_region_ = regionByIndex(outerVerts) ~= h;  % Check which outer verts aren't in the region we're interpolating.
                    
                    if all(remove_region_)
                        continue;  % outerVerts doesn't contain this region. Includes filtering for this region. Also includes case where this region doesn't border that region.
                    end
                    
                    % Change it so that it can only choose a nearest vertex from the region specified by h.
                    dists_region_ = dists_;
                    dists_region_(remove_region_) = Inf;
                    
                    [closest_dist, nearest_indx] = min(dists_region_);
                    
                    region_ids_ = [region_ids_; h];
                    region_vert_indices_ = [region_vert_indices_; nearest_indx];
                    region_distances_ = [region_distances_; closest_dist];
                    
                    region_amount_counter = region_amount_counter + 1;
                end
                
                [min_dist_, min_indx_] = min(region_distances_);
                max_dist_ = outerDists(region_vert_indices_(min_indx_));  % The maximum distance of that vertex.
                sum_dists_ = sum(region_distances_);
                
                s_ = min_dist_ / (maxDistanceToSmooth * regionDepth);  % Ta parameter je pomemben. Napisi v overleaf. This is the smoothing factor for this vertex's region. 
                                                   % After some amount, in this case twice the max gap distance of the nearest border vertex, completely use this region.
                                            

                % If we want to force all the edges to play fair and say 50/50.
                if s_ < 0.5
                   s_ = 0.5; 
                end
                if s_ >= 1
                    continue;
                end
                
                collageFace.VertexRGB(innerVerts(j), :) = [1, 0, 0];
                                
                % Assign this vertex's current region weight.
                
                vertWeights(innerVerts(j), regionByIndex(innerVerts(j))) = s_;
                % Assign this vertex's other regions' weights. region_ids_
                % never includes this region, so this is safe to do.
                for c_ = 1:region_amount_counter
                    vertWeights(innerVerts(j), region_ids_(c_)) = (1 - region_distances_(c_) / sum_dists_) * (1 - s_) / (region_amount_counter - 1);  % Dividing by num_weights-1 because that's how you calc inverse proportional weights.
                end
                
                changedVert = true;
            end
            if ~changedVert
                break;  % Every inner vertex in this ring was too far away.
            end
    
            % Prepare region for the next run.
            region = setdiff(region, innerVerts);
        end
    end
    
    if shouldAverageWeights
        vertWeights = AverageWeights(collageFace, vertWeights);
    end
    
    for i = 1:size(vertWeights, 1)
        avg_pos = [0, 0, 0];
        for j = 1:numRegions
            actualFaceIndex = chosenFaces(chosenFacesByRegion(j));
            avg_pos = avg_pos + vertWeights(i, j) * OBJs{actualFaceIndex}.Vertices(i, :);
        end
        %{
        collageFace.VertexRGB(i, :) = [0, 0, 1 - vertWeights(i, vert_colors_ids(i))];
        
        if vertWeights(i, vert_colors_ids(i)) <= 0.5
            collageFace.VertexRGB(i, :) = [1, 1, 0]; 
        end
        %}
        collageFace.Vertices(i, :) = avg_pos;
    end
end

function [dists] = Distance(vertex, vertices)
    dists = sqrt(sum((vertices - repmat(vertex, size(vertices, 1), 1)) .^ 2, 2));
end

function [y] = AggregateDistances(dists)
    y = max(dists);%mean(dists);
end

function [verts] = GetOutsideBorderVerts(mesh, region)
    % Get the indices of the faces on the border of this region.
    belonging1 = ismember(mesh.Faces, region);  
    [indices1, ~] = find(belonging1);           
    belonging2 = ~belonging1;
    [indices2, ~] = find(belonging2);
    indices = intersect(indices1, indices2);
    
    faces = mesh.Faces(indices, :);
    verts = unique(faces);  % A list of unique elements of faces (vertex IDs).
    verts = setdiff(verts, region);  % Don't want the ones from this region.
end

function [verts] = GetInsideBorderVerts(mesh, region)
    % Get the indices of the faces on the border of this region.
    belonging1 = ismember(mesh.Faces, region);  
    [indices1, ~] = find(belonging1);           
    belonging2 = ~belonging1;
    [indices2, ~] = find(belonging2);
    indices = intersect(indices1, indices2);
    
    faces = mesh.Faces(indices, :);
    verts = unique(faces);  % A list of unique elements of faces (vertex IDs).
    verts = intersect(verts, region);  % Don't want the ones from this region.
end

% We only need to take a mesh in to see the faces and how many vertices the
% face has (which we can already calculate from weights).
function weights_out = AverageWeights(mesh_in, weights)
    weights_out = weights;

    for vert_id = 1:size(mesh_in.Vertices, 1)
        
        [rows_with_vert, ~] = find(mesh_in.Faces == vert_id);
        
        local_vert_ids = unique(mesh_in.Faces(rows_with_vert, :));
        
        average = sum(weights(local_vert_ids, :), 1) / length(local_vert_ids);
        
        weights_out(vert_id, :) = average;
    end
end


%{
% MERGE_SMOOTH_PERCENT
% Currently treats each region differently, even if two neighboring regions
% belong to the same face.
function collageFace = ColorMerge(OBJs, splicedFace, numRegions, regionByIndex, indicesByRegion, chosenFaces, chosenFacesByRegion, shouldAverageWeights, maxDistanceToSmooth)

	maxDistanceToSmooth = max(maxDistanceToSmooth, 0);  % The maximum relative distance to smooth. Can also put something like twice that distance.

    collageFace = clone(splicedFace);
    collageFace.SingleColor = [0.9, 0.9, 0.9];
    collageFace.VertexRGB = repmat([0.9, 0.9, 0.9], collageFace.nVertices, 1);
    collageFace.ColorMode = 'texture';
    
    vertWeights = zeros(length(regionByIndex), numRegions);
    for i = 1:length(vertWeights)
        vertWeights(i, regionByIndex(i)) = 1;  % Initially, every vertex is weighted fully (only) by its own region.
    end
    
    for i = 1:numRegions
        region = indicesByRegion{i};
        
        outerVerts = GetOutsideBorderVerts(collageFace, region);
        outerDists = zeros(size(outerVerts));
        V_ = collageFace.Vertices(outerVerts, :);
        
        % Assign each outer_verts vertex a transition strength.
        for j = 1:length(outerVerts)
            v_ = outerVerts(j);
            
            % Get the indices of faces containing outerVerts(j).
            locations_ = (collageFace.Faces == v_);
            [locations_, ~] = find(locations_);
            
            % Get the vertices in these faces inside of region (all are border vertices).
            verts_ = unique(collageFace.Faces(locations_, :));
            verts_ = intersect(verts_, region);

            verts_ = collageFace.Vertices(verts_, :);
            
            % Get the farthest vertex to outer_verts(j) of these.
            distList_ = Distance(collageFace.Vertices(v_, :), verts_);
            outerDists(j) = AggregateDistances(distList_);
        end

        % Get the next inner ring and set their vertex color and position.
        while 1
            innerVerts = GetInsideBorderVerts(collageFace, region);
            
            changedVert = false;
            
            for j = 1:length(innerVerts)
                v_ = collageFace.Vertices(innerVerts(j), :);
                
                % Calculate the distances from the inner vertices to the outer
                % vertices.
                dists_ = Distance(v_, V_);
                
                region_amount_counter = 0;
                region_ids_ = [];
                region_vert_indices_ = [];
                region_distances_ = [];
                % Get min distance for each region.
                for h = 1:numRegions  % h is the region index
                    
                    % NOTICE This is probably something that would change
                    % if you wanted to merge whole continuous same face
                    % regions.
                    remove_region_ = regionByIndex(outerVerts) ~= h;  % Check which outer verts aren't in the region we're interpolating.
                    
                    if all(remove_region_)
                        continue;  % outerVerts doesn't contain this region. Includes filtering for this region. Also includes case where this region doesn't border that region.
                    end
                    
                    % Change it so that it can only choose a nearest vertex from the region specified by h.
                    dists_region_ = dists_;
                    dists_region_(remove_region_) = Inf;
                    
                    [closest_dist, nearest_indx] = min(dists_region_);
                    
                    region_ids_ = [region_ids_; h];
                    region_vert_indices_ = [region_vert_indices_; nearest_indx];
                    region_distances_ = [region_distances_; closest_dist];
                    
                    region_amount_counter = region_amount_counter + 1;
                end
                
                [min_dist_, min_indx_] = min(region_distances_);
                max_dist_ = outerDists(region_vert_indices_(min_indx_));  % The maximum distance of that vertex.
                sum_dists_ = sum(region_distances_);
                
                s_ = min_dist_ / (max_dist_ * maxDistanceToSmooth);  % Ta parameter je pomemben. Napisi v overleaf. This is the smoothing factor for this vertex's region. 
                                                                     % After some amount, in this case twice the max gap distance of the nearest border vertex, completely use this region.
                                            

                % If we want to force all the edges to play fair and say 50/50.
                if s_ < 0.5
                   s_ = 0.5; 
                end
                if s_ >= 1
                    continue;
                end
                
                collageFace.VertexRGB(innerVerts(j), :) = [1, 0, 0];
                
                % Assign this vertex's current region weight.
                
                vertWeights(innerVerts(j), regionByIndex(innerVerts(j))) = s_;
                % Assign this vertex's other regions' weights. region_ids_
                % never includes this region, so this is safe to do.
                for c_ = 1:region_amount_counter
                    vertWeights(innerVerts(j), region_ids_(c_)) = (1 - region_distances_(c_) / sum_dists_) * (1 - s_) / (region_amount_counter - 1);  % Dividing by num_weights-1 because that's how you calc inverse proportional weights.
                end
                
                changedVert = true;
            end
            if ~changedVert
                break;  % Every inner vertex in this ring was too far away.
            end
    
            % Prepare region for the next run.
            region = setdiff(region, innerVerts);
        end
    end
    
    if shouldAverageWeights
        vertWeights = AverageWeights(collageFace, vertWeights);
    end
    
    for i = 1:size(vertWeights, 1)
        avg_pos = [0, 0, 0];
        for j = 1:numRegions
            actualFaceIndex = chosenFaces(chosenFacesByRegion(j));
            avg_pos = avg_pos + vertWeights(i, j) * OBJs{actualFaceIndex}.Vertices(i, :);
        end
        %{
        collageFace.VertexRGB(i, :) = [0, 0, 1 - vertWeights(i, vert_colors_ids(i))];
        
        if vertWeights(i, vert_colors_ids(i)) <= 0.5
            collageFace.VertexRGB(i, :) = [1, 1, 0]; 
        end
        %}
        collageFace.Vertices(i, :) = avg_pos;
    end
end

function [dists] = Distance(vertex, vertices)
    dists = sqrt(sum((vertices - repmat(vertex, size(vertices, 1), 1)) .^ 2, 2));
end

function [y] = AggregateDistances(dists)
    y = max(dists);%mean(dists);
end

function [verts] = GetOutsideBorderVerts(mesh, region)
    % Get the indices of the faces on the border of this region.
    belonging1 = ismember(mesh.Faces, region);  
    [indices1, ~] = find(belonging1);           
    belonging2 = ~belonging1;
    [indices2, ~] = find(belonging2);
    indices = intersect(indices1, indices2);
    
    faces = mesh.Faces(indices, :);
    verts = unique(faces);  % A list of unique elements of faces (vertex IDs).
    verts = setdiff(verts, region);  % Don't want the ones from this region.
end

function [verts] = GetInsideBorderVerts(mesh, region)
    % Get the indices of the faces on the border of this region.
    belonging1 = ismember(mesh.Faces, region);  
    [indices1, ~] = find(belonging1);           
    belonging2 = ~belonging1;
    [indices2, ~] = find(belonging2);
    indices = intersect(indices1, indices2);
    
    faces = mesh.Faces(indices, :);
    verts = unique(faces);  % A list of unique elements of faces (vertex IDs).
    verts = intersect(verts, region);  % Don't want the ones from this region.
end

% We only need to take a mesh in to see the faces and how many vertices the
% face has (which we can already calculate from weights).
function weights_out = AverageWeights(mesh_in, weights)
    weights_out = weights;

    for vert_id = 1:size(mesh_in.Vertices, 1)
        
        [rows_with_vert, ~] = find(mesh_in.Faces == vert_id);
        
        local_vert_ids = unique(mesh_in.Faces(rows_with_vert, :));
        
        average = sum(weights(local_vert_ids, :), 1) / length(local_vert_ids);
        
        weights_out(vert_id, :) = average;
    end
end
%}
%{
% MERGE_SMOOTH
% Currently treats each region differently, even if two neighboring regions
% belong to the same face.
function collageFace = ColorMerge(OBJs, splicedFace, numRegions, regionByIndex, indicesByRegion, chosenFaces, chosenFacesByRegion, shouldAverageWeights, maxDistanceToSmooth)

	maxDistanceToSmooth = max(maxDistanceToSmooth, 0);  % The maximum relative distance to smooth. Can also put something like twice that distance.

    collageFace = clone(splicedFace);
    collageFace.SingleColor = [0.9, 0.9, 0.9];
    collageFace.VertexRGB = repmat([0.9, 0.9, 0.9], collageFace.nVertices, 1);
    collageFace.ColorMode = 'texture';
    
    vertWeights = zeros(length(regionByIndex), numRegions);
    for i = 1:length(vertWeights)
        vertWeights(i, regionByIndex(i)) = 1;  % Initially, every vertex is weighted fully (only) by its own region.
    end
    
    for i = 1:numRegions
        region = indicesByRegion{i};
        
        outerVerts = GetOutsideBorderVerts(collageFace, region);
        outerDists = zeros(size(outerVerts));
        V_ = collageFace.Vertices(outerVerts, :);
        
        % Assign each outer_verts vertex a transition strength.
        for j = 1:length(outerVerts)
            v_ = outerVerts(j);
            
            % Get the indices of faces containing outerVerts(j).
            locations_ = (collageFace.Faces == v_);
            [locations_, ~] = find(locations_);
            
            % Get the vertices in these faces inside of region (all are border vertices).
            verts_ = unique(collageFace.Faces(locations_, :));
            verts_ = intersect(verts_, region);

            verts_ = collageFace.Vertices(verts_, :);
            
            % Get the farthest vertex to outer_verts(j) of these.
            distList_ = Distance(collageFace.Vertices(v_, :), verts_);
            outerDists(j) = AggregateDistances(distList_);
        end

        % Get the next inner ring and set their vertex color and position.
        while 1
            innerVerts = GetInsideBorderVerts(collageFace, region);
            
            changedVert = false;
            
            for j = 1:length(innerVerts)
                v_ = collageFace.Vertices(innerVerts(j), :);
                
                % Calculate the distances from the inner vertices to the outer
                % vertices.
                dists_ = Distance(v_, V_);
                
                region_amount_counter = 0;
                region_ids_ = [];
                region_vert_indices_ = [];
                region_distances_ = [];
                % Get min distance for each region.
                for h = 1:numRegions  % h is the region index
                    
                    % NOTICE This is probably something that would change
                    % if you wanted to merge whole continuous same face
                    % regions.
                    remove_region_ = regionByIndex(outerVerts) ~= h;  % Check which outer verts aren't in the region we're interpolating.
                    
                    if all(remove_region_)
                        continue;  % outerVerts doesn't contain this region. Includes filtering for this region. Also includes case where this region doesn't border that region.
                    end
                    
                    % Change it so that it can only choose a nearest vertex from the region specified by h.
                    dists_region_ = dists_;
                    dists_region_(remove_region_) = Inf;
                    
                    [closest_dist, nearest_indx] = min(dists_region_);
                    
                    region_ids_ = [region_ids_; h];
                    region_vert_indices_ = [region_vert_indices_; nearest_indx];
                    region_distances_ = [region_distances_; closest_dist];
                    
                    region_amount_counter = region_amount_counter + 1;
                end
                
                [min_dist_, min_indx_] = min(region_distances_);
                max_dist_ = outerDists(region_vert_indices_(min_indx_));  % The maximum distance of that vertex.
                sum_dists_ = sum(region_distances_);
                
                s_ = min_dist_ / (max_dist_ * maxDistanceToSmooth);  % Ta parameter je pomemben. Napisi v overleaf. This is the smoothing factor for this vertex's region. 
                                                                     % After some amount, in this case twice the max gap distance of the nearest border vertex, completely use this region.
                                            

                % If we want to force all the edges to play fair and say 50/50.
                if s_ < 0.5
                   s_ = 0.5; 
                end
                if s_ >= 1
                    continue;
                end
                
                collageFace.VertexRGB(innerVerts(j), :) = [1, 0, 0];
                
                % Assign this vertex's current region weight.
                
                vertWeights(innerVerts(j), regionByIndex(innerVerts(j))) = s_;
                % Assign this vertex's other regions' weights. region_ids_
                % never includes this region, so this is safe to do.
                for c_ = 1:region_amount_counter
                    vertWeights(innerVerts(j), region_ids_(c_)) = (1 - region_distances_(c_) / sum_dists_) * (1 - s_) / (region_amount_counter - 1);  % Dividing by num_weights-1 because that's how you calc inverse proportional weights.
                end
                
                changedVert = true;
            end
            if ~changedVert
                break;  % Every inner vertex in this ring was too far away.
            end
    
            % Prepare region for the next run.
            region = setdiff(region, innerVerts);
        end
    end
    
    if shouldAverageWeights
        vertWeights = AverageWeights(collageFace, vertWeights);
    end
    
    for i = 1:size(vertWeights, 1)
        avg_pos = [0, 0, 0];
        for j = 1:numRegions
            actualFaceIndex = chosenFaces(chosenFacesByRegion(j));
            avg_pos = avg_pos + vertWeights(i, j) * OBJs{actualFaceIndex}.Vertices(i, :);
        end
        %{
        collageFace.VertexRGB(i, :) = [0, 0, 1 - vertWeights(i, vert_colors_ids(i))];
        
        if vertWeights(i, vert_colors_ids(i)) <= 0.5
            collageFace.VertexRGB(i, :) = [1, 1, 0]; 
        end
        %}
        collageFace.Vertices(i, :) = avg_pos;
    end
end

function [dists] = Distance(vertex, vertices)
    dists = sqrt(sum((vertices - repmat(vertex, size(vertices, 1), 1)) .^ 2, 2));
end

function [y] = AggregateDistances(dists)
    y = max(dists);%mean(dists);
end

function [verts] = GetOutsideBorderVerts(mesh, region)
    % Get the indices of the faces on the border of this region.
    belonging1 = ismember(mesh.Faces, region);  
    [indices1, ~] = find(belonging1);           
    belonging2 = ~belonging1;
    [indices2, ~] = find(belonging2);
    indices = intersect(indices1, indices2);
    
    faces = mesh.Faces(indices, :);
    verts = unique(faces);  % A list of unique elements of faces (vertex IDs).
    verts = setdiff(verts, region);  % Don't want the ones from this region.
end

function [verts] = GetInsideBorderVerts(mesh, region)
    % Get the indices of the faces on the border of this region.
    belonging1 = ismember(mesh.Faces, region);  
    [indices1, ~] = find(belonging1);           
    belonging2 = ~belonging1;
    [indices2, ~] = find(belonging2);
    indices = intersect(indices1, indices2);
    
    faces = mesh.Faces(indices, :);
    verts = unique(faces);  % A list of unique elements of faces (vertex IDs).
    verts = intersect(verts, region);  % Don't want the ones from this region.
end

% We only need to take a mesh in to see the faces and how many vertices the
% face has (which we can already calculate from weights).
function weights_out = AverageWeights(mesh_in, weights)
    weights_out = weights;

    for vert_id = 1:size(mesh_in.Vertices, 1)
        
        [rows_with_vert, ~] = find(mesh_in.Faces == vert_id);
        
        local_vert_ids = unique(mesh_in.Faces(rows_with_vert, :));
        
        average = sum(weights(local_vert_ids, :), 1) / length(local_vert_ids);
        
        weights_out(vert_id, :) = average;
    end
end
%}