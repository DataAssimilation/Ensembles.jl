export AbstractOperator, AbstractNoisyOperator
export apply_operator, apply_operator!
export get_state_keys
export split_clean_noisy, xor_seed!

abstract type AbstractOperator end
abstract type AbstractNoisyOperator <: AbstractOperator end

"""
    (M::AbstractOperator)(ensemble, args...; inplace=false)

Shorter syntax for [`apply_operator(M, ensemble, args...)`](@ref apply_operator)
or [`apply_operator!(M, ensemble, args...)`](@ref apply_operator!).

Keyword argument `inplace` determines whether in-place version of [`apply_operator`](@ref) is called.
"""
function (M::AbstractOperator)(
    ensemble::T, args...; inplace=false
) where {T<:AbstractEnsemble}
    if inplace
        return apply_operator!(M, ensemble, args...)
    end
    return apply_operator(M, ensemble, args...)
end

"""
    apply_operator(M::AbstractOperator, ensemble, args...)

Return a new ensemble consisting of `M` applied to each member of `ensemble`
with `args...` passed to each invokation of `M`.
"""
function apply_operator(
    M::AbstractOperator, ensemble::T, args...
) where {T<:AbstractEnsemble}
    members = M.(get_ensemble_members(ensemble), args...)
    return T(ensemble, members)
end

"""
    apply_operator!(M::AbstractOperator, ensemble, args...)

Modify the given ensemble by merging each ensemble member with the result of `M` applied on that member
with `args...` passed to each invokation of `M`.

Note: this does not change the state keys of the ensemble.
"""
function apply_operator!(
    M::AbstractOperator, ensemble::T, args...
) where {T<:AbstractEnsemble}
    for em in get_ensemble_members(ensemble)
        merge!(em, M(em, args...))
    end
    return ensemble
end

"""
    get_state_keys(M::AbstractOperator)

Return the keys that the given operator generates when applied to an ensemble member.

Should be implemented by each AbstractOperator. 
"""
function get_state_keys(M::T) where {T<:AbstractOperator}
    return error("Please implement this for type $T")
end

"""
    xor_seed!(M::AbstractNoisyOperator, seed_mod::UInt)

Modify the seed for `M`'s random number generator.

Should be implemented for each AbstractNoisyOperator.
"""
function xor_seed!(M::T, seed_mod::UInt) where {T<:AbstractNoisyOperator}
    return error("Please implement this for type $T")
end

"""
    split_clean_noisy(M::AbstractNoisyOperator, ensemble_obs::AbstractEnsemble)

Given an operator and the ensemble generated by that operator, return two ensembles
that represent the clean operator results and the noisy operator results.
"""
function split_clean_noisy(M::AbstractNoisyOperator, ensemble_obs::AbstractEnsemble)
    N = get_ensemble_size(ensemble_obs)
    members_clean = Vector{eltype(ensemble_obs.members)}(undef, N)
    members_noisy = Vector{eltype(ensemble_obs.members)}(undef, N)
    for i in 1:N
        members_clean[i], members_noisy[i] = split_clean_noisy(M, ensemble_obs.members[i])
    end
    ensemble_clean = Ensemble(ensemble_obs, members_clean)
    ensemble_noisy = Ensemble(ensemble_obs, members_noisy)
    return ensemble_clean, ensemble_noisy
end

"""
For non-noisy operators, simply return the given ensemble and `nothing`.
"""
function split_clean_noisy(M::AbstractOperator, ensemble_obs::AbstractEnsemble)
    ensemble_obs, nothing
end

"""
For non-noisy operators, simply return the given member and `nothing`.
"""
split_clean_noisy(M::AbstractOperator, member) = member, nothing

"""
    split_clean_noisy(M::AbstractNoisyOperator, member)

Given an operator and the ensemble member generated by that operator, return two members
that represent the clean operator results and the noisy operator results.

Should be implemented for each `AbstractNoisyOperator`.
"""
function split_clean_noisy(M::T, member) where {T<:AbstractNoisyOperator}
    return error("Please implement this for type $T")
end
