w = warning ('off','all');  %Suppress warnings about equation conditions
set(gcf, 'Position', get(0, 'Screensize')); %Make figures fullscreen

%Create Cour-Palais Equation
syms Y c d_p rho nu theta propto beta gamma sigma
eqn = Y == c * d_p.^propto * rho.^beta * nu^gamma * (cos(theta))^sigma;

%pretty(eqn);

%Define empirical values

C = 30.9;
PROPTO = 1.33;
BETA = 0.44;
GAMMA = 0.44;
SIGMA = 0.44;

%Create solution for d_p
sln = subs(solve(eqn,d_p,"Real",true), ...
        {c, propto, beta,   gamma,  sigma}, ...
        {C, PROPTO, BETA,   GAMMA,  SIGMA});


%Define variable values

y = [1,32]    *0.1;    %Conversion  mm->cm
RHO = 2.7;
THETA = deg2rad(45);

V = 0.001*sqrt( ...
    3.986E14 ...         %Standard gravitational parameter, Earth
    /6371000+408000);    %Orbital radius not altitude..

%Solve for d_p
values = subs(sln, ...
    {Y, rho,    theta,  nu}, ...
    {y, RHO,    THETA,  V});

values = round(values,6);
smallest_D = double(values(1));
largest_D = double(values(2));

disp(['Smallest Particle Size: ',num2str(smallest_D),'cm'])
disp(['Largest Particle Size: ',num2str(largest_D),'cm'])

graph_function = subs(sln, ...
    {rho,    theta,  nu}, ...
    {RHO,    THETA,  V});   %Impactor diam as a function of crater diameter 


tiledlayout(2,3);   %Create tiled layout for figures, makes output cleaner
nexttile([2 1])
hold on
fplot(graph_function,[0 100])   %Crater size range 0-100
xlabel('Crater Diameter /mm')
ylabel('Impactor Diameter /mm')
title('Impactor Diameter vs Crater Diameter')
hold off
nexttile

%ANALYSIS OF MULTIPLE VARIABLES

%1. Impactor Velocity

velo_sln = subs(solve(eqn,Y,"Real",true), ...
        {c, propto, beta,   gamma,  sigma}, ...
        {C, PROPTO, BETA,   GAMMA,  SIGMA});

graph_function = subs(velo_sln, ...
    {d_p,                       rho,    theta}, ...
    {(largest_D+smallest_D/2),  RHO,    THETA});


hold on

fplot(graph_function,[0 50])   %Velocity range 0-50 kms^-1
xlabel('Velocity /kms^-1')
ylabel('Crater Diameter /mm')
title('Crater Diameter vs Velocity')
hold off
nexttile

%{ 
Assumptions made:

    1)  Particle size is the mean of the sizes found above
    2)  Density is that of aluminium
    3)  Impact is made at 45deg

%}

%2. Impactor Density

dens_sln = subs(solve(eqn,rho,"Real",true), ...
        {c, propto, beta,   gamma,  sigma}, ...
        {C, PROPTO, BETA,   GAMMA,  SIGMA});

graph_function = subs(dens_sln, ...
    {d_p,                       nu,    theta}, ...
    {(largest_D+smallest_D/2),  V,    THETA});


hold on

fplot(graph_function,[1 10])   %Velocity range 0-50 kms^-1
xlabel('Density /gcm^-3')
ylabel('Crater Diameter /mm')
title('Crater Diameter vs Impactor Density')
hold off
nexttile

%{ 
Assumptions made:

    1)  Particle size is the mean of the sizes found above
    2)  Velocity is that of the space station, found above
    3)  Impact is made at 45deg

%}

%3. Impactor Angle

angle_sln = subs(solve(eqn,theta,"Real",true), ...
        {c, propto, beta,   gamma,  sigma}, ...
        {C, PROPTO, BETA,   GAMMA,  SIGMA});
angle_sln = angle_sln(1);   %Keep the positive root

graph_function = subs(angle_sln, ...
    {d_p,                       nu, rho}, ...
    {(largest_D+smallest_D/2),  V,  RHO});


hold on

set(gca, 'XDir','reverse')
fplot(graph_function,[0 0.5*pi])   %Velocity range 0-50 kms^-1
xlabel('Impactor Angle from Perpendicular /radians')
ylabel('Crater Diameter /mm')
title('Crater Diameter vs Impactor Angle')
hold off

%{ 
Assumptions made:

    1)  Particle size is the mean of the sizes found above
    2)  Density is that of aluminium
    3)  Velocity is that of the space station, found above

%}

