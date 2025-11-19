# Speaking Script – Background of Fully Homomorphic Encryption (CKKS and TFHE)

> Style: simple English, short sentences, slightly informal.  
> You can read this text directly during class.  
> When you see a formula followed by `[read: "..."]`, that bracket tells you how to read it aloud.

---

## Slide 0 – Title Page

Today I will talk about the background of Fully Homomorphic Encryption.  
The focus will be on two schemes: CKKS and TFHE.  
CKKS works well for approximate real numbers and vector-style data.  
TFHE works on encrypted bits and Boolean circuits.  
I will first motivate why we care about FHE.  
Then we will look at the math foundations.  
After that, we go into CKKS.  
Finally we switch to TFHE and programmable bootstrapping.

---

## Slide 1 – 1.1 Motivation and Definition of FHE

On this slide I explain why we need to compute on encrypted data.  
In many real systems, data must be used but cannot be seen in plaintext.  
For example, in cloud outsourcing, a company sends data to the cloud for model inference, statistics, or search.  
At the same time there are strong privacy rules like GDPR and HIPAA, and cross‑border data controls.  
Traditional encryption protects data in storage and in transit.  
But as soon as we want to compute, we usually decrypt first, and that is the risky step.

The goal of privacy‑preserving computing is different.  
We want the server to work only on ciphertexts, without seeing the plaintext.  
The client will later decrypt the final result and get the same answer as if we had computed on plaintext.

Here you see the core property of FHE:  
the formula is `Dec(f(Enc(x))) = f(x)`  
`[read: "Dec of f of Enc of x equals f of x"]`.  
`Enc` means encryption, `Dec` means decryption, and `f` is the same function on plaintext and ciphertext.

Typical applications include privacy‑preserving healthcare analytics,  
privacy‑preserving finance and anti‑fraud,  
and privacy smart contracts where ciphertexts live on chain but the computation can still happen.  
This is the high‑level motivation for FHE.

---

## Slide 2 – 1.2 Evolution of Fully Homomorphic Encryption

Now I give a short history of FHE.  
In 2009, Gentry proposed the first FHE scheme using ideal lattices.  
It was a big theoretical breakthrough but very slow.

Between 2011 and 2014, second‑generation schemes such as BGV and BFV appeared.  
They introduced leveled FHE and more efficient bootstrapping, so the performance improved a lot.

In 2016, the CKKS scheme was introduced.  
CKKS supports approximate arithmetic on real and complex numbers,  
which is very useful for machine learning inference and numerical analytics.

Around the same time, TFHE appeared.  
TFHE focuses on fast Boolean gates with very efficient bootstrapping for each gate.  
It is good for comparisons, branching, and verification logic.

Today there are many practical libraries, like HElib, SEAL, Concrete, and OpenFHE.  
There is also a lot of work on GPUs and hardware acceleration.  
We will focus on CKKS and TFHE as two important representatives.

---

## Slide 3 – 2. Mathematical Foundations Overview

Now we go to the mathematical foundations of FHE.  
There are three key ingredients.

First, modular arithmetic and polynomial rings  
`Z_q` and `R_q` `[read: "Z sub q" and "R sub q"]`.  
These rings give us a place where we can do both addition and multiplication on ciphertexts.

Second, batched or SIMD encoding.  
Here one encrypted polynomial can carry many data slots in parallel.  
This is why homomorphic operations can be vectorized.

Third, the security assumptions: LWE and RLWE.  
They say that solving certain noisy linear equations is hard.  
Modern FHE schemes build on these problems and inherit their hardness.

In the next slides we look at each ingredient in more detail.

---

## Slide 4 – 2.1 Modular Arithmetic and Polynomial Rings

