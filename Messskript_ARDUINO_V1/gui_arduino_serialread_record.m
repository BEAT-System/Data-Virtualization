function varargout = gui_arduino_serialread_record(varargin)
% GUI_ARDUINO_SERIALREAD_RECORD MATLAB code for gui_arduino_serialread_record.fig
%      GUI_ARDUINO_SERIALREAD_RECORD, by itself, creates a new GUI_ARDUINO_SERIALREAD_RECORD or raises the existing
%      singleton*.
%
%      H = GUI_ARDUINO_SERIALREAD_RECORD returns the handle to a new GUI_ARDUINO_SERIALREAD_RECORD or the handle to
%      the existing singleton*.
%
%      GUI_ARDUINO_SERIALREAD_RECORD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_ARDUINO_SERIALREAD_RECORD.M with the given input arguments.
%
%      GUI_ARDUINO_SERIALREAD_RECORD('Property','Value',...) creates a new GUI_ARDUINO_SERIALREAD_RECORD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_arduino_serialread_record_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_arduino_serialread_record_OpeningFcn via varargin.
%




%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_arduino_serialread_record

% Last Modified by GUIDE v2.5 04-Dec-2018 11:46:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_arduino_serialread_record_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_arduino_serialread_record_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gui_arduino_serialread_record is made visible.
function gui_arduino_serialread_record_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_arduino_serialread_record (see VARARGIN)

% Choose default command line output for gui_arduino_serialread_record
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_arduino_serialread_record wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global settings play record record_data;

settings = {'Port: ','COM3';... 
            'Baudrate: ', '500000';...   
            'Ringpuffer (Plot): ','300';...
            'xlabel','U [mV[';...
            'ylabel','I [mA]';...
            'title','Leistungstracking';...
            'ylim','0, 1'};
        
play = false;
record = false;
record_data = [];

try
    load('arduino_serialread_record_settings.mat', 'settings')
end

clc;
cla;


% --- Outputs from this function are returned to the command line.
function varargout = gui_arduino_serialread_record_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global serial_connection settings zaehler

clc;

%% Bestehende Verbindungen schließen
try
k = instrfind;
fclose(k(:));
fclose(serial_connection);
end

%% Serielle Verbindung aufbauen
try
    serial_connection = serial(settings{1,2}); 
    serial_connection.Baudrate = str2double(settings{2,2}); 
    %serial_connection.DataBits=6; 
    %serial_connection.StopBits=1;
    %serial_connection.InputBufferSize = str2double(settings{9,2});
    %s.Parity='none'; 
    %serial_connection.OutputBufferSize = 128;
    fopen(serial_connection);
    disp('Serielle Verbindung hergestellt');
    zaehler = 0;
catch
    disp('Serielle Verbindung fehlgeschlagen');
end




% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global play serial_connection record_data zaehler;
play = false;
set(handles.pushbutton3,'BackgroundColor',[0.94 0.94 0.94]);

try
    fclose(serial_connection);
    disp('Serielle Verbindung geschlossen');
    zaehler = 0;
catch
	disp('Serielle Verbindung konnte nicht geschlossen werden.');
    zaehler = 0;
end

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global  serial_connection settings play p record record_data p2 rpuffer zaehler;

