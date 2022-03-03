# Hosting Capacity Estimator

This library provides a Distributed Generators (DGs) Hosting Capacity (HC) of distribution systems considering that Distribution Company (DisCo) owned other DGs installed in the system.

## Getting Started

### Data Format

The ```DistSystem.System``` structure expected a [DataFrames.jl](https://dataframes.juliadata.org/stable/) with the follow columns:
```
Row │ Branch  FB     TB     R_Ohm    X_ohm    Bus      P_MW        Q_MW        
    │ Int64   Int64  Int64  Float64  Float64  Int64    Float64     Float64
────┼─────────────────────────────────────────────────────────────────────
```

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


data = DataFrame(CSV.File("./exemple_data.csv"))

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
    0.4,                    # Reactive power limit(MVAr)
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


<!-- $\text{max.        }$  -->

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\text{max.&space;&space;&space;&space;&space;&space;&space;&space;}&space;" title="\bg_white \text{max. } " />

<!-- $$
\text{Hosting Capacity}
\begin{cases}
\sum_{k \in K} N^B p^{HC}_k + \sum_{d \in D}  p^{HC}_{kd}
\end{cases}
$$ -->

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\text{Hosting&space;Capacity}\begin{cases}\sum_{k&space;\in&space;K}&space;N^B&space;p^{HC}_k&space;&plus;&space;\sum_{d&space;\in&space;D}&space;&space;p^{HC}_{kd}\end{cases}" title="\bg_white \text{Hosting Capacity}\begin{cases}\sum_{k \in K} N^B p^{HC}_k + \sum_{d \in D} p^{HC}_{kd}\end{cases}" />
 
<!-- $\text{s.t.        }$ -->

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\text{s.t.&space;&space;&space;&space;&space;&space;&space;&space;}" title="\bg_white \text{s.t. }" />

<!-- $$
\begin{matrix}
\text{Power injection}\\
\text{in buses without DGs}
\end{matrix}
\begin{cases}
p_{blks} =  \mu^{HC}_{ks}p^{HC}_k - \mu^L_lP^L_ b\\ 
q_{blks} = - \mu^L_lQ^L_ b\\
\forall b \in \overline{\Omega}, \forall l \in L, \forall k \in K, \forall s \in S_k
\end{cases}
$$ -->
<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\begin{matrix}\text{Power&space;injection}\\\text{in&space;buses&space;without&space;DGs}\end{matrix}\begin{cases}p_{blks}&space;=&space;&space;\mu^{HC}_{ks}p^{HC}_k&space;-&space;\mu^L_lP^L_&space;b\\&space;q_{blks}&space;=&space;-&space;\mu^L_lQ^L_&space;b\\\forall&space;b&space;\in&space;\overline{\Omega},&space;\forall&space;l&space;\in&space;L,&space;\forall&space;k&space;\in&space;K,&space;\forall&space;s&space;\in&space;S_k\end{cases}" title="\bg_white \begin{matrix}\text{Power injection}\\\text{in buses without DGs}\end{matrix}\begin{cases}p_{blks} = \mu^{HC}_{ks}p^{HC}_k - \mu^L_lP^L_ b\\ q_{blks} = - \mu^L_lQ^L_ b\\\forall b \in \overline{\Omega}, \forall l \in L, \forall k \in K, \forall s \in S_k\end{cases}" />

<!-- $$
\begin{matrix}
\text{Power injection}\\
\text{in buses with DGs}
\end{matrix}
\begin{cases}
p_{blks} =  \mu^{HC}_{ks}p^{HC}_{kd} + p^{DG}_{dlks} - \mu^L_lP^L_ b\\ 
q_{blks} = q^{DG}_{dlks} - \mu^L_lQ^L_ b\\
\forall d \in D, \forall b \in \{b_d\}, \forall l \in L, \forall k \in K, \forall s \in S_k
\end{cases}
$$ -->
<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\begin{matrix}\text{Power&space;injection}\\\text{in&space;buses&space;with&space;DGs}\end{matrix}\begin{cases}p_{blks}&space;=&space;&space;\mu^{HC}_{ks}p^{HC}_{kd}&space;&plus;&space;p^{DG}_{dlks}&space;-&space;\mu^L_lP^L_&space;b\\&space;q_{blks}&space;=&space;q^{DG}_{dlks}&space;-&space;\mu^L_lQ^L_&space;b\\\forall&space;d&space;\in&space;D,&space;\forall&space;b&space;\in&space;\{b_d\},&space;\forall&space;l&space;\in&space;L,&space;\forall&space;k&space;\in&space;K,&space;\forall&space;s&space;\in&space;S_k\end{cases}" title="\bg_white \begin{matrix}\text{Power injection}\\\text{in buses with DGs}\end{matrix}\begin{cases}p_{blks} = \mu^{HC}_{ks}p^{HC}_{kd} + p^{DG}_{dlks} - \mu^L_lP^L_ b\\ q_{blks} = q^{DG}_{dlks} - \mu^L_lQ^L_ b\\\forall d \in D, \forall b \in \{b_d\}, \forall l \in L, \forall k \in K, \forall s \in S_k\end{cases}" />

<!-- $$
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
$$ -->
<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\begin{matrix}\text{Power,&space;voltage&space;}\\\text{and&space;current}\\\text{relationship}\end{matrix}\begin{cases}p_{blks}&space;=&space;v^{\Re}_{blks}i^{\Re}_{blks}&space;&plus;&space;v^{\Im}_{blks}i^{\Im}_{blks}\\&space;q_{blks}&space;=&space;v^{\Im}_{blks}i^{\Re}_{blks}&space;-&space;v^{\Re}_{blks}i^{\Im}_{blks}\\i^{\Re}_{blks}&space;=&space;\sum_{j&space;\in&space;\Omega}&space;G_{bj}v^{\Re}_{jlks}&space;-&space;B_{bj}v^{\Im}_{jlks}\\i^{\Im}_{blks}&space;=&space;\sum_{j&space;\in&space;\Omega}&space;B_{bj}v^{\Re}_{jlks}&space;&plus;&space;G_{bj}v^{\Im}_{jlks}\\\forall&space;b&space;\in&space;\Omega,&space;\forall&space;l&space;\in&space;L,&space;\forall&space;k&space;\in&space;K&space;,\forall&space;s&space;\in&space;S_k\end{cases}" title="\bg_white \begin{matrix}\text{Power, voltage }\\\text{and current}\\\text{relationship}\end{matrix}\begin{cases}p_{blks} = v^{\Re}_{blks}i^{\Re}_{blks} + v^{\Im}_{blks}i^{\Im}_{blks}\\ q_{blks} = v^{\Im}_{blks}i^{\Re}_{blks} - v^{\Re}_{blks}i^{\Im}_{blks}\\i^{\Re}_{blks} = \sum_{j \in \Omega} G_{bj}v^{\Re}_{jlks} - B_{bj}v^{\Im}_{jlks}\\i^{\Im}_{blks} = \sum_{j \in \Omega} B_{bj}v^{\Re}_{jlks} + G_{bj}v^{\Im}_{jlks}\\\forall b \in \Omega, \forall l \in L, \forall k \in K ,\forall s \in S_k\end{cases}" />


<!-- $$
\text{Voltage limits}
\begin{cases}
(\underline{V})^2\leq(v^{\Re}_{blks})^2 + (v^{\Im}_{blks})^2 \leq (\overline{V})^2\\
\forall b \in \Omega, \forall l \in L, \forall k \in K ,\forall s \in S_k
\end{cases}
$$ -->
<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\text{Voltage&space;limits}\begin{cases}(\underline{V})^2\leq(v^{\Re}_{blks})^2&space;&plus;&space;(v^{\Im}_{blks})^2&space;\leq&space;(\overline{V})^2\\\forall&space;b&space;\in&space;\Omega,&space;\forall&space;l&space;\in&space;L,&space;\forall&space;k&space;\in&space;K&space;,\forall&space;s&space;\in&space;S_k\end{cases}" title="\bg_white \text{Voltage limits}\begin{cases}(\underline{V})^2\leq(v^{\Re}_{blks})^2 + (v^{\Im}_{blks})^2 \leq (\overline{V})^2\\\forall b \in \Omega, \forall l \in L, \forall k \in K ,\forall s \in S_k\end{cases}" />

<!-- $$\begin{matrix}
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
$$ -->
<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\begin{matrix}\text{Substation}\\\text{constraints}\\\end{matrix}\begin{cases}v^{\Re}_{blks}&space;=&space;V^{SB}\\v^{\Im}_{blks}&space;=&space;0\\0&space;\leq&space;p_{blks}&space;\leq&space;\overline{P^{SB}}\\0&space;\leq&space;q_{blks}&space;\leq&space;\overline{Q^{SB}}\\(i^{\Re}_{blks})^2&space;&plus;&space;(i^{\Im}_{blks})^2&space;\geq&space;0\\\forall&space;b&space;\in&space;\{b^{SB}\},&space;\forall&space;l&space;\in&space;L,&space;\forall&space;k&space;\in&space;K&space;,\forall&space;s&space;\in&space;S_k\end{cases}" title="\bg_white \begin{matrix}\text{Substation}\\\text{constraints}\\\end{matrix}\begin{cases}v^{\Re}_{blks} = V^{SB}\\v^{\Im}_{blks} = 0\\0 \leq p_{blks} \leq \overline{P^{SB}}\\0 \leq q_{blks} \leq \overline{Q^{SB}}\\(i^{\Re}_{blks})^2 + (i^{\Im}_{blks})^2 \geq 0\\\forall b \in \{b^{SB}\}, \forall l \in L, \forall k \in K ,\forall s \in S_k\end{cases}" />

<!-- $$
\begin{matrix}
\text{Limit of power}\\
\text{in buses with DG}
\end{matrix}
\begin{cases}
  p^{HC}_{kd} \leq p^{HC}_{k}\\
  \forall k \in K ,\forall d \in D
\end{cases}
$$ -->
<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\begin{matrix}\text{Limit&space;of&space;power}\\\text{in&space;buses&space;with&space;DG}\end{matrix}\begin{cases}&space;&space;p^{HC}_{kd}&space;\leq&space;p^{HC}_{k}\\&space;&space;\forall&space;k&space;\in&space;K&space;,\forall&space;d&space;\in&space;D\end{cases}" title="\bg_white \begin{matrix}\text{Limit of power}\\\text{in buses with DG}\end{matrix}\begin{cases} p^{HC}_{kd} \leq p^{HC}_{k}\\ \forall k \in K ,\forall d \in D\end{cases}" />


<!-- $$
\text{DGs limits}
\begin{cases}
0\leq p^{DG}_{dlks} \leq \overline{P^{DG}_{d}}\\
0\leq q^{DG}_{dlks} \leq \overline{Q^{DG}_{d}}\\
\forall d \in D, \forall l \in L, \forall k \in K ,\forall s \in S_k
\end{cases}
$$ -->
<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\text{DGs&space;limits}\begin{cases}0\leq&space;p^{DG}_{dlks}&space;\leq&space;\overline{P^{DG}_{d}}\\0\leq&space;q^{DG}_{dlks}&space;\leq&space;\overline{Q^{DG}_{d}}\\\forall&space;d&space;\in&space;D,&space;\forall&space;l&space;\in&space;L,&space;\forall&space;k&space;\in&space;K&space;,\forall&space;s&space;\in&space;S_k\end{cases}" title="\bg_white \text{DGs limits}\begin{cases}0\leq p^{DG}_{dlks} \leq \overline{P^{DG}_{d}}\\0\leq q^{DG}_{dlks} \leq \overline{Q^{DG}_{d}}\\\forall d \in D, \forall l \in L, \forall k \in K ,\forall s \in S_k\end{cases}" />

<!-- $$\begin{matrix}
\text{Power, voltage }\\
\text{and current}\\
\text{constraints}
\end{matrix}
\begin{cases}
-M \leq p_{blks}, q_{blks}, i^{\Re}_{blks}, i^{\Im}_{blks}\leq M\\
-\overline{V}\leq v^{\Re}_{blks}, v^{\Im}_{blks} \leq \overline{V}\\
\forall b \in \Omega, \forall l \in L, \forall k \in K ,\forall s \in S_k
\end{cases}
$$ -->
<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\begin{matrix}\text{Power,&space;voltage&space;}\\\text{and&space;current}\\\text{constraints}\end{matrix}\begin{cases}-M&space;\leq&space;p_{blks},&space;q_{blks},&space;i^{\Re}_{blks},&space;i^{\Im}_{blks}\leq&space;M\\-\overline{V}\leq&space;v^{\Re}_{blks},&space;v^{\Im}_{blks}&space;\leq&space;\overline{V}\\\forall&space;b&space;\in&space;\Omega,&space;\forall&space;l&space;\in&space;L,&space;\forall&space;k&space;\in&space;K&space;,\forall&space;s&space;\in&space;S_k\end{cases}" title="\bg_white \begin{matrix}\text{Power, voltage }\\\text{and current}\\\text{constraints}\end{matrix}\begin{cases}-M \leq p_{blks}, q_{blks}, i^{\Re}_{blks}, i^{\Im}_{blks}\leq M\\-\overline{V}\leq v^{\Re}_{blks}, v^{\Im}_{blks} \leq \overline{V}\\\forall b \in \Omega, \forall l \in L, \forall k \in K ,\forall s \in S_k\end{cases}" />


<!-- $$
\text{Costs}
\begin{cases}
\large?
\end{cases}
$$ -->
<!-- <img src="https://latex.codecogs.com/svg.image?\bg_white&space;\text{Costs}\begin{cases}\large?\end{cases}" title="\bg_white \text{Costs}\begin{cases}\large?\end{cases}" /> -->



## Nomenclature

### Variables

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;p^{HC}" title="\bg_white p^{HC}" />: Active power injection to HC calculation

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;p^{DG},&space;q^{DG}" title="\bg_white p^{DG}, q^{DG}" />: Active and reactive power injection of DisCo's DG

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;p,&space;q" title="\bg_white p, q" />: Nodal active and reactive power injection

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;i^{\Re},&space;i^{\Im}" title="\bg_white i^{\Re}, i^{\Im}" />: Real and imaginary part of nodal current injection

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;v^{\Re},&space;v^{\Im}" title="\bg_white v^{\Re}, v^{\Im}" />: Real and imaginary part of nodal voltage


### Sets

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\Omega" title="\bg_white \Omega" />: Buses' set

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\overline{\Omega}" title="\bg_white \overline{\Omega}" />: Buses' set excluded substation bus

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;L" title="\bg_white L" />: Set of load scenarios

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;K" title="\bg_white K" />: Set of DG types for HC calculation

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;S" title="\bg_white S" />: Set of scenarios of DG types for HC calculation

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;D" title="\bg_white D" />: Set of DisCo's DGs

### Parameters

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\underline{V},&space;\overline{V}" title="\bg_white \underline{V}, \overline{V}" />: Lower and upper voltage limits

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;V^{SB}" title="\bg_white V^{SB}" />: Substation's voltage

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;M" title="\bg_white M" />: A big number

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\overline{P^{DG}},\overline{Q^{DG}}" title="\bg_white \overline{P^{DG}},\overline{Q^{DG}}" />: Active and reactive limit of DisCo's DG

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\overline{P^{SB}},&space;\overline{Q^{SB}}" title="\bg_white \overline{P^{SB}}, \overline{Q^{SB}}" />: Active and reactive limit of the substation

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\mu^L" title="\bg_white \mu^L" />: Load scenario multiplier

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\mu^{HC}" title="\bg_white \mu^{HC}" />: Scenario multiplier for HC calculation

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;N^B" title="\bg_white N^B" />: Quantity of buses

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;b^{SB}" title="\bg_white b^{SB}" />: Substation's bus

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;b_{d}" title="\bg_white b_{d}" /> : DG's bus