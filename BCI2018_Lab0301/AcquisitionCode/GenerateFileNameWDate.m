function [FileNameOut] = GenerateFileNameWDate(FileRoot)
%  Output file of the format FileRoot_YYYYMMDD-HH-MM-SS
if nargin<1
    FileRoot = 'Data';
end
%%
DateNow = datestr(now,'yyyymmdd-HH-MM-SS');
%%
FileNameOut = strcat(FileRoot,'_',DateNow);

end