Before we go to the abstract symbols, let me start with a concrete example.  
Think about a clock with 12 hours.  
The numbers on the clock are `0, 1, …, 11`.  
If I add `9` and `5`, I get `14`,  
but on the clock this wraps around to `2`.  
We write this as `9 + 5 ≡ 2 (mod 12)`.  
This is modular arithmetic: we keep the result inside a fixed set by wrapping around.

Now we generalize this idea.  
Modern FHE does not work over plain integers.  
Instead, it uses rings that support both addition and multiplication.

The first example is the integer modular ring  
`Z_q` `[read: "Z sub q"]`.  	
It is the set of numbers `0, 1, …, q minus 1`,  
with addition and multiplication taken modulo `q`.  
Here `q` is usually a large prime or one modulus in an RNS chain.

The second example is the polynomial ring  
`R_q = Z_q[x] / (x^N + 1)`  
`[read: "R sub q equals Z sub q of x, modulo x to the N plus one"]`.  
Here `N` is usually a power of two.  
Elements in this ring are polynomials of degree less than `N`,  
with coefficients in `Z_q`.

When we multiply two polynomials, we convolve the coefficients,  
and then we reduce modulo `x^N + 1`.  
In practice that means we treat `x^N` as equal to `-1` when we reduce.  
These polynomial rings are the container for ciphertexts in many FHE schemes.

---

## Slide 5 – 2.2 Intuition for Batched (SIMD) Encoding

Next we look at the idea of batching, or SIMD encoding.  
The goal is to pack a whole vector of complex numbers into one polynomial.

Suppose we start from a complex vector  
`z = (z_1, z_2, …, z_{N/2})` in `C^{N/2}`  
`[read: "z one, …, z to the N over two in C to the N over two"]`.  

When `N` is a power of two, there is an approximate isomorphism  
`R_q tensor C is isomorphic to C^{N/2}`.  
You can think of this as saying: one polynomial in the ring corresponds to `N/2` complex slots.

To encode, we run an inverse discrete Fourier transform, or inverse DFT,  
from the vector `z` to a polynomial `m(x)`.  
Then we scale and round the coefficients to get an integer polynomial  
`m_tilde(x)` `[read: "m tilde of x"]`.  
After that, we reduce the coefficients modulo `q` so the polynomial lies in `Z_q[x]`.

The key idea is simple:  
one ciphertext holds many slots, so FHE operations act on whole vectors at once.

---

## Slide 6 – 2.3 LWE and RLWE

Now I introduce the LWE and RLWE assumptions.  
They provide the hardness foundations for FHE schemes.

The main idea is to hide the secret message by adding small random noise,  
while still keeping enough algebraic structure for computation.  
The hardness of LWE and RLWE is related to lattice problems like GapSVP,  
and these are believed to be hard even for quantum computers.

In LWE, we work with vectors and matrices over `Z_q`.  
Samples look like `(A, b)`, where  
`b = A * s + e (mod q)` `[read: "b equals A times s plus e, modulo q"]`.  
Here `A` is a random matrix, `s` is a secret vector, and `e` is small noise.

In RLWE, we move to polynomials.  
Samples look like `(a(x), b(x))`, where  
`b(x) = a(x) * s(x) + e(x) (mod q)`  
`[read: "b of x equals a of x times s of x plus e of x, modulo q"]`.  
Now everything lives in the polynomial ring `R_q`.

RLWE keeps the hardness of LWE, but it fits much better with polynomial‑based FHE schemes.  
Most ring‑based FHE constructions rely directly on RLWE.

---

## Slide 7 – 2.4 LWE: Key Generation, Encryption, Decryption

Here we see the full LWE workflow.  
I will walk through key generation, encryption, and decryption.

For key generation, we pick a secret vector `s` in  
`Z_q^n` `[read: "Z sub q to the n"]`.  
We also sample a noise vector `e` and a random public matrix `A` in `Z_q^{n x n}`.  
Then we compute  
`b = A * s + e (mod q)`.  
The pair `(A, b)` is the public key, and `s` is the secret key.

