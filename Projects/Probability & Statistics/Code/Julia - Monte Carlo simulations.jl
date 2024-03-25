using Distributions
using Distributed
using Random
using StatsBase
using Base.Threads
using BenchmarkTools


## Group 1 - Using Random Normal Distribution
## 1. Basic
function max_length_of_runs()
    flips = rand(["H", "T"], 100)
    lengths_rle = StatsBase.rle(flips)
    return maximum(lengths_rle[2])
end

num_simulations = 1_000_000
max_lengths = [max_length_of_runs() for _ in 1:num_simulations]
mean_length = mean(max_lengths)
println(mean_length)

"""
## 2. Using multithreading
function max_length_of_runs()
    flips = rand(["H", "T"], 100)
    lengths_rle = StatsBase.rle(flips)
    return maximum(lengths_rle[2])
end

num_simulations = 1_000_000


# Run simulations in parallel using multithreading
max_lengths = Vector{Int}(undef, num_simulations)
@threads for i in 1:num_simulations
    max_lengths[i] = max_length_of_runs()
end

mean_length = mean(max_lengths)
println(mean_length)

"""

"""
## Group 2 - Using Binomial Distribution
## 1. Basic
function max_length_of_runs()
    flips = rand(Distributions.Binomial(1, 0.5), 100)
    lengths_rle = StatsBase.rle(flips)
    return maximum(lengths_rle[2])
end

num_simulations = 10_000_000
max_lengths = [max_length_of_runs() for _ in 1:num_simulations]
mean_length = mean(max_lengths)
println(mean_length)

"""

"""
## 2. Using multithreading
function max_length_of_runs()
    flips = rand(Distributions.Binomial(1, 0.5), 100)
    lengths_rle = StatsBase.rle(flips)
    return maximum(lengths_rle[2])
end

num_simulations = 10_000_000

# Run simulations in parallel using multithreading
max_lengths = Vector{Int}(undef, num_simulations)
@threads for i in 1:num_simulations # Threads.@threads for i in 1:num_simulations
    max_lengths[i] = max_length_of_runs()
end

mean_length = mean(max_lengths)
println(mean_length)
"""