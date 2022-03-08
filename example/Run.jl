module Run


using CSV, DataFrames
using JuMP
using Ipopt

using HCEstimator

export run

function run()
    data = DataFrame(CSV.File("exemple_data.csv"))

    VL = 0.95   #Lower limit voltage
    VH = 1.05  #Higher limit voltage

    sub = DistSystem.Substation(
        12600.0,                # Nominal Voltage
        1,                      # Bus
        1.0,                     # Voltage(p.u)
        4.0,                     # Active power limit(MW)
        2.5,                    # Reactive power limit(MVAr)
        [240.0, 12.0, 0.003]    # Costs [Fixed, Linear, Quadratic]
    )

    dg1 = DistSystem.DG(
        18,                     # Bus
        0.2,                    # Active power limit(MW)
        0.0,                    # Reative power limit(MW)
        [210; 10.26; 0.0026]    # Costs [Fixed, Linear, Quadratic]
    )

    sys = DistSystem.System(data, VL, VH, sub)

    sys.dgs = [
        dg1,
        DistSystem.DG(22, 0.2, 0.0, [210; 10.26; 0.0026]),
        DistSystem.DG(25, 0.2, 0.0, [210; 10.26; 0.0026]),
        DistSystem.DG(33, 0.2, 0.0, [210; 10.26; 0.0026])
    ]
    sys.m_load = collect(0.6:0.2:1) # Load Multipliers
    sys.m_new_dg = [
        collect(0.0:0.2:1) # Generic generator Multipliers
    ]

    model = Model(Ipopt.Optimizer)  # Create a JuMP model
    model = build_model(model, sys) # Build the HC model
    optimize!(model)                # Optimize!

    println("Hosting Capacity: ", objective_value(model))
end
end