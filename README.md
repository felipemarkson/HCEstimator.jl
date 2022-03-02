# Hosting Capacity Estimation



## Getting Started

### Data Format

The ```DistSystem.System``` structure expected a [DataFrames.jl](https://dataframes.juliadata.org/stable/) with the follow columns:
```
Row │ Branch  FB     TB     R_Ohm    X_ohm    Bus      P_MW        Q_MW        
    │ Int64   Int64  Int64  Float64  Float64  Int64    Float64     Float64
────┼─────────────────────────────────────────────────────────────────────
```

### Exemple of use

This exemple also can be found in ```example.jl```.

The data example is also available in [Dolatabadi et. al. (2021)](https://ieeexplore.ieee.org/document/9258930).

```julia
using CSV, DataFrames
using JuMP
using Ipopt

using HCEstimator


data = DataFrame(CSV.File("./data.csv"))

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
    0.4,                    # Reative power limit(MW)
    [210; 10.26; 0.0026]    # Costs [Fixed, Linear, Quadratic]
)

sys = DistSystem.System(data, VL, VH, sub)

sys.dgs = [
    dg1,
    DistSystem.DG(22, 0.2, 0.,[210; 10.26; 0.0026]),
    DistSystem.DG(25, 0.2, 0.,[210; 10.26; 0.0026]),
    DistSystem.DG(33, 0.2, 0.6,[210; 10.26; 0.0026])
]
sys.m_load = collect(0.6:0.2:1.2) # Load Multipliers
sys.m_new_dg = [
    collect(0.0:0.2:1) # Generic generator Multipliers
]

model = Model(Ipopt.Optimizer)  # Create a JuMP model
model = build_model(model, sys) # Build the HC model
optimize!(model)                # Optimize!

print("Hosting Capacity: ", objective_value(model))
```

## Mathematical Model

This library uses the following model:


$\text{max.        }$ 

$$
\text{Hosting Capacity}
\begin{cases}
\sum_{k \in K} N^B p^{HC}_k + \sum_{d \in D}  p^{HC}_{kd}
\end{cases}
$$
 
$\text{s.t.        }$


$$
\begin{matrix}
\text{Power injection}\\
\text{in buses without DGs}
\end{matrix}
\begin{cases}
p_{blks} =  \mu^{HC}_{ks}p^{HC}_k - \mu^L_lP^L_ b\\ 
q_{blks} = - \mu^L_lQ^L_ b\\
\forall b \in \overline{\Omega}, \forall l \in L, \forall k \in K, \forall s \in S_k
\end{cases}
$$

$$
\begin{matrix}
\text{Power injection}\\
\text{in buses with DGs}
\end{matrix}
\begin{cases}
p_{blks} =  \mu^{HC}_{ks}p^{HC}_{kd} + p^{DG}_{dlks} - \mu^L_lP^L_ b\\ 
q_{blks} = q^{DG}_{dlks} - \mu^L_lQ^L_ b\\
\forall d \in D, \forall b \in \{b_d\}, \forall l \in L, \forall k \in K, \forall s \in S_k
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
\forall b \in \Omega, \forall l \in L, \forall k \in K ,\forall s \in S_k
\end{cases}
$$


$$
\text{Voltage limits}
\begin{cases}
(\underline{V})^2\leq(v^{\Re}_{blks})^2 + (v^{\Im}_{blks})^2 \leq (\overline{V})^2\\
\forall b \in \Omega, \forall l \in L, \forall k \in K ,\forall s \in S_k
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
\forall b \in \{b^{SB}\}, \forall l \in L, \forall k \in K ,\forall s \in S_k
\end{cases}
$$


$$
\begin{matrix}
\text{Limit of power}\\
\text{in buses with DG}
\end{matrix}
\begin{cases}
  p^{HC}_{kd} \leq p^{HC}_{k}\\
  \forall k \in K ,\forall d \in D
\end{cases}
$$


$$
\text{DGs limits}
\begin{cases}
0\leq p^{DG}_{dlks} \leq \overline{P^{DG}_{d}}\\
0\leq q^{DG}_{dlks} \leq \overline{Q^{DG}_{d}}\\
\forall d \in D, \forall l \in L, \forall k \in K ,\forall s \in S_k
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
\forall b \in \Omega, \forall l \in L, \forall k \in K ,\forall s \in S_k
\end{cases}
$$


$$
\text{Costs}
\begin{cases}
\large?
\end{cases}
$$


## Nomenclature

### Variables

$p^{HC}$: Active power injection to HC calculation

$p^{DG}$, $q^{DG}$: Active and reactive power injection of DisCo's DG

$p$, $q$: Nodal active and reactive power injection

$i^{\Re}$, $i^{\Im}$: Real and imaginary part of nodal current injection

$v^{\Re}$, $v^{\Im}$: Real and imaginary part of nodal voltage


### Sets

$\Omega$: Buses' set

$\overline{\Omega}$: Buses' set excluded substation bus

$L$: Set of load scenarios

$K$: Set of DG types for HC calculation

$S$: Set of scenarios of DG types for HC calculation

$D$: Set of DisCo's DGs

### Parameters

$\underline{V}$, $\overline{V}$: Lower and upper voltage limits

$V^{SB}$: Substation's voltage

$M$: A big number

$\overline{P^{DG}}$, $\overline{Q^{DG}}$: Active and reactive limit of DisCo's DG

$\overline{P^{SB}}$, $\overline{Q^{SB}}$: Active and reactive limit of the substation

$\mu^L$: Load scenario multiplier

$\mu^{HC}$: Scenario multiplier for HC calculation

$N^B$: Quantity of buses

$b^{SB}$: Substation's bus

$b_{d}$: DG's bus