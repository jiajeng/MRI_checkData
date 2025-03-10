clear; close all;

% define file path
paths = 'E:\MRI_checkData\testData\firstlevel_SBC\';
outpaths = fullfile(paths,'niifile');
temfile = 'E:\test\temp\ratlas.nii'; % <------------------- define template path
teminfo = 'E:\test\temp\atlas.txt'; % <------------------- define template file

% unzip .gz file to .nii file
files = dir(fullfile(paths,'*.gz'));
if isempty(files)
    outpaths = paths;
else
    if ~exist(outpaths,'dir'), mkdir(outpaths); end
    for i = 1:length(files)
        gunzip(fullfile(paths,files(i).name),outpaths);
    end
end
file = dir(fullfile(outpaths,'*.nii'));
file = fullfile({file.folder}',{file.name}');

%% get mask >0.25 or <-0.25
% define what threshold you want and output a mask .nii file
% in this case the map is fisher z value, threshold is 0.25 or -0.25(depend on thres variables)
thres = '+';

% define output file path
maskpath = fullfile(outpaths,'mask');
if ~exist(maskpath,'dir'), mkdir(maskpath); end
% loop for all file
for Fi = 1:length(file)
    % read file
    V = spm_vol(file{Fi});
    filename = split(V.fname,filesep);
    filename = filename{end};
    vol = spm_read_vols(V);
    switch thres
        case "+"
            m = double(vol>0.25);
        case "-"
            m = double(vol<-0.25);
    end
    V.fname = fullfile(maskpath,['m',filename]);
    spm_write_vol(V,m);
end

%% get brainarea percentage
% input data original and mask .niifile, template .nii file and info file
tfile = dir(fullfile(outpaths,'*.nii'));
subjectName = split({tfile.name},'_');
subjectName = squeeze(subjectName(:,:,2))';
tfile = fullfile({tfile.folder}',{tfile.name}');
mfile = dir(fullfile(maskpath,'*.nii'));
mfile = fullfile({mfile.folder}',{mfile.name}');

for i = 1:length(tfile)
    Templabel_pert(tfile{i},mfile{i},temfile, readcell(teminfo,'Delimiter','\n'))
end

%% get all subject brain area table
% get correlation R matrix (subject x subject)
% transfer to fisher z
% check every columns how many z < 0.25 (different from others)
% use difference number to get ouliter(Q3+1.5*iqr)

xlxfile = dir(fullfile(maskpath,'*.xlsx'));
xlxfile = fullfile({xlxfile.folder}',{xlxfile.name}');
Tab = readtable(xlxfile{1});
pertcent_tab = Tab(:,'Brainarea');
for i = 1:length(xlxfile)
    Tab = readtable(xlxfile{i});
    tmp = Tab(:,'percentage');
    tmp.Properties.VariableNames = subjectName(i);
    pertcent_tab = cat(2,pertcent_tab,tmp);
end

% real z 
allpert = table2array(pertcent_tab(:,2:end));
[r,p] = corrcoef(allpert);
z = 1/2.*log((1+r)./(1-r));

% find different subject number
difsubnum = sum(z<0.25,1)';

% get outlier
Q3 = quantile(difsubnum,3/4);
outliersubName = subjectName(difsubnum>(iqr(difsubnum)*1.5+Q3))
% outliersub = subjectName(difsubnum>(242/2));

save(fullfile(maskpath,'Result.mat'),"pertcent_tab","difsubnum","r","z","outliersubName")
