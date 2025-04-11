module EnsembleKalmanFiltersExt

using Ensembles:
    Ensembles,
    AbstractEnsemble,
    Ensemble,
    get_ensemble_matrix,
    get_ensemble_dicts,
    get_member_vector
using EnsembleKalmanFilters: EnsembleKalmanFilters, EnKF

function Ensembles.assimilate_data(
    filter::EnKF,
    ensemble::AbstractEnsemble,
    ensemble_obs::AbstractEnsemble,
    y_obs,
    log_data,
)
    X_matrix = EnsembleKalmanFilters.assimilate_data(
        filter,
        Float64.(get_ensemble_matrix(ensemble)),
        Float64.(get_ensemble_matrix(ensemble_obs)),
        get_member_vector(ensemble_obs_clean, y_obs),
        log_data,
    )
    members = get_ensemble_dicts(ensemble, X_matrix)
    posterior = Ensemble(members, ensemble.state_keys)
    return posterior
end

function Ensembles.assimilate_data(
    filter::EnKF,
    ensemble::AbstractEnsemble,
    ensemble_obs_clean::AbstractEnsemble,
    ensemble_obs_noisy::AbstractEnsemble,
    y_obs,
    log_data,
)
    X_matrix = EnsembleKalmanFilters.assimilate_data(
        filter,
        Float64.(get_ensemble_matrix(ensemble)),
        Float64.(get_ensemble_matrix(ensemble_obs_clean)),
        Float64.(get_ensemble_matrix(ensemble_obs_noisy)),
        get_member_vector(ensemble_obs_clean, y_obs),
        log_data,
    )
    members = get_ensemble_dicts(ensemble, X_matrix)
    posterior = Ensemble(members, ensemble.state_keys)
    return posterior
end

end
