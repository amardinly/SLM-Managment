function shootSequencesMultiEnsemble(Setup,sequences,masterSocket);

while 1
    sendVar = 'C';
    mssend(masterSocket,sendVar);


    order = [];
    disp('waiting for socket to send sequence number')
    while isempty(order)
        order = msrecv(masterSocket,.5);
    end
    disp(['received sequence of length ' num2str(length(order)-1)]);

    %the first number in order is which seq to choose
    this_sequence = sequences{order(1)};
    order(1)=[];

    timeout = false;
    counter = 1;
    orig_time = Setup.SLM.timeout_ms;
    while ~timeout && counter<=length(order)
        %for the first count set the timeout to be crazy long 
        if counter==1
            Setup.SLM.timeout_ms = 300000;
        else
            Setup.SLM.timeout_ms = orig_time;
        end
        %disp(['now queuing hologram ' num2str(order(counter))])
        outcome = Function_Feed_SLM(Setup.SLM, this_sequence{order(counter)});
        if outcome == -1
            timeout = true;
        end
        counter = counter+1;
    end
    Setup.SLM.timeout_ms = orig_time;

    if ~timeout
        disp('completed sequence to the end')
    else
        disp(['timeout while waiting to display hologram order ' num2str(counter-1)]);
    end
end