% Este guion toma los resultados de los calculos hechos con BCT sobre las
% redes y divide en grupos de nivel de conciencia para calcular la
% dependencia estadistica a la vez que grafica los valores de las medidas
% limpiar el area de trabajo
clc; close all; clear;

% definir los parametros para el funcionamiento del guión
data         = '../Results';
Experimentos = {'Experimento01', 'Experimento02'};
Poblaciones  = {'Control', 'MinimallyConsciousState', 'VegetativeState'};
NombresPoblaciones  = {'Control', 'MCS', 'VS/UWS'};
%Correlacion  = {'DC', 'NMI', 'Pearson'};
Correlacion  = {'DC'};
Umbrales     = 0.0:0.1:1.0;
Binary       = 0;
% aEliminar    = [4 5 9];
aEliminar    = [];
%                    'Degree', 'Strength', 'Clustering', 'Transitivity', 'Eigenvector', 'LocalEfficiency', 'Outreach**'
ArrayMeasurement  = {'Strength', 'Clustering', 'LocalEfficiency', 'Eigenvector'};
NombresArrayMeasurement = {'Strength', 'Clustering Coefficient', 'Local Efficiency', 'Eigenvector Centrality'};
%                     'Efficiency', 'Charpath'
SingleMeasurement  = {'Efficiency', 'Charpath', 'Radius', 'Diameter'};
NombresSingleMeasurement  = {'Efficiency', 'Characteristic Path', 'Radius', 'Diameter'};
pValue = 0.05;
nombresRedes = {'Auditory';'Cerebellum';'Default Mode Network';'Excecutive Control Left';'Excecutive Control Right';'Salliency';'Sensori-motor';'Visual lateral';'Visual Media';'Visual Occipital'};
nombresRedes(aEliminar) = [];
binSize = 0.1;


% string que identifica los nodos excliudos
excluidos = '';
if ~isempty(aEliminar)
    excluidos = ['No-' regexprep( int2str(aEliminar), '  ', '-')];
end

% Para cada uno de los experimentos
for e = 1 : 1 %length(Experimentos)
    currentExp = char(Experimentos(e));
    medidasPoblaciones = {};
    % para las medidas de redes que son de tipo arreglo(locales)
    for am = 1 : length(ArrayMeasurement)
        currentMea = char( ArrayMeasurement(am) );
        % Para cada una de las medidas de correlación
        for c = 1 : 1 %length(Correlacion);
            currentCor = char(Correlacion(c));
            meanstd = struct([]);
            medida = struct([]);
            % crea e contenedor de todas las poblaciones y el de los grupos
            % para el parametro de boxplot
            medidas = [];
            grupo = [];
            medidasPoblacion = cell(length(Poblaciones));
            % Para cada una de las poblaciones
            for p = 1 : length(Poblaciones)
                currentPob = char(Poblaciones(p));
                 % Para cada valor de umbral
                for u = 1:1 %length(Umbrales)
                    currentUmb = Umbrales(u);
                    % cargar el archivo
                    if ~isempty(aEliminar)
                        currentFile = [data '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-summary' currentMea '.csv'];
                    else
                        currentFile = [data '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-summary' currentMea '.csv'];
                    end
                    currentMeasurement = load( currentFile );
                    % Separar los valores del promedio y desviación
                    % estandar de los valores de lso sujetos
                    dim = size(currentMeasurement,1);
                    % promedios y desviaciones por población con la misma
                    % medida de correlación para la medida actual de la red
                    meanstd(p).mean = currentMeasurement(dim-1,:);
                    meanstd(p).std = currentMeasurement(dim,:);
                    currentMeasurement = currentMeasurement(1:dim-2,:);
                    % obtener para cada nodo la información representativa,
                    % diferente de cero para el ananlisis de independencia
                    % estadistica con las poblaciones.
                    for n = 1:size(currentMeasurement,2)
                        medida(p).nodo(n).valores = currentMeasurement(currentMeasurement(:,n)~=0,n);
                    end
                    % guardar la matriz de medidas actual para el calculo
                    % de la pdf y la cdf
                    medidasPoblacion{p} = currentMeasurement;
                    grupo = [ grupo; ones(size(currentMeasurement)).*p];
                    medidasPoblaciones{am,p} = currentMeasurement;
                end
            end
            % imprimir la grafica de PDF para la medida actual de
            % la poblacion actual
            fpdf = pintarGraficaPDF(medidasPoblacion, binSize, Poblaciones, ...
                                    nombresRedes, char(ArrayMeasurement(am)), ...
                                    'SavePath', strcat(data,'/',currentExp), ...
                                    'Threshold',  num2str(currentUmb,'%-2.1f'), ...
                                    'Excluidos', excluidos);
            
            % realizar el test estadistico para mirar independencia
            test = zeros(size(currentMeasurement,2),2);
            for n = 1:size(test,1)
                [h,p] = ttest2(medida(1).nodo(n).valores,  [medida(2).nodo(n).valores; medida(3).nodo(n).valores]);
                test(n,:) = [h,p];
            end
            
            % para cada medida de correlación se pinta una grafica de
            % barras con la media y desviación estándar de cada población.
            filename = [ currentMea '-' num2str(currentUmb,'%-2.1f') '-' currentCor '-MeanStD'];
            if ~isempty(aEliminar)
                filename = [ currentMea '-' num2str(currentUmb,'%-2.1f') '-' currentCor '-' excluidos '-MeanStD'];
            end 
            fdc = pintarGraficaMeanSTD([ meanstd(1).mean ; meanstd(2).mean; meanstd(3).mean], ...
                                       [ meanstd(1).std;   meanstd(2).std;  meanstd(3).std], ...
                                       { 'Control', 'MCS', 'VS/UWS' }, currentMea, ...
                                       'Marca', (test(:,2)<pValue).*(test(:,1)) ); %, ...
