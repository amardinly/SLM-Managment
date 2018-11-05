function function_HR_listener(holoRequest,masterSocket);
persistent Setup COC Points;

%configure SLM first run
if isempty(Setup);
[Setup ] = function_loadparameters();
%assign setup in base for teardown 
assignin('base','Setup', Setup);
load([Setup.Datapath '\07_XYZ_Calibration.mat']);  %load calibration params
end;

%stop SLM
[Setup.SLM ] = Function_Stop_SLM( Setup.SLM );
Setup.CGHMethod=1;
cycleiterations =1; % Change this number to repeat the sequence N times instead of just once
%Overwrite delay duration
Setup.TimeToPickSequence = 0.02;    %second window to select sequence ID
Setup.SLM.timeout_ms = 500;     %No more than 2000 ms until time out
calibID =1;                     % Select the calibration ID (z1=1 but does not exist, Z1.5=2, Z1 sutter =3);
%
    LN = size(holoRequest.targets,1);
    SICoordinates = holoRequest.targets;
    SICoordinates(:,1)=SICoordinates(:,1)+holoRequest.xoffset;
    SICoordinates(:,2)=SICoordinates(:,2)+holoRequest.yoffset;    
    SICoordinates=SICoordinates';
    SLMCoordinates = zeros(4,LN);

%% Convert ot SLM coordinates
SLMCoordinates(1,:) = polyvaln(COC.SI_SLM_X{calibID} ,SICoordinates');
SLMCoordinates(2,:) = polyvaln(COC.SI_SLM_Y{calibID} ,SICoordinates');
SLMCoordinates(3,:) = polyvaln(COC.SI_SLM_Z{calibID} ,SICoordinates');

%Add power
SLMCoordinates(4,:) = 1./function_Power_Adjust( SLMCoordinates(1:3,:)',COC );

AttenuationCoeffs = function_Power_Adjust( SLMCoordinates(1:3,:)', COC );

%%%%%%%%%%%%%%%%%%%%

Setup.verbose =0;
hololist = zeros(Setup.Nx,Setup.Ny, numel(holoRequest.rois),'uint8');
DE = linspace(0,0,numel(holoRequest.rois));

for j = 1:numel(holoRequest.rois)
    disp(['Now compiling hologram ' int2str(j) ' of ' int2str(numel(holoRequest.rois))])
    ROIselection = holoRequest.rois{j};
    myattenuation = AttenuationCoeffs(ROIselection);
    energy = 1./myattenuation; energy = energy/sum(energy);
    DE(j) = sum(energy.*myattenuation);
    disp(['Diffraction efficiency of the hologram : ' int2str(100*DE(j)) '%']);
    subcoordinates = SLMCoordinates(:,ROIselection);
    [ Hologram,Reconstruction,Masksg ] = function_Make_3D_SHOT_Holos( Setup,subcoordinates' );
    hololist(:,:,j) = Hologram;
    % compile holograms
end

DE_list=DE;

mssend(masterSocket,DE_list);  
disp('Sent DE to master');


LSequences = numel(holoRequest.Sequence);
sequences = {};

for i = 1:LSequences
    sequence = {};   
    for iterations = 1:cycleiterations
        for j = 1:numel(holoRequest.Sequence{i})
            sequence{(iterations-1)*numel(holoRequest.Sequence{i})+j} =  squeeze(hololist(:,:,holoRequest.Sequence{i}(j)));
        end
    end
    sequences{i} = sequence;
end

%%
[Setup.SLM ] = Function_Stop_SLM( Setup.SLM );
Setup.SLM.wait_For_Trigger= 1;
[ Setup.SLM ] = Function_Start_SLM( Setup.SLM );
%assogm setup in base for teardown 
assignin('base','Setup', Setup);
%Function_shoot_sequences_due_CloseLoop(Setup,sequences,cycleiterations, masterSocket);
shootSequences(Setup, sequences, masterSocket);
[Setup.SLM ] = Function_Stop_SLM( Setup.SLM );

disp('Sequence quit, waiting for new holorequest')








