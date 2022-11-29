clear all;clc;close all
rng default
[file,path] = uigetfile('*.vrp');
if isequal(file,0)
   disp('User selected Cancel');
else
   disp(['User selected ', fullfile(path,file)]);
end
file_path = fullfile(path, file);
% [VRP.Dantzig_Fulkerson_Johnson,
% VRP.Miller_Tucker_Zemlin,
% VRP.Simulated_Annealing,
% VRP.Simple_Integer_Model]
tic
vrp = Factory.CreateProblem(VRP.Dantzig_Fulkerson_Johnson, file_path);
vrp.parseFile;
vrp.solve
vrp.displayResult
toc

