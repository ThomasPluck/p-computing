# p-Computing

These are implementations of stuff that I've seen and learnt about during my time reading through papers on Ising models and their application in the emergent field of "probabilistic computing". 

## Ising Models

The Ising model is a mathematical model of ferromagnetism in statistical mechanics. It is a binary system, where each particle can be in one of two states, up or down. The model is defined by a set of particles, each with a spin, and a set of interactions between the particles. The interactions are defined by a matrix, J, where J<sub>ij</sub> is the interaction between particles i and j. The energy of the system is defined by the Hamiltonian:

$$H = -\sum_{i,j} J_{ij} s_i s_j$$

where s<sub>i</sub> is the spin of particle i. The probability of the system being in a particular state is given by the Boltzmann distribution:

$$P(s) = \frac{1}{Z} e^{-\beta H}$$

where Z is the partition function, and $\beta$ is the inverse temperature. The partition function is given by:

$$Z = \sum_s e^{-\beta H}$$

The partition function is the normalising constant that ensures that the probability distribution sums to 1. The partition function is intractable to compute for large systems, so we use Monte Carlo methods to sample from the distribution.

## Probabilistic Computing

Probabilistic computing is a field that aims to leverage the Ising model to use probabilistic inference to solve NP-hard problems. The idea is to encode the problem as an Ising model, and then use Monte Carlo methods to sample from the distribution. The samples can then be used to solve the problem.

There's a few different approaches that I've written programs for, these include:

- Realizing Classical Circuits in Ising Models with Invertible Logic
- Sparsified Ising Models for Improved Convergence
- Quick and Dirty Ising Models for NP-Hard Problems
- CTMC/Stochastic Formalisms of Probabilistic Computing
- The Suzuki-Trotter Transform to Realize Quantum Circuits in Ising Models

My chief motivation is trying to see how I can implement hardware for probabilistic computing and apply it to the very particular problem of semiprime factorization which is very important for cryptography and so is tangentially related to my day-job.

I'll also write some notes here in the `README.md` because this is discipline chock full of fun facts that someone may want to read someday if they fall down the same rabbit hole as me.