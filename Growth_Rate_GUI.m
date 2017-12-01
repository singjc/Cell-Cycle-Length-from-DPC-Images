function varargout = Growth_Rate_GUI(varargin)
% GROWTH_RATE_GUI MATLAB code for Growth_Rate_GUI.fig
%      GROWTH_RATE_GUI, by itself, creates a new GROWTH_RATE_GUI or raises the existing
%      singleton*.
%
%      H = GROWTH_RATE_GUI returns the handle to a new GROWTH_RATE_GUI or the handle to
%      the existing singleton*.
%
%      GROWTH_RATE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GROWTH_RATE_GUI.M with the given input arguments.
%
%      GROWTH_RATE_GUI('Property','Value',...) creates a new GROWTH_RATE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Growth_Rate_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Growth_Rate_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Growth_Rate_GUI

% Last Modified by GUIDE v2.5 23-Nov-2017 14:04:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Growth_Rate_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @Growth_Rate_GUI_OutputFcn, ...
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


% --- Executes just before Growth_Rate_GUI is made visible.
function Growth_Rate_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Growth_Rate_GUI (see VARARGIN)

% Choose default command line output for Growth_Rate_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Growth_Rate_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Growth_Rate_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes during object creation, after setting all properties.
function InputFilePath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InputFilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% get(handles.InputFile,'String')

% --- Executes during object creation, after setting all properties.
function uniExperiments_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uniExperiments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in InputFile.
function [Excel_File,Excel_Path,data,Total_uniExp] = InputFile_Callback(hObject, eventdata, handles)
% hObject    handle to InputFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Excel_File,Excel_Path,Filer_Index] = uigetfile('*.xlsx','Select the Excel Data File'); %Prompts user for the excel file that contains their data.
data = readtable([char(Excel_Path) char(Excel_File)]);
Total_uniExp = unique(data.Exp_Name,'stable'); %Stores unique experiments, preserving the order.
path = ['Working Directory: ' Excel_Path Excel_File];
set(handles.InputFilePath,'String',path);
[uniExp,uniExp_Ok] = listdlg('PromptString','Select which experiments you wish to analyze.','SelectionMode','multiple','ListString',Total_uniExp,'ListSize',[300 200],'CancelString','None'); %Prompts user what plots they want

set(handles.uniExperiments,'String',Total_uniExp(uniExp))

% --- Executes on selection change in uniExperiments.
function list = uniExperiments_Callback(hObject, eventdata, handles)
% hObject    handle to uniExperiments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns uniExperiments contents as cell array
%        contents{get(hObject,'Value')} returns selected item from uniExperiments
% contents = cellstr(get(hObject,'String'))
% s = contents{get(hObject,'Value')}
