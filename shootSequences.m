function shootSequences(Setup,sequences,masterSocket);
sequences = sequences{1};
threshold_Voltage = 2.5; %V

while true
    
    sendVar = 'C';
    mssend(masterSocket,sendVar);
    
    
    HRin = [];
    disp('waiting for socket to send sequence number')
    while isempty(HRin)
        HRin = msrecv(masterSocket,.5);
    end
    disp(['received sequence: ' num2str(HRin)]);
    [ Setup.SLM ] = Function_Feed_SLM(Setup.SLM, sequences{HRin});
%     state=0;
%     while state == 0;
%         voltage = readVoltage(Setup.DAQ,'A0');
%         if voltage>threshold_Voltage; 
%             state=1;disp('got off pulse')
%         else 
%             state=0; 
%         end;
%     end;
%     while state == 1;  
%         voltage = readVoltage(Setup.DAQ,'A0');
%         if voltage>threshold_Voltage; 
%             state=1;
%         else 
%             state=0; disp('off pulse ends');
%         end;
%     end;
%     Hologram = zeros(Setup.SLM.Nx,Setup.SLM.Ny);
%     [ Setup.SLM ] = Function_Feed_SLM(Setup.SLM, Hologram);
end