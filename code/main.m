% P = 'E:\test\'; %<------------------- define path
if ~exist("P",'var')
    P = uigetdir('','select directory containing the subject ID folder folder');
end
sub = {dir(P).name};
sub = sub(contains(sub,'SUB'));
% p = 'E:\test\SUB0007'; % first subject SPM path
if ~exist("p",'var')
    p = uigetdir(P,'select first subject SPM.mat folder');
end

% output folder 
% outfold = 'E:\test\Res_pert'; %<------------------- define path
if ~exist("outfold",'var')
    outfold = uigetdir('','select result excel file output direction');
end

% template var
% temfile = 'E:\test\temp\ratlas.nii'; % <------------------- define path
% teminfo = 'E:\test\temp\atlas.txt'; % <------------------- define path
if ~exist("temfile",'var') || ~exist(temfile,'file')
    [tn,tp] = uigetfile('*.nii','select template niifile');
    temfile = fullfile(tp,tn);
end
if ~exist("teminfo",'var') || ~exist(teminfo,'file')
    if ~exist("tp",'var') || any(~tp), tp = ''; end
    [tn,tp] = uigetfile(fullfile(tp,'*.txt'),'select template label info');
    teminfo = fullfile(tp,tn);
end

wd = pwd;
addpath(wd)
try
    for isub = 1:length(sub)
        if isub ~= 1, p = strrep(p,sub{isub-1},sub{isub}); end
        try
            if isub ~= 1
                if contains(p,sub{1}) && contains(p,sub{isub-1}) 
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
        CONNAME = {SPM.xCon.name};
        if ~any(contains(CONNAME,'constant'))
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

        load(fullfile(p,'SPM.mat'));
        % get all contrast
        CONNAME = {SPM.xCon.name};
        nCON = length(CONNAME);
        spmTfile = {dir(fullfile(p,'spmT*.nii')).name};

        % loop for all contrast
        chkp = fullfile(p,'Clust_check');
        chkfile = {SPM.xCon.name};
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
            chkfex = {dir(chkp).name};
            chkfex = chkfex(contains(chkfex,'.nii'));
            if ~isempty(chkfex)
                if any(contains(chkfex,chkfile{nc}))
                    Templabel_pert(fullfile(p,spmTfile{nc}),fullfile(chkp,[chkfile{nc},'.nii']), temfile, readcell(teminfo,'Delimiter','\n'))

                    % copy Res.xlsx to a specific folder 
                    if exist("outfold",'var')
                        outpath = fullfile(outfold,CONNAME{nc});
                        if ~isempty(outfold)
                            if ~exist(outpath,'dir'), mkdir(outpath); end
                            fname = [chkfile{nc},'.xlsx'];
                            copyfile(fullfile(chkp,fname),outpath);
                            movefile(fullfile(outpath,fname),fullfile(outpath,[sub{isub},'_',fname]));
                        end
                    end
                end
            end
        end
    end
catch ME
    cd(wd)
    rmpath(wd)
    rethrow(ME)
end
cd(wd)
rmpath(wd)


if exist("outfold",'var')
    % folder name is contrast name
    CONNAME = {dir(outfold).name};
    CONNAME = CONNAME(~contains(CONNAME,'.'));
    R = struct();
    k = 1.5;% 
    for conI = 1:length(CONNAME)
        % get excel file
        file = {dir(fullfile(outfold,CONNAME{conI})).name};
        file = file(contains(file,'.xlsx'));
        % read percentage for every brain area
        pert = []; % number of brain area x nsubject
        for fileI = 1:length(file)
            tmp = readtable(fullfile(outfold,CONNAME{conI},file{fileI}));
            pert = cat(2,pert,tmp.percentage);
        end
        % find corrcoef in every two subject 
        R.(CONNAME{conI}).Value = nan(length(file));
        for i = 1:length(file)
            for j = 1:length(file)
                if i==j, continue; end
                r = corrcoef(pert(:,i),pert(:,j));
                R.(CONNAME{conI}).Value(i,j) = r(1,2);
            end
        end
        sr = mean(R.(CONNAME{conI}).Value,1,'omitmissing');
        
        
        r = R.(CONNAME{conI}).Value(R.(CONNAME{conI}).Value~=0);
        R.(CONNAME{conI}).IQR = iqr(r);
        % Q1 and Q3
        Q = quantile(r,[1/4,3/4]);
        Qb = [Q(1)-k*iqr(r),Q(2)+k*iqr(r)];
        R.(CONNAME{conI}).Bound = Qb;

        rr = tril(ones(length(file)),-1);
        rr(logical(rr)) = r;
        rr(rr<Qb(1)|rr>Qb(2)) = 0;
        R.(CONNAME{conI}).maskValue = rr;
    end
end


function [app] = check_copyoutexcel

    % Create UIFigure and hide until all components are created
    app.UIFigure = uifigure('Visible', 'off');
    app.UIFigure.Position = [100 100 363 70];
    app.UIFigure.Name = 'MATLAB App';
    
    % Create yesCheckBox
    app.yesCheckBox = uicheckbox(app.UIFigure,"ValueChangedFcn",@yesCheckBoxValueChanged);
    app.yesCheckBox.Text = 'yes';
    app.yesCheckBox.Position = [163 -2 46 31];

    % Create Label
    app.Label = uilabel(app.UIFigure);
    app.Label.FontSize = 14;
    app.Label.FontWeight = 'bold';
    app.Label.Position = [71 49 226 22];
    app.Label.Text = 'move .xlsx file to another folder?';

    % Create textLabel
    app.textLabel = uilabel(app.UIFigure);
    app.textLabel.FontSize = 14;
    app.textLabel.FontWeight = 'bold';
    app.textLabel.Position = [9 28 352 22];
    app.textLabel.Text = 'split contrast and store all subject file in one folder.';

    % Show the figure after all components are created
    app.UIFigure.Visible = 'on';
    app.UIFigure.CloseRequestFcn = @UIFigureCloseRequest;
    yesCheckBoxValueChanged(app)

    % Value changed function: yesCheckBox
    function yesCheckBoxValueChanged(app, ~)
        switch class(app)
            case "struct"
                app.Parent.UserData = app.yesCheckBox.Value;
            case "matlab.ui.control.CheckBox"
                app.Parent.UserData = app.Value;
        end
    end

    % Close request function: UIFigure
    function UIFigureCloseRequest(app, ~)
        Value = app.UserData;
        assignin('base',"f_mvfile",Value);
        assignin('base',"close_f",true);
        delete(app)
    end
end