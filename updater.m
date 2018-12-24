function [ val ] = updater( optim,options )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
val=options.InitialTemperature.*(0.8.^optim.k);
end

