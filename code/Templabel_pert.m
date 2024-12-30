function Templabel_pert(niifile,mniifile, templabelfile, Brainarea)
    % loop for all temp label, output a table that contains how many voxel
    % in this template brain area

    % require input : 
    %           niifile, "string", spmT_*.nii file
    %           mniifile, "string", mask spmT_*.mii file that pass through some
    %                               threshold
    %           templabel, "string",niifile that contains label for all brain area
    %           Brainarea, "cell", n x 1 array, contains brain area name
    %
    

    % default MNI space 
    % 182x218x182 1mm
    % 91x109x91 2mm

    % get niifile t value
    tV = spm_read_vols(spm_vol(niifile));

    % get mask niifile 
    niiV = spm_read_vols(spm_vol(mniifile));
    mV = logical(niiV);
    Resfilename = split(mniifile,filesep);
    Resfilepath = strjoin(Resfilename(1:end-1),filesep);
    Resfilename = split(Resfilename{end},'.');
    Resfilename = Resfilename{1};

    
    % get template file
    BrainareaV = spm_read_vols(spm_vol(templabelfile));
    if size(niiV) ~= size(BrainareaV)
        matlabbatch{1}.spm.spatial.coreg.write.ref = {[mniifile,',1']};
        matlabbatch{1}.spm.spatial.coreg.write.source = {[templabelfile,',1']};
        matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 4;
        matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
        matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
        matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';
        spm('defaults','FMRI');
        spm_jobman('run',matlabbatch);
        tempfilename = split(templabelfile,filesep);
        tempfilepath = strjoin(tempfilename(1:end-1),'\');
        tempfilename = ['r',tempfilename{end}];
        BrainareaV = spm_read_vols(spm_vol(fullfile(tempfilepath,tempfilename)));
    end

    % check temp label number is same as info
    if length(unique(BrainareaV))-1 ~= length(Brainarea)
        error('template label is need to same as template info.')
    end
    
    % loop for template info 
    Res = table(Brainarea,zeros(size(Brainarea)),zeros(size(Brainarea)),zeros(size(Brainarea)), ...
                'VariableNames',{'Brainarea','percentage','maxTValue','meanTValue'});
    for i = 1:length(Brainarea)
        % Brainarea i
        BaV = BrainareaV == i;
        % get significant mask in brainarea i
        andmask = BaV & mV;
        if ~isempty(tV(andmask))
            % percentage
            Res.percentage(i) = sum(andmask,"all")/sum(BaV,'all')*100;
            % max T
            Res.maxTValue(i) = max(tV(andmask),[],"all");
            % mean T
            Res.meanTValue(i) = mean(tV(andmask),"all");
        end
    end
    writetable(Res,[Resfilepath,filesep,Resfilename,'.xlsx'])
end

