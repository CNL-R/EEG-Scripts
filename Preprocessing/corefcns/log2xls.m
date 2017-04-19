% Script to save Presentation logfile in Excel spreadsheet
% Mick Crosse 9/8/2016

% Define subject IDs and directory
id = {'1001','10012','1003'};
direc  = 'C:\Users\Data\';


for i = 1:numel(id)
    
    trial = [];
    event_type = [];
    code = [];
    
    for j = 1:15
        [~,log] = importPresentationLog([direc,id{i},'.log']);
        trial = [trial;log.trial];
        event_type = [event_type;log.event_type];
        code = [code;log.code];
    end
    
    run = (1:length(trial))';
    
    iResp = find(strcmp(event_type,'Response'));
    iPics = find(strcmp(event_type,'Picture'));
    feckoff = unique([iResp,iPics]);
    
    run(feckoff) = [];
    trial(feckoff) = [];
    event_type(feckoff) = [];
    code(feckoff) = [];
    
    xlswrite('testdata.xls',run,3,'A1')
    xlswrite('testdata.xls',trial,3,'B1')
    xlswrite('testdata.xls',event_type,3,'C1')
    xlswrite('testdata.xls',code,3,'D1')
    
    clear log run trial event_type code iResp iPics feckoff
    
end