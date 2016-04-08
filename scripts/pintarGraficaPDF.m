% Esta función crea una grafica de la funcion de distribución de
% probabilidad de los valores de una matriz cuyas filas indican el numero
% de sujetos y las columnas de la medida de una propiedad de cada sujeto.
% 
% function [f1, f2] = pintarGraficaPDF(measurements, binSize, population, networkNames, measurementName)
% function [f1, f2] = pintarGraficaPDF(measurements, binSize, population, networkNames, measurementName, 'SavePath', path)
% function [f1, f2] = pintarGraficaPDF(measurements, binSize, population, networkNames, measurementName, 'SavePath', path, 'Threshold', thresh)
% function [f1, f2] = pintarGraficaPDF(measurements, binSize, population, networkNames, measurementName, 'SavePath', path, 'Threshold', thresh, 'Excluidos', excluidos)
%
%
% Parámetros:
%
%    measurements    = arreglo de celdas con la información de la matriz 
%                      con las medidas por poblacion cuyas filas 
%                      representan unsujeto y columnas las medidas hechas 
%                      sobre los nodos del sujeto.
%    binSize         = tamaño del bin a considerar en la grafica de la
%                      distribución de probabilidad.
%    population      = arreglo con los nombres de la poblaciones
%    networkNames    = arreglo con los nombres de las redes que representan
%                      cada nodo
%    measurementName = nombre de la medida de la red que se esta
%                      graficando
%
% Parámetros Opcionales
%    path            = Directorio donde se guardaran las imagenes
%    thresh          = valor del threshold aplicado a la conectividad de
%                      las redes que se analizan
%    excluidos       = cadena de caracteres con los nodos que se excluyeron
%                      del analisis
%
function [f1, f2] = pintarGraficaPDF(measurements, binSize, population, networkNames, measurementName, varargin )
    saveImages = 0;
    currentUmb = '';
    pathImages = '';
    excluidos = '';
    if nargin > 5 
        % Si tiene parametros adicionales son para guardar correctamente las imagenes 
        if nargin == 7
            comando = char(varargin(1));
            if strcmpi( comando, 'savepath') == 1
                saveImages = 1;
                pathImages = char(varargin(2));
            elseif strcmpi( comando, 'threshold') == 1
                currentUmb = char(varargin(2));
            elseif strcmpi( comando, 'excluidos') == 1
                excluidos = char(varargin(2));
            else
                error('bad arguments, optional arguments must be: SavePath and/or Threshold and/or Excluidos\n'); 
            end
        elseif nargin == 9
            comando = char(varargin(1));
            if strcmpi( comando, 'savepath') == 1
                saveImages = 1;
                pathImages = char(varargin(2));
                comando = char(varargin(3));
                if strcmpi( comando, 'threshold') == 1
                    currentUmb = char(varargin(4));
                elseif strcmpi( comando, 'excluidos') == 1
                    excluidos = char(varargin(4));
                else
                    error('bad arguments, optional arguments must be: SavePath and/or Threshold and/or Excluidos\n'); 
                end
            elseif strcmpi( comando, 'threshold') == 1
                currentUmb = char(varargin(2));
                comando = char(varargin(3));
                if strcmpi( comando, 'savepath') == 1
                    saveImages = 1;
                    pathImages = char(varargin(4));
                elseif strcmpi( comando, 'excluidos') == 1
                    excluidos = char(varargin(4));
                else
                    error('bad arguments, optional arguments must be: SavePath and/or Threshold and/or Excluidos\n'); 
                end
            elseif strcmpi( comando, 'excluidos') == 1
                excluidos = char(varargin(2));
                comando = char(varargin(3));
                if strcmpi( comando, 'savepath') == 1
                    saveImages = 1;
                    pathImages = char(varargin(4));
                elseif strcmpi( comando, 'threshold') == 1
                    currentUmb = char(varargin(4));
                else
                    error('bad arguments, optional arguments must be: SavePath and/or Threshold and/or Excluidos\n'); 
                end
            else
                error('bad arguments, optional arguments must be: SavePath and/or Threshold and/or Excluidos\n'); 
            end
        elseif nargin == 11
            comando = char(varargin(1));
            if strcmpi( comando, 'savepath') == 1
                saveImages = 1;
                pathImages = char(varargin(2));
                comando = char(varargin(3));
                if strcmpi( comando, 'threshold') == 1
                    currentUmb = char(varargin(4));
                    comando = char(varargin(5));
                    if strcmpi( comando, 'excluidos') == 1
                        excluidos = char(varargin(6));
                    else
                        error('bad arguments, optional arguments must be: SavePath and/or Threshold and/or Excluidos\n'); 
                    end
                elseif strcmpi( comando, 'excluidos') == 1
                    excluidos = char(varargin(4));
                    comando = char(varargin(5));
                    if strcmpi( comando, 'threshold') == 1
                        currentUmb = char(varargin(6));
                    else
                        error('bad arguments, optional arguments must be: SavePath and/or Threshold and/or Excluidos\n'); 
                    end
                else
                    error('bad arguments, optional arguments must be: SavePath and/or Threshold and/or Excluidos\n'); 
                end
            elseif strcmp( comando, 'threshold') == 1
                currentUmb = char(varargin(2));
                comando = char(varargin(3));
                if strcmpi( comando, 'savepath') == 1
                    saveImages = 1;
                    pathImages = char(varargin(4));
                    comando = char(varargin(5));
                    if strcmpi( comando, 'threshold') == 1
                        currentUmb = char(varargin(6));
                    else
                        error('bad arguments, optional arguments must be: SavePath and/or Threshold and/or Excluidos\n'); 
                    end
                elseif strcmpi( comando, 'excluidos') == 1
                    excluidos = char(varargin(4));
                    comando = char(varargin(5));
                    if strcmpi( comando, 'savepath') == 1
                        saveImages = 1;
                        pathImages = char(varargin(6));
                    else
                        error('bad arguments, optional arguments must be: SavePath and/or Threshold and/or Excluidos\n'); 
                    end
                else
                    error('bad arguments, optional arguments must be: SavePath and/or Threshold and/or Excluidos\n'); 
                end
            elseif strcmpi( comando, 'excluidos') == 1
                excluidos = char(varargin(2));
                comando = char(varargin(3));
                if strcmpi( comando, 'savepath') == 1
                    saveImages = 1;
                    pathImages = char(varargin(4));
                    comando = char(varargin(5));
                    if strcmpi( comando, 'threshold') == 1
                        currentUmb = char(varargin(6));
                    else
                        error('bad arguments, optional arguments must be: SavePath and/or Threshold and/or Excluidos\n'); 
                    end
                elseif strcmpi( comando, 'threshold') == 1
                    currentUmb = char(varargin(4));
                    comando = char(varargin(5));
                    if strcmpi( comando, 'savepath') == 1
                        saveImages = 1;
                        pathImages = char(varargin(6));
                    else
                        error('bad arguments, optional arguments must be: SavePath and/or Threshold and/or Excluidos\n'); 
                    end
                else
                    error('bad arguments, optional arguments must be: SavePath and/or Threshold and/or Excluidos\n'); 
                end
            else
                error('bad arguments, optional arguments must be: SavePath and/or Threshold and/or Excluidos\n'); 
            end
        else
            error('bad arguments, optional arguments must be: SavePath and/or Threshold and/or Excluidos\n'); 
        end
    end
    
    tam = length(measurements);
    % calcular el minimo y maximo de todas las matrices en el arreglo
    minValue = min(min(measurements{1})); 
    maxValue = max(max(measurements{1})); 
    for i = 2:tam
        if minValue > min(min(measurements{i}))
            minValue = min(min(measurements{i}));
        end
        if maxValue < max(max(measurements{i}))
            maxValue = max(max(measurements{i}));
        end
    end
    % crear el arreglo de valores para el calculo de la pdf
    binValues = minValue:binSize:maxValue;
    % por cada nodo en las redes
    col = size(measurements{1},2);
    pop = length(population);
    for i = 1:col
        f1 = figure;
        hold on;
        hValues = zeros(pop,length(binValues));
        cValues = zeros(pop,length(binValues));
        for p = 1:pop
            fil = size(measurements{p},1);
            hPopulation = hist(measurements{p}(:,i),binValues);
            cdfPopulation = cumsum(hPopulation./fil);
            hValues(p,:) = hPopulation./fil;
            cValues(p,:) = cdfPopulation;
        end
        % pintar la PDF
        plot(binValues, hValues);
        set(gca, 'Box', 'on', 'LineWidth', 1, 'Layer', 'Top', ...
                'XMinorTick', 'off', 'YMinorTick', 'on', 'Xgrid', 'off', ...
                'YGrid', 'on', 'TickDir', 'out');
