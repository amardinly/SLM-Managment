function [ ] = Function_shoot_sequences_due(Setup,sequences,cycleiterations)
threshold_Voltage = 2.5; %V
if Setup.Holodaq.DAQReady==1;
    disp(['You have ' num2str(Setup.TimeToPickSequence) ' seconds to select which sequence to use, send too many pulses to quit'])
    disp(['You have ' int2str(numel(sequences)) ' sequences to choose from'])
    
    sequenceID = 0;
    while sequenceID<=numel(sequences)
        disp('Anytime now !')
        state = 0;
        counter = 0;
        
        %read pin and look for it to go high and then for it to go low to
        %ensure that you received a trigger before you look for the next 
        while state == 0;
            voltage = readVoltage(Setup.DAQ,'A0');
            if voltage>threshold_Voltage; 
                state=1;disp('voltage high')
            else 
                state=0; 
            end;
        end;
        while state == 1;  
            voltage = readVoltage(Setup.DAQ,'A0');
            if voltage>threshold_Voltage; 
                state=1; disp('voltage high')
            else 
                state=0; 
            end;
        end;

        tic; t = toc;
        while t<Setup.TimeToPickSequence
          
            %look for voltages going high
            while state == 0&&t<Setup.TimeToPickSequence;
                voltage = readVoltage(Setup.DAQ,'A0') ;
                if voltage>threshold_Voltage; 
                    state=1; disp('voltage high')
                else
                    state=0;
                end;
                t=toc;
            end;
            
            %look for voltage high and going low
            while state == 1&&t<Setup.TimeToPickSequence; 
                voltage = readVoltage(Setup.DAQ,'A0');
                if voltage>threshold_Voltage;
                    state=1;disp('voltage high')
                else
                    state=0; 
                end;
                t=toc;
            end;
        % if nothing else happens this equals one.  Otherwise everytime we
        % get a voltage high and then low we increase counter by one
            counter = counter+1;
            t=toc;
        end
        
        
        sequenceID = counter;
        
        if sequenceID<=numel(sequences)
            disp(['Sequence ' int2str(sequenceID) ' of ' int2str(numel(sequences)) ' Selected !'])
            function_Triggered_SequenceCloseLoop( Setup, sequences{sequenceID},cycleiterations  );
        end
        
    end
    
    disp('You are done !')
    
else
    disp('Your DAQ is not ready to receive next sequence pulse')
end

end

