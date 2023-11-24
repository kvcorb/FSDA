function createMLTBX 
%% Create toolbox file for FSDA, both locally and in a CI action

% Specify the version number, please use the format 'major.minor.revision'
% During a github build this will be taken from github.ref_name and stored
% in GITHUB_ENV - and for local sandbox builds that don't specify this we
% simply default to a large 10.0.0 release
newVersion = getenv('GITHUB_RELEASE_TAG');

if isempty(newVersion)
    disp('Missing a GITHUB_RELEASE_TAG to build the toolbox : using version 10.0.0')
    newVersion = "10.0.0";
end

% Builds need to start from the root to cleanly define all the relative
% paths, but revert back to where ever we started from when the "cleanup"
% object goes out of scope
[FSDAroot, cleanup] = changeDirToRootWithCleanup; %#ok<ASGLU>

% create realFSDAroot that points to the rela root of FSDA
% and not ot the FSDA/toolbox folder
tmp=split(FSDAroot,"/");
realFSDAroot=join(tmp(1:end-1,1), "/");

% Get filesep
fsep=filesep;

%% Publish contents file in the root inside subfolder html
% This instruction is necessary in order to display subfolder examples in
% Mathworks web site
publish('Contents.m');



%% Create toolbox project file

% Create our desired toolbox options 
%
% 1. Our File Exchange UUID (currently 20669fbc-61ca-4050-bc87-575422f4c0b8)
% 2. By default ALL files should be packaged in the toolbox - we will
%   exclude those that are not needed below using some helpers.

uuid = '20669fbc-61ca-4050-bc87-575422f4c0b8';
uuid = 'd6e027ff-e27e-448a-aa53-ef8f1ba4b647';

options = matlab.addons.toolbox.ToolboxOptions(FSDAroot, uuid);

% Firstly there are a set of folders in this repository that we do not want
% in the packaged toolbox - remove those using a helper function
options = removeFoldersFromToolboxPackage(options, [ ...
    ".buildtool"
    ".circleci"
    ".git"
    ".github"
    "_automation_tools"
    "_development"
    "_TODO"
    "bin"
    "docker"
    "helpfiles" + fsep + "XML"
    "utilities_help" + fsep + "build"
    "Univ"
    ]);

% Secondly there are a set of files in this repository that we do not want
% in the packaged toolbox - remove those using a helper function
% some of them to be discussed with Bensingh snd Rob
options = removeFilesFromToolboxPackage(options, [...
    ".gitattributes"
    ".gitignore"
    ".travis.yml"
    "azure-pipelines.yml"
    "buildfile.m"
    "CODE_OF_CONDUCT.md"
    "CONTRIBUTING.md"
    "copyright.md"
    "defaultToolboxPackageConf.prj"
    "license.md"
    "examples" + fsep + "examples_categorical.mlx"
    "examples" + fsep + "examples_multivariate.mlx"
    "examples" + fsep + "examples_regression.mlx"
    "examples" + fsep + "examples_MixSim.mlx"
    "FSDA.prj"
    "helpfiles" + fsep + "FSDA" + fsep + "images" + fsep + "githubimgexamples.jpg"
    "helpfiles" + fsep + "FSDA" + fsep + "images" + fsep + "githubimgindex.jpg"
    "helpfiles" + fsep + "FSDA" + fsep + "images" + fsep + "githubimgtutorials.jpg"    
    "README.md"
    "utilities_help" + fsep + "FlowChart.pptx"
    ]);


% Define the paths that we want to add to an installed MATLAB path
% NOTE - we need the root as well as some sub-folders so include the empty
% string at the beginning
% IMPORTANT - the folders must be added in a bottom-up style, starting from 
% the subfolder, failure to do so results in an exception.
pathsToAdd = [ ...
    ""
    "multivariate"
    "regression"
    "clustering"
    "graphics"
    "datasets" + fsep + "regression"
    "datasets" + fsep + "multivariate"
    "datasets" + fsep + "multivariate_regression"
    "datasets" + fsep + "clustering"
    "combinatorial"
    "utilities"
    "utilities_stat"
    "utilities_help"
    "examples"
    "FSDAdemos"    
    "apps"    
    % "helpfiles" + fsep + "FSDA"
    % "helpfiles" + fsep + "includes" + fsep + "product" + fsep + "css"
    % "helpfiles" + fsep + "includes" + fsep + "product" + fsep + "fonts"
    % "helpfiles" + fsep + "includes" + fsep + "product" + fsep + "scripts"
    % "helpfiles" + fsep + "includes" + fsep + "shared" + fsep + "scripts"
    % "helpfiles" + fsep + "pointersHTML"
    ];

