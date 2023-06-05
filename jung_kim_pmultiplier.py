import numpy as np

class JK_Multiplier:

    def __init__(self, n = 64, N = 0, sieve_width = 4):

        self.n = n

        self.X = np.random.choice([0,1], size=self.n)
        self.Y = np.random.choice([0,1], size=self.n)

        self.I = np.zeros(n)

        self.N = N

        self.const_1 = 2 ** (3 + np.arange(1,n+1) - 2 * n )
        self.const_2 = 2 ** (1 + 2 * np.arange(1,n+1) - 2 * n )

        self.is_X_flag = True

    def _bin_to_int(X):

        return int(''.join(map(str, X)), 2)
    
    def _int_to_bin(X):
        binary_str = bin(X)[2:]
        return np.array([int(bit) for bit in binary_str])

    def compute_activation(self):

        """Compute p-bit activation as described in the paper"""

        X = self._bin_to_int(self.X)
        Y = self._bin_to_int(self.Y)
    
        self.I = self.const_1 * (self.N - X * Y) * Y
        self.I += (2 * self.X - 1 ) * self.const_2 * Y ** 2

    def _sigmoid(x):

        return 1/(1+np.exp(-x))

    def sample_distribution(self):

        out = (np.random.uniform(0,1,self.n) < self._sigmoid(self.I)).astype(int)

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
            self.X = X-4

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
            self.Y = Y-4

    def test(self):

        if self.N % self._bin_to_int(self.X) == 0:
            return True
        elif self.N % self._bin_to_int(self.Y) == 0:
            return True
        else:
            return False
        
    def loop(self):

        self.compute_activation()
        self.sample_distribution()
        self.sieve()

        if self.test():
            return

        self.is_X_flag = not self.is_X_flag