%        xlabel('bin values', 'FontName', 'helvetica', 'FontSize', 11, 'FontWeight', 'bold');
%        ylabel('PDF', 'FontName', 'helvetica', 'FontSize', 11, 'FontWeight', 'bold');set()
        title(['{\color{red} PDF of ' measurementName ' on ' networkNames{i} '}'], 'FontName','palatino', 'FontSize', 14, 'FontWeight', 'bold', 'FontAngle', 'italic');
        legf = legend(population,'Location','northeast');
        set(legf, 'FontName', 'helvetica', 'FontSize', 8, 'FontAngle', 'italic')
        set(f1, 'Name',['PDF of ' measurementName ' on ' networkNames{i}], 'Filename', [ 'PDF of ' measurementName ' on ' networkNames{i}], 'NumberTitle', 'off' );
        % salvar las imagenes
        if saveImages == 1
            if strcmp( currentUmb, '') == 1
                if strcmp(excluidos,'') == 1
                    filename = [measurementName '-PDF-' networkNames{i}];
                else
                    filename = [measurementName '-PDF-' excluidos '-' networkNames{i}];
                end
            else
                if strcmp(excluidos,'') == 1    
                    filename = [measurementName '-' currentUmb '-PDF-' networkNames{i}];
                else
                    filename = [measurementName '-' currentUmb '-PDF-' excluidos '-' networkNames{i}];
                end
            end
            saveas(f1,[pathImages '/Images/fig/' filename '.fig'], 'fig');
            print(f1,'-dpng','-r150',[pathImages '/Images/png/' filename '.png']);
        end 
        hold off
        
        % pintar la CDF
        f2 = figure;
        hold on;
        plot(binValues, cValues);
        set(gca, 'Box', 'on', 'LineWidth', 1, 'Layer', 'Top', ...
                'XMinorTick', 'off', 'YMinorTick', 'on', 'Xgrid', 'off', ...
                'YGrid', 'on', 'TickDir', 'out');
