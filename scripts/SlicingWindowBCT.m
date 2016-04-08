% this script compute the BCT values for a set of graph derived of the
% functional network connectivity with a sliding window on the different
% population. The  BCT measurements included in this experiment are:
%  
%    Strength 
%    Clustering coefficient
%    Global efficiency
%    Average shortest path
%
% Additionally, the following measurements were also made for each network
%
%    Average strength
%    Average clustering coefficient
% -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -

% clear the workspace
clc; close all; clear;

%  Define the global parameters to configure the script
data         = '../Data';
file_prefix  = 'DistanceCorrelation_Slice_';
Experimentos = {'SlicingWindow'};
Poblaciones  = {'Control', 'MinimallyConsciousState', 'VegetativeState'};
%Poblaciones  = {'Control'};
%Correlacion  = {'DC', 'NMI', 'Pearson'};
Correlacion  = {'DC'};
windows      = 57;
Umbrales     = 0.0:0.1:1.0;
Binary       = 0;
%aEliminar    = [4 5 9];
aEliminar    = [];
% string que identifica los nodos excliudos
if ~isempty(aEliminar)
    excluidos = ['No-' regexprep( int2str(aEliminar), '  ', '-')];
end


% The current experiment
currentExp = char(Experimentos(1));

% The current correlation measurement
currentCor = char(Correlacion(1));

% Compute the measurements for all populations in all slicing windows.
bctSlicingResultsMatrix = {windows};
% for each window
for w = 1:windows
  % Cell array to save the measurements of the populations in the current
  % slicing window
  bctPopulationMatrix = {length(Poblaciones)};
  % for each population
  for p = 1:length(Poblaciones)
    % the current population
    currentPob = char(Poblaciones(p));
    % Load the file with the matrix for the current population in the current window
    currentFile = [data '/' currentExp '/' currentPob '/' file_prefix int2str(w) '.mat'];
    currentNetwork = importdata(currentFile);
    % Get the number of subject/patients
    numSubjects = length(currentNetwork);
    % For each threshold 
    for u = 1:1 %length(Umbrales)
      currentUmb = Umbrales(u);
      % obtengo las dimensiones de la matriz de cada paciente 
      dimMatrix = length(currentNetwork(:,:,1))-length(aEliminar);
      % Create a cell matrix to save the BCT results
      bctResultsMatrix = {numSubjects};
      % for each subject in the correlation matrix 
      for i = 1:numSubjects
        % get the symetric network with the correlation values between [0, 1]
        %  - get the values between [0, 1]
        X = prepareNetworkMatrix(currentNetwork(:,:,i),currentCor,currentUmb,Binary);
        currentNetwork(:,:,i) = X;
        %  - eliminate the nodes in the aEliminar vector
        X(:,aEliminar) = [];
        X(aEliminar,:) = [];
        %  - get the symetric matrix
        X = X + X';
        % TODO: Aqui eliminar los nodos de procedencia artifactural? o hacerlo en la funcion de preparación de la matriz
        % ....
        % Call the function to compute the measurements and save it in a cell array
        M = computeBCTMeasures(X,Binary);
        % TODO: eliminate the nodes with zero values of the measurements ???
        % save the measurements for the subject i in the array
        bctResultsMatrix{i} = M;
      end
    end
    bctPopulationMatrix{p} = bctResultsMatrix;
  end
  bctSlicingResultsMatrix{w} = bctPopulationMatrix;
end
% Save the results to a .mat file
filename = ['../Results/' currentExp '/' currentCor '-' num2str(currentUmb, '%-2.1f') '-matrixMeasurements.mat'];
save(filename, 'bctSlicingResultsMatrix');


%%
% Here for each slicing window we have a population measurements. 
% Each population measurement consist of the measurementes of the BCT 
% measurements for the subjects of each population.
% The measurements of the subjects of one population are the measurements
% computed on each individual and keep it in an array 
% .......1.........2.........3.........4.........5.........6.........7.........8.........9.........0

