"""
This class implements the Probabilistic Prime Factorization algorithm based on the Virtually Connected Boltzmann Machine
and Probabilistic Annealing as described in the paper "Probabilistic Prime Factorization based on Virtually Connected Boltzmann
Machine and Probabilistic Annealing" by Hyundo Jung, Hyunjin Kim, Woojin Lee, and Jinwoo Jeon.

The algorithm is a part of the field of probabilistic computing, where functional networks operate using a probabilistic bit (p-bit),
which generates 0 or 1 based on its electrical input. This method is different from quantum computing and can operate adiabatic algorithms
even at room temperature. It is expected to enhance computational abilities in non-deterministic polynomial searching and learning problems.

The algorithm attempts to find the prime factors of a given number by probabilistically searching the space of potential factors.
It uses a Boltzmann Machine, a type of stochastic recurrent neural network, to model the distribution of potential factors.
The Boltzmann Machine is virtually connected, meaning that the connections between nodes in the network are not fixed but are instead
determined probabilistically. The algorithm also uses a technique called Probabilistic Annealing, which is a variant of Simulated Annealing,
to gradually refine the search for factors.

The class provides methods for initializing the factorization candidates, computing the activation of the Boltzmann Machine,
sampling from the distribution of potential factors, and testing whether the current candidates are indeed factors of the target number.

Attributes:
    n (int): Number of bits.
    N (int): Factorization target.
    X (numpy.array): First factorization candidate.
    Y (numpy.array): Second factorization candidate.
    I (numpy.array): Activation of the Boltzmann Machine.
    const_1 (numpy.array): Multiplication constant 1.
    const_2 (numpy.array): Multiplication constant 2.
    is_X_flag (bool): Flag to indicate whether X or Y is being updated.
    panneal_flag (bool): Flag to indicate whether Probabilistic Annealing is being used.
    count (int): Counter for loop iterations.

Methods:
    _bin_to_int(X): Converts a binary numpy array to an integer.
    _int_to_bin(X): Converts an integer to a binary numpy array.
    compute_activation(): Computes the activation of the Boltzmann Machine.
    _sigmoid(x): Computes the sigmoid function.
    sample_distribution(): Samples from the distribution of potential factors.
    sieve(): Applies a sieve to eliminate non-prime numbers.
    test(): Tests whether the current candidates are factors of the target number.
    loop(): Main loop of the algorithm.

This approach can make probabilistic computing more cost-effective and can be used to solve various large non-deterministic polynomial (NP) searching problems in the future.
"""

import numpy as np

class JK_Multiplier:

    def __init__(self, n = 64, N = 0):

        #  Number of bits
        self.n = n

        #  Randomly initialize factorization candidates X and Y
        self.X = np.random.choice([0.0,1.0], size=self.n//2-1)
        self.Y = np.random.choice([0.0,1.0], size=self.n//2-1)

        #  Activation
        self.I = np.zeros(n//2-1, dtype=float)

        # Factorization target
        self.N = N

        #  Multiplication Constants
        self.const_1 = 2.0 ** (3 + np.arange(1,n//2) - 2 * n )
        self.const_2 = 2.0 ** (1 + 2 * np.arange(1,n//2) - 2 * n )

        #  Control flags
        self.is_X_flag = True
        self.panneal_flag = False
        self.count = 0

    def _bin_to_int(self,X):

        # From numpy array to int (little endian)
        return int(''.join(map(str, X.astype(int)[::-1]))+"1", 2)
    
    def _int_to_bin(self, X):
        # From int to binary string (little endian)
        binary_str = bin(X)[:-1][2:]  # We start from index 2 to skip the '0b' prefix and remove the last character
        binary_array = np.array([int(bit) for bit in binary_str][::-1])
        # Pad the array with zeros to make its length self.n//2 - 1
        padded_array = np.pad(binary_array, (0, self.n//2 - 1 - len(binary_array)), 'constant')
        return padded_array

    def compute_activation(self):

        """Compute p-bit activation as described in the paper"""

        # Convert X and Y to int
        X = self._bin_to_int(self.X)
        Y = self._bin_to_int(self.Y)
    
        # Compute I_k
        if self.is_X_flag:
            self.I = self.const_1 * (self.N - X * Y) * Y
            self.I += (2 * self.X - 1 ) * self.const_2 * Y ** 2
        else:
            self.I = self.const_1 * (self.N - Y * X) * X
            self.I += (2 * self.Y - 1 ) * self.const_2 * X ** 2


    def _sigmoid(self,x):

        return 1.0/(1+np.exp(-x))

    def sample_distribution(self):

        """Sample from the distribution"""

        out = (np.random.uniform(0,1,self.n//2) < self._sigmoid(self.I)).astype(float)

        # Update X or Y
        if self.is_X_flag:
            self.X = out
        else:
            self.Y = out

    def sieve(self):

        #TODO: Possibly expand this to an arbitrary amount

        if self.is_X_flag:

            X = self._bin_to_int(self.X)

            arr = [X-4, X-2, X, X+2, X+4]

             # Check each number in the array
            for num in arr:
                # If the number is not divisible by 3, 5, or 7, return it
                if num % 3 != 0 and num % 5 != 0 and num % 7 != 0:
                    self.X = self._int_to_bin(num)
                    return
            
            # If no such number is found, return None
            self.X = self._int_to_bin(X-4)

        else:

            Y = self._bin_to_int(self.Y)

            arr = [Y-4, Y-2, Y, Y+2, Y+4]

             # Check each number in the array
            for num in arr:
                # If the number is not divisible by 3, 5, or 7, return it
                if num % 3 != 0 and num % 5 != 0 and num % 7 != 0:
                    self.Y = self._int_to_bin(num)
                    return
            
            # If no such number is found, return None
            self.Y = self._int_to_bin(Y-4)

    def test(self):

        # Check if the current X and Y are factors of N
        if self.N % self._bin_to_int(self.X) == 0:
            return True
        elif self.N % self._bin_to_int(self.Y) == 0:
            return True
        else:
            return False
        
    def loop(self):

        # Count and loop
        self.count += 1
        self.count %= 8

        # Compute vanilla I_k
        self.compute_activation()

        if self.test():
            return
        
        # Probabilistic Annealing
        if not self.is_X_flag:

            if self.count == 0:
                self.panneal_flag = True

            if self.panneal_flag:

                self.I *= 2.0 ** 4

            else:

                self.I *= 2.0 ** -1

            self.panneal_flag = False

        # Sample from the distribution
        self.sample_distribution()
        self.sieve()
        
        self.is_X_flag = not self.is_X_flag