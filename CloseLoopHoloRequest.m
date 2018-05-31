function CloseLoopHoloRequest();
clc; clear; close all force;

[Setup ] = function_loadparameters(2);


% get directory
A=dir('Y:\holography\FrankenRig\HoloRequest\');
for k = 1:numel(A);
    if strcmp('HoloRequest.mat',A(k).name);
        HRidx=k;  %find the index for the directory that equals holorequest
    end
end;

%date stamp for while create data
createNum = A(HRidx).date;

x = 1;
while x>0
    
    A=dir('Y:\holography\FrankenRig\HoloRequest\');
    STRTEST = strmatch(createNum,A(HRidx).date);
    if ~isempty(STRTEST);
        newFile = 0;
    else
        newFile = 1;
        createNum = A(HRidx).date;
    end
    
    if newFile
        disp('new File Detected - running HoloRequest')
        run('RUNME_04_LISTENER_ForHolorequest_alanOnly_2');
    end
    
end