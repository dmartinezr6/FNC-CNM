% Esta función mezcla una gráfica de barras con una gráfica de error para
% crear un gráfica donde se muestra una barra con el valor promedio y una
% línea que muestra la desviación estándar.
%
% f = pintarGraficaMeanSTD ( promedios, desviaciones, poblaciones, measurement )
% f = pintarGraficaMeanSTD ( promedios, desviaciones, poblaciones, measurement, 'Color', colores )
% f = pintarGraficaMeanSTD ( promedios, desviaciones, poblaciones, measurement, 'Color', colores, 'Marca', marcas )
% 
% Parámetros:
% 
%     valores       = Arreglo de estructuras con los valores de cada medida 
%                     para graficar Violin plots mostrando la ditribución 
%                     de la medida en la población. Cada elemento del
%                     arreglo corresponde con una medida realizada sobre
%                     una población.
%     poblaciones   = Arreglo de strings con los nombres de las poblaciones
%                     a las que pertenecen los promedios y desviaciones
%                     estándar
%     nombresRedes  = Arreglo con los nombres de las redes a las que
%                     corresponden cada una de las medidas que conforman un
%                     elemento del arreglo de valores
%     measurement   = String which indicate the label for Y axis
%
% Parámetros opcionales:
%
%     colores       = Matriz con la definición de los colores a usar en las
%                     barras (un color por cada población)
%     marcas        = Matriz que contiene la familia con la diferencia
%                     significativa. Si la matriz tiene mas de una
%                     dimensión se asume que en la grafica se encuentran
%                     mas de un elemento con una diferencia significativa.
% 
function f = pintarGraficaDistribucionPlot ( valores, poblaciones, nombresRedes, measurement, varargin )
    f = figure;
    hold on;
    % los colores
    colores = colormap('lines');
    marcas = [];
    % los tamaños de las matrices con información
    numPob = length(poblaciones);
    numRedes = size(valores);
    numNombres = length(nombresRedes);
    
    % revisar si tiene argumentos adicionales
    if nargin > 4 
        % Si tiene un solo parametro adicional Color o Marca
        if nargin == 6
            comando = char(varargin(1));
            if strcmp(comando,'Color') == 1
                colores = varargin{2};
                if size(colores,1) ~= numPob
                    error('Each populations must have a corresponding color in the color matrix');
                end
            elseif strcmp(comando,'Marca') == 1
                marcas = varargin{2};
                if size(marcas,1) ~= tamPromedios
                    error('Each network must have a corresponding marca in the marcas matrix');
                end
            else
                error('bad arguments, optional arguments must be one of: Color or Marca\n'); 
            end
        elseif nargin == 8
            comando1 = char(varargin(1));
            comando2 = char(varargin(3));
            if strcmp(comando1,'Color') == 1 && strcmp(comando2,'Marca') == 1
                colores = varargin{2};
                if size(colores,1) ~= numPob
                    error('Each populations must have a corresponding color in the color matrix');
                end
                marcas = varargin{4};
                if size(marcas,1) ~= tamPromedios
                    error('Each network must have a corresponding marca in the marcas matrix');
                end
            elseif strcmp(comando2,'Color') == 1 && strcmp(comando1,'Marca') == 1
                colores = varargin{4};
                if size(colores,1) ~= numPob
                    error('Each populations must have a corresponding color in the color matrix');
                end
                marcas = varargin{2};
                if size(marcas,1) ~= tamPromedios
                    error('Each network must have a corresponding marca in the marcas matrix');
                end
            else
                error('bad arguments, optional arguments must be one of: Color or Marca\n'); 
            end
        else
            error('bad order or missing optional arguments. They must be in pair values i.e. Color, matrix of color\n');
        end
    end
    
    % Primero algunas validaciones de la información
    % El número de elementos de los valores debe corresponder con el numero
    % de nombres de las redes
    if ( numRedes(1) == numNombres || numRedes(2) == numNombres )
        % crear una matriz con la información completa para los violinplots
        tamHC = length(valores(1).hc);
        tamMCS = length(valores(1).mcs);
        tamVS = length(valores(1).vs);
        numFilas = max( max(tamHC, tamMCS), tamVS );
        valoresDistribucion = zeros(numFilas, numPob*numNombres);
        % guardar los valores de cada medida en la matriz
        for i = 1:numNombres
            valoresDistribucion(1:tamHC,((i-1)*numPob)+1) = valores(i).hc;
            if tamHC < numFilas
                valoresDistribucion(tamHC+1:numFilas,((i-1)*numPob)+1) = mean(valores(i).hc);
            end
            valoresDistribucion(1:tamMCS,((i-1)*numPob)+2) = valores(i).mcs;
            if tamMCS < numFilas
                valoresDistribucion(tamMCS+1:numFilas,((i-1)*numPob)+2) = mean(valores(i).mcs);
            end
            valoresDistribucion(1:tamVS,((i-1)*numPob)+3) = valores(i).vs;
            if tamVS < numFilas
                valoresDistribucion(tamVS+1:numFilas,((i-1)*numPob)+3) = mean(valores(i).vs);
            end
        end
        colores = { colores(1,:) colores(2,:) colores(3,:) ...
                    colores(1,:) colores(2,:) colores(3,:) ...
                    colores(1,:) colores(2,:) colores(3,:) ... 
                    colores(1,:) colores(2,:) colores(3,:) ...
                    colores(1,:) colores(2,:) colores(3,:) ...
                    colores(1,:) colores(2,:) colores(3,:) ... 
                    colores(1,:) colores(2,:) colores(3,:) ...
                    colores(1,:) colores(2,:) colores(3,:) ...
                    colores(1,:) colores(2,:) colores(3,:) ... 
                    colores(1,:) colores(2,:) colores(3,:) };
        hvp = distributionPlot(valoresDistribucion ...
                             , 'color', colores ...
                             , 'globalNorm', 0 ... % groups ????
                             , 'histOpt', 1 ... % it is the smoothing option  , 'divFactor', 1.0 ...
                             , 'addSpread', 1 ... % show the points into the violin plot
                             , 'showMM', 5 ... % this option shows the mean and standard deviation    
        );
        set(f, 'Position', [0 0 1800 800]);
        title(['\color{red} ' measurement ' - Distribution by population'],'FontName','palatino', 'FontSize', 22, 'FontWeight', 'bold', 'FontAngle', 'italic');
        set(hvp{4}{1},'color', [0 0 0], 'marker', 'o', 'LineWidth', 0.2, 'MarkerSize', 3);
        set(hvp{2}, 'LineWidth', 0.5, 'MarkerSize', 10);
        legf = legend(poblaciones);
        set(legf, 'FontName', 'helvetica', 'FontSize', 8, 'FontAngle', 'italic')
    else
        fprintf('The dimensions of valores does not correspond to any dimension size of the nombresRedes. It must be equal to at least one of the dimension\n')
    end
end