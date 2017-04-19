function [out2, out1] = importPresentationLog(fileName)
% Import any Presentation log file into MATLAB and enjoy your analysis ;)
% This function imports all columns of any presentation log file into
% MATLAB and names the variables to the column names used in the log file.
% The following columns are automaticaly converted to doubles:
% Trial, Time, TTime, Uncertainty, Duration, ReqTime, ReqDur
% The others however are strings.
%
% The data are represented as a vector of structs or a struct with vectors
% for every colum.
%
% Usage: [out1, out2] = presLog(fileName);
% * INPUT
%       * filename  -> full qualified file name as string
%
% * OUTPUT
%       * out1      -> data represented as 1xn struct
%       * out2      -> struct that contains vectors for every column
%


% Tobias Otto, tobias.otto@ruhr-uni-bochum.de
% 1.1
% 02.02.2011

% 21.09.2010, Tobias: first draft
% 02.02.2011, Tobias: added check for wrong header entries

%% Init variables
tmp         = [];
names       = {};
out1        = [];
out2        = [];
j           = 0;
convNames   = {'trial', 'Time', 'TTime', 'Uncertainty', 'Duration', ...
    'ReqTime', 'ReqDur'};
convNames   = lower(convNames);

%% Load file
fid = fopen(fileName,'r');
if(fid == -1)
    disp(' *************************************************************');
    disp(['The file ' fileName ' can''t be loaded']);
    disp(' *************************************************************');
    error('Please check the input file name and try again');
end

%% Read file
header{1} = fgetl(fid);
header{2} = fgetl(fid);
header{3} = fgetl(fid);

%% Get variable names
[numEntries, indexEntries, logLine] = sepEntries(fid);

for i = 1:numEntries
    tmp             = logLine(indexEntries(i):indexEntries(i+1));
    tmp(tmp==32)    = '_';                  % Replace white space with _
    names{i}        = lower(tmp(tmp~=9));   % remove tab
end

% Remove white line
fgetl(fid);

%% Get entries by line
try
    while(ischar(logLine))
        j = j+1;
        
        %% Separate values from line
        [numEntries, indexEntries, logLine] = sepEntries(fid);
        
        %% Copy entries to struct
        for i=1:numEntries
            tmp = logLine(indexEntries(i):indexEntries(i+1));
            tmp = tmp(tmp~=9);  % Remove tab
            
            %% Check, if entry has to be converted to a double value
            % Some scripts have more entries than defined in header file
            % Warn user and ignore entry !!!
            if(length(names) < i)
                i = length(names);
                disp(' **********************************************************************');
                disp(' !!! The log file has more entries than defined in the header !!!');
                disp([' Skipping additional entries. Please check your log file in line ' num2str(j+5)]);
                disp(' **********************************************************************');
            end
            k=1;
            while(k<=length(convNames) && ~strcmpi(convNames{k},names{i}))
                k=k+1;
            end
            
            if(k<=length(convNames))
                out1.(names{i})(j,:)    = str2double(tmp);
                out2(j).(names{i})      = str2double(tmp);
            else
                out1.(names{i}){j,:}    = tmp;
                out2(j).(names{i})      = tmp;
            end
        end
    end
    
catch
    disp(' *************************************************************');
    disp([' Sorry I''m giving up on line ' num2str(j+5)]);
    disp(' This is a permanent error ... I give up :(');
    disp(' If you are able to find the error feel free to contact me');
    disp(' and I will add the changes.');
    disp(' *************************************************************');
end

%% Tidy up
fclose(fid);


%% SUB FUNCTIONS
function [numEntries, indexEntries, logLine] = sepEntries(fid)
% Get header line
logLine         = fgetl(fid);
% Find valid separators
separators      = find(double(logLine)==9);
separators      = separators(diff(separators)~=1);
% Compute last variables
numEntries      = length(separators)+1;
indexEntries    = [1 separators length(logLine)];
