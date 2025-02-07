% fisher z +-0.25 
path = 'E:\test\firstlevel_SBC\niifile';
file = dir(fullfile(path,'*.nii'));
file = fullfile({file.folder}',{file.name}');


%% get mask >0.25 and <-0.25
% define output file path
maskpath = fullfile(path,'mask');
if ~exist(maskpath,'dir'), mkdir(maskpath); end
% loop for all file
for Fi = 1:length(file)
    % read file
    V = spm_vol(file{Fi});
    filename = split(V.fname,filesep);
    filename = filename{end};
    vol = spm_read_vols(V);
    m = double(vol>0.25 | vol<-0.25);
    V.fname = fullfile(maskpath,['m',filename]);
    spm_write_vol(V,m);
end

%% get brainarea percentage
tfile = dir(fullfile(path,'*.nii'));
tfile = fullfile({tfile.folder}',{tfile.name}');
mfile = dir(fullfile(maskpath,'*.nii'));
mfile = fullfile({mfile.folder}',{mfile.name}');
temfile = 'E:\test\temp\ratlas.nii'; % <------------------- define template path
teminfo = 'E:\test\temp\atlas.txt'; % <------------------- define template file

for i = 1:length(tfile)
    Templabel_pert(tfile{i},mfile{i},temfile, readcell(teminfo,'Delimiter','\n'))
end

%% get all subject brain area table
xlxfile = dir(fullfile(maskpath,'*.xlsx'));
xlxfile = fullfile({xlxfile.folder}',{xlxfile.name}');
tab = [];
for i = 1:length(xlxfile)
    Tab = readtable(xlxfile{i});
    tab = cat(2,tab,Tab.percentage);
end