To encrypt a bit `m` in `{0, 1}`,  
we pick a small random vector `r`.  
Then we compute  
`c_0 = A^T * r` and  
`c_1 = b^T * r + Delta * m`  
`[read: "c zero equals A transpose r, c one equals b transpose r plus Delta times m"]`.  
Here the scaling factor is `Delta = q/2` `[read: "Delta equals q over two"]` for binary messages.  
The ciphertext is the pair `(c_0, c_1)`.

To decrypt, we use the secret key `s` and compute  
`c_1 - c_0^T * s`.  
This equals `e^T * r + Delta * m`,  
so the result is very close to either `0` or `Delta`.  
Finally we divide by `Delta` and round to get back `m`.

The key point is: the small noise hides the message but does not break decryption.

---

## Slide 8 – 2.5 RLWE: b(x) = a(x)s(x) + e(x) mod q

Now we lift LWE into the ring setting, which gives RLWE.  
Everything becomes a polynomial.

We work in the ring  
`R_q = Z_q[x] / (x^N + 1)`  
`[read: "R sub q equals Z sub q of x, modulo x to the N plus one"]`.  
The secret key is a polynomial `s(x)` with small coefficients.  
The noise `e(x)` is also a small polynomial.

For key generation, we sample a random polynomial `a(x)` in `R_q`,  
sample a noise polynomial `e(x)`,  
and then compute  
`b(x) = a(x) * s(x) + e(x) mod q`.  
We publish `(a(x), b(x))` and keep `s(x)` secret.

To encrypt a plaintext polynomial `m(x)` in `R_q`,  
we sample a small polynomial `r(x)`.  
For intuition, you can imagine `r(x) = 1`.  
Then we set  
`c_0(x) = a(x) * r(x)` and  
`c_1(x) = b(x) * r(x) + Delta * m(x)`.  
Here `Delta = q / t` if we embed `t` plaintext levels.  
The ciphertext is the pair `(c_0(x), c_1(x))`.

To decrypt, we compute  
`c_1(x) - c_0(x) * s(x)`.  
This cancels the `a(x) * s(x)` part and gives  
`Delta * m(x) + small noise`.  
We divide by `Delta` and round the coefficients to recover `m(x)`.

RLWE is the backbone for many modern FHE schemes.

---

## Slide 9 – 3. CKKS Overview

Now we move to CKKS, which is a practical FHE scheme for approximate real or complex numbers.  
It is widely used for machine learning inference and data analytics.

CKKS supports packed vectors, so one ciphertext can hold many real or complex values.  
It uses the batching idea we saw earlier.

The basic workflow is:  
first we scale the plaintext numbers by a large factor `Delta`.  
Then we encode the scaled integers into RLWE polynomials.  
Then we encrypt those polynomials.

Homomorphic addition in CKKS is very cheap, as long as the ciphertexts have the same scale.  
Homomorphic multiplication is more expensive.  
After multiplication we need two extra steps:  
relinearization to keep ciphertext size small,  
and rescaling to control the scale and the noise.

CKKS always introduces a small approximation error,  
but the error can be kept within a target bound.  
This makes CKKS very useful in many practical applications.

---

## Slide 10 – 3.1 CKKS Encoding and Scaling

On this slide we look at how to encode real vectors for CKKS.  
The goal is to move real numbers into the polynomial ring so we can encrypt them.

Let the real vector be `(z_1, z_2, …, z_k)`.  
We want to encode it into the ring  
`R_q = Z_q[x] / (x^N + 1)`  
`[read: "R sub q equals Z sub q of x, modulo x to the N plus one"]`.  

First, we scale the vector.  
We multiply each real value by a large `Delta`.  
The formula is `m_tilde = Delta * m`  
`[read: "m tilde equals Delta times m"]`.  
After this, the fractional parts become big integers, which are safe for modular arithmetic.

