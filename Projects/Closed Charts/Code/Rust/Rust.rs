/*
use std::sync::{Arc, Mutex};
use std::thread;

fn fibonacci(n: u128, memo: &mut Vec<u128>) -> u128 {
    if n <= 1 {
        return n;
    }

    if memo[n as usize] != 0 {
        return memo[n as usize];
    }

    let fib_value = fibonacci(n - 1, memo) + fibonacci(n - 2, memo);
    memo[n as usize] = fib_value;
    fib_value
}

fn fibonacci_worker(start: u128, end: u128, result: Arc<Mutex<Vec<u128>>>, memo: Arc<Mutex<Vec<u128>>>) {
    let mut result = result.lock().unwrap();
    for i in start..=end {
        result[i as usize] = fibonacci(i, &mut memo.lock().unwrap());
    }
}

fn main() {
    let n = 400; // The Fibonacci number to calculate
    let num_threads = 5; // Number of threads to use

    // Initialize memoization vector
    let memo = vec![0; (n + 1) as usize];

    // Create a shared mutable vector to hold the results
    let result = Arc::new(Mutex::new(vec![0; (n + 1) as usize]));

    // Create a shared mutable vector for memoization
    let memo_arc = Arc::new(Mutex::new(memo));

    // Create a vector to hold the thread handles
    let mut handles = vec![];

    // Divide the work among threads
    for i in 0..num_threads {
        let result_clone = Arc::clone(&result);
        let memo_clone = Arc::clone(&memo_arc);
        let start = (i * n) / num_threads;
        let end = ((i + 1) * n) / num_threads;

        let handle = thread::spawn(move || {
            fibonacci_worker(start, end, result_clone, memo_clone);
        });

        handles.push(handle);
    }

    // Wait for all threads to finish
    for handle in handles {
        handle.join().unwrap();
    }

    // Print the Fibonacci sequence
    let result = result.lock().unwrap();
    println!("Fibonacci sequence: {:?}", &result[1..]);
}
*/

use num_bigint::BigUint;
use num_traits::{Zero}; // Bring Zero trait into scope
use std::sync::{Arc, Mutex};
use std::thread;

fn fibonacci(n: u128, memo: &mut Vec<BigUint>) -> BigUint {
    if n <= 1 {
        return BigUint::from(n);
    }

    if memo[n as usize].is_zero() {
        memo[n as usize] = fibonacci(n - 1, memo) + fibonacci(n - 2, memo);
    }

    memo[n as usize].clone()
}

fn fibonacci_worker(start: u128, end: u128, result: Arc<Mutex<Vec<BigUint>>>, memo: Arc<Mutex<Vec<BigUint>>>) {
    let mut result = result.lock().unwrap();
    let memo = memo.lock().unwrap(); // Lock once here
    for i in start..=end {
        result[i as usize] = fibonacci(i, &mut memo.to_vec()); // Pass mutable reference
    }
}

fn main() {
    let n = 1000; // The Fibonacci number to calculate
    let num_threads = 5; // Number of threads to use

    // Initialize memoization vector
    let memo = vec![BigUint::zero(); (n + 1) as usize];

    // Create a shared mutable vector to hold the results
    let result = Arc::new(Mutex::new(vec![BigUint::zero(); (n + 1) as usize]));

    // Create a shared mutable vector for memoization
    let memo_arc = Arc::new(Mutex::new(memo));

    // Create a vector to hold the thread handles
    let mut handles = vec![];

    // Divide the work among threads
    for i in 0..num_threads {
        let result_clone = Arc::clone(&result);
        let memo_clone = Arc::clone(&memo_arc);
        let start = (i * n) / num_threads;
        let end = ((i + 1) * n) / num_threads;

        let handle = thread::spawn(move || {
            fibonacci_worker(start, end, result_clone, memo_clone);
        });

        handles.push(handle);
    }

    // Wait for all threads to finish
    for handle in handles {
        handle.join().unwrap();
    }

    // Print the Fibonacci sequence
    let result = result.lock().unwrap();
    println!("Fibonacci sequence: {:?}", &result[1..]);
}
