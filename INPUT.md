<!-- INPUT FILE TO README FOR readme2tex -->

# Hosting Capacity Estimator

This library provides a Distributed Generators (DGs) Hosting Capacity (HC) of distribution systems considering that Distribution Company (DisCo) owned other DGs installed in the system.

## Getting Started

### Data Format

The ```DistSystem.System``` structure expected a [DataFrames.jl](https://dataframes.juliadata.org/stable/) with the follow columns:
```
Row │ Branch  FB     TB     Type     R_Ohm    X_ohm    Bus      P_MW        Q_MVAr      Bshunt_MVAr
    │ Int64   Int64  Int64  String   Float64  Float64  Int64    Float64     Float64     Float64
────┼──────────────────────────────────────────────────────────────────────────────────────────────────
```
The active branches must have "Fixed" in ```Type``` field.

### Dependencies

You will need [Julia](https://julialang.org/) v1.6 or greater, [JuMP.jl](https://jump.dev/)  v0.23 or greater, and a nonlinear solver compatible with [JuMP.jl](https://jump.dev/) and the model described below.

### Exemple of use

This exemple also can be found in [example.jl](example.jl).

The distribution system of the example is also available in [Dolatabadi et. al. (2021)](https://ieeexplore.ieee.org/document/9258930).

```julia
using CSV, DataFrames
using JuMP
using Ipopt

using HCEstimator


data = DataFrame(CSV.File("exemple_data.csv"))

VL = 0.95   #Lower limit voltage
VH = 1.05  #Higher limit voltage

sub = DistSystem.Substation(
    12600.0,                # Nominal Voltage
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
    [210; 10.26; 0.0026]    # Costs [Fixed, Linear, Quadratic]
)

sys = DistSystem.System(data, VL, VH, sub)

sys.dgs = [
    dg1,
    DistSystem.DG(22, 0.2, 0.,[210; 10.26; 0.0026]),
    DistSystem.DG(25, 0.2, 0.,[210; 10.26; 0.0026]),
    DistSystem.DG(33, 0.2, 0.,[210; 10.26; 0.0026])
]
sys.m_load = collect(0.6:0.2:1) # Load Multipliers
sys.m_new_dg = [
    collect(0.0:0.2:1) # Generic generator Multipliers
]

model = Model(Ipopt.Optimizer)  # Create a JuMP model
model = build_model(model, sys) # Build the HC model
optimize!(model)                # Optimize!

println("Hosting Capacity: ", objective_value(model))
```

## Mathematical Model

This library uses the following model:


$\text{max.        }$ 


$$
\text{Hosting Capacity}
\begin{cases}
N^B p^{HC}
\end{cases}
$$

 
$\text{s.t.        }$


$$
\begin{matrix}
\text{Power injection}\\
\text{in buses without DERs}
\end{matrix}
\begin{cases}
p_{blks} =  \mu^{HC}_{s}p^{HC} - \mu^L_lP^L_ b\\ 
q_{blks} = - \mu^L_lQ^L_ b\\
\forall b \in \overline{\Omega}, \forall l \in L, \forall s \in S
\end{cases}
$$

$$
\begin{matrix}
\text{Power injection}\\
\text{in buses with DERs}
\end{matrix}
\begin{cases}
p_{blks} = \mu^{DER}_kP^{DER}_{d} - \mu^L_lP^L_ b\\ 
q_{blks} = q^{DER}_{dlk} - \mu^L_lQ^L_ b\\
\forall d \in D, \forall b \in \{b_d\}, \forall l \in L,  \forall k \in K, \forall s \in S
\end{cases}
$$

$$
\begin{matrix}
\text{Power, voltage }\\
\text{and current}\\
\text{relationship}
\end{matrix}
\begin{cases}
p_{blks} = v^{\Re}_{blks}i^{\Re}_{blks} + v^{\Im}_{blks}i^{\Im}_{blks}\\ 
q_{blks} = v^{\Im}_{blks}i^{\Re}_{blks} - v^{\Re}_{blks}i^{\Im}_{blks}\\
i^{\Re}_{blks} = \sum_{j \in \Omega} G_{bj}v^{\Re}_{jlks} - B_{bj}v^{\Im}_{jlks}\\
i^{\Im}_{blks} = \sum_{j \in \Omega} B_{bj}v^{\Re}_{jlks} + G_{bj}v^{\Im}_{jlks}\\
\forall b \in \Omega, \forall l \in L, \forall k \in K, \forall s \in S
\end{cases}
$$


$$
\text{Voltage limits}
\begin{cases}
(\underline{V})^2\leq(v^{\Re}_{blks})^2 + (v^{\Im}_{blks})^2 \leq (\overline{V})^2\\
\forall b \in \Omega, \forall l \in L,\forall k \in K, \forall s \in S
\end{cases}
$$

$$\begin{matrix}
\text{Substation}\\
\text{constraints}\\
\end{matrix}
\begin{cases}
v^{\Re}_{blks} = V^{SB}\\
v^{\Im}_{blks} = 0\\
0 \leq p_{blks} \leq \overline{P^{SB}}\\
0 \leq q_{blks} \leq \overline{Q^{SB}}\\
(i^{\Re}_{blks})^2 + (i^{\Im}_{blks})^2 \geq 0\\
\forall b \in \{b^{SB}\}, \forall l \in L,\forall k \in K, \forall s \in S
\end{cases}
$$

$$
\text{DERs limits}
\begin{cases}
\underline{Q}^{DER}_{d}\leq q^{DER}_{dlks} \leq \overline{Q}^{DER}_{d}\\
(\mu^{DER}_k P^{DER}_{d})^2 + (q^{DER}_{dlks})^2 \leq S^{DER}_{d}\\
\forall d \in D, \forall l \in L, \forall k \in K,\forall s \in S
\end{cases}
$$

$$\begin{matrix}
\text{Power, voltage }\\
\text{and current}\\
\text{constraints}
\end{matrix}
\begin{cases}
-M \leq p_{blks}, q_{blks}, i^{\Re}_{blks}, i^{\Im}_{blks}\leq M\\
-\overline{V}\leq v^{\Re}_{blks}, v^{\Im}_{blks} \leq \overline{V}\\
\forall b \in \Omega, \forall l \in L, \forall k \in K,\forall s \in S
\end{cases}
$$

<!-- $$
\text{Costs}
\begin{cases}
\large?
\end{cases}
$$ -->



## Nomenclature

### Variables

$p^{HC}$: Active power injection to HC calculation

$q^{DER}$: Reactive power injection of DERs dispached by DisCo.

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;p,&space;q" title="\bg_white p, q" />: Nodal active and reactive power injection

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;i^{\Re},&space;i^{\Im}" title="\bg_white i^{\Re}, i^{\Im}" />: Real and imaginary part of nodal current injection

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;v^{\Re},&space;v^{\Im}" title="\bg_white v^{\Re}, v^{\Im}" />: Real and imaginary part of nodal voltage


### Sets

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\Omega" title="\bg_white \Omega" />: Buses' set

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\overline{\Omega}" title="\bg_white \overline{\Omega}" />: Buses' set excluded substation bus

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;L" title="\bg_white L" />: Set of load scenarios

$K$: Set of operation scenario of DERs' Owner

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;S" title="\bg_white S" />: Set of scenarios of DG types for HC calculation

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;D" title="\bg_white D" />: Set of DisCo's DGs

### Parameters

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\underline{V},&space;\overline{V}" title="\bg_white \underline{V}, \overline{V}" />: Lower and upper voltage limits

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;V^{SB}" title="\bg_white V^{SB}" />: Substation's voltage

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;M" title="\bg_white M" />: A big number

$\overline{P}^{DER}, \overline{Q}^{DER}$: DisCO's upper limits of active and reactive power dispached by DERs.

$\underline{P}^{DER}, \underline{Q}^{DER}$: DisCO's lower limits of active and reactive power dispached by DERs.

$S^{DER}$: DERs' power limit.

$P^{DER}$: DERs' owner power injection capacity.

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\overline{P^{SB}},&space;\overline{Q^{SB}}" title="\bg_white \overline{P^{SB}}, \overline{Q^{SB}}" />: Active and reactive limit of the substation

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\mu^L" title="\bg_white \mu^L" />: Load scenario multiplier

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\mu^{HC}" title="\bg_white \mu^{HC}" />: Scenario multiplier for HC calculation

$\mu^{DER}$: DERs' Owner Operation multiplier

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;N^B" title="\bg_white N^B" />: Quantity of buses without DGs

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;b^{SB}" title="\bg_white b^{SB}" />: Substation's bus

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;b_{d}" title="\bg_white b_{d}" /> : DG's bus

## Roadmap

- [x] Define the model

- [x] Implement the model on JuMP.jl

- [x] High-level interface for HC estimation

- [x] Initial documentation

- [x] Implement the minimization of costs.

- [ ] Implement changes on system's topology.

- [ ] Implement tests for power flow calculation using a simple system

- [ ] Describe the relationship between the model and codebase

- [ ] Better Documentation