Second, we use the same SIMD encoding trick from before.  
We rely on the fact that `R_q tensor C` is roughly `C^{N/2}`.  
So we can pack the scaled vector into one polynomial with many slots.

During decryption, we decode the polynomial back into an integer vector,  
and then divide by `Delta` to get an approximation of the original real vector.  
The difference between the original and the recovered values is the CKKS approximation error.

---

## Slide 11 – 3.2 CKKS Encryption and Decryption

Here we connect CKKS to the RLWE encryption pattern.  
The structure is almost the same as RLWE,  
but we remember that the plaintext has been scaled by `Delta`.

Before encryption, we scale by `Delta` and encode the real vector into an integer polynomial `m(x)`.  
Then we run RLWE key generation.  
We choose a small secret polynomial `s(x)`,  
sample random `a(x)` and noise `e(x)`,  
and compute  
`b(x) = a(x) * s(x) + e(x) mod q`.  
This gives us the public and secret keys.

To encrypt, we sample a small polynomial `r(x)` and compute  
`c_0(x) = a(x) * r(x)` and  
`c_1(x) = b(x) * r(x) + Delta * m(x)`.  
The ciphertext is the pair `(c_0(x), c_1(x))`.

To decrypt, we compute  
`c_1(x) - c_0(x) * s(x)`.  
This gives `Delta * m(x) + small noise`.  
Then we divide by the stored `Delta` to recover an approximation of `m(x)`.  
After that we decode the vector from the polynomial back into real numbers.

One more detail:  
in CKKS, each ciphertext explicitly stores its current `Delta`.  
This scale changes after operations like multiplication and rescaling,  
so we need to track it carefully to keep precision.

---

## Slide 12 – 3.3 CKKS Rescaling and Scale Management

Now we explain rescaling, which controls the growth of the scale and the noise.  

Every CKKS ciphertext encodes a value as `m * Delta`.  
When we multiply two ciphertexts, the new scale becomes `Delta^2`.  
The formula on the slide is  
`(Delta * m_0) * (Delta * m_1) = Delta^2 * (m_0 * m_1)`  
`[read: "Delta times m zero times Delta times m one equals Delta squared times m zero times m one"]`.  
If we keep multiplying, the scale and noise will quickly become too large.

To fix this, CKKS uses a rescale operation.  
We think of the ciphertext as living over a modulus chain `Q = q_0 * q_1 * … * q_L`.  
We take the ciphertext `c` and divide it by the last modulus `q_L`,  
then round and drop that modulus from the chain.  
The slide writes this as  
`c' = Rescale(c) = floor(c / q_L) (mod Q / q_L)`  
`[read: "c prime equals Rescale of c equals floor of c over q sub L, modulo big Q over q sub L"]`.  

After rescaling, the new modulus is `Q' = Q / q_L`,  
and the new scale is `Delta' = Delta / q_L`.  
This brings the scale back into a reasonable range.  
Each rescale step consumes one level in the modulus chain,  
so we must plan how many multiplications we can afford in the circuit.

---

## Slide 13 – 3.4 CKKS Homomorphic Addition

Now we look at homomorphic addition in CKKS, which is very simple.  
Each ciphertext is a pair `(c_0, c_1)`.  
To add two ciphertexts we just add them component‑wise:

`(c_0, c_1) + (c_0', c_1') = (c_0 + c_0', c_1 + c_1')`  
`[read: "c zero, c one plus c zero prime, c one prime equals c zero plus c zero prime, and c one plus c one prime"]`.  

Because decryption uses `c_1 - c_0 * s`,  
the decrypted value of the sum is just the sum of the underlying scaled plaintexts.  
This works slot‑wise across the packed vector.

There is one condition:  
the two ciphertexts must have the same scale `Delta`.  
If their scales are different, we rescale one of them first so they match.  
Once the scales are aligned, addition does not change the scale and only adds a tiny bit of noise.

So addition is the cheapest and most stable operation in CKKS.  
It is almost “free” compared with multiplication.