% define the other parameters
NombresPoblaciones  = {'Control', 'MCS', 'VS/UWS'};
%ArrayMeasurement  = {'Strength', 'Clustering', 'LocalEfficiency'};
ArrayMeasurement  = {'Strength', 'Clustering'};
%NombresArrayMeasurement = {'Strength', 'Clustering Coefficient', 'Local Efficiency'};
NombresArrayMeasurement = {'Strength', 'Clustering Coefficient'};
%SingleMeasurement  = {'Efficiency', 'Charpath', 'Radius', 'Diameter'};
SingleMeasurement  = {'Efficiency', 'Charpath'};
%NombresSingleMeasurement  = {'Efficiency', 'Characteristic Path', 'Radius', 'Diameter'};
NombresSingleMeasurement  = {'Global Efficiency', 'Characteristic Path'};
pValue = 0.05;
nombresRedes = {'Auditory';'Cerebellum';'Default Mode Network';'Excecutive Control Left';'Excecutive Control Right';'Salliency';'Sensori-motor';'Visual lateral';'Visual Media';'Visual Occipital'};
nombresRedes(aEliminar) = [];
binSize = 0.1;

% Begin with the global measurements
% take the values of each single computation on each population in each 
% slicing window once the vector of populations were obtained, plot the 
% values.
% .........................................................................
numControl = length(bctSlicingResultsMatrix{1,1}{1,1});
numMCS = length(bctSlicingResultsMatrix{1,1}{1,2});
numVS = length(bctSlicingResultsMatrix{1,1}{1,3});


% Global Efficiency
globalEfficiencyControl = zeros(numControl, windows);
globalEfficiencyMCS     = zeros(numMCS,windows);
globalEfficiencyVS      = zeros(length(bctSlicingResultsMatrix{1,1}{1,3}),windows);
% Characteristic Path Length
charPathControl = zeros(numControl, windows);
charPathMCS     = zeros(numMCS, windows);
charPathVS      = zeros(length(bctSlicingResultsMatrix{1,1}{1,3}),windows);
% Average strength
averageStrengthControl = zeros(numControl, windows); 
averageStrengthMCS = zeros(length(bctSlicingResultsMatrix{1,1}{1,2}),windows);
averageStrengthVS = zeros(length(bctSlicingResultsMatrix{1,1}{1,3}),windows);

% Average clustering coefficient
averageClusteringControl = zeros(numControl, windows); 
averageClusteringMCS = zeros(length(bctSlicingResultsMatrix{1,1}{1,2}),windows);
averageClusteringVS = zeros(length(bctSlicingResultsMatrix{1,1}{1,3}),windows);

for w = 1:windows
  % get the mean and standar deviation of the network measurement for each
  % population 
  sliceMeasures = bctSlicingResultsMatrix{w};
  % Control Measurements
  control = sliceMeasures{1,1};
  for i = 1 : length(control)
    globalEfficiencyControl(i,w) = control{i}.efficiency;
    charPathControl(i,w) = control{i}.charpath{1};
    averageStrengthControl(i,w) = mean(control{i}.strength);
    averageClusteringControl(i,w) = mean(control{i}.clustering);
  end
  
  
  % MCS Measurements
  mcs = sliceMeasures{1,2};
  for i = 1 : length(mcs)
    globalEfficiencyMCS(i,w) = mcs{i}.efficiency;
    charPathMCS(i,w) = mcs{i}.charpath{1};
    averageStrengthMCS(i,w) = mean(mcs{i}.strength);
    averageClusteringMCS(i,w) = mean(mcs{i}.clustering);
  end
  
  
  % VS/UWS Measurements
  vs = sliceMeasures{1,3};
  for i = 1 : length(vs)
    globalEfficiencyVS(i,w) = vs{i}.efficiency;
    charPathVS(i,w) = vs{i}.charpath{1};
    averageStrengthVS(i,w) = mean(vs{i}.strength);
    averageClusteringVS(i,w) = mean(vs{i}.clustering);
  end
  
