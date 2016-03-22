classdef CEOKernelKalmanFilterConfigurator < Experiments.Configurator
    %CEOKERNELKALMANFILTE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = CEOKernelKalmanFilterConfigurator(name)
            obj = obj@Experiments.Configurator(name);
            
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
        end
        
        function postConfigureTrial(obj, trial)
            trial.setprop('filterLearner',Filter.Learner.CEOKernelKalmanFilterLearner(trial.dataManager,'filterLearner'));
            
            for i = 1:length(trial.preprocessors)
                trial.filterLearner.addDataPreprocessor(trial.preprocessors{i});
            end
            
            trial.setprop('filterOptimizer', Filter.Learner.CEOKernelKalmanFilterOptimizer(trial.dataManager, trial.filterLearner));
        end
        
        function setupScenarioForLearners(obj, trial)
            trial.scenario.addLearner(trial.filterOptimizer);
        end
    end
    
end
