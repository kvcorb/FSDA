function [out]=addt(y,X,w,varargin)
%addt produces the t test for an additional expl. variable
%
%<a href="matlab: docsearchFS('addt')">Link to the help page for this function</a>
%
% Required input arguments:
%
%       y:  A vector with n elements that contains the response variable.
%           y can be both a row of column vector.
%       X:  Data matrix of explanatory variables (also called 'regressors')
%           Rows of X represent observations, and columns represent
%           variables.
%           Missing values (NaN's) and infinite values (Inf's) are allowed,
%           since observations (rows) with missing or infinite values will
%           automatically be excluded from the computations.
%       w:  additional explanatory variable whose t test must be computed
%
% Optional input arguments:
%
%   intercept : If 1, a column of one will be added to the left of matrix X (default),
%               if 0, no constant term will be included.
%   la:         scalar or '' which specifies for which Box Cox transformation parameter it
%               is necessary to compute the t statistic for the additional
%               variable. If la is an empty value (default) no transformation is used.
%   plots:      scalar. If plots=1 the added variable plot is produced else
%               (default) no plot is produced.
%   units:      vector containing the list of units which has to be removed
%               in the computation of the test.
%   textlab:    if textlab='' default no text label is written on the plot
%               for units else text label of units are added on the plot
%   Fontsize:   Scalar which controls the fontsize of the labels of the
%               axes and eventual plot labels. Default value is 12
%   SizeAxesNum: Scalar which controls the fontsize of the numbers of the
%                axes. Default value is 10
%
% Output:
%
%  The output consists of a structure 'out' containing the following fields:
%       out.b:          estimate of the slope for additional explanatory
%                       variable
%       out.S2add:  estimate of s^2 of the model which contains the
%                       additional explanatory variable
%       out.Tadd:         t statistic for additional explanatory variable
%
% See also FSRaddt
%
% References:
%
%   Atkinson and Riani (2000), Robust Diagnostic Regression Analysis,
%   Springer Verlag, New York.
%
% Copyright 2008-2015.
% Written by FSDA team
%
%
%<a href="matlab: docsearchFS('addt')">Link to the help page for this function</a>
% Last modified 06-Feb-2015

% Examples:

