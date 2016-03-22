classdef PendulumPlotterExplorationConfigurator < Experiments.Configurator
    
    properties
        evalCriterion
        configuredFeatures
        configuredGatingFeatures
    end
    
    methods
        function obj = PendulumPlotterExplorationConfigurator   (evalCriterion, configuredFeatures, configuredGatingFeatures)
            obj = obj@Experiments.Configurator('PendulumPlotter');
            
            obj.evalCriterion       = evalCriterion;
            obj.configuredFeatures  = configuredFeatures;
            obj.configuredGatingFeatures = configuredGatingFeatures;
            
        end
                
        
        function preConfigureTrial(obj, trial)
        end
        
        function postConfigureTrial(obj, trial)
            plotter = Evaluator.PendulumPlotterExploration(...
                trial.learner, trial.dataManager, obj.configuredFeatures.featureOutputName, ...
                obj.configuredGatingFeatures.featureOutputName, trial.sampler);
            
            obj.evalCriterion.registerEvaluator(plotter);
        end
        
    end    
end