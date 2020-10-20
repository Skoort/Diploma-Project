function [numRegions, regionList, regions, regionColors] = LoadRegions(pathToRegions, noiseThreshold)

    if nargin < 2
        noiseThreshold = 0;
    end

    ptCloud = pcread(pathToRegions);

    [numRegions, regionColors, regionList] = GetColors(ptCloud, noiseThreshold);
    regions = GetRegions(numRegions, regionList);

end

function [numUniqueColors, uniqueColors, colorList] = GetColors(ptCloud, noiseThreshold)

    % Check the number of colors. We don't know how many there are, but we
    % assume that there are a discrete amount. So if there are 100, that's
    % already fishy.
    numUniqueColors = 0;
    uniqueColors = zeros(0, 3);
    colorList = zeros(ptCloud.Count, 1);
    for i = 1:ptCloud.Count
        color = ptCloud.Color(i, :);
        % Get the rows of uniqueColors where colors occurs. Should be <= 1.
        if noiseThreshold == 0
            lia = ismember(uniqueColors, color, 'rows');
        else
            lia = ismembertol(uniqueColors, double(color), noiseThreshold, 'ByRows', true, 'DataScale', 1);
        end
        row = find(lia);
        if length(row) < 1
            % This color is unique.
            uniqueColors = [uniqueColors; color];
            numUniqueColors = numUniqueColors + 1;
            row = numUniqueColors;
        end
        
        colorList(i) = row;
    end
end

function regions = GetRegions(numRegions, regionList)
    regions = cell(numRegions, 1);
    
    % Iterate over the vertices and add each vertex to its corresponding
    % region.
    for i = 1:length(regionList)
        region = regionList(i);
        regions{region} = [regions{region}; i];
    end
end



%{
sum(colorList == 2)

ans =

   571

sum(colorList == 1)

ans =

        1336

sum(colorList == 3)

ans =

   241

sum(colorList == 4)

ans =

   309

sum(colorList == 5)

ans =

   529

sum(colorList == 6)

ans =

   104

sum(colorList == 7)

ans =

   145

sum(colorList == 8)

ans =

   152

sum(colorList == 9)

ans =

    73

sum(colorList == 10)

ans =

   152

sum(colorList == 11)

ans =

    99

sum(colorList == 12)

ans =

    12

sum(colorList == 13)

ans =

   221

sum(colorList == 14)

ans =

   165

sum(colorList == 15)

ans =

   280

sum(colorList == 16)

ans =

   128

regions =

  21×1 cell array

    {1336×1 double}
    { 571×1 double}
    { 241×1 double}
    { 309×1 double}
    { 529×1 double}
    { 104×1 double}
    { 145×1 double}
    { 152×1 double}
    {  73×1 double}
    { 152×1 double}
    {  99×1 double}
    {  12×1 double}  <-
    { 221×1 double}
    { 165×1 double}
    { 280×1 double}
    { 128×1 double}
    { 508×1 double}
    { 585×1 double}
    {[       3697]}  <-
    {1318×1 double}
    { 231×1 double} 

Problematic vertex indices (identified as region):
3062,3171,3591,3957,4262

Nearest vert to 3062 is vert 3119 with region ID 9.
Nearest vert to 3171 is vert 3123 with region ID 8.
Nearest vert to 3591 is vert 3524 with region ID 9.
Nearest vert to 3957 is vert 3900 with region ID 12.
Nearest vert to 4262 is vert 4263 with region ID 12.

    {1333×1 double}
    { 571×1 double}
    { 239×1 double}
    { 309×1 double}
    { 529×1 double}
    { 212×1 double}
    { 272×1 double}
    { 237×1 double}
    { 149×1 double}
    {[       3062]}
    {[       3171]}
    { 165×1 double}
    {[       3591]}
    { 280×1 double}
    { 217×1 double}
    { 508×1 double}
    { 585×1 double}
    {[       3957]}
    {[       4262]}
    {1318×1 double}
    { 231×1 double}

8 255 255 255
9 0 0 0
12 0 0 255
%}