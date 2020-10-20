function [numFaces, OBJs] = LoadFaces(pathToDir)
    files = dir(pathToDir);
    filenames = {};
    OBJs = {};
    for i = 1:length(files)
        filename = files(i).name;
        if regexp(filename, regexptranslate('wildcard', '*.obj'))
            filenames{end+1} = filename;
            OBJs{end+1} = LoadFace(fullfile(pathToDir, filename));
        end
    end

    numFaces = length(OBJs);
end

