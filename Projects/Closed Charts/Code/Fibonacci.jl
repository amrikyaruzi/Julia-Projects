function fibonacci(n, memo)
    if n == 0
        return BigInt(0)
    elseif n == 1
        return BigInt(0)  # Fibonacci number 0
    elseif n == 2
        return BigInt(1)
    end

    if memo[n] == 0
        memo[n] = fibonacci(n - 1, memo) + fibonacci(n - 2, memo)
    end

    return memo[n]
end

function fibonacci_worker(start, stop, result, memo)
    for i in start:stop
        result[i+1] = fibonacci(i, memo)  # Adjust index for Fibonacci number 0
    end
end

function main()
    n = 500  # The Fibonacci number to calculate
    num_threads = 5  # Number of threads to use

    # Initialize memoization vector with length n+1
    memo = zeros(BigInt, n+1)

    # Create a vector to hold the results with length n+1, starting from index 0
    result = zeros(BigInt, n+1)

    # Divide the work among threads dynamically using Threads.@threads
    Threads.@threads for i in 1:num_threads
        chunk_size = div(n, num_threads)
        start = (i - 1) * chunk_size + 1
        stop = i == num_threads ? n : i * chunk_size  # Ensure last thread processes the remaining numbers
        fibonacci_worker(start, stop, result, memo)
    end

    # Print the Fibonacci sequence
    println("Fibonacci sequence: ", result)
end

main()