if strcmp(get(serial_connection,'Status'),'open')% Wenn Verbindung hergestellt ist
    % Status/ Buttonfarbe ändern 
    play = not(play);
    % Startbyte Senden
    if play == true
        fprintf(serial_connection,'1');
    elseif play == false
        fprintf(serial_connection,'0');
    end
    % Buttonfarbe ändern
    set(handles.pushbutton3,'BackgroundColor',[0.94 0.94 0.94]);
    pause(0.5);
    
    zaehler = 0;
	% Plotschleife Play Button  
	while play == true
          
        if serial_connection.BytesAvailable > 0 % Wenn Daten verfügbar sind
            
            zaehler = zaehler+1;
            
            if zaehler == 1 % Im Ersten Schleifendurchlauf Puffer erstellen
                for i = 1:3
                    test = str2num(fscanf(serial_connection)); % Testweise einlesen
                    m = size(test,2); % Anzahl Werte bestimmen
                    if m>0; break; end
                end
    
                if m == 0;return; end % Wenn keine Daten vorhanden sind
    
    
                n = str2double(settings{3,2}); % Größe Ringpuffer
                rpuffer = nan(n,m); % Ringpuffer erstellen
                
            end

            ax = handles.axes1; % Axes
            set(handles.pushbutton3,'BackgroundColor',[0 1 0]);
        
            rpuffer(1,:) = [];% letzten Wert im Ringpuffer löschen
            versuch = 1;
            while versuch < 5
                try
                    rpuffer(n,:) = str2num(fscanf(serial_connection)); % Neuer Wert
                    break;
                catch
                    versuch = versuch + 1;
                end
            end
        
            time = rpuffer(:,1) - rpuffer(end,1); % Zeitvektor
            time = time/1000;% Zeitvektor umrechnung in Sekunden
            
            delete(p);
            %delete(p2);
        
            p = plot(ax,time,rpuffer(:,2)); hold off;
            %p2 = plot(ax,time(end),rpuffer(end,4),'o'); hold off;
            
            if max(abs(time)) ~= 0; set(ax,'xlim',[min(time) max(time)]); end;
            set(ax,'ylim',str2num(settings{7,2}));
            grid on;         
            xlabel(settings{4,2});
            ylabel(settings{5,2});
            title(settings{6,2});    
            
%             try; delete(t); end       
%             tx = max(time);
%             ty = str2num(settings{7,2}); ty = ty(2);
%             tex = 'I [mA], U [mV], P [mW]';
%             %tex = settings{5,2};
%             t = text(tx,ty,[tex,': ', num2str(rpuffer(end,2:end))],'FontSize',11,'Interpreter','none',...
%              'HorizontalAlignment','right','VerticalAlignment','top');
         
  
            
            % Daten aufzeichnen wenn Record Button betätigt wird
            if record == true
                nrec = size(record_data,1);
                record_data(nrec+1,:) = rpuffer(n,:);
            end
            
            
            
        end %  Ende Wenn Daten verfügbar sind Schleife
        
        pause(0.01);    
    end % Ende Play Button Schleife
    zaehler = 0;
    
end % Ende Wenn Verbindung hergestellt ist Schleife


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global play record record_data;

if play == true && record == true
    record = false;
    set(handles.pushbutton4,'BackgroundColor',[0.94 0.94 0.94]);
    assignin('base', 'record_data', record_data);
    
elseif play == true && record == false
    record = true;
    set(handles.pushbutton4,'BackgroundColor',[1 0 0]);
    
    record_data = [];
    
else
    record = false;
    set(handles.pushbutton4,'BackgroundColor',[0.94 0.94 0.94]);
end

pause(0.5)




% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global settings

try           
    prompt = settings(:,1);
    defaultans = settings(:,2);

    dlg_title = 'Settings';
    num_lines = 1;
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

    settings(:,2) = answer;
    save('arduino_serialread_record_settings.mat', 'settings')
catch
    return;
end





% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
global play serial_connection settings;
play = false;
set(handles.pushbutton3,'BackgroundColor',[0.94 0.94 0.94]);

try
    fclose(serial_connection);
    disp('Serielle Verbindung geschlossen');
catch
	disp('Serielle Verbindung konnte nicht geschlossen werden.');
end


save('arduino_serialread_record_settings.mat', 'settings')
delete(hObject);


% --------------------------------------------------------------------
function uipushtool2_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ge = {handles.pushbutton1,handles.pushbutton2,handles.pushbutton3,...
    handles.pushbutton4,handles.pushbutton5};
for i = 1:5
set(ge{i},'Visible','off');
end
pause(0.1);
print(gcf(),'-dmeta')
for i = 1:5
set(ge{i},'Visible','on');
end