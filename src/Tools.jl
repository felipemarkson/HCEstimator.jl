module Tools
using DataFrames
export make_Y_bus, Get

function admitance(value)
    return value^-1
end


function make_Y_bus(data, VN)

    n_bus = length(collect(skipmissing(data.Bus)))
    Y = zeros(Complex, n_bus, n_bus)
    Z = zeros(Complex, n_bus, n_bus) .+ Inf

    branch = dropmissing(data[:, [:FB, :TB, :Type, :R_Ohm, :X_ohm]])
    branch = branch[branch.Type.=="Fixed", :]

    Bshunt = 1im * (data.Bshunt_MVAr * 1e6) ./ (VN^2)

    for value in eachrow(branch)
        Z[value.FB, value.TB] = value.R_Ohm + 1im * value.X_ohm
        Z[value.TB, value.FB] = value.R_Ohm + 1im * value.X_ohm
    end

    for i in 1:n_bus
        for j in 1:n_bus
            if i == j
                Y[i, j] = sum(admitance.(Z[i, :])) + Bshunt[i]
            else
                Y[i, j] = -admitance(Z[i, j])
            end
        end
    end

    return Y

end


module Get
using JuMP: value

function voltage(model, b, l, k, s)
    Vre = value.(model[:V])[:Re, b, l, k, s]
    Vim = value.(model[:V])[:Im, b, l, k, s]
    return Vre + 1im * Vim
end

function current(model, b, l, k, s)
    Ire = value.(model[:I])[:Re, b, l, k, s]
    Iim = value.(model[:I])[:Im, b, l, k, s]
    return Ire + 1im * Iim
end

function power(model, b, l, k, s)
    P = value.(model[:P])[b, l, k, s]
    Q = value.(model[:Q])[b, l, k, s]
    return P + 1im * Q
end

function power_DG(model, d, l, k, s)
    pᴰᴱᴿ = value.(model[:pᴰᴱᴿ])[d, l, k, s]
    qᴰᴱᴿ = value.(model[:qᴰᴱᴿ])[d, l, k, s]
    return pᴰᴱᴿ + 1im * qᴰᴱᴿ
end

function losses(model, l, k, s)
    Ploss = value.(model[:Ploss])[l, k, s]
    Qloss = value.(model[:Qloss])[l, k, s]
    return Ploss + 1im * Qloss
end
end

end