%
%{
    XX=load('wool.txt');
    y=log(XX(:,end));
    X=XX(:,1:end-2);
    w=XX(:,end-1);
    [out]=addt(y,X,w);
    
    % out.Tadd (equal to -8.9707) is exactly equal to stats.tstat.t(4)
    % obtained as
    
    whichstats = {'tstat','mse'};
    stats = regstats(y,XX(:,1:end-1),'linear',whichstats);
    
    % Similarly out.S2add (equal to 0.0345) is exactly equal to stats.mse (estimate of
    % \sigma^2 for augmented model)
   
%}
%
%
%{
    load('multiple_regression.txt');
    y=multiple_regression(:,4);
    X=multiple_regression(:,1:3);

    %Compare the added variable plot based on all units
    % with that which excludes unit 43
    [out]=addt(y,X(:,2:3),X(:,1),'plots',1,'units',[43]','textlab','y');

    %Compare the added variable plot based on all units
    %with that which excludes units 9,21,30,31,38 and 47
    [out]=addt(y,X(:,2:3),X(:,1),'plots',1,'units',[9 21 30 31 38 47]','textlab','y');

%}
%
%
%% User options

if nargin<3
    error('FSDA:addt:missingInputs','A required input argument is missing.')
end

options=struct('intercept',1,'plots',0,'la','','units','','textlab','','FontSize',10,'SizeAxesNum',10);

UserOptions=varargin(1:2:length(varargin));
if ~isempty(UserOptions)
    % Check if number of supplied options is valid
    if length(varargin) ~= 2*length(UserOptions)
        error('FSDA:addt:WrongInputOpt','Number of supplied options is invalid. Probably values for some parameters are missing.');
    end
    % Check if user options are valid options
    chkoptions(options,UserOptions)
end

if nargin > 3
    % We overwrite inside structure options the default values with those
    % chosen by the user
    for i=1:2:length(varargin);
        options.(varargin{i})=varargin{i+1};
    end
end
la=options.la;
plots=options.plots;
units=options.units;
textlab=options.textlab;

% FontSize = font size of the axes labels
FontSize =options.FontSize;
% FontSizeAxes = font size for the axes numbers
SizeAxesNum=options.SizeAxesNum;

%% t test for an additional explanatory variable

if options.intercept    % add column of ones to matrix X
    X=cat(2,ones(length(y),1),X);
end

[n,p]=size(X);

if rank(X)==p && rank([X w])==p+1      % Full rank
    [~, R] = qr(X,0);
    E = X/R;
    A = -E*E';
    sel=1:n;
    linind=sub2ind(size(A),sel,sel);
    A(linind)=1+A(linind);
    % Notice that:
    % -E*E' = matrix -H = -X*inv(X'X)*X' computed through qr decomposition
    % A = Matrix I - H
    
    if ~isempty(la)
        %geometric mean of the y
        G=exp(mean(log(y)));
        if la==0;
            z=G*log(y);
        else
            z=(y.^la-1)/(la*G^(la-1));
        end
    else
        z=y;
    end
    
    Az=A*z;
    r=z'*Az;
    Aw=A*w;
    zAw=z'*Aw;
    wAw=w'*Aw;
    
    if wAw <1e-12;
        Sz_square=NaN;
        Tl=NaN;
        b=NaN;
        warning('Addt:message','The augmented X matrix is nearly singular');
    else
        % b=regress(Az,Aw);
        b=zAw/wAw;
        
        Sz=sqrt(r-zAw^2/wAw); % See Atkinson (1985) p. 98 @
        Sz_square=Sz^2/(n-p-1);
        
        if abs(real(Sz)) > 0.0000001;
            % Compute t-statistic
            Tl=zAw*sqrt(n-p-1)/(Sz*sqrt(wAw));
            % Compute p-value of t-statistic
            pval=2*(1-tcdf(abs(Tl),n-p-1));
        else
            Tl=NaN;
            pval=NaN;
        end
    end

else % Rank is not full
    warning('Addt:message','Matrix rank is low, the added t-test can not be performed');
    b=NaN;
    Tl=NaN;
    Sz_square=NaN;
    pval=NaN; 
end 

% Store results in structure out.
out.b=b;
out.S2add=Sz_square;
out.Tadd=Tl;
out.pval=pval;

%% Added variable plot

if plots==1;
    if ~isempty(units)
        sel=setdiff(1:length(y),units);
        [outsel]=addt(y(sel),X(sel,2:end),w(sel),'plots',0);
        
        plot(Aw(sel),Az(sel),'+b','MarkerSize',FontSize);
        hold('on');
        plot(Aw(units),Az(units),'or','MarkerSize',6,'MarkerFaceColor','r');
        
        xlimits = get(gca,'Xlim');
        % Superimpose line based on all units
        line(xlimits , b.*xlimits,'Color','r','LineWidth',2);
        % Superimposed line based on reduced set of units
        line(xlimits , outsel.b.*xlimits,'LineWidth',2);
        if ~isempty(textlab)
            text(Aw(units)+0.05,Az(units),num2str(units),'FontSize',FontSize);
        end
        set(gca,'FontSize',SizeAxesNum)
        
        xlabel('Aw','Fontsize',FontSize);
        ylabel('Ay','Fontsize',FontSize);
        % Format for the legend 
        forleg='%11.3g';
        forleg1='%3.2g';
        
        legend('Normal units','Excluded units',['Fit on all units tstat=' num2str(Tl,forleg) ' (pval=' num2str(pval,forleg1) ')'],...
            ['Fit on subset tstat=' num2str(outsel.Tadd,forleg) ' (pval=' num2str(outsel.pval,forleg1) ')'])
        hold('off');
        
        %olsline(2)
    else
        plot(Aw,Az,'+');
        xlimits = get(gca,'Xlim');
        % Superimpose line based on all units
        line(xlimits, b.*xlimits,'LineWidth',3);
        set(gca,'FontSize',SizeAxesNum)
        
        xlabel('Aw','Fontsize',FontSize);
        ylabel('Ay','Fontsize',FontSize);
        
    end
    
    % Make the legends clickable.
    hLines = findobj(gca, 'type', 'line');
    eLegend = cell(length(hLines), 1);
    for iLines = 1:length(hLines)
        eLegend{iLines} = get(hLines(iLines), 'DisplayName');
    end
    clickableMultiLegend(hLines, eLegend{:});
    
    % and freeze the scaling at the current limits
    axis(axis); % equivalent to "axis manual";
    
end

end