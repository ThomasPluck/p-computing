from random import uniform
from math import tanh
import numpy as np
import pulp

class pbit():

    def __init__(self, clamped=None):

        self.activation = 0
        self.clamped = None 
        if clamped != None:
            self.clamped = clamped
    
    def sample(self):
        if self.clamped != None:
            return self.clamped
        return self.__sgn(uniform(-1,1)+tanh(self.activation))

    def __sgn(self,i):
        if i <= 0:
            return -1
        return 1

# Here we first describe the general p-bit network
class pbit_network:
    def __init__(self, pbits: list, J: np.array, h: np.array):

        self.pbits = pbits
        self.J = J
        self.h = h

    def step(self, dt = 1):

        sample = [p.sample() for p in self.pbits]
        forward = (self.J * dt) @ np.array(sample).T + self.h * dt

        for idx, p in enumerate(self.pbits):
            p.activation = forward[idx]

    def sample(self):
        return [p.sample() for p in self.pbits]


class AND(pbit_network):

    def __init__(self):

        # Note in this format we take the first two pbits to be inputs A,B
        # and the final pbit to be the output C = AND(A,B)
        J = np.array([[0, -1, 2], [-1, 0, 2], [2, 2, 0]])
        h = np.array([1, 1, -2])
        super().__init__([pbit(), pbit(), pbit()], J, h)

# Simple ease-of-use wrapper class
class booleanFunction():

    def __init__(self,num_args : int,executable : callable):

        self.num_args = num_args
        self.executable = executable

    def __call__(self,args : list) -> bool:
        return self.executable(args[:self.num_args])

# Simple Hamiltonian finder
def FindHamiltonian(boolfunc : booleanFunction, node_count : int) -> tuple[np.array, np.array]:

    problem = pulp.LpProblem('problem',pulp.LpMinimize)

    # Energy
    E = pulp.LpVariable('E',-10,10,'Continuous')
    # Biases
    h = pulp.LpVariable.dicts('h',([0],[i for i in range(node_count)]),-5,5,'Integer')
    # Weights
    j = pulp.LpVariable.dicts('j',([0],[i for i in range((node_count*(node_count-1))//2)]),-5,5,'Integer')
   
    # Dummy summation variables
    H_h, H_j = (0,0)

    for i in range(2 ** node_count):
        args = [2*((i >> j)%2)-1 for j in range(node_count)]
        count = 0

        # Initialize variables
        H_hp = 0; H_jp = 0

        # Build out constraints line by line
        for idx,a in enumerate(args):
            H_hp += a * h[0][idx]
            
            for jdx in range(idx+1,len(args)):
                H_jp += args[jdx]*a*j[0][count]
                count += 1

        # Summed terms of final energy
        H_h = H_h + H_hp
        H_j = H_j + H_jp

        # Do you satisfy the boolean function?
        if boolfunc(args):
            problem += (-1)*H_hp-H_jp-E == 0
        else:
            problem += (-1)*H_hp-H_jp-E-1 >= 0

    # Define the energy
    problem += -H_h-H_j-E

    # Solve problem
    status = problem.solve()

    if status == -1:
        raise AssertionError("No optimal solution found!")

    # Initialize output and pack
    h_out = np.zeros(node_count)
    J_out = np.zeros((node_count, node_count))
    count = 0

    for idx in range(node_count):
        h_out[idx] = pulp.value(h[0][idx])

        for jdx in range(idx+1,node_count):
            J_out[idx][jdx] = pulp.value(j[0][count])
            count += 1

    J_out += J_out.T

    return (h_out, J_out)