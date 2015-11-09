function run_compute_patches(paths,params)

% shape instances
names_ = dir(fullfile(paths.input,'*.mat'));
names = sortn({names_.name}); clear names_;

% loop over the shape instances
parfor idx_shape = 1:length(names)
    
    % re-assigning structs variables to avoid parfor errors
    paths_ = paths;
    params_ = params;
    
    % current shape
    name = names{idx_shape}(1:end-4);
    
    % avoid unnecessary computations
    if exist(fullfile(paths_.output,[name,'.mat']),'file')
        fprintf('[i] shape ''%s'' already processed, skipping\n',name);
        continue;
    end
    
    % display info
    fprintf('[i] processing shape ''%s'' (%03.0d/%03.0d)... ',name,idx_shape,length(names));
    time_start = tic;
    
    % compute patch
    P = compute_patches(name,params_.angles,params_.tvals,paths_,params_);
    
    % convert the patch to Python compatible format
    M_ = convert_patches_to_python_format(P);
    
    % convert to sparse format to save memory
    [r,c,v] = find(M_);
    M = sparse(r,c,double(v),size(M_,1),size(M_,2));
    M_ = [];
    
    % saving
    if ~exist(paths_.output,'dir')
        mkdir(paths_.output);
    end
    par_save(fullfile(paths_.output,[name,'.mat']),M);
    
    % display infos
    fprintf('%3.0fs\n',toc(time_start));
    
end

end

function par_save(path,M)
save(path,'M','-v7.3');
end

% older code
% % reshape the patches
% patches = patches_';
% patches = patches(:);
% P       = cell2mat(patches)'; % P has size N x ( ( N * |tvals| ) * |angles| )
