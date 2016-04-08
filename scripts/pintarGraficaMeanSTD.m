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
%     promedios     = Matriz con los promedios a graficar con las barras.
%     desviaciones  = Matriz con las desviaciones estándar a gráficar con
%                     las barras de error.
%     poblaciones   = Arreglo de strings con los nombres de las poblaciones
%                     a las que pertenecen los promedios y desviaciones
%                     estándar
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
function f = pintarGraficaMeanSTD ( promedios, desviaciones, poblaciones, measurement, varargin )
    f = figure;
    hold on;
    % los colores
    colores = colormap('lines');
    marcas = [];
    % los tamaños de las matrices con información
    numPob = length(poblaciones);
    tamPromedios = size(promedios);
    tamDesviaciones = size(desviaciones);
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
    % El número de elementos en poblaciones debe corresponder con una de
    % las dimensiones de los promedios y las desviaciones.
    if ( numPob == tamPromedios(1) || numPob == tamPromedios(2) )
        % si la informacion de los promedios viene en una columna por
        % población, transponerla
        if numPob == tamPromedios(2)
            promedios = promedios';
            tamPromedios = size(promedios);
        end
        if ( numPob == tamDesviaciones(1) || numPob == tamDesviaciones(2) )
            % si la informacion de las desviaciones viene en una columna 
            % por población, transponerla
            if numPob == tamDesviaciones(2)
                desviaciones = desviaciones';
                tamDesviaciones = size(desviaciones);
            end
            % una vez validados las entradas se pinta la gráfica
            set(gca, 'Box', 'on', 'LineWidth', 1, 'Layer', 'Top', ...
                'XMinorTick', 'off', 'YMinorTick', 'on', 'Xgrid', 'off', ...
                'YGrid', 'on', 'TickDir', 'out', 'TickLength', [.015 .015], ...
                'XLim', [0, ((tamPromedios(2)*numPob)+1)]);
            xlabel('Networks', 'FontName', 'helvetica', 'FontSize', 11, 'FontWeight', 'bold');
            ylabel(measurement, 'FontName', 'helvetica', 'FontSize', 11, 'FontWeight', 'bold');
            for i = 1:numPob
                hb(i) = bar(i:numPob:(tamPromedios(2)*numPob), ...
                            promedios(i,:), ...
                            0.5/numPob, ...
                            'FaceColor', colores(i,:), ...
                            'EdgeColor', colores(i,:) );
            end
            legfdc = legend(poblaciones);
            set(legfdc, 'FontName', 'helvetica', 'FontSize', 8, 'FontAngle', 'italic')
            for i = 1:numPob
                he(i) = errorbar(i:numPob:(tamDesviaciones(2)*numPob), ...
                            promedios(i,:), ...
                            zeros(size(desviaciones(i,:))), ...
                            desviaciones(i,:), ...
                            'Color', colores(i,:), ...
                            'LineStyle', ':');
            end
            % pintar las barras que tienen diferencia estadistica
            if ~isempty(marcas)
                for i = 1:tamPromedios
                    % evaluar en que posiciones se debe pintar la barra con el
                    % asterisco.
                    if marcas(i) == 1
                        % obtener el mayor valor de los valores de cada grupo
                        % de barras y de errores para pintar sobre estos la
                        % barra de indicación de diferencia estadistica
                        mayor = 0;
                        for v = 1:numPob
                            if (promedios(v,i) + desviaciones(v,i)) > mayor 
                                mayor = (promedios(v,i) + desviaciones(v,i));
                            end
                        end
                        xIni = ((i-1)*numPob)+1;
                        xFin   = i*numPob;
                        yIni = ceil((mayor*100)+1)/100;
                        yFin   = ceil(mayor*10)/10;
                        if ceil(mayor*10)/10 == ceil(mayor*100)/100
                            yFin = ceil((mayor*10)+1)/10;
                        end
                        line( [xIni, xIni, xFin, xFin], [yIni, yFin, yFin, yIni], 'Color', [0 0 0], 'LineWidth', 2);
                        text( floor(xIni + numPob/2), yFin, '*', 'FontName', 'Helvetica','FontSize',20,'HorizontalAlignment','center');
                    end
                end
            end
            set(gca,'XTick',((numPob+1)/2):numPob:(tamDesviaciones(2)*numPob));
            set(gca,'XTickLabel', 1:tamDesviaciones(2));
            hold off
        else
            fprintf('The dimensions of poblacion does not correspond to any dimension size of the desviaciones. It must be equal to at least one of the dimension\n')    
        end
    else
        fprintf('The dimensions of poblacion does not correspond to any dimension size of the promedio. It must be equal to at least one of the dimension\n')
    end
end