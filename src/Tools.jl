module Tools
using DataFrames
export make_Y_bus

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

end