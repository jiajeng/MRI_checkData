function Clust_Label_file(SPMfile,ic,varargin)
    % using spm_write_filterd.m get clusters label (n-ary)
    % spm_write_filterd(Z,XYZ,DIM,M,descrip,F)
    % require input : SPMfile, "string", spm.mat file
    %               : contrast_idx, "double", contrast index
    %               : 


    % load SPM
    load(SPMfile)
    imf = false;
    thresDesc = nan;
    u = nan;
    kf = false;
    krf = false;
    
    % set varin
    varname = varargin(1:2:end);
    varvar = varargin(2:2:end);
    for i = 1:length(varname)
        v = varname{i};
        switch v
            case 'mask'
                im = varvar{i};
                if class(im) ~= "double"
                    error(['mask data type is "double", input is ',class(im)]); 
                end
                imf = true;
            case 'thresType'
                thresDesc = varvar{i};
                if class(thresDesc) ~= "string" && class(thresDesc) ~= "char"
                    error(['thresType data type is "string" or "char", input is ',class(thresDesc)]); 
                end
            case 'thres_value'
                u = varvar{i};
                if class(u) ~= "double"
                    error(['thres_value data type is "double", input is ',class(u)]); 
                end
            case 'thres_clusSize'
                k = varvar{i};
                if class(k) ~= "double"
                    error(['thres_clusSize data type is "double", input is ',class(k)]); 
                end
                kf = true;
            case 'thres_clusSize_ResTab'
                krf = varvar{i};
                if class(krf) ~= "logical"
                    error(['thres_clusSize_ResTab data type is "logical", input is ',class(krf)]); 
                end
            otherwise
                error(['do not know input ',v]);
        end
    end
    
    % set some variable
    if ~isnan(ic)
        SPM.Ic = ic; % which contrast SPM.xCon idx
    end
    if imf
        SPM.Im = im;% mask ?? not sure the rule --> mask = ~isempty(Im) * (isnumeric(Im) + 2*iscellstr(Im)) if no mask mask == 0
    else % default
        SPM.Im = [];
    end
    if ~isnan(thresDesc)
        SPM.thresDesc = thresDesc; % threshold method FWE|none
    else % default
        SPM.thresDesc = 'none';
    end
    if ~isnan(u)
        SPM.u = u; % threshold value
    else % default
        SPM.u = 0.001;
    end
    if kf
        SPM.k = k;% Get extent threshold [default = 0], cluster voxel size threshold
    else % default
        SPM.k = 0;
    end
    
    % get spm list to get FDRc value
    if krf
        if ~kf 
            tSPM = SPM;
            tSPM.k = 0;
            [~,xSPM] = spm_getSPM(tSPM);
        else
            [~,xSPM] = spm_getSPM(SPM);
        end

        TabDat = spm_list('Table',xSPM);
        k = TabDat.ftr{5,2}; % FWEp: %0.3f, FDRp: %0.3f, FWEc: %0.0f, FDRc: %0.0f
        switch SPM.thresDesc
            case 'none'
                k = k(end);  % FDRc
            case 'FWE'
                k = k(end-1); % FWEc
        end
        SPM.k = k;
        if k == inf, fprintf('%s contrast %d cluster FDR is Inf',SPMfile,ic); return; end 
    end
    [~,xSPM] = spm_getSPM(SPM);

    if ~exist(fullfile('.','Clust_check'),'dir'), mkdir(fullfile('.','Clust_check')); end
    OUTFname = fullfile(fullfile('.','Clust_check'),xSPM.title);
    
    % Z input 
    if ~isfield(xSPM,'G')
        Z       = spm_clusters(xSPM.XYZ);
        num     = max(Z);
        [n, ni] = sort(histc(Z,1:num), 2, 'descend');
        n       = size(ni);
        n(ni)   = 1:num;
        Z       = n(Z);
    else
        C       = NaN(1,size(xSPM.G.vertices,1));
        C(xSPM.XYZ(1,:)) = ones(size(xSPM.Z));
        C       = spm_mesh_clusters(xSPM.G,C);
        Z       = C(xSPM.XYZ(1,:));
    end
            
    
    V   = spm_write_filtered(Z, xSPM.XYZ, xSPM.DIM, xSPM.M,...
            sprintf('SPM{%c}-filtered: u = %5.3f, k = %d',xSPM.STAT,xSPM.u,xSPM.k),OUTFname);
            cmd = 'spm_image(''display'',''%s'')';
end