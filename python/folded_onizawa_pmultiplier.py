import numpy as np

"""
The following class describes a n-bit p-Multiplier that is a Multiplier with probabilistic logic.
"""


class Onizawa_Multiplier:
    def __init__(self, n: int, output: int = 0, pseudotemperature: float = 1.0,
                 lr = 0.001, beta_1 = 0.9, beta_2 = 0.999, epsilon = 1e-07, and_temp = 1e-1):

        if n % 2 == 0:

            # Set the parameters

            # n is the number of bits in the multiplier
            # T is the pseudotemperature of the multiplier
            self.n = n
            self.T = pseudotemperature
            self.and_temp = and_temp

            # Desirable output
            if output < 0 or output > 2 ** (n + 1):
                raise ValueError(f"output={output} must be between 0 and {2 ** (n+1)}")
            else:
                self.output = [
                    2 * int(b) - 1 for b in bin(output)[::-1][:-2].ljust(n, "0")
                ]

            # Initialize the multiplier's non-recursive p-bits
            self.a = np.random.choice([-1, +1], size=(n // 2)).astype(np.float64)
            self.b = np.random.choice([-1, +1], size=(n // 2)).astype(np.float64)
            self.first_bit = self.output[0]
            self.last_bit = self.output[-1]

            # Populate the counters/recursive p-bits
            temp = [i for i in range(2, n // 2 + 1)] + [
                i for i in range(n // 2 - 1, 0, -1)
            ]
            answers = temp.copy()

            for idx, _ in enumerate(temp):

                b = np.ceil(np.log2(answers[idx]+1))

                for jdx in range(1, int(b)):

                    if idx + jdx < len(temp):
                        answers[idx + jdx] += 1
                    else:
                        continue

            # Counter dimensions
            self.counter_dims = [
                (temp[i], answers[i] - temp[i], int(np.ceil(np.log2(answers[i] + 1))))
                for i in range(len(answers))
            ]

            # Initialize the counters and other computational arrays
            self.counters = np.zeros((n - 2, max([sum(i) for i in self.counter_dims])))
            self.counter_J = np.zeros((n - 2, max([sum(i) for i in self.counter_dims])))
            self.partial_prods = np.zeros(
                (n - 2, max([sum(i) for i in self.counter_dims]))
            )

            # Populate the counters and other computational arrays
            for i in range(n - 2):

                a = answers[i]
                b = int(np.ceil(np.log2(answers[i] + 1)))

                self.counter_J[i, :a] = -1

                self.counters[i, : a + b] = np.random.choice([-1, +1], size=a + b)
                self.counters[i, a] = self.output[i+1]

                self.partial_prods[i, : self.counter_dims[i][0]] = 1

                for j in range(b):
                    self.counter_J[i, answers[i] + j] = 2**j
            
            # Create a mask for all the counters
            self.counter_mask = (self.counters != 0).astype(int)

            # Create the carry maps and the or_bin
            # Carry maps map (row,col,power) to (row,col)
            self.maps = {}
            self.or_bin = []
            counts = np.zeros(n - 2)

            for i in range(n - 2):
                # Column of the base of the counter cells of a given counter
                c = self.counter_dims[i][0] + self.counter_dims[i][1]

                # Count up the carry cells
                for j in range(1, self.counter_dims[i][2]):
                    try:
                        # Start counting out target carry
                        counts[i + j] += 1

                        # Target column
                        ct = int(self.counter_dims[i + j][0] + counts[i + j]) - 1

                        # Map from excess counters to higher and higher carry cells
                        self.maps.update({(i, c + j, j): (i + j, ct)})

                    except:
                        # If we run out of counters, push them to the or_bin
                        self.or_bin.append((i, c + j, j))

        else:
            raise ValueError(f"n={n} must be even")

        self.a_rows = []

        # Adam parameters
        self.lr = lr
        self.beta_1 = beta_1
        self.beta_2 = beta_2
        self.epsilon = epsilon
        self.timestep = 0

        # First and second moment estimates initialized as 0
        self.m_a_A, self.v_a_A = 0, 0
        self.m_a_B, self.v_a_B = 0, 0
        self.m_a_C, self.v_a_C = 0, 0
        self.m_a_Cio, self.v_a_Cio = 0, 0
        self.m_a_Cor, self.v_a_Cor = 0, 0

    def get_inputs(self):

        A = sum([int(val * 2**idx) for idx, val in enumerate(self.a > 0)])
        B = sum([int(val * 2**idx) for idx, val in enumerate(self.b > 0)])

        return A,B

    def get_output(self):

        out = [self.first_bit]
        for idx,e in enumerate(self.counter_dims):
            out.append(self.counters[idx,e[0]+e[1]])
        out.append(self.last_bit)

        return sum([int(o > 0) * 2 ** idx for idx, o in enumerate(out)])

    """
    The following functions are used to manipulate the shape of the counters
    to make it simple to run the computation required for p-bit activations.
    """

    # Right isoceles to north-west rhombus
    def _lower_push(self, array: np.array) -> np.array:
        temp = array.copy()
        for i in range(self.n // 2 - 2, self.n - 2):
            temp[i] = np.roll(temp[i], i - self.n // 2 + 2)
        return temp

    # Right isoceles to north-east rhombus
    def _upper_push(self, array: np.array) -> np.array:
        temp = array.copy()
        for i in range((self.n) // 2 - 2):
            temp[i] = np.roll(temp[i], (self.n) // 2 - 2 - i)
        return temp

    # North-west rhombus to square
    def _lu_rhombus_to_square(self, array: np.array) -> np.array:
        temp = array.copy()
        temp = np.vstack((np.zeros(temp.shape[1]), temp))
        for i in range(self.n // 2):
            temp[:, i] = np.roll(temp[:, i], -i)
        return temp

    # Square to north-west rhombus
    def _square_to_lu_rhombus(self, array: np.array) -> np.array:
        temp = array.copy()
        for i in range(self.n // 2):
            temp[:, i] = np.roll(temp[:, i], i)
        return temp[1:]

    # North-west rhombus to right isoceles
    def _lower_pushback(self, array: np.array) -> np.array:
        temp = array.copy()
        for i in range(self.n // 2 - 2, self.n - 2):
            temp[i] = np.roll(temp[i], self.n // 2 - 2 - i)
        return temp

    # Multiply by pseudotemperature and apply tanh
    def _mult_n_tanh(self, array: np.array):

        return np.tanh(self.T * array)

    def compute_activations(self):

        """
        This function computes the activations of the p-bits in the multiplier. It does so by performing the following steps:

        1. Isolates the partial products (right_iso) based on the shape of counters and partial_prods.
        2. Computes the activation of components A (a_A) and B (a_B) by applying upper_push and lower_push operations on right_iso, respectively.
        3. Computes the activation of the first bit (a_f) using the first elements of components A and B.
        4. Computes the activation of partial product bits (a_C) by applying lower_push and square_to_lu_rhombus operations on a_rows, right_iso, and AB_outer.
        5. Computes the activation of the carry bits (a_Cio) based on the maps and counters.
        6. Computes the activation of the "or"-bits (a_cor) by procedurally generating or-gate weights and computing the "or_bin" output.
        7. Correctly attaches the "or"-gate output to the carry bits.

        The function returns a tuple containing activations of components A, B, the first bit, partial product bits, carry bits, and "or"-bits.
        """

        # Isolate the partial products - called right iso because of its shape
        right_iso = self.counters * self.partial_prods

        # a_A and a_B are activations of the inputs A/B into an AND-Gate Array

        # Compute activation of A
        a_A = (
            2 * np.sum(self._upper_push(right_iso), axis=0)[: self.n // 2]
            - np.sum(self.b)
            + self.n // 2
        )
        a_A[-1] += 2 * self.first_bit

        # Compute activation of B
        a_B = (
            2 * np.sum(self._lower_push(right_iso), axis=0)[: self.n // 2]
            - np.sum(self.a)
            + self.n // 2
        )
        a_B[0] += 2 * self.first_bit

        # Compute the activation of partial product bits
        self.a_rows = np.sum(self.counters * self.counter_J, axis=1).reshape(-1, 1)

        # These are the outer products of a and b, aka. partial product activations
        AB_outer = np.pad(
            np.add.outer(self.a.T, self.b),
            (
                (0, self.n // 2 - 1),
                (0, max([i[1] + i[2] for i in self.counter_dims]) - 1),
            ),
            "constant",
        )

        # Combine partial product activations and counter activations

        # Bias terms are -2 from partial products and -1 from counters
        # This gives the final bias terms as -3 for each partial product
        a_C = (
            self._lower_pushback(
                (
                    self._lower_push((self.a_rows + self.counters) * self.partial_prods)
                    + 2 * self._square_to_lu_rhombus(AB_outer)
                ),
            )
            - 3 * self.partial_prods
        )

        # Compute the activation of the carry bits
        a_Cio = []

        for key, val in self.maps.items():

            current = self.counters[key[0], key[1]]
            cio = (
                # This segment reflects ordinary behavior from the carry cell
                self.a_rows[val[0]]
                + current
                - 1
                # This segment characterizes more complicated role as a counter cell
                # I've checked this formula a number of times and it does do what it should do
                - (2 ** key[2] * (self.a_rows[key[0]] - 2 ** key[2] * current - 1))
            )

            a_Cio.append(cio[0])

        a_Cio = np.array(a_Cio)

        # Compute the activation of the "or"-bits
        Cor = []
        for o in self.or_bin:
            Cor.append(self.counters[o[0], o[1]])

        # Procedurally generate or-gate weights and compute "or_bin" output
        J_Cor = np.eye(len(self.or_bin)) - 1

        a_Cor = J_Cor @ np.array(Cor) - np.ones(len(self.or_bin))

        # Correctly attach the "or"-gate output to the carry bits
        for i, o in enumerate(self.or_bin):
            current = self.counters[o[0], o[1]]
            a_Cor[i] += -(2 ** o[2] * (self.a_rows[o[0]] - 2 ** o[2] * current - 1))
            a_Cor[i] += 2 * self.last_bit

        # Multiply everything by the pseudotemperature and take the tanh
        return (
            self._mult_n_tanh(a_A),
            self._mult_n_tanh(a_B),
            self._mult_n_tanh(a_C),
            self._mult_n_tanh(a_Cio),
            self._mult_n_tanh(a_Cor),
        )

    def compute_gradients(self):

        """
        This function computes the activations of the p-bits in the multiplier. It does so by performing the following steps:

        1. Isolates the partial products (right_iso) based on the shape of counters and partial_prods.
        2. Computes the activation of components A (a_A) and B (a_B) by applying upper_push and lower_push operations on right_iso, respectively.
        3. Computes the activation of the first bit (a_f) using the first elements of components A and B.
        4. Computes the activation of partial product bits (a_C) by applying lower_push and square_to_lu_rhombus operations on a_rows, right_iso, and AB_outer.
        5. Computes the activation of the carry bits (a_Cio) based on the maps and counters.
        6. Computes the activation of the "or"-bits (a_cor) by procedurally generating or-gate weights and computing the "or_bin" output.
        7. Correctly attaches the "or"-gate output to the carry bits.

        The function returns a tuple containing activations of components A, B, the first bit, partial product bits, carry bits, and "or"-bits.
        """

        # Isolate the partial products - called right iso because of its shape
        right_iso = self.counters * self.partial_prods

        # a_A and a_B are activations of the inputs A/B into an AND-Gate Array

        # Compute activation of A
        a_A = (
            np.sum(self._upper_push(right_iso), axis=0)[: self.n // 2]
            - np.sum(self.b) / 2
            + self.n // 2
        )
        a_A[-1] += self.first_bit

        # Compute activation of B
        a_B = (
            np.sum(self._lower_push(right_iso), axis=0)[: self.n // 2]
            - np.sum(self.a) / 2
            + self.n // 2
        )
        a_B[0] += self.first_bit

        # Compute the activation of partial product bits
        self.a_rows = np.sum(self.counters * self.counter_J, axis=1).reshape(-1, 1)

        # These are the outer products of a and b, aka. partial product activations
        AB_outer = np.pad(
            np.add.outer(self.a.T, self.b),
            (
                (0, self.n // 2 - 1),
                (0, max([i[1] + i[2] for i in self.counter_dims]) - 1),
            ),
            "constant",
        )

        AB_outer *= self.and_temp

        # Combine partial product activations and counter activations

        # Bias terms are -2 from partial products and -1 from counters
        # This gives the final bias terms as -3 for each partial product
        a_C = (
            self._lower_pushback(
                (
                    self._lower_push((self.a_rows + self.counters) * self.partial_prods)
                    + 2 * self._square_to_lu_rhombus(AB_outer)
                ),
            ) / 2
            - 3 * self.partial_prods
        )


        # Compute the activation of the carry bits
        a_Cio = []

        for key, val in self.maps.items():

            current = self.counters[key[0], key[1]]
            cio = (
                # This segment reflects ordinary behavior from the carry cell
                self.a_rows[val[0]] / 2
                + current / 2
                - 1
                # This segment characterizes more complicated role as a counter cell
                # I've checked this formula a number of times and it does do what it should do
                - (2 ** key[2] * (self.a_rows[key[0]] / 2 - 2 ** ( key[2] - 1 ) * current - 1))
            )

            a_Cio.append(cio[0])

        a_Cio = np.array(a_Cio)

        # Compute the activation of the "or"-bits
        Cor = []
        for o in self.or_bin:
            Cor.append(self.counters[o[0], o[1]])

        # Procedurally generate or-gate weights and compute "or_bin" output
        J_Cor = np.eye(len(self.or_bin)) - 1

        a_Cor = J_Cor @ np.array(Cor) - np.ones(len(self.or_bin))

        # Correctly attach the "or"-gate output to the carry bits
        for i, o in enumerate(self.or_bin):
            current = self.counters[o[0], o[1]]
            a_Cor[i] += -(2 ** o[2] * (self.a_rows[o[0]] / 2 - 2 ** ( o[2] - 1 ) * current - 1))
            a_Cor[i] += self.last_bit

        return (
            a_A,
            a_B,
            a_C,
            a_Cio,
            a_Cor,
        )
    
    def descent(self, grad_a_A, grad_a_B, grad_a_C, grad_a_Cio, grad_a_Cor):

        # Update timestep
        self.timestep += 1

        # Update bias-corrected first moment estimate for each activation
        self.m_a_A = self.beta_1 * self.m_a_A + (1 - self.beta_1) * grad_a_A
        self.m_a_B = self.beta_1 * self.m_a_B + (1 - self.beta_1) * grad_a_B
        self.m_a_C = self.beta_1 * self.m_a_C + (1 - self.beta_1) * grad_a_C
        self.m_a_Cio = self.beta_1 * self.m_a_Cio + (1 - self.beta_1) * grad_a_Cio
        self.m_a_Cor = self.beta_1 * self.m_a_Cor + (1 - self.beta_1) * grad_a_Cor

        # Update bias-corrected second raw moment estimate for each activation
        self.v_a_A = self.beta_2 * self.v_a_A + (1 - self.beta_2) * np.square(grad_a_A)
        self.v_a_B = self.beta_2 * self.v_a_B + (1 - self.beta_2) * np.square(grad_a_B)
        self.v_a_C = self.beta_2 * self.v_a_C + (1 - self.beta_2) * np.square(grad_a_C)
        self.v_a_Cio = self.beta_2 * self.v_a_Cio + (1 - self.beta_2) * np.square(grad_a_Cio)
        self.v_a_Cor = self.beta_2 * self.v_a_Cor + (1 - self.beta_2) * np.square(grad_a_Cor)

        # Compute bias-corrected estimates
        m_a_A_corr = self.m_a_A / (1 - np.power(self.beta_1, self.timestep))
        m_a_B_corr = self.m_a_B / (1 - np.power(self.beta_1, self.timestep))
        m_a_C_corr = self.m_a_C / (1 - np.power(self.beta_1, self.timestep))
        m_a_Cio_corr = self.m_a_Cio / (1 - np.power(self.beta_1, self.timestep))
        m_a_Cor_corr = self.m_a_Cor / (1 - np.power(self.beta_1, self.timestep))

        v_a_A_corr = self.v_a_A / (1 - np.power(self.beta_2, self.timestep))
        v_a_B_corr = self.v_a_B / (1 - np.power(self.beta_2, self.timestep))
        v_a_C_corr = self.v_a_C / (1 - np.power(self.beta_2, self.timestep))
        v_a_Cio_corr = self.v_a_Cio / (1 - np.power(self.beta_2, self.timestep))
        v_a_Cor_corr = self.v_a_Cor / (1 - np.power(self.beta_2, self.timestep))

        # Calculate updated gradients
        grad_a_A_updated = m_a_A_corr / (np.sqrt(v_a_A_corr) + self.epsilon)
        grad_a_B_updated = m_a_B_corr / (np.sqrt(v_a_B_corr) + self.epsilon)
        grad_a_C_updated = m_a_C_corr / (np.sqrt(v_a_C_corr) + self.epsilon)
        grad_a_Cio_updated = m_a_Cio_corr / (np.sqrt(v_a_Cio_corr) + self.epsilon)
        grad_a_Cor_updated = m_a_Cor_corr / (np.sqrt(v_a_Cor_corr) + self.epsilon)

        # Use updated gradients to update class data structures
        self.a += self.lr * grad_a_A_updated
        self.b += self.lr * grad_a_B_updated

        # Null out partial products and replace
        self.counters *= 1 - self.partial_prods
        self.counters += self.lr * grad_a_C_updated * self.partial_prods

        # The remaining are a little more complicated
        new_Cio = self.lr * grad_a_Cio_updated
        new_Cor = self.lr * grad_a_Cor_updated

        # Update the carry/counter bits
        for idx, (count, carry) in enumerate(self.maps.items()):
            self.counters[count[0], count[1]] += new_Cio[idx]
            self.counters[carry[0], carry[1]] += new_Cio[idx]

        # Update the carry-or bits
        for idx, Cor in enumerate(self.or_bin):
            self.counters[Cor[0], Cor[1]] += new_Cor[idx]

        # Apply tanh to all activations
        self.a = np.clip(self.a, -1, +1)
        self.b = np.clip(self.b, -1, +1)
        self.counters = np.clip(self.counters, -1, +1)


    def sample(self,a_A, a_B, a_C, a_Cio, a_Cor):

        """
        This function samples a new state, given the activation of the underlying p-bits:

        1. Computes the activations of the p-bits in the multiplier from its current state.
        2. Computes the random numbers necessary to compare with the activation.
        3. Complete the comparison and return the updated state of the multiplier.
        """

        # Compute random numbers
        r_A = np.random.uniform(-1, +1, size=self.a.shape)
        r_B = np.random.uniform(-1, +1, size=self.b.shape)
        r_C = np.random.uniform(-1, +1, size=self.partial_prods.shape)
        r_Cio = np.random.uniform(-1, +1, size=len(a_Cio))
        r_Cor = np.random.uniform(-1, +1, size=len(a_Cor))

        # Complete comparison
        self.a = np.sign(r_A + a_A)
        self.b = np.sign(r_B + a_B)

        # Null out partial products and replace
        self.counters *= 1 - self.partial_prods
        self.counters += np.sign(r_C + a_C) * self.partial_prods

        # The remaining are a little more complicated
        new_Cio = np.sign(r_Cio + a_Cio)
        new_Cor = np.sign(r_Cor + a_Cor)

        # Update the carry/counter bits
        for idx, (count, carry) in enumerate(self.maps.items()):
            self.counters[count[0], count[1]] = new_Cio[idx]
            self.counters[carry[0], carry[1]] = new_Cio[idx]

        # Update the carry-or bits
        for idx, Cor in enumerate(self.or_bin):
            self.counters[Cor[0], Cor[1]] = new_Cor[idx]

    def deterministic_iteration(self):

        a_A, a_B, a_C, a_Cio, a_Cor = self.compute_gradients()
        self.descent(a_A, a_B, a_C, a_Cio, a_Cor)

    def stochastic_iteration(self):

        a_A, a_B, a_C, a_Cio, a_Cor = self.compute_activations()
        self.sample(a_A, a_B, a_C, a_Cio, a_Cor)