---

## Slide 14 – 3.5 CKKS Homomorphic Multiplication and Relinearization

Now we look at homomorphic multiplication, which is more involved.  
The key issue is that the ciphertext grows in size and starts to depend on higher powers of the secret key.

Recall that a CKKS ciphertext decrypts as  
`c_1 - c_0 * s ≈ Delta * m`  
`[read: "c one minus c zero times s is approximately Delta times m"]`.  

If we multiply two ciphertexts, we multiply these decrypted forms.  
The slide shows the expansion:

`(c_1 - c_0 * s) * (c_1' - c_0' * s) = d_0 + d_1 * s + d_2 * s^2`.  
Here  
`d_0 = c_1 * c_1'`,  
`d_1 = -(c_1 * c_0' + c_0 * c_1')`, and  
`d_2 = c_0 * c_0'`.  
So the result depends on both `s` and `s^2`.

This means the new ciphertext has three components `(d_0, d_1, d_2)`  
and would require knowledge of `s^2` to decrypt.  
If we keep multiplying without fixing this, ciphertext size and key operations would grow a lot.

Relinearization solves this problem.  
We use a special evaluation key, which is an encryption of `s^2`,  
to fold the `d_2 * s^2` term back into the first two components.  
The slide shows this as  
`(c_0, c_1) x (c_0', c_1') -> (d_0, d_1, d_2) -> (e_0, e_1)`.  
After relinearization we again have a normal two‑component ciphertext `(e_0, e_1)`  
that decrypts with the original secret key `s`.

In practice, we do multiplication followed by relinearization,  
and then usually followed by rescaling to control the scale.

---

## Slide 15 – 4. TFHE Overview

Now we switch from CKKS to TFHE.  
TFHE works with encrypted bits instead of approximate real numbers.

In TFHE, each Boolean value `m` in `{0, 1}` is encrypted as an LWE‑style sample.  
The slide shows  
`c = (c_0, c_1) = (A, A * s + mu * m + e)`  
`[read: "c equals c zero, c one equals big A, and A times s plus mu times m plus e"]`.  
Here `mu` is a scaling factor, usually `q/2`,  
similar to `Delta` in LWE.

TFHE supports homomorphic logic gates like AND, XOR, and NOT.  
This makes it very good for comparisons, conditional branches, and verification tasks.  
It is the opposite of CKKS: CKKS is great for numeric workloads,  
but has trouble with exact branching and comparisons.  
TFHE is designed exactly for those bit‑level operations.

The most important feature of TFHE is fast bootstrapping.  
In TFHE, each gate call can include a bootstrapping step that refreshes the noise.  
This allows us to run circuits with many gate levels without losing correctness.

So TFHE gives us a bit‑level toolkit that complements the numeric power of CKKS.

---

## Slide 16 – 4.1 TFHE Gate Operations

Next we look at some basic gate operations in TFHE.  
We will see how NOT, XOR, and AND behave on encrypted bits.

Each ciphertext encrypts a bit `m` in `{0, 1}` as  
`c = (A, c_1)` with `c_1 = A * s + mu * m + e`.  
Again, `mu` is a scaling factor, and `e` is small noise.

For the NOT gate, the output should encrypt `1 - m`.  
Algebraically, `mu * (1 - m) = mu - mu * m`.  
The slide writes the NOT operation as  
`NOT(c) = (-A, mu - c_1) mod q`  
`[read: "N O T of c equals minus A, mu minus c one, modulo q"]`.  
This effectively flips the phase of the ciphertext.

For the XOR gate, homomorphic addition is enough.  
The slide writes  
`XOR(c_0, c_1) = c_0 + c_1 mod q`  
`[read: "X O R of c zero and c one equals c zero plus c one, modulo q"]`.  
This works because XOR is like addition modulo 2, and the structure is linear.

