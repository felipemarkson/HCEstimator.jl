module Estimator
include("SimplePF.jl")
import .SimplePF
using JuMP

function build_sets(sys)
    Ω = sys.buses
    bΩ = filter(bus -> bus != sys.substation.bus, Ω)
    L = collect(1:length(sys.m_load))
    K = collect(1:reduce(*, length(der.scenario) for der in sys.dgs))
    D = collect(1:length(sys.dgs))
    S = collect(1:length(sys.m_new_dg))
    return (Ω, bΩ, L, K, D, S)
end

function add_variables(model, sys)
    (Ω, bΩ, L, K, D, S) = Estimator.build_sets(sys)


    @variable(model, -sys.VH ≤ V[[:Re, :Im], Ω, L, K, S] ≤ sys.VH)
    for b = Ω, l = L, k = K, s = S
        set_start_value.(V[:Re, b, l, k, s], 1.0)
        set_start_value.(V[:Im, b, l, k, s], 0.0)
    end
    @variable(model, sys.dgs[d].P_limit[1] ≤ pᴰᴱᴿ[d = D, L, K, S] ≤ sys.dgs[d].P_limit[2], start = 0.0)
    @variable(model, sys.dgs[d].Q_limit[1] ≤ qᴰᴱᴿ[d = D, L, K, S] ≤ sys.dgs[d].Q_limit[2], start = 0.0)
    @variable(model, 0.0 ≤ pᴴᶜ, start = 0.0)

    return model
end

end