%                                        'Color', [0.73 0.87 1.00; 0.93 0.78 1.00; 0.90 1.00 0.96] );
            set(fdc, 'Name',['DC for ' char(NombresArrayMeasurement(am)) '-' num2str(currentUmb,'%-2.1f') ' (Mean and Standard deviation)'], ... 
                     'Filename', [ currentMea '-' num2str(currentUmb,'%-2.1f') '-DC-MeanStD.fig'], 'NumberTitle', 'off' );
            title(['{\color{red}Distance Correlation} (Mean and Standard deviation) measurements for {\color{red}' char(NombresArrayMeasurement(am)) '}'],...
                   'FontName','palatino', 'FontSize', 14, 'FontWeight', 'bold', 'FontAngle', 'italic');
            set(gca,'XTickLabel', nombresRedes,'FontSize', 11);% , 'XTickLabelRotation', 90);
            rotateXLabels( gca, 45 )
            set(fdc, 'Position', [0 0 1600 600]);
            saveas(fdc,[data '/' currentExp '/Images/fig/' filename '.fig'], 'fig');
            print(fdc,'-dpng','-r150',[ data '/' currentExp '/Images/png/' filename '.png']);    
            print(fdc,'-depsc','-r600',[ data '/' currentExp '/Images/eps/' filename '.eps']);
            
            
            % Pintar las graficas incluyendo la dispersión de los datos.
            filename = [ currentMea '-' num2str(currentUmb,'%-2.1f') '-' currentCor '-MeanStD-VP'];
            if ~isempty(aEliminar)
                filename = [ currentMea '-' num2str(currentUmb,'%-2.1f') '-' currentCor '-' excluidos '-MeanStD-VP'];
            end
            % Crear el arreglo de medidas por nodo 
            for nd = 1:10
                % por cada poblacion
                valoresMedidaNodo.hc = medidasPoblaciones{am,1}(:,nd);
                valoresMedidaNodo.mcs = medidasPoblaciones{am,2}(:,nd);
                valoresMedidaNodo.vs = medidasPoblaciones{am,3}(:,nd);
                valoresVP(nd) = valoresMedidaNodo;
            end
            fvp = pintarGraficaDistribucionPlot( valoresVP, Poblaciones, nombresRedes, char(NombresArrayMeasurement(am)), 'Color', [0.73 0.87 1.00; 0.93 0.78 1.00; 0.90 1.00 0.96] );
            
            xlabel('\color{gray}RSNs', 'FontSize', 16, 'FontWeight', 'demi');
            ylabel(['\color{gray}' char(NombresArrayMeasurement(am))], 'FontSize',16, 'FontWeight', 'demi');
            set(gca,'XTick',2:3:length(Poblaciones)*10);
            set(gca,'XTickLabel', nombresRedes,'FontSize', 11, 'FontWeight', 'Bold');
            rotateXLabels( gca, 45 )
            
            set(fvp, 'Name',[char(NombresArrayMeasurement(am)) ' of ' currentCor ' -' num2str(currentUmb,'%-2.1f') '-(distribution)'], ... 
                    'Filename', [ currentMea '-' num2str(currentUmb,'%-2.1f') '-' currentCor '-distributionPoints.fig'], 'NumberTitle', 'off' );
            saveas(fvp,[data '/' currentExp '/Images/fig/' filename '.fig'], 'fig');
            print(fvp,'-dpng','-r150',[ data '/' currentExp '/Images/png/' filename '.png']);
            print(fvp,'-depsc','-r600',[ data '/' currentExp '/Images/eps/' filename '.eps']);
            
            
            
            % Calcular las medidas globales como los promedios de las 
            % locales y graficarlas. pintar la medida de cada población 
            
            filename = [ currentMea '-' num2str(currentUmb,'%-2.1f') '-' currentCor '-Global-MeanStD-distributionPoints'];
            if ~isempty(aEliminar)
                filename = [ currentMea '-' num2str(currentUmb,'%-2.1f') '-' currentCor '-' excluidos '-Global-MeanStD-distributionPoints'];
            end
            fd = figure;
            hold on;
            % crear la matrix de pequeños desplazamientos para pintar
            % los valores de la medida
            colores = [ 1 0 0; 0 1 0; 0 0 1]; 
            for p = 1 : length(Poblaciones)
                medidasPoblaciones{am,p};
                Yvalues = mean(medidasPoblaciones{am,p},2);
                Xvalues = zeros(length(Yvalues),1);
                dif = -0.3;
                for xv = 1:length(Xvalues)
                    Xvalues(xv) = Xvalues(xv) + dif;
                    dif = dif + 0.05;
                    if dif > 0.3
                        dif = -0.3;
                    end
                end
                medidas = [medidas; Yvalues];
                plot(Xvalues+p, Yvalues, 'o', 'MarkerEdgeColor', colores(p,:));
            end
            title(['{\color{red}' char(NombresArrayMeasurement(am)) ' - Point distribution by population }'], 'FontName','palatino', 'FontSize', 14, 'FontWeight', 'bold', 'FontAngle', 'italic');
            %xlabel('Populations');
            ylabel( char(NombresArrayMeasurement(am)) );
            set(gca,'XTick',1:1:length(Poblaciones));
            set(gca,'XTickLabel', NombresPoblaciones);
            ymax = max(medidas);
            if ymax > 1
                set(gca,'XLim', [0 length(Poblaciones)+1], 'YLim', [0 ceil(ymax)]);
            else
                set(gca,'XLim', [0 length(Poblaciones)+1], 'YLim', [0 1]);
            end
            set(fd, 'Name',[char(NombresArrayMeasurement(am)) ' of ' currentCor ' -' num2str(currentUmb,'%-2.1f') '-(distribution)'], ... 
                    'Filename', [ currentMea '-' num2str(currentUmb,'%-2.1f') '-' currentCor '-distributionPoints.fig'], 'NumberTitle', 'off' );
            saveas(fd,[data '/' currentExp '/Images/fig/' filename '.fig'], 'fig');
            print(fd,'-dpng','-r150',[ data '/' currentExp '/Images/png/' filename '.png']);
            print(fd,'-depsc','-r300',[ data '/' currentExp '/Images/eps/' filename '.eps']);
            hold off
                        
            filename = [ currentMea '-' num2str(currentUmb,'%-2.1f') '-' currentCor '-Global-MeanStD'];
            if ~isempty(aEliminar)
                filename = [ currentMea '-' num2str(currentUmb,'%-2.1f') '-' currentCor '-' excluidos '-Global-MeanStD'];
            end
            fb = figure;
            boxplot(medidas, grupo, 'labels', NombresPoblaciones);
            title(['{\color{red}' char(NombresArrayMeasurement(am)) ' - Distribution by population }'], 'FontName','palatino', 'FontSize', 14, 'FontWeight', 'bold', 'FontAngle', 'italic');
