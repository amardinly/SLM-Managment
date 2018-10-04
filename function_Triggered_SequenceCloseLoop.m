function [  ] = function_Triggered_SequenceCloseLoop( Setup, sequence, n  )

%This function takes as argument sequnece, and will attemp to repeat it up
%to n times then quit.
%If time out occurs, the sequence is aborted and the next sequence is put
%in place
LN = numel(sequence);
disp(['This Sequence Contains ' int2str(numel(sequence)) ' holograms, SLM Loaded !'])

threshold_Voltage = 2;
state = 0 ;
%monitor the voltage pin on the arduino and look for the sequence trigger
% while state == 0   
%     voltage = readVoltage(Setup.DAQ,'A0');
%     if voltage>threshold_Voltage;
%         state=1;
%         disp('Sequence Triggered')
%     else
%         state=0;
%     end;
% end

counter = 1;
abug = 0;

while counter <= numel(sequence) && abug==0
    tic;
    [ Setup.SLM ] = Function_Feed_SLM( Setup.SLM, sequence{counter} );
    t = toc
    disp('sent one');
    if t> (Setup.SLM.timeout_ms/1000)-0.2;
        abug =1;
    end;
    counter = counter+1  ;
    
end

if abug==1
    disp(['Sequence ended while waiting to display hologram ' int2str(counter-1)])
else
    disp('Sequence successfully completed until the end')
end





end

