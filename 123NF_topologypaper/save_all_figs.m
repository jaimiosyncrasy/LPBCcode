function [outputArg1,outputArg2] = save_all_figs(FolderName,fig_names)
    FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
    for iFig = 1:length(fig_names)
      FigHandle = FigList(iFig);
      %FigName   = num2str(get(FigHandle, 'Number'));
      FigName=fig_names{iFig};
      set(0, 'CurrentFigure', FigHandle);
      savefig(fullfile(FolderName, [FigName '.fig']));
    end
end

