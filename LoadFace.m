function face = LoadFace(pathToFace)
    [filepath, name, ext] = fileparts(pathToFace);

    face = shape3D;
    face.importWavefront(strcat(name, ext), filepath);
end