end



fswEff = figure;
hold on
for i = 1:numControl
  plot(1:windows,globalEfficiencyControl(i,:), 'Color', 'b');
end    
for i = 1:numMCS
  plot(1:windows,globalEfficiencyMCS(i,:), 'Color', 'g');
end
for i = 1:numVS
   plot(1:windows,globalEfficiencyVS(i,:), 'Color', 'r');
end
ylim([0 1])
ylabel('Global efficiency');
hold off

fswChP = figure;
hold on
for i = 1:numControl
  plot(1:windows,charPathControl(i,:), 'Color', 'b');
end    
for i = 1:numMCS
  plot(1:windows,charPathMCS(i,:), 'Color', 'g');
end
for i = 1:numVS
   plot(1:windows,charPathVS(i,:), 'Color', 'r');
end
ylim([0 1])
ylabel('Characteristic path');
hold off

fswASt = figure;
hold on
for i = 1:numControl
  plot(1:windows,averageStrengthControl(i,:), 'Color', 'b');
end    
for i = 1:numMCS
  plot(1:windows,averageStrengthMCS(i,:), 'Color', 'g');
end
for i = 1:numVS
   plot(1:windows,averageStrengthVS(i,:), 'Color', 'r');
end
ylabel('Average strength');
hold off


fswACl = figure;
hold on
for i = 1:numControl
  plot(1:windows,averageClusteringControl(i,:), 'Color', 'b');
end    
for i = 1:numMCS
  plot(1:windows,averageClusteringMCS(i,:), 'Color', 'g');
end
for i = 1:numVS
   plot(1:windows,averageClusteringVS(i,:), 'Color', 'r');
end
ylim([0 1]);
ylabel('Average clustering coefficient');
hold off

%% Dispersion and central measurements of each individual by network measurement
[fswStatsEffC, fswStatsEffM, fswStatsEffV, controlGlobalEfficiency, mcsGlobalEfficiency, vsGlobalEfficiency] = pintarResultadosDispersionSlicingWindow(globalEfficiencyControl, globalEfficiencyMCS, globalEfficiencyVS);
[fswStatsChPC, fswStatsChPM, fswStatsChPV, controlCharPath, mcsCharPath, vsCharPath] = pintarResultadosDispersionSlicingWindow(charPathControl, charPathMCS, charPathVS);
[fswStatsAStC, fswStatsAStM, fswStatsAStV, controlAverageStrength, mcsAverageStrength, vsAverageStrength] = pintarResultadosDispersionSlicingWindow(averageStrengthControl, averageStrengthMCS, averageStrengthVS);
[fswStatsAClC, fswStatsAClM, fswStatsAClV, controlAverageClustering, mcsAverageClustering, vsAverageClustering] = pintarResultadosDispersionSlicingWindow(averageClusteringControl, averageClusteringMCS, averageClusteringVS);



hold on
    errorbar( controlGlobalEfficiency.mean, controlGlobalEfficiency.std, 'Linestyle', 'none', 'Marker', '+', 'Color', 'b');
    errorbar( mcsGlobalEfficiency.mean, mcsGlobalEfficiency.std, 'Linestyle', 'none', 'Marker', '+', 'Color', 'g');
    errorbar( vsGlobalEfficiency.mean, vsGlobalEfficiency.std, 'Linestyle', 'none', 'Marker', '+', 'Color', 'r');
    plot(controlGlobalEfficiency.max, 'Linestyle', 'none', 'Marker', '^', 'Color', 'b');
    plot(controlGlobalEfficiency.min, 'Linestyle', 'none', 'Marker', 'v', 'Color', 'b');
    plot(mcsGlobalEfficiency.max, 'Linestyle', 'none', 'Marker', '^', 'Color', 'g');
    plot(mcsGlobalEfficiency.min, 'Linestyle', 'none', 'Marker', 'v', 'Color', 'g');
    plot(vsGlobalEfficiency.max, 'Linestyle', 'none', 'Marker', '^', 'Color', 'r');
    plot(vsGlobalEfficiency.min, 'Linestyle', 'none', 'Marker', 'v', 'Color', 'r');
