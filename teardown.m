%dislay blank hologram, then delete SDK?
Function_Stop_SLM( Setup.SLM );
Setup.SLM.wait_For_Trigger= 0; % Set to 1 before initialization as needed.
Hologram = zeros(Setup.SLM.Nx,Setup.SLM.Ny);
Setup.SLM.State =0;
[ Setup.SLM ] = Function_Start_SLM( Setup.SLM );
[ Setup.SLM ] = Function_Feed_SLM( Setup.SLM, Hologram);
Function_Stop_SLM( Setup.SLM );

calllib('Blink_C_wrapper', 'Delete_SDK');

%remove arduino
clear Setup;