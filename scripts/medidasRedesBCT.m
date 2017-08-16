% Este guion se configura para realizar operaciones sobre las medidas de
% redes de conexión funcional. Las operaciones a realizar buscan explorar
% las propiedades de las redes de manera global y local a los nodos. Para
% el cálculo de las diferentes operaciones sobre cada red, se utiliza el
% Brain Connectivity Toolbox (BCT).
% Algunas de las operaciones del toolbox son:
%
%    degree = numero de relaciones conectadas a un nodo
%    shortest path length = base para las medidas de integracion
%    number of triangles = base para las medidas de segregacion
%    Medidas de integracion
%        Characteristic path length
%        Global efficiency
%    Medidas de segregacion
%        Clustering coefficient
%        Transitivity
%        Local efficiency
%        Modularity
%    Medidas de centralidad
%        Closeness centrality
%        Betweeness centrality
%        Within module degree z-score
%        Participation coefficient
%    Network Motifs
%        Motif z-score
%        motif fingerprint
%    Medidas de resistencia/adaptacion
%        Degree distribution
%        Average neighbor degree
%        Assortativity coefficient
%    Otros
%        Degree distribution preserving network randomization
%        small-worldness
%
% Las operaciones a realizar sobre cada red son:   
%
%    degree
%    strength
%    eigenvector
%    modularity
%    characteristic path
%    clustering coefficient
%    transitivity
%    local efficiency
%    global efficiency
%    distance
%    rich club
%    betweenness
%
%    outreach
%    small-worldness
%
% Además se calcularán 
%    degree distribution
%    strength distribution
%    
% -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -

% limpiar el area de trabajo
clc; close all; clear;

% definir los parametros para el funcionamiento del guión
%data          = '../../data';
data          = '../data';
% directorio donde se guardaran los resultados
%resultsDir    = '../../Results-FNC-CNM/'
resultsDir    = '../results';
% Experimentos  = {'Experimento01', 'Experimento02'};
Experimentos  = {'Experimento01'};
Poblaciones   = {'Control', 'MinimallyConsciousState', 'VegetativeState'};
%Correlacion   = {'DC', 'NMI', 'Pearson'};
Correlacion   = {'DC'};
%Umbrales      = 0.0:0.1:1.0;
Umbrales      = 0.0;
Binary        = 0;
%aEliminar     = [4 5 9];
aEliminar     = [];
noArtifactual = 1;

% string que identifica los nodos excliudos
if ~isempty(aEliminar)
    excluidos = ['No-' regexprep( int2str(aEliminar), '  ', '-')];
end