% AND NOTE scalar expansion here with vector of pathsToAdd
 options.ToolboxMatlabPath = FSDAroot + fsep + pathsToAdd;

% Define our TOOLBOX name, version and other metadata
options.ToolboxName = "FSDAtest";

options.ToolboxVersion = newVersion;

options.Description="Flexible Statistics and Data Analysis (FSDA) extends MATLAB for " + ...
    "a robust analysis of data sets affected by different sources of heterogeneity. " + ...
    "It is open source software licensed under the European Union Public Licence (EUPL). " + ...
    "FSDA is a joint project by the University of Parma and the Joint Research Centre " + ...
    "of the European Commission."; 

options.Summary="Flexible Statistics Data Analysis Toolbox";

options.AuthorName= "Marco Riani";

options.AuthorEmail = "FSDA@unipr.it";

options.AuthorCompany = "University of Parma (UNIPR) and Joint Research Centre of the " + ...
    "European Commission(JRC).";
 
% Define the final architectures that we will correctly work on
options.SupportedPlatforms.Win64 = true;
options.SupportedPlatforms.Maci64 = true;
options.SupportedPlatforms.Glnxa64 = true;
options.SupportedPlatforms.MatlabOnline = true;

% version compatibility
options.MinimumMatlabRelease = 'R2018a';
options.MaximumMatlabRelease = '';

% add big logo
options.ToolboxImageFile = fullfile(realFSDAroot, "images", "logoblue.jpg");

% add getting startup file
options.ToolboxGettingStartedGuide = fullfile(FSDAroot, 'doc', 'GettingStarted.mlx');

% add gallery files
options.AppGalleryFiles=[];

mkdir(FSDAroot, 'bin')
options.OutputFile = fullfile(FSDAroot, "bin", "FSDA");

% Display the options during build in case the github action fails and we
% need some debugging output.
disp(options)

% Finally - package the toolbox
disp('Package toolbox and create file FSDA.mltbx')
matlab.addons.toolbox.packageToolbox(options);

end

function options = removeFoldersFromToolboxPackage(options, foldersToRemove)
% This helper function removes all files in a a set of folders (defined
% relative to the root of the package) from the ToolboxFiles list. This is
% done using string comparison startsWith to find all the currently listed
% files in ToolboxFiles that start with the desired folders.
root = options.ToolboxFolder;
% NOTE - likely scalar expansion of root to accomodate multiple
% foldersToRemove - DO NOT replace with fullfile which does not support
% expansion.
% Also note addition of filesep on the end to ensure that ONLY files in
% folders are removed. Without this a file that began with the name
% folderToRemove and continued with more chars would ALSO be removed.
foldersToRemove = root + filesep + foldersToRemove + filesep;
% NOTE - startsWith takes multiple patterns for second option - we are in
% that case
itemsToRemove = startsWith(options.ToolboxFiles, foldersToRemove);
options.ToolboxFiles(itemsToRemove) = [];
end

function options = removeFilesFromToolboxPackage(options, filesToRemove)
% This helper function removes all files listed from the ToolboxFiles list.
% This is done using string comparison matches to find all the currently
% listed files in ToolboxFiles that match the desired list.
root = options.ToolboxFolder;
% NOTE likely scalar expansion of root to accomodate multiple
% filesToRemove - DO NOT replace with fullfile which does not support
% expansion
filesToRemove = root + filesep + filesToRemove;
% NOTE - matches takes multiple patterns for second option - we are in
% that case
itemsToRemove = matches(options.ToolboxFiles, filesToRemove);
options.ToolboxFiles(itemsToRemove) = [];
end