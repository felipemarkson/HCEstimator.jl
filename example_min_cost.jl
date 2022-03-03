using CSV, DataFrames
using JuMP
using Ipopt

using HCEstimator


data = DataFrame(CSV.File("exemple_data.csv"))
VN = 12600.0 # Nominal Voltage
VL = 0.95   #Lower limit voltage
VH = 1.05  #Higher limit voltage

sub = DistSystem.Substation(
    VN,                     # Nominal Voltage
    1,                      # Bus
    1.,                     # Voltage(p.u)
    4.,                     # Active power limit(MW)
    2.5,                    # Reactive power limit(MVAr)
    [240.0, 12.0, 0.003]    # Costs [Fixed, Linear, Quadratic]
)

dg1 = DistSystem.DG(
    18,                     # Bus
    0.2,                    # Active power limit(MW)
    0.0,                    # Reative power limit(MW)
    [210; 10.26; 0.0026]    # Costs $/MWh [Fixed, Linear, Quadratic]
)

sys = DistSystem.System(data, VL, VH, sub)

sys.dgs = [
    dg1,
    DistSystem.DG(22, 0.2, 0.0,[210; 10.26; 0.0026]),
    DistSystem.DG(25, 0.2, 0.0,[210; 10.26; 0.0026]),
    DistSystem.DG(33, 0.2, 0.0,[210; 10.26; 0.0026])
]


model = Model(Ipopt.Optimizer)  # Create a JuMP model
model = build_model(model, sys, false) # Build the Cost model
optimize!(model)                # Optimize!


println("Costs: ", objective_value(model))