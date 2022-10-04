function [] = save_all_figs(FolderName,fig_names)
    FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
    
    if isempty(fig_names) % if fig names empty, save all figs
        n=length(FigList)
        for iFig = 1:n
          FigHandle = FigList(iFig);
          FigName   = num2str(get(FigHandle, 'Number'));
          set(0, 'CurrentFigure', FigHandle);
          savefig(fullfile(FolderName, [FigName '.fig']));
        end
    else % use fig_names
        n=length(fig_names)
        for iFig = 1:n
          FigHandle = FigList(iFig);
          FigName=fig_names{iFig};
          set(0, 'CurrentFigure', FigHandle);
          savefig(fullfile(FolderName, [FigName '.fig']));
        end
    end
end