% Para cada uno de los experimentos
for e = 1 : length(Experimentos)
    currentExp = char(Experimentos(e));
    display(['Beginnig with experiment ' currentExp]);
    
    % Para cada una de las poblaciones
    for p = 1 : length(Poblaciones)
        currentPob = char(Poblaciones(p));
        display(['Computing values for ' currentPob ' population']);
        
        % Para cada una de las medidas de correlación
        for c = 1 : length(Correlacion);
            currentCor = char(Correlacion(c));
            display(['Loading ' currentCor ' correlation matrix from' ]);
            
            currentFile = [data '/' currentExp '/' currentPob '/' currentCor '.mat'];
            display(['    -> ' currentFile]);
            
            % Para cada archivo de medidas
            currentRed = importdata(currentFile);
            % si se eliminan o no las redes que no tienen valores neuronales
            if noArtifactual == 1
                display('Removing artifactual values')
                [currentRed, removedSubjects] =  removeArtifactualMatrix(currentRed);
            end
            % obtengo el numero de pacientes
            tam = length(currentRed);
            % Para cada valor de umbral
            for u = 1:length(Umbrales)
                currentUmb = Umbrales(u);
                display(['Making computations for ' num2str(currentUmb,'%-2.1f') ' threshold']);
                % obtengo las dimensiones de la matriz de cada paciente 
                dimMatrix = length(currentRed(:,:,1))-length(aEliminar);
                % Crear una matriz de celdas en donde se guardaran los
                % resultados de las operaciones con BCT
                medidas = {tam};
                % Crear las matrices donde se guardaran las medidas de cada
                % operacion sobre las redes para cada sujeto
                matrizDegree = zeros(tam, dimMatrix);
                matrizStrength = zeros(tam, dimMatrix);
                matrizClustering = zeros(tam, dimMatrix);
                matrizTransitivity = zeros(tam, dimMatrix);
                matrizDistance = zeros(((tam)*dimMatrix(1)), dimMatrix(1));
                matrizLocalEfficiency = zeros(tam, dimMatrix);
                matrizEfficiency = zeros(tam, 1);
                matrizCharpath = cell(tam,5);
                matrizEigenvector = zeros(tam, dimMatrix);
                matrizModularity = zeros(tam, dimMatrix);
                matrizBetweenness = zeros(tam, dimMatrix);
                matrizRichclub = zeros(tam, dimMatrix);
                
                % para cada sujeto en la matriz de medidas de correlación
                for i = 1:tam
                    X = prepareNetworkMatrix(currentRed(:,:,i),currentCor,currentUmb,Binary);
                    % Cambiar la información de la matriz triangular por la
                    % matriz con valores entre 0 y 1
                    currentRed(:,:,i) = X;
                    % Aqui se eliminan los nodos que no se requieren
                    X(:,aEliminar) = [];
                    X(aEliminar,:) = [];
                    % Obtener la matriz completa a partir de la matriz
                    % triangular
                    X = X + X';
                    % llamar la funcion que calcula las medidas y las
                    % guarda en un array de celdas
                    M = computeBCTMeasures(X,Binary);
                    % guarda las medidas del sujeto i de la poblacion en el
                    % arreglo de medidas
                    medidas{i} = M;
                    % crea una matriz de cada medida donde en cada fila
                    % tiene la medida para la red del sujeto i
                    % correspondiente
                    matrizDegree(i,:) = M.degree;
                    matrizStrength(i,:) = M.strength;
                    for v =1:5
                        matrizCharpath{i,v} = M.charpath{v};
                    end
                    matrizEigenvector(i,:) = M.eigenvector;
                    matrizModularity(i,:) = M.modularity;
                    matrizClustering(i,:) = M.clustering;
                    matrizTransitivity(i) = M.transitivity;
                    matrizLocalEfficiency(i,:) = M.localefficiency;
                    matrizEfficiency(i) = M.efficiency;
                    currentDistance = M.distance;
                    matrizDistance( (((i-1)*dimMatrix(1))+1):(i*dimMatrix(1)), : ) = currentDistance;
                    matrizBetweenness(i,:) = M.betweenness;
                    % TODO: revisar la heterogeneidad de rich club
                    matrizRichclub(i,1:length(M.richclub)) = M.richclub;
                end
                % Guardar las medidas con bct
                filename = [resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-measurements.mat'];
                if noArtifactual == 1
                    filename = [resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-NoArtifactual-measurements.mat'];
                    
                    if ~isempty(aEliminar)
                        filename = [resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-NoArtifactual-measurements.mat'];
                    end
                else
                    if ~isempty(aEliminar)
                        filename = [resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-measurements.mat'];
                    end
                end
                save(filename, 'medidas','currentRed');
                
                % Calcular el promedio y desviación estándar de cada matriz
                % y guardarlas en las dos ultimas filas de cada matriz
                % respectivamente.
                % El promedio y desviación estandar se calculan solo para
                % los valores diferente de cero en las matrices
                for i1=1:size(matrizDegree,2)
                    matrizDegree(tam+1,i1) = mean(matrizDegree(matrizDegree(1:tam,i1)~=0,i1));
                    matrizDegree(tam+2,i1) = std(matrizDegree(matrizDegree(1:tam,i1)~=0,i1));
                end
                for i1=1:size(matrizStrength,2)
                    matrizStrength(tam+1,i1) = mean(matrizStrength(matrizStrength(1:tam,i1)~=0,i1));
                    matrizStrength(tam+2,i1) = std(matrizStrength(matrizStrength(1:tam,i1)~=0,i1));
                end
                % para cada valor de la ruta caracteristica 
                matrizCharpath{tam+1,1} = mean([matrizCharpath{:,1}]);
                matrizCharpath{tam+1,2} = mean([matrizCharpath{:,2}]);
                matrizCharpath{tam+1,3} = mean([matrizCharpath{:,3}],2);
                matrizCharpath{tam+1,4} = mean([matrizCharpath{:,4}]);
                matrizCharpath{tam+1,5} = mean([matrizCharpath{:,5}]);
                matrizCharpath{tam+2,1} = std([matrizCharpath{:,1}]);
                matrizCharpath{tam+2,2} = std([matrizCharpath{:,2}]);
                matrizCharpath{tam+2,3} = std([matrizCharpath{:,3}]')';
                matrizCharpath{tam+2,4} = std([matrizCharpath{:,4}]);
                matrizCharpath{tam+2,5} = std([matrizCharpath{:,5}]);
                for i1 = 1:size(matrizEigenvector,2)
                    matrizEigenvector(tam+1,:) = mean(matrizEigenvector(matrizEigenvector(1:tam,i1)~=0));
                    matrizEigenvector(tam+2,:) = std(matrizEigenvector(matrizEigenvector(1:tam,i1)~=0));
                end
                for i1 = 1:size(matrizModularity,2)
                    matrizModularity(tam+1,:) = mean(matrizModularity(matrizModularity(1:tam,i1)~=0));
                    matrizModularity(tam+2,:) = std(matrizModularity(matrizModularity(1:tam,i1)~=0));
                end
                for i1=1:size(matrizClustering,2)
                    matrizClustering(tam+1,i1) = mean(matrizClustering(matrizClustering(1:tam,i1)~=0,i1));
                    matrizClustering(tam+2,i1) = std(matrizClustering(matrizClustering(1:tam,i1)~=0,i1));
                end
                matrizTransitivity(tam+1) = mean(matrizTransitivity(matrizTransitivity(1:tam)~=0));
                matrizTransitivity(tam+2) = std(matrizTransitivity(matrizTransitivity(1:tam)~=0));
                matrizEfficiency(tam+1) = mean(matrizEfficiency(matrizEfficiency(1:tam)~=0));
                matrizEfficiency(tam+2) = std(matrizEfficiency(matrizEfficiency(1:tam)~=0));
                for i1=1:size(matrizLocalEfficiency,2)
                    matrizLocalEfficiency(tam+1,i1) = mean(matrizLocalEfficiency(matrizLocalEfficiency(1:tam,i1)~=0,i1));
                    matrizLocalEfficiency(tam+2,i1) = std(matrizLocalEfficiency(matrizLocalEfficiency(1:tam,i1)~=0,i1));
                end
                for i1=1:size(matrizBetweenness,2)
                    matrizBetweenness(tam+1,i1) = mean(matrizBetweenness(matrizBetweenness(1:tam,i1)~=0,i1));
                    matrizBetweenness(tam+2,i1) = std(matrizBetweenness(matrizBetweenness(1:tam,i1)~=0,i1));
                end
                
                % TODO: promedio y desviación estandar de las matrices de
                %       distancia
                
                filename = [resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-matrixMeasurements.mat'];
                if noArtifactual == 1
                    filename = [resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-NoArtifactual-matrixMeasurements.mat'];
                    if ~isempty(aEliminar)
                        % Guardar las matrices de resumen de cada medida
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-NoArtifactual-summaryDegree.csv'], matrizDegree);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-NoArtifactual-summaryStrength.csv'], matrizStrength);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-NoArtifactual-summaryClustering.csv'], matrizClustering);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-NoArtifactual-summaryTransitivity.csv'], matrizTransitivity);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-NoArtifactual-summaryEfficiency.csv'], matrizEfficiency);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-NoArtifactual-summaryDistance.csv'], matrizDistance);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-NoArtifactual-summaryLocalEfficiency.csv'], matrizLocalEfficiency);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-NoArtifactual-summaryBetweenness.csv'], matrizBetweenness);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-NoArtifactual-summaryCharpath.csv'], [matrizCharpath{:,1}]');
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-NoArtifactual-summaryEccentricity.csv'], [matrizCharpath{:,3}]');
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-NoArtifactual-summaryRadius.csv'], [matrizCharpath{:,4}]');
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-NoArtifactual-summaryDiameter.csv'], [matrizCharpath{:,5}]');
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-NoArtifactual-summaryEigenvector.csv'], matrizEigenvector);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-NoArtifactual-summaryModularity.csv'], matrizModularity);
                        filename = [resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-NoArtifactual-matrixMeasurements.mat'];
                    else 
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-NoArtifactual-summaryDegree.csv'], matrizDegree);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-NoArtifactual-summaryStrength.csv'], matrizStrength);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-NoArtifactual-summaryClustering.csv'], matrizClustering);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-NoArtifactual-summaryTransitivity.csv'], matrizTransitivity);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-NoArtifactual-summaryEfficiency.csv'], matrizEfficiency);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-NoArtifactual-summaryDistance.csv'], matrizDistance);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-NoArtifactual-summaryLocalEfficiency.csv'], matrizLocalEfficiency);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-NoArtifactual-summaryBetweenness.csv'], matrizBetweenness);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-NoArtifactual-summaryCharpath.csv'], [matrizCharpath{:,1}]');
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-NoArtifactual-summaryEccentricity.csv'], [matrizCharpath{:,3}]');
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-NoArtifactual-summaryRadius.csv'], [matrizCharpath{:,4}]');
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-NoArtifactual-summaryDiameter.csv'], [matrizCharpath{:,5}]');
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-NoArtifactual-summaryEigenvector.csv'], matrizEigenvector);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-NoArtifactual-summaryModularity.csv'], matrizModularity);
                    end
                else
                    if ~isempty(aEliminar)
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-summaryDegree.csv'], matrizDegree);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-summaryStrength.csv'], matrizStrength);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-summaryClustering.csv'], matrizClustering);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-summaryTransitivity.csv'], matrizTransitivity);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-summaryEfficiency.csv'], matrizEfficiency);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-summaryDistance.csv'], matrizDistance);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-summaryLocalEfficiency.csv'], matrizLocalEfficiency);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-summaryBetweenness.csv'], matrizBetweenness);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-summaryCharpath.csv'], [matrizCharpath{:,1}]');
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-summaryEccentricity.csv'], [matrizCharpath{:,3}]');
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-summaryRadius.csv'], [matrizCharpath{:,4}]');
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-summaryDiameter.csv'], [matrizCharpath{:,5}]');
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-summaryEigenvector.csv'], matrizEigenvector);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-summaryModularity.csv'], matrizModularity);
                        filename = [resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-matrixMeasurements.mat'];
                    else
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-summaryDegree.csv'], matrizDegree);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-summaryStrength.csv'], matrizStrength);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-summaryClustering.csv'], matrizClustering);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-summaryTransitivity.csv'], matrizTransitivity);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-summaryEfficiency.csv'], matrizEfficiency);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-summaryDistance.csv'], matrizDistance);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-summaryLocalEfficiency.csv'], matrizLocalEfficiency);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-summaryBetweenness.csv'], matrizBetweenness);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-summaryCharpath.csv'], [matrizCharpath{:,1}]');
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-summaryEccentricity.csv'], [matrizCharpath{:,3}]');
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-summaryRadius.csv'], [matrizCharpath{:,4}]');
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-summaryDiameter.csv'], [matrizCharpath{:,5}]');
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-summaryEigenvector.csv'], matrizEigenvector);
                        csvwrite([resultsDir '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-summaryModularity.csv'], matrizModularity);
                    end
                end
                save(filename, 'matrizDegree', 'matrizStrength', 'matrizClustering', 'matrizTransitivity', 'matrizEigenvector', 'matrizCharpath', 'matrizEfficiency', 'matrizDistance', 'matrizModularity');
                
            end
        end
    end
end
