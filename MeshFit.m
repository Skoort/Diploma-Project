function [mesh_out] = MeshFit(mesh_in, template)

    %% Set up shape mappers
    % The ShapeMappers handle the mapping according to the given transformation
    % type. We define one for the rigid step and one for the non-rigid step
    % for this demo we use the default settings we have found optimal for faces
    % where the meshes are regular
    % see supplementary material of White et al (2019): https://doi.org/10.1038%2Fs41598-019-42533-y

    % Set up Rigid ICP step using ShapeMapper with 'rigid' transformation type
    % in general this works fine and the settings don't need that much thinking
    % about
    RM= ShapeMapper;
    RM.NumIterations = 30;

    RM.TransformationType = 'rigid';
    RM.UseScaling = true;

    % settings for determining the correspondences
    RM.CorrespondencesNumNeighbours = 3; % number of neighbours to use to estimate correspondences
    RM.CorrespondencesFlagThreshold = 0.9; 
    RM.CorrespondencesSymmetric = true; % if true correspondences are estimated from the template to target and target to template and combined - 
                                        % this can help with mapping structures
                                        % such as long bones and allows the
                                        % target to 'pull' the template
    RM.CorrespondencesEqualizePushPull = false;

    % settings that determine which points are 'outliers' not used to estimate the
    % transformation. This is based on 1. whether the point is an outlier in the
    % distribution of differences between floating and target and 2. Whether
    % the points corresponds to a point that has been 'flagged'.
    RM.InlierKappa = 3;
    RM.InlierUseOrientation = true; % use surface normal direction to determine of point is inlier/outlier

    % ignore points that correspond to the edges of the mesh - only applicable
    % to 'open' surfaces like the face
    RM.FlagFloatingBoundary = true; % ignore points that correspondences to the edge of Floating surface - only applicable if using SymmetricCorrespndences
    RM.FlagTargetBoundary = true;% ignore points that correspondences to the edge of Target surface

    RM.FlagTargetBadlySizedTriangles = true; % ignore points that match to regions of abnormally sized triangles
    RM.TriangleSizeZscore = 6; % threshold to determine which triangles are abnormally sized

    RM.UpSampleTarget = false; % will upsample the target mesh. if meshes are irregular it can help to set this to true


    % Set up non rigid ICP with ShapeMapper with 'nonrigid' transformation type
    NRM = ShapeMapper;
    NRM.TransformationType = 'nonrigid';
    NRM.NumIterations = 80;%200; 
    NRM.CorrespondencesSymmetric = true;
    NRM.CorrespondencesNumNeighbours = 3;
    NRM.CorrespondencesFlagThreshold = 0.9;
    NRM.CorrespondencesUseOrientation = true;
    NRM.CorrespondencesEqualizePushPull =false;
    NRM.InlierKappa = 12; % basically you want this really high, so that the outlier detection is effectively turned off. in future you will be able to actually turn this off. 
    NRM.InlierUseOrientation = true;
    NRM.FlagFloatingBoundary = true;
    NRM.FlagTargetBoundary = true;
    NRM.FlagTargetBadlySizedTriangles = true;
    NRM.TriangleSizeZscore = 6;
    NRM.UpSampleTarget = false;




    % parameters specific to non-rigid step. In general, if computing time is not a factor
    % set the NumIterations and the TransformNumViscousIterationsStart and
    % TransformNumElasticIterationsStart as high as possible. This will ensure
    % a slow, gradual deformation of the template to target.
    % please see the tutorial 'UnderstandingNonRigidMappingWithMeshmonk' for
    % some more details on how this all works. 
    % TransformNumViscousIterationsEnd, TransformNumElasticIterationsEnd should
    % always be around 1. If they are higher than the floating shape may not
    % actually match the shape of the target at the end of the algorithm. They
    % can be 0 but this is only advisable with very high quality meshes


    NRM.TransformSigma = 3;
    NRM.TransformNumViscousIterationsStart = 80;%200;
    NRM.TransformNumViscousIterationsEnd = 1;
    NRM.TransformNumElasticIterationsStart = 80;%200;
    NRM.TransformNumElasticIterationsEnd = 1;
    NRM.TransformNumNeighbors = 80;


    %% Batch process files

    % load Template floating face
    %Floating = clone(template);


    % load landmarks on template
    %FloatingLandmarks = readTextLandmarkFile(strcat(tutorialPath,filesep,'TutorialData/Template.csv'),',');




    %TargetLandmarks = readTextLandmarkFile(strcat(path2landmarks,targetName(1:end-4),'.csv'),',');


    %%%% Initialisation from landmarks

    % calculate rigid transformation from FloatingLandmarks to
    % TargetLandmarks
    %T = computeTransform(FloatingLandmarks,TargetLandmarks,true);

    % apply rigid transform to Floating
    %forFloating = applyTransform(Floating,T);
    forFloating = template;%Floating;  

    %check normals of floating and target consistently point inward or
    %outward. If they are inconsistent the normals will be flipped. 
    %THIS CHECK WORKS IN MOST CASES BUT IS NOT INFALLIBLE. PARTICULARLY
    % IT MAY FAIL IF THE INITIALISATION IS BAD OR FLOATING AND TARGET ARE
    % VERY DIFFERENT SHAPES
    % The only way to exactly check this is to plot
    % each shape with their normals
    % e.g v = viewer(Shape)
    %    plotVectorField(Shape.Vertices,Shape.VertexNormals,v)

    if ~normalsConsistent(mesh_in, forFloating)
       mesh_in.FlipNormals = true;
    end


    % Execute Rigid Mapping
    forRM = clone(RM);
    forRM.FloatingShape = clone(forFloating);
    forRM.TargetShape = mesh_in;

    forRM.map();

    % Execute Non-Rigid Mapping
    forNRM = clone(NRM);
    forNRM.FloatingShape = forRM.FloatingShape; % floating shape is now the floating shaoe after Rigid Mapping
    forNRM.TargetShape = mesh_in;%Target;
    forNRM.map()

    mesh_out = forNRM.FloatingShape;
    
end