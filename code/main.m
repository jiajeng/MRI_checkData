P = 'E:\test\';
sub = {dir(P).name};
sub = sub(contains(sub,'SUB'));
p = 'E:\test\SUB0004'; % first subject SPM path
if ~exist("p",'var')
    p = uigetdir(P,'select first subject SPM.mat folder');
end

% output folder 
outfold = 'E:\test\Res';

% template var
temfile = 'E:\test\SUB0004\ratlas.nii';
teminfo = 'E:\test\SUB0004\atlas.txt';
if ~exist("temfile",'var')
    [tn,tp] = uigetfile;
    temfile = fullfile(tn,tp);
end
if ~exist("teminfo",'var')
    [tn,tp] = uigetfile;
    teminfo = fullfile(tn,tp);
end

wd = pwd;
addpath(wd)
% try
    for isub = 1:length(sub)
        if isub ~= 1, p = strrep(p,sub{1},sub{isub}); end
        try
            if isub ~= 1
                if contains(p,sub{1}) || contains(p,sub{isub-1}) 
                    error('Unable to find file or directory');
                end
            end
            load(fullfile(p,'SPM.mat')); % SPM
        catch ME
            if contains(ME.message,"Unable to find file or directory")
                p = uigetdir(P,['select ', sub{isub}, ' SPM.mat folder']);
                load(fullfile(p,'SPM.mat')); % SPM
            end
        end
        
        % check SPM save dir is same as SPM file dir
        if string(SPM.swd) ~= (p), SPM.swd = p; save(fullfile(p,'SPM.mat'),'SPM'); end
    
        % define constant contrast 
        load(fullfile(p,'SPM.mat'));
        con = {SPM.xCon.name};
        if ~any(contains(con,'constant'))
            X = SPM.xX.name;
            iX = double(cellfun(@(x) x(end-7:end)=="constant",X));
    
            matlabbatch{1}.spm.stats.con.spmmat = {fullfile(p,'SPM.mat')};
            matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'constant';
            matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = iX;
            matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
            matlabbatch{1}.spm.stats.con.delete = 0;
            spm('defaults','FMRI');
            spm_jobman('run',matlabbatch);
        end

        % get all contrast
        xCON = {SPM.xCon.name};
        nCON = length(xCON);
        spmTfile = {dir(fullfile(p,'spmT*.nii')).name};


        % loop for all contrast
        for nc = 1:nCON
            % get contrast cluster label file
            Clust_Label_file(fullfile(p,'SPM.mat'),nc ...
                            ,'mask',[] ...
                            ,'thresType','none' ...
                            ,'thres_value',0.01 ...
                            ,'thres_clusSize',0 ...
                            ,'thres_clusSize_ResTab',true ...
                            )

            % map to all cluster label and get percentage of area
            chkp = fullfile(p,'Clust_check');
            chkfile = {dir(fullfile(chkp,'*.nii')).name};
            Templabel_pert(fullfile(p,spmTfile{nc}),fullfile(chkp,chkfile{nc}), temfile, readcell(teminfo,'Delimiter','\n'))

            % copy Res.xlsx to a specific folder 
            if exist("outfold",'var')
                outpath = fullfile(outfold,xCON{nc});
                if ~isempty(outfold)
                    if ~exist(outpath,'dir'), mkdir(outpath); end
                    fname = strrep(chkfile{nc},'.nii','.xlsx');
                    copyfile(fullfile(chkp,fname),outpath);
                    movefile(fullfile(outpath,fname),fullfile(outpath,[sub{isub},'_',fname]));
                end
            end
        end
       
    end
% catch ME
%     cd(wd)
%     rmpath(wd)
%     rethrow(ME)
% end
cd(wd)
rmpath(wd)