%        xlabel('bin values', 'FontName', 'helvetica', 'FontSize', 11, 'FontWeight', 'bold');
%        ylabel('PDF', 'FontName', 'helvetica', 'FontSize', 11, 'FontWeight', 'bold');set()
        title(['{\color{red} CDF of ' measurementName ' on ' networkNames{i} '}'], 'FontName','palatino', 'FontSize', 14, 'FontWeight', 'bold', 'FontAngle', 'italic');
        legf = legend(population, 'Location', 'SouthEast');
        set(legf, 'FontName', 'helvetica', 'FontSize', 8, 'FontAngle', 'italic')
        set(f2, 'Name',['CDF of ' measurementName ' on ' networkNames{i}], 'Filename', [ 'CDF of ' measurementName ' on ' networkNames{i}], 'NumberTitle', 'off' );
        % Salvar la imagen
        if saveImages == 1
            if strcmp( currentUmb, '') == 1
                if strcmp(excluidos,'') == 1
                    filename = [measurementName '-CDF-' networkNames{i}];
                else
                    filename = [measurementName '-CDF-' excluidos '-' networkNames{i}];
                end
            else
                if strcmp(excluidos,'') == 1    
                    filename = [measurementName '-' currentUmb '-CDF-' networkNames{i}];
                else
                    filename = [measurementName '-' currentUmb '-CDF-' excluidos '-' networkNames{i}];
                end
            end
            saveas(f2,[pathImages '/Images/fig/' filename '.fig'], 'fig');
            print(f2,'-dpng','-r150',[pathImages '/Images/png/' filename '.png']);
        end 
        %set(gca,'XTickLabel', nombresRedes,'FontSize',6);
        hold off;
    end
end