%            xlabel('Populations');
            ylabel( char(NombresArrayMeasurement(am)) );
            set(fb, 'Name',[currentMea ' of ' currentCor ' -' num2str(currentUmb,'%-2.1f') '-(distribution)'], ... 
                'Filename', [ currentMea '-' num2str(currentUmb,'%-2.1f') '-' currentCor '-distribution.fig'], 'NumberTitle', 'off' );
            saveas(fb,[data '/' currentExp '/Images/fig/' filename '.fig'], 'fig');
            print(fb,'-dpng','-r150',[ data '/' currentExp '/Images/png/' filename '.png']);
            print(fb,'-depsc','-r300',[ data '/' currentExp '/Images/eps/' filename '.eps']);

        end
        measurementsSummary(am) = struct('name', NombresArrayMeasurement(am), ...
                                         'valoresControl', mean(medidasPoblaciones{am,1},2), ...
                                         'valoresMCS', mean(medidasPoblaciones{am,2},2), ...
                                         'valoresVS', mean(medidasPoblaciones{am,3},2), ...
                                         'comp_1',[],'comp_2',[],'comp_3',[],'comp_4',[]);
        close all;
    end
    
%     % Las graficas y analisis de las medidas globales
%     medidasPoblacion = {};
%     testSingle = zeros(length(SingleMeasurement),3);
%     for sm = 1 : length(SingleMeasurement)
%         currentMea = char(SingleMeasurement(sm));
%         % Para cada medida de correlación
%         for c = 1 : length(Correlacion);
%             currentCor = char(Correlacion(c));
%             % crea e contenedor de todas las poblaciones y el de los grupos
%             % para el parametro de boxplot
%             medida = [];
%             grupo = [];
%             % Para cada valor de umbral
%             for u = 1:1 %length(Umbrales)
%                 currentUmb = Umbrales(u);
%                 % Para cada una de las poblaciones
%                 for p = 1 : length(Poblaciones)
%                     currentPob = char(Poblaciones(p));
%                     % cargar el archivo
%                     if ~isempty(aEliminar)
%                         currentFile = [data '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-' excluidos '-summary' currentMea '.csv'];
%                     else
%                         currentFile = [data '/' currentExp '/' currentPob '/' currentCor '-' num2str(currentUmb,'%-2.1f') '-summary' currentMea '.csv'];
%                     end
%                     currentMeasurement = load( currentFile );
%                     % Separar los valores del promedio y desviación
%                     % estandar de los valores de los sujetos
%                     dim = size(currentMeasurement,1);
%                     currentMeasurement = currentMeasurement(1:dim-2,:);
%                     medida = [medida; currentMeasurement];
%                     grupo = [ grupo; ones(size(currentMeasurement)).*p];
%                     medidasPoblacion{sm,p} = currentMeasurement;
%                 end
%                 % calcular el test estadistico con TTest2
%                 [h,p] = ttest2(medidasPoblacion{sm,1}, [medidasPoblacion{sm,2}; medidasPoblacion{sm,3}]);
%                 testSingle(sm,1:2) = [h,p];
%                 % Bonferroni Correction
%                 if( p < pValue/2 )
%                     testSingle(sm,3) = 1;
%                 end
%                 % Pintar el boxplot con las medidas y nombres adecuados
%                 filename = [ currentMea '-' num2str(currentUmb,'%-2.1f') '-' currentCor '-MeanStD'];
%                 if ~isempty(aEliminar)
%                     filename = [ currentMea '-' num2str(currentUmb,'%-2.1f') '-' currentCor '-' excluidos '-MeanStD'];
%                 end
%                 fb = figure;
%                 boxplot(medida, grupo, 'labels', NombresPoblaciones);
%                 title(['{\color{red}' char(NombresSingleMeasurement(sm)) ' - Distribution by population }'], 'FontName','palatino', 'FontSize', 14, 'FontWeight', 'bold', 'FontAngle', 'italic');
% %                xlabel('Populations');
%                 ylabel(  char(NombresSingleMeasurement(sm)) );
%                 % Pintar un asterisco indicando la diferencia significativa
%                 % entre healthy and DOC
% %                xIni = ((i-1)*numPob)+1;
% %                xFin   = i*numPob;
% %                yIni = ceil((mayor*100)+1)/100;
% %                yFin   = ceil(mayor*10)/10;
% %                if ceil(mayor*10)/10 == ceil(mayor*100)/100
% %                    yFin = ceil((mayor*10)+1)/10;
% %                end
% %                line( [xIni, xIni, xFin, xFin], [yIni, yFin, yFin, yIni], 'Color', [0 0 0], 'LineWidth', 2);
% %                text( floor(xIni + numPob/2), yFin, '*', 'FontName', 'Helvetica','FontSize',20,'HorizontalAlignment','center');
%                 %
%                 
%                 set(fb, 'Name',[ char(NombresSingleMeasurement(sm)) ' of ' currentCor ' -' num2str(currentUmb,'%-2.1f') '-(distribution)'], ... 
%                         'Filename', [ currentMea '-' num2str(currentUmb,'%-2.1f') '-' currentCor '-distribution.fig'], 'NumberTitle', 'off' );
%                 saveas(fb,[data '/' currentExp '/Images/fig/' filename '.fig'], 'fig');
%                 print(fb,'-dpng','-r150',[ data '/' currentExp '/Images/png/' filename '.png']);
%                 print(fb,'-depsc','-r300',[ data '/' currentExp '/Images/eps/' filename '.eps']);
%                 
%                 % pintar la medida de cada población 
%                 filename = [ currentMea '-' num2str(currentUmb,'%-2.1f') '-' currentCor '-MeanStD-distributionPoints'];
%                 if ~isempty(aEliminar)
%                     filename = [ currentMea '-' num2str(currentUmb,'%-2.1f') '-' currentCor '-' excluidos '-MeanStD-distributionPoints'];
%                 end
%                 fd = figure;
%                 hold on;
%                 % crear la matrix de pequeños desplazamientos para pintar
%                 % los valores de la medida
%                 colores = [ 1 0 0; 0 1 0; 0 0 1]; 
%                 for p = 1 : length(Poblaciones)
%                      Xvalues = zeros(length(medidasPoblacion{sm,p}),1);
%                     dif = -0.3;
%                     for xv = 1:length(Xvalues)
%                         Xvalues(xv) = Xvalues(xv) + dif;
%                         dif = dif + 0.05;
%                         if dif > 0.3
%                             dif = -0.3;
%                         end
%                     end
%                     plot(Xvalues+p, medidasPoblacion{sm,p}, 'o', 'MarkerEdgeColor', colores(p,:));
%                 end
%                 title(['{\color{red}'  char(NombresSingleMeasurement(sm)) ' - Point distribution by population}'], 'FontName','palatino', 'FontSize', 14, 'FontWeight', 'bold', 'FontAngle', 'italic');
% %                xlabel('Populations');
%                 ylabel(  char(NombresSingleMeasurement(sm)) );
%                 set(gca,'XTick',1:1:length(Poblaciones));
%                 set(gca,'XTickLabel', NombresPoblaciones);
%                 set(gca,'XLim', [0 length(Poblaciones)+1], 'YLim', [0 1]);
%                 set(fd, 'Name',[ char(NombresSingleMeasurement(sm)) ' of ' currentCor ' -' num2str(currentUmb,'%-2.1f') '-(distribution)'], ... 
%                         'Filename', [ currentMea '-' num2str(currentUmb,'%-2.1f') '-' currentCor '-distributionPoints.fig'], 'NumberTitle', 'off' );
%                 saveas(fd,[data '/' currentExp '/Images/fig/' filename '.fig'], 'fig');
%                 print(fd,'-dpng','-r150',[ data '/' currentExp '/Images/png/' filename '.png']);
%                 print(fd,'-depsc','-r300',[ data '/' currentExp '/Images/eps/' filename '.eps']);
%             end
%         end
%         
%         measurementsSummary(am+sm) = struct('name', NombresSingleMeasurement(sm), ...
%                                          'valoresControl', medidasPoblacion{sm,1}, ...
%                                          'valoresMCS', medidasPoblacion{sm,2}, ...
%                                          'valoresVS', medidasPoblacion{sm,3}, ...
%                                          'comp_1',[],'comp_2',[],'comp_3',[],'comp_4',[]);
%     end
%     close all;
% end
% 
% % keep the values for the paper in the same order as in paper
% measurementsSummary = measurementsSummary([4 5 6 7 1 2]);
% 
% % array to keep h and p values of the ttest2
% statisticTestValues = zeros(length(measurementsSummary),12);
% % array to keep the mean a standard deviation
% statisticValues = zeros(length(measurementsSummary),3,2);
% for i = 1: length(measurementsSummary)
%     nanControl = measurementsSummary(i).valoresControl(~isnan(measurementsSummary(i).valoresControl));
%     nanMCS = measurementsSummary(i).valoresMCS(~isnan(measurementsSummary(i).valoresMCS));
%     nanVS = measurementsSummary(i).valoresVS(~isnan(measurementsSummary(i).valoresVS));
% 
%     statisticValues(i,1,1) = mean(nanControl);
%     statisticValues(i,2,1) = mean(nanMCS);
%     statisticValues(i,3,1) = mean(nanVS);
%     statisticValues(i,1,2) = std(nanControl);
%     statisticValues(i,2,2) = std(nanMCS);
%     statisticValues(i,3,2) = std(nanVS);
%     
%     % comparison 1: Control against DoC
%     [h,p] = ttest2(nanControl, [nanMCS; nanVS]);
%     statistic = struct('H', h, 'P', p, 'Bonfferroni', p < pValue/2 );
%     measurementsSummary(i).comp_1 = statistic;
%     statisticTestValues(i,1:3) = [h, p, (p < pValue/2)];
%     % comparison 2: Control against MCS
%     [h,p] = ttest2(nanControl, nanMCS);
%     statistic = struct('H', h, 'P', p, 'Bonfferroni', p < pValue/2 );
%     statisticTestValues(i,4:6) = [h, p, (p < pValue/2)];
%     measurementsSummary(i).comp_2 = statistic;
%     % comparison 3: Control against VS
%     [h,p] = ttest2(nanControl, nanVS);
%     statistic = struct('H', h, 'P', p, 'Bonfferroni', p < pValue/2 );
%     measurementsSummary(i).comp_3 = statistic;
%     statisticTestValues(i,7:9) = [h, p, (p < pValue/2)];
%     % comparison 4: Control against MCS against VS/UWS
%     [h,p] = ttest2( nanMCS, nanVS);
%     statistic = struct('H', h, 'P', p, 'Bonfferroni', p < pValue/2 );
%     measurementsSummary(i).comp_4 = statistic;
%     statisticTestValues(i,10:12) = [h, p, (p < pValue/2)];
%     
%     
% %     % comparison 1: Control against DoC
% %     [h,p] = ttest2(measurementsSummary(i).valoresControl, [measurementsSummary(i).valoresMCS; measurementsSummary(i).valoresVS]);
% %     statistic = struct('H', h, 'P', p, 'Bonfferroni', p < pValue/2 );
% %     measurementsSummary(i).comp_1 = statistic;
% %     statisticTestValues(i,1:3) = [h, p, (p < pValue/2)];
% %     % comparison 2: Control against MCS
% %     [h,p] = ttest2(measurementsSummary(i).valoresControl, measurementsSummary(i).valoresMCS);
% %     statistic = struct('H', h, 'P', p, 'Bonfferroni', p < pValue/2 );
% %     statisticTestValues(i,4:6) = [h, p, (p < pValue/2)];
% %     measurementsSummary(i).comp_2 = statistic;
% %     % comparison 3: Control against VS
% %     [h,p] = ttest2(measurementsSummary(i).valoresControl, measurementsSummary(i).valoresVS);
% %     statistic = struct('H', h, 'P', p, 'Bonfferroni', p < pValue/2 );
% %     measurementsSummary(i).comp_3 = statistic;
% %     statisticTestValues(i,7:9) = [h, p, (p < pValue/2)];
% %     % comparison 4: Control against MCS against VS/UWS
% %     [h,p] = ttest2( measurementsSummary(i).valoresMCS, measurementsSummary(i).valoresVS);
% %     statistic = struct('H', h, 'P', p, 'Bonfferroni', p < pValue/2 );
% %     measurementsSummary(i).comp_4 = statistic;
% %     statisticTestValues(i,10:12) = [h, p, (p < pValue/2)];
% 
% 
% 
% end
% 
% fdc = pintarGraficaMeanSTD(statisticValues(:,:,1),statisticValues(:,:,2),{'Control', 'MCS', 'VS/UWS'}, '')
% xlabel('\color{gray}Measurements', 'FontName', 'helvetica', 'FontSize', 17, 'FontWeight', 'bold');
% set(gca,'XTickLabel', {'Global efficiency' 'Average characteristic path' 'Diameter' 'Radius' 'Average strength' 'Average clustering'}, 'FontSize',16, 'FontWeight', 'demi');
% %rotateXLabels( gca, 45 )
% set(fdc, 'Position', [0 0 1600 1280]);title('\color{red} Global network measurements by population','FontName','palatino', 'FontSize', 22, 'FontWeight', 'bold', 'FontAngle', 'italic')
% title('\color{red} Global network measurements by population','FontName','palatino', 'FontSize', 22, 'FontWeight', 'bold', 'FontAngle', 'italic')
% 
% statisticTestValues(:,[1 2 4 5 7 8 10 11]);
% 
% 
% currentExp = char(Experimentos(1));
% for i = 1: length(measurementsSummary)
%     dataPrueba = zeros(27,3);
%     nanControl = measurementsSummary(i).valoresControl(~isnan(measurementsSummary(i).valoresControl));
%     nanMCS = measurementsSummary(i).valoresMCS(~isnan(measurementsSummary(i).valoresMCS));
%     nanVS = measurementsSummary(i).valoresVS(~isnan(measurementsSummary(i).valoresVS));
%     dataPrueba(:,1) = measurementsSummary(i).valoresControl;
%     dataPrueba(1:24,2) = measurementsSummary(i).valoresMCS;
%     dataPrueba(25:27,2) = mean(nanMCS);
%     dataPrueba(1:25,3) = measurementsSummary(i).valoresVS;
%     dataPrueba(26:27,3) = mean(nanVS);
%     fvp = figure;
%     hvp = distributionPlot(dataPrueba ...
%         , 'color' , [0.3490 0.5765 0.7569] ...   % {[1 1 0] [0 1 1] [1 0 1]} ...%        , 'colormap', copper ...
%         , 'globalNorm', 0 ... % groups ????
%         , 'histOpt', 1 ... % it is the smoothing option        , 'divFactor', 1.0 ...
%         , 'addSpread', 1 ... % show the points into the violin plot
%         , 'showMM', 5 ... % this option shows the mean and standard deviation        , 'xNames' , {'Control', 'MCS', 'VS/UWS'} ...         , 'yLabel' , char(measurementsSummary(i).name) ... 
%     );
%     
%     set(fvp, 'Position', [0 0 2000 800]);
%     title(['\color{red} ' measurementsSummary(i).name ' - Distribution by population'],'FontName','palatino', 'FontSize', 22, 'FontWeight', 'bold', 'FontAngle', 'italic');
%     set(hvp{4}{1},'color', [0 0 0], 'marker', 'o', 'LineWidth', 2)
%     xlabel('\color{gray}Populations', 'FontSize',16, 'FontWeight', 'demi');
%     set(gca,'XTickLabel', NombresPoblaciones, 'FontSize',16, 'FontWeight', 'demi');
%     %xTickLabel({'Control', 'MCS', 'VS/UWS'});
%     ylabel(['\color{gray}' char(measurementsSummary(i).name)], 'FontSize',16, 'FontWeight', 'demi');
%     set(hvp{2}, 'LineWidth', 2, 'MarkerSize', 40);
%     
%     filename = [ char(measurementsSummary(i).name) '-MeanStD-distributionPoints-VP'];
%     if ~isempty(aEliminar)
%         filename = [ char(measurementsSummary(i).name) '-' excluidos '-MeanStD-distributionPoints-VP'];
%     end
%     
%     set(fvp, 'Name',[char(measurementsSummary(i).name) '-(distribution)']);
%     saveas(fvp,[data '/' currentExp '/Images/fig/' filename '.fig'], 'fig');
%     print(fvp,'-dpng','-r150',[ data '/' currentExp '/Images/png/' filename '.png']);
%     print(fvp,'-depsc','-r900',[ data '/' currentExp '/Images/eps/' filename '.eps']);
% end
%     
% 
% 
% 
% 
% 
% % 1-by-4 cell array with patch-handles for the distributions, plot handles 
% % for mean/median, the axes handle, and the plotSpread-points handle
% 
% 
% 
% 
% 
end

