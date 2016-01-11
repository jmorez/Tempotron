function V=Tempotron(n_a, t)
    %n_a    Number of afferents
    %t      Vector with discretized time
    I_input=zeros(size(t));
    w=rand(10);
    for i=1:n_a
        Kn(i,:)=reshape(K(t,rand(3)/2),1,length(t));
        I_input=I_input+w(i)*Kn(i,:);
    end
    
    close all; imagesc(Kn); colormap('hot');
    xlabel('t (ms)'); ylabel('n'); colorbar;
    
    figure; plot(t,I_input);
    %hold on; plot(t,I_input); hold off;
    
end

function V=LIF(t,I_ext)
    %Input arguments
    %adapt_flag     1 for an adaptation current, 0 no adaptation current
    %tau_adapt      Adaptation current time constant
    %delta_adapt    Adaptation current increment for each spike
    
    %Model parameters that are unchanged (therefore hardcoded)
    E=-1;      %Hyperpolarized clamping potential 
    Em=0;%Membrane resting potential 
    Cm=0.01;       %Membrane capacitance
    Rm=10;      %Membrane resistance
    theta=1;   %AP threshold
    t_arp=0.001;  %Absolute refractory Period
    tau_adapt=0.01;
    delta_adapt=10;
    adapt_flag=1;
    %Simulation parameters
    dt=t(2)-t(1);    %Timestep
    %tmax=100;    %Simulation time
    
    %Discretize time
    tn=t;
    
    %Initialization of variables
    u=zeros(size(tn));
    u(1)=Em;                    %Initial condition
    g_adapt=zeros(size(tn));    
    
    t0=-t_arp;  %Time when a peak last has occurred
    t=0;    %Time variable that increments with dt amount
    
    for j=1:(length(tn)-1)
        g_adapt(j+1)=g_adapt(j)-dt*g_adapt(j)/tau_adapt;        %Integrate the evolution of the adaptation current
        if u(j) >= theta                                        %If the treshold is reached, clamp to E for t_arp
            u(j+1)=E;                               
            g_adapt(j+1)=g_adapt(j)+delta_adapt;                %Also increase the adaptation current
            t0=t;                                               %Save the time when the peak occurred
        elseif t-t0 < t_arp                                     %During a spike we start counting the time
            u(j+1)=E;                                           %Clamp for t_arp to E   
        else
            u(j+1)=u(j)+dt*((Em-u(j))/(Rm*Cm)+I_ext(j)/Cm-adapt_flag*g_adapt(j)*(u(j)-Em)/Cm); 
        end
        t=t+dt;        
    end
    V=u;
end

function V=K(t,t_spikes)
    %For some time interval <t> (an N-element vector) this function will
    %generate exponentially decaying spikes at times <t_spikes>. 
    
    %Model parameters
    tau=0.015;      %Membrane integration time constant
    tau_s=tau/4;    %Synaptic current time constant
    V0=2.12;        %Normalization
    
    %The step function is required to acquire the correct form of the
    %spikes (i.e. 0 everywhere except after some spike). 
    V=zeros(1,length(t));
    for i=1:length(t_spikes)
        V=V+heaviside(t-t_spikes(i)).*(exp(-(t-t_spikes(i))/tau)-exp(-(t-t_spikes(i))/tau_s));
    end
    V=V0.*V;
end

%Written by Jan Morez
%Computational Neuroscience, Miniproject 2016
%University of Antwerp