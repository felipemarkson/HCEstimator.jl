module Tools

export make_Y_bus

function admitance(value)
    return value^-1
end


function make_Y_bus(data)

    n_bus = length(collect(skipmissing(data.Bus)))
    Y = zeros(Complex, n_bus, n_bus)
    Z = ones(Complex, n_bus, n_bus)*Inf

    branch_data = data[data.R_Ohm.!==missing, [:FB, :TB, :R_Ohm, :X_ohm]]

    for value in eachrow(branch_data)
        Z[value.FB, value.TB] = value.R_Ohm + 1im * value.X_ohm
        Z[value.TB, value.FB] = value.R_Ohm + 1im * value.X_ohm
    end
    Z = Z

    for i in 1:n_bus
        for j in 1:n_bus
            if i == j
                Y[i, j] = sum(admitance.(Z[i,:]))
            else
                Y[i, j] = - admitance(Z[i,j])
            end
        end
    end

    return Y

end
  
end