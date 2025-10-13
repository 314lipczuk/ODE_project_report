#import "@preview/ilm:1.4.1": *

#set text(lang: "en")

#show: ilm.with(
  title: [Research project report:\ Modelling MAPK/ERK pathway using Ordinary Differential Equations],
  author: "Przemysław Pilipczuk",
  date: datetime(year: 2025, month: 10, day: 13),
  abstract: [
    Abstract text
  ],
  preface: [
    #align(center + horizon)[
      Preface text
    ]
  ],
  bibliography: bibliography("refs.bib"),
  figure-index: (enabled: true),
  table-index: (enabled: true),
  listing-index: (enabled: true),
)

= Abstract
The MAPK/ERK pathway serves a key role in determining fate of a cell from extracellular inputs. 
Different cell fates are linked to a dynamics of the final node in the cascade, `ERK` kinases. 
To understand how different dynamc patterns of their behavior arise, 
we attempt to mechanistically model the simplified version of this pathway using Ordinary Differential Equations.
Using data from a fibroblast cell transfected with optoRTK constructs and stimulated with various patterns of light, 
we attempted to estimated model parameters based on these experiments and use cross-validation techniques to 
check for generalization. Resulting fits had problems with achieving several performance metrics that would singify 
an optimal solution. 

= Introduction
TODO

= Methods

== Ordinary Differential Equations

Ordinary differential equations is a mathemathical framework for describing the change of one variable
 (dependant variable, here Y) over another variable (independent variable, here X). 
Its simplest formulation is an expression that equates some mathematical expression to a
 derivative of our variable in question over the independent variable. $ frac(d Y,d X) = ... $ 
A solution to a differential equation is usually understood as obtaining a $Y(X)$ form, also called an _general solution_.
General solutions can be obtained using an analytical solving process, the difficulty of which is heavily 
dependant on the specifc problem being solved. An often encountered problem with analytical solution approach 
is a problem that contains complex, nonlinearly coupled equations, which do not yield easily to this method. 
An alternative approach to solving a system that has these characteristics is a numerical one.
This method relies on a provided initial conditions and a `X-step` resolution to simulate a single trajectory within
an ODE system by evaluating the equations sequentially at a consecutive `X-steps` away from the provided starting point.
This method, while providing a weaker form of solution, can deal with harder problems,
including those that describe complex, nonlinear systems. 

== Modeling & Simulation pipeline

Model definition was done in symbolic form using python and SymPy (TODO: reference them). 
A constructed model consists of a set of differential equations and current parameters.
An interactive environment for simulating behavior of such models was constructed unsing marimo notebooks. 


= Results 

= Discussion

= Conclusions

= Future work

= Supplementary material