For AND, things are harder.  
Multiplying two ciphertexts scales the phase by `mu^2`.  
The slide shows  
`(m_0 * mu) * (m_1 * mu) = (m_0 * m_1) * mu^2`  
`[read: "m zero times mu times m one times mu equals m zero times m one times mu squared"]`.  
This increases the scale and noise, so TFHE uses bootstrapping after AND or NAND gates to refresh the ciphertext.

---

## Slide 17 – 4.2 TFHE Programmable Bootstrapping (PBS) – Concept

The last topic is programmable bootstrapping, or PBS, in TFHE.  
PBS is what keeps TFHE powerful at deep Boolean circuits.

Each TLWE ciphertext hides a phase value `phi` that is close to either `0` or `mu`.  
If `phi` is near `0`, it encodes bit `0`.  
If `phi` is near `mu`, it encodes bit `1`.

The goal of bootstrapping is to extract this phase homomorphically,  
apply some Boolean function `f` to it,  
and then re‑encrypt a fresh ciphertext with low noise.  
All of this must happen without decrypting in the clear.

Conceptually, PBS does three things under encryption:  
decode the phase, evaluate the function, and re‑encrypt the result.  
Because the function is programmable,  
we can implement many different gates and even small lookup tables with PBS.

---

## Slide 18 – 4.2 TFHE Programmable Bootstrapping (PBS) – Phase Reconstruction

Now we zoom in on the first technical step: phase reconstruction.  
We want to recover the phase `phi` in encrypted form.

The phase is `phi = c_1 - A * s`.  
`[read: "phi equals c one minus A times s"]`.  
However, we cannot compute this directly, because it would reveal the secret key `s`.

Instead, we aim for an encryption of `phi`, written as `Enc(phi)`.  
The slide shows  
`Enc(phi) = Enc(c_1 - A * s)`.  
So we need an encryption of `A * s`.

Note that `A * s` can be written as a sum  
`sum_{i=1}^n a_i * s_i`.  
If we publish encryptions of each secret coefficient `s_i`,  
we can compute  
`sum_{i=1}^n a_i * Enc_GLWE(s_i) = Enc(A * s)`  
`[read: "sum from i equals one to n of a i times Enc G L W E of s i equals Enc of A times s"]`.  

These encryptions of the secret coefficients form the bootstrapping key, or `BK`.  
With `BK`, PBS can reconstruct the phase in encrypted form,  
without ever exposing the secret key.

---

## Slide 19 – 4.2 TFHE Programmable Bootstrapping (PBS) – Gadget Decomposition and LUT

Finally, we see how PBS applies the function `f` and finishes the refresh.  
We start from an encrypted phase `Enc(phi)` and want an encryption of `f(b)`,  
where `b` is the underlying bit.

First, we use gadget decomposition.  
This is a standard trick in lattice cryptography.  
We decompose the ciphertext into a tuple of weights  
`(w_0, w_1, …, w_k)`.  
The slide writes  
`GadgetDecomp(c = Enc(phi)) = (w_0, w_1, …, w_k)`.  
These weights act as encrypted selection signals.

Second, we prepare a look‑up table, or LUT, for the function `f`.  
For a single bit, the LUT is  
`LUT_f = (Enc(f(0)), Enc(f(1)))`.  
We can generalize this idea to more inputs if needed.

Third, we compute an external product between the weights and the LUT.  
The slide writes this as  
`Enc(f(b)) = LUT_f ⋆ (w_0, …, w_k) = sum_{i=0}^k w_i * LUT_f^{(i)}`.  
I read this roughly as: “Enc of f of b equals LUT sub f star of the tuple w zero to w k equals the sum over i of w i times LUT sub f to the i.”  
Each `w_i` selects part of the encrypted function value.

The result is a fresh ciphertext that encrypts `f(b)` with low noise.  
Because we can precompute `LUT_f` for many functions,  
PBS is called programmable bootstrapping.
