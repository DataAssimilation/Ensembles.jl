module NormalizingFlowFiltersExt

using Ensembles:
    Ensembles, AbstractEnsemble, Ensemble, get_ensemble_matrix, get_ensemble_dicts, get_member_vector
using NormalizingFlowFilters: NormalizingFlowFilters, NormalizingFlowFilter

function Ensembles.assimilate_data(
    filter::NormalizingFlowFilter,
    ensemble::AbstractEnsemble,
    ensemble_obs::AbstractEnsemble,
    y_obs,
    log_data,
)
    X_matrix = NormalizingFlowFilters.assimilate_data(
        filter,
        Float64.(get_ensemble_matrix(ensemble)),
        Float64.(get_ensemble_matrix(ensemble_obs)),
        get_member_vector(ensemble_obs, y_obs),
        log_data,
    )
    members = get_ensemble_dicts(ensemble, X_matrix)
    posterior = Ensemble(members, ensemble.state_keys)
    return posterior
end

function Ensembles.assimilate_data(
    filter::NormalizingFlowFilter,
    ensemble::AbstractEnsemble,
    ensemble_obs_clean::AbstractEnsemble,
    ensemble_obs_noisy::AbstractEnsemble,
    y_obs,
    log_data,
)
    X_matrix = NormalizingFlowFilters.assimilate_data(
        filter,
        Float64.(get_ensemble_matrix(ensemble)),
        Float64.(get_ensemble_matrix(ensemble_obs_noisy)),
        get_member_vector(ensemble_obs_clean, y_obs),
        log_data,
    )
    members = get_ensemble_dicts(ensemble, X_matrix)
    posterior = Ensemble(members, ensemble.state_keys)
    return posterior
end

function Ensembles.get_data(filter::NormalizingFlowFilter)
    return NormalizingFlowFilters.get_data(filter)
end

function Ensembles.set_data!(filter::NormalizingFlowFilter, params)
    return NormalizingFlowFilters.set_data!(filter, params)
end

end