hold off    

figure;
hold on
    errorbar( controlCharPath.mean, controlCharPath.std, 'Linestyle', 'none', 'Marker', '+', 'Color', 'b');
    errorbar( mcsCharPath.mean, mcsCharPath.std, 'Linestyle', 'none', 'Marker', '+', 'Color', 'g');
    errorbar( vsCharPath.mean, vsCharPath.std, 'Linestyle', 'none', 'Marker', '+', 'Color', 'r');
    plot(controlCharPath.max, 'Linestyle', 'none', 'Marker', '^', 'Color', 'b');
    plot(controlCharPath.min, 'Linestyle', 'none', 'Marker', 'v', 'Color', 'b');
    plot(mcsCharPath.max, 'Linestyle', 'none', 'Marker', '^', 'Color', 'g');
    plot(mcsCharPath.min, 'Linestyle', 'none', 'Marker', 'v', 'Color', 'g');
    plot(vsCharPath.max, 'Linestyle', 'none', 'Marker', '^', 'Color', 'r');
    plot(vsCharPath.min, 'Linestyle', 'none', 'Marker', 'v', 'Color', 'r');
hold off 

figure;
hold on
    errorbar( controlAverageStrength.mean, controlAverageStrength.std, 'Linestyle', 'none', 'Marker', '+', 'Color', 'b');
    errorbar( mcsAverageStrength.mean, mcsAverageStrength.std, 'Linestyle', 'none', 'Marker', '+', 'Color', 'g');
    errorbar( vsAverageStrength.mean, vsAverageStrength.std, 'Linestyle', 'none', 'Marker', '+', 'Color', 'r');
    plot(controlAverageStrength.max, 'Linestyle', 'none', 'Marker', '^', 'Color', 'b');
    plot(controlAverageStrength.min, 'Linestyle', 'none', 'Marker', 'v', 'Color', 'b');
    plot(mcsAverageStrength.max, 'Linestyle', 'none', 'Marker', '^', 'Color', 'g');
    plot(mcsAverageStrength.min, 'Linestyle', 'none', 'Marker', 'v', 'Color', 'g');
    plot(vsAverageStrength.max, 'Linestyle', 'none', 'Marker', '^', 'Color', 'r');
    plot(vsAverageStrength.min, 'Linestyle', 'none', 'Marker', 'v', 'Color', 'r');
hold off    

figure;
hold on
    errorbar( controlAverageClustering.mean, controlAverageClustering.std, 'Linestyle', 'none', 'Marker', '+', 'Color', 'b');
    errorbar( mcsAverageClustering.mean, mcsAverageClustering.std, 'Linestyle', 'none', 'Marker', '+', 'Color', 'g');
    errorbar( vsAverageClustering.mean, vsAverageClustering.std, 'Linestyle', 'none', 'Marker', '+', 'Color', 'r');
    plot(controlAverageClustering.max, 'Linestyle', 'none', 'Marker', '^', 'Color', 'b');
    plot(controlAverageClustering.min, 'Linestyle', 'none', 'Marker', 'v', 'Color', 'b');
    plot(mcsAverageClustering.max, 'Linestyle', 'none', 'Marker', '^', 'Color', 'g');
    plot(mcsAverageClustering.min, 'Linestyle', 'none', 'Marker', 'v', 'Color', 'g');
    plot(vsAverageClustering.max, 'Linestyle', 'none', 'Marker', '^', 'Color', 'r');
    plot(vsAverageClustering.min, 'Linestyle', 'none', 'Marker', 'v', 'Color', 'r');
hold off


    
    
    
    
    